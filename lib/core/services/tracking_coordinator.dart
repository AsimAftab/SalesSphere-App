import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/services/location_tracking_service.dart';
import 'package:sales_sphere/core/services/tracking_socket_service.dart';
import 'package:sales_sphere/core/services/offline_queue_service.dart';
import 'package:sales_sphere/core/services/background_tracking_service.dart';
import 'package:sales_sphere/core/services/notification_permission_service.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/beat_plan/models/active_tracking_session.models.dart';

/// Tracking Coordinator
/// Master service that orchestrates all tracking components:
/// - Location tracking (GPS)
/// - Socket communication (real-time updates)
/// - Offline queue (when disconnected)
/// - Background service (keep alive)
class TrackingCoordinator {
  TrackingCoordinator._();
  static final TrackingCoordinator instance = TrackingCoordinator._();

  // Service instances
  final LocationTrackingService _locationService = LocationTrackingService.instance;
  final TrackingSocketService _socketService = TrackingSocketService.instance;
  final OfflineQueueService _queueService = OfflineQueueService.instance;
  final BackgroundTrackingService _backgroundService = BackgroundTrackingService.instance;

  // Subscriptions
  StreamSubscription<LocationUpdate>? _locationSubscription;
  StreamSubscription<Map<String, dynamic>?>? _backgroundServiceSubscription;
  StreamSubscription<TrackingStoppedEvent>? _trackingStoppedSubscription;
  StreamSubscription<TrackingForceStoppedEvent>? _trackingForceStoppedSubscription;
  StreamSubscription<String>? _socketErrorSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Tracking state
  bool _isTracking = false;
  TrackingState _currentState = TrackingState.idle;
  String? _currentBeatPlanId;
  String? _currentSessionId; // Session ID for reconnection
  DateTime? _trackingStartTime;
  int _totalDirectories = 0;
  int _visitedDirectories = 0;

  // Dio client for API calls
  Dio? _dio;

  // Sync state
  Timer? _syncTimer;
  bool _isOnline = true;
  static const Duration _syncInterval = Duration(minutes: 1);

  // Stream controllers
  final StreamController<TrackingState> _stateController =
      StreamController<TrackingState>.broadcast();
  final StreamController<TrackingStats> _statsController =
      StreamController<TrackingStats>.broadcast();

  /// Get tracking state stream
  Stream<TrackingState> get onStateChanged => _stateController.stream;

  /// Get tracking stats stream
  Stream<TrackingStats> get onStatsChanged => _statsController.stream;

  /// Check if tracking is active
  bool get isTracking => _isTracking;

  /// Get current tracking state
  TrackingState get currentState => _currentState;

  /// Get current beat plan ID
  String? get currentBeatPlanId => _currentBeatPlanId;

  /// Initialize coordinator
  /// Accepts an optional Dio client for API calls (should be provided from ProviderScope)
  Future<void> initialize({Dio? dioClient}) async {
    try {
      AppLogger.i('🔧 Initializing TrackingCoordinator...');

      // Store Dio client if provided
      if (dioClient != null) {
        _dio = dioClient;
        AppLogger.d('✅ Dio client provided to TrackingCoordinator');
      } else {
        AppLogger.w('⚠️ No Dio client provided, API calls will fail');
      }

      // Initialize all services
      await _queueService.initialize();
      await _backgroundService.initialize();

      // Listen to connectivity changes
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_handleConnectivityChange);

      // Check initial connectivity
      final connectivity = await Connectivity().checkConnectivity();
      _isOnline = connectivity.first != ConnectivityResult.none;

      AppLogger.i('✅ TrackingCoordinator initialized (Online: $_isOnline)');

      // Check if tracking was already active (app restarted while tracking)
      await _checkAndResumeTracking();
    } catch (e, stack) {
      AppLogger.e('❌ Error initializing TrackingCoordinator: $e');
      AppLogger.e('Stack trace: $stack');
      rethrow;
    }
  }

  /// Get Dio client instance
  Dio _getDioClient() {
    if (_dio == null) {
      throw Exception('Dio client not initialized. Call initialize() with a Dio instance first.');
    }
    return _dio!;
  }

  /// Fetch active tracking sessions from API
  Future<ActiveTrackingSession?> _fetchActiveTrackingSession() async {
    try {
      AppLogger.i('🔍 Checking for active tracking sessions on server...');

      final dio = _getDioClient();
      final response = await dio.get(ApiEndpoints.activeTrackingSessions).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          AppLogger.w('⚠️ Active sessions API timeout');
          throw TimeoutException('API timeout');
        },
      );

      if (response.statusCode == 200) {
        final sessionResponse = ActiveTrackingSessionResponse.fromJson(response.data);

        if (sessionResponse.data.isNotEmpty) {
          final session = sessionResponse.data.first; // Get first active session
          AppLogger.i('✅ Found active tracking session:');
          AppLogger.i('   • Session ID: ${session.sessionId}');
          AppLogger.i('   • Beat Plan: ${session.beatPlan.name} (${session.beatPlan.id})');
          AppLogger.i('   • Status: ${session.beatPlan.status}');
          return session;
        } else {
          AppLogger.d('No active tracking sessions found on server');
          return null;
        }
      } else {
        AppLogger.w('⚠️ Active sessions API returned status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      AppLogger.w('⚠️ Could not fetch active tracking sessions: $e');
      return null;
    }
  }

  /// Check if tracking is active and resume if needed
  /// This handles the case where app is closed and reopened while tracking
  Future<void> _checkAndResumeTracking() async {
    try {
      // First, try to fetch active tracking session from server
      final activeSession = await _fetchActiveTrackingSession();

      if (activeSession != null) {
        AppLogger.i('🔄 Detected active tracking session on server, resuming...');

        final beatPlanId = activeSession.beatPlan.id;
        final sessionId = activeSession.sessionId;

        AppLogger.i('📍 Resuming tracking for beat plan: ${activeSession.beatPlan.name}');
        AppLogger.i('🔑 Session ID: $sessionId');

        // Get progress from server response
        // The active session endpoint might not include progress, so we need to check
        var totalDirectories = activeSession.beatPlan.progress.totalDirectories;
        var visitedDirectories = activeSession.beatPlan.progress.visitedDirectories;

        AppLogger.i('📊 Active session progress: $visitedDirectories/$totalDirectories directories');

        // If the active session endpoint doesn't return progress data, fetch from details endpoint
        if (totalDirectories <= 0) {
          AppLogger.w('⚠️ Active session endpoint returned no progress, fetching from details endpoint...');
          try {
            final dio = _getDioClient();
            final detailsResponse = await dio.get('/api/v1/beat-plans/$beatPlanId').timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                AppLogger.w('⚠️ Beat plan details API timeout');
                throw TimeoutException('API timeout');
              },
            );

            if (detailsResponse.statusCode == 200 && detailsResponse.data['success'] == true) {
              final data = detailsResponse.data['data'];
              final progress = data['progress'] as Map<String, dynamic>?;
              if (progress != null) {
                totalDirectories = progress['totalDirectories'] ?? 0;
                visitedDirectories = progress['visitedDirectories'] ?? 0;
                AppLogger.i('📊 Details endpoint progress: $visitedDirectories/$totalDirectories directories');
              }
            }
          } catch (e) {
            AppLogger.w('⚠️ Could not fetch progress from details endpoint: $e');
            // Fall back to SharedPreferences if available
            final prefs = await SharedPreferences.getInstance();
            totalDirectories = prefs.getInt('totalDirectories') ?? 0;
            visitedDirectories = prefs.getInt('visitedDirectories') ?? 0;
            AppLogger.i('📊 Fallback to SharedPreferences: $visitedDirectories/$totalDirectories directories');
          }
        }

        // Validate the progress data
        if (totalDirectories <= 0) {
          AppLogger.w('⚠️ Could not get valid totalDirectories: $totalDirectories');
          // Use 1 as minimum to prevent auto-stop
          totalDirectories = 1;
        }

        if (visitedDirectories < 0) {
          AppLogger.w('⚠️ Invalid visitedDirectories: $visitedDirectories');
          visitedDirectories = 0;
        }

        if (visitedDirectories > totalDirectories && totalDirectories > 0) {
          AppLogger.e('❌ Invalid progress: visited($visitedDirectories) > total($totalDirectories)');
          // Reset visited to avoid auto-stop
          visitedDirectories = 0;
        }

        // Set tracking state
        _currentBeatPlanId = beatPlanId;
        _currentSessionId = sessionId;
        _isTracking = true;
        _trackingStartTime = DateTime.now(); // Approximation
        _totalDirectories = totalDirectories;
        _visitedDirectories = visitedDirectories;

        // Get SharedPreferences instance
        final prefs = await SharedPreferences.getInstance();

        // Save session info to SharedPreferences with fresh values from server
        await prefs.setString('beatPlanId', beatPlanId);
        await prefs.setString('sessionId', sessionId);
        await prefs.setBool('isTracking', true);
        await prefs.setInt('totalDirectories', totalDirectories);
        await prefs.setInt('visitedDirectories', visitedDirectories);

        AppLogger.i('📊 Final resumed progress: $visitedDirectories/$totalDirectories directories');

        // Reconnect to socket with session ID
        try {
          final connected = await _socketService.connect().timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              AppLogger.w('⚠️ Socket reconnection timeout');
              return false;
            },
          );

          if (connected) {
            AppLogger.i('✅ Socket reconnected');
            await _socketService.startTracking(beatPlanId, sessionId: sessionId);
          } else {
            AppLogger.w('⚠️ Socket reconnection failed, will queue offline');
          }
        } catch (e) {
          AppLogger.e('❌ Socket reconnection error: $e');
        }

        // Start location tracking in foreground
        try {
          await _locationService.startTracking(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10.0,
            enableBackgroundUpdates: true,
          );

          // Subscribe to location updates
          _locationSubscription = _locationService.locationStream.listen(
            _handleLocationUpdate,
            onError: (error) {
              AppLogger.e('❌ Location stream error: $error');
            },
          );
        } catch (e) {
          AppLogger.w('⚠️ Could not start foreground location: $e');
        }

        // Subscribe to background service updates
        _backgroundServiceSubscription = _backgroundService.onServiceUpdate.listen(
          _handleBackgroundServiceUpdate,
          onError: (error) {
            AppLogger.e('❌ Background service stream error: $error');
          },
        );

        // Subscribe to tracking stopped event
        _trackingStoppedSubscription = _socketService.onTrackingStopped.listen(
          _handleTrackingStopped,
        );

        // Subscribe to tracking force-stopped event (when server stops tracking)
        _trackingForceStoppedSubscription = _socketService.onTrackingForceStopped.listen(
          _handleTrackingForceStopped,
        );

        // Subscribe to socket errors
        _socketErrorSubscription = _socketService.onError.listen(
          _handleSocketError,
        );

        // Start periodic sync timer
        _startSyncTimer();

        // Update state
        _emitState(TrackingState.active);

        // Emit stats immediately so UI updates
        _emitStats();

        AppLogger.i('✅ Tracking session resumed successfully from server');
      } else {
          // No active session on server, check local state as fallback
          AppLogger.d('No active session on server, checking local state...');

          final prefs = await SharedPreferences.getInstance();
          final beatPlanId = prefs.getString('beatPlanId');
          final sessionId = prefs.getString('sessionId');
          final isTrackingFlag = prefs.getBool('isTracking') ?? false;

          // Check if background service is also running
          final isBackgroundServiceRunning = await _backgroundService.isRunning();

          if (beatPlanId != null && isTrackingFlag && isBackgroundServiceRunning) {
            AppLogger.i('🔄 Found local tracking state, attempting to resume...');
            AppLogger.i('📍 Beat plan ID: $beatPlanId');
            if (sessionId != null) {
              AppLogger.i('🔑 Session ID: $sessionId');
            }

            // Load progress info from SharedPreferences
            var totalDirectories = prefs.getInt('totalDirectories') ?? 0;
            var visitedDirectories = prefs.getInt('visitedDirectories') ?? 0;

            // Validate the progress data from SharedPreferences
            if (totalDirectories <= 0) {
              AppLogger.w('⚠️ SharedPreferences has invalid totalDirectories: $totalDirectories');
            }

            if (visitedDirectories < 0) {
              AppLogger.w('⚠️ SharedPreferences has invalid visitedDirectories: $visitedDirectories');
              visitedDirectories = 0;
            }

            if (visitedDirectories > totalDirectories && totalDirectories > 0) {
              AppLogger.e('❌ Invalid progress in SharedPreferences: visited($visitedDirectories) > total($totalDirectories)');
              // Reset visited to avoid auto-stop with stale data
              AppLogger.w('⚠️ Resetting visitedDirectories to 0 due to stale data');
              visitedDirectories = 0;
              await prefs.setInt('visitedDirectories', 0);
            }

            // Set tracking state
            _currentBeatPlanId = beatPlanId;
            _currentSessionId = sessionId;
            _isTracking = true;
            _trackingStartTime = DateTime.now();
            _totalDirectories = totalDirectories;
            _visitedDirectories = visitedDirectories;

            AppLogger.i('📊 Resumed progress: $visitedDirectories/$totalDirectories directories');

            // Try to reconnect to socket
            try {
              final connected = await _socketService.connect().timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  AppLogger.w('⚠️ Socket reconnection timeout');
                  return false;
                },
              );

              if (connected) {
                AppLogger.i('✅ Socket reconnected');
                await _socketService.startTracking(beatPlanId, sessionId: sessionId);
              } else {
                AppLogger.w('⚠️ Socket reconnection failed, will queue offline');
              }
            } catch (e) {
              AppLogger.e('❌ Socket reconnection error: $e');
            }

            // Start location tracking
            try {
              await _locationService.startTracking(
                accuracy: LocationAccuracy.high,
                distanceFilter: 10.0,
                enableBackgroundUpdates: true,
              );

              _locationSubscription = _locationService.locationStream.listen(
                _handleLocationUpdate,
                onError: (error) {
                  AppLogger.e('❌ Location stream error: $error');
                },
              );
            } catch (e) {
              AppLogger.w('⚠️ Could not start foreground location: $e');
            }

            // Subscribe to services
            _backgroundServiceSubscription = _backgroundService.onServiceUpdate.listen(
              _handleBackgroundServiceUpdate,
              onError: (error) {
                AppLogger.e('❌ Background service stream error: $error');
              },
            );

            _trackingStoppedSubscription = _socketService.onTrackingStopped.listen(
              _handleTrackingStopped,
            );

            _socketErrorSubscription = _socketService.onError.listen(
              _handleSocketError,
            );

            // Start sync timer
            _startSyncTimer();

            // Update state
            _emitState(TrackingState.active);
            _emitStats();

            AppLogger.i('✅ Tracking session resumed from local state');
          } else {
            AppLogger.d('No active tracking session detected (local or server)');
          }
        }
    } catch (e, stack) {
      AppLogger.e('❌ Error checking/resuming tracking: $e');
      AppLogger.e('Stack trace: $stack');
    }
  }

  /// Start tracking a beat plan
  Future<void> startTracking(
    String beatPlanId, {
    int totalDirectories = 0,
    int visitedDirectories = 0,
  }) async {
    if (_isTracking) {
      AppLogger.w('⚠️ Tracking already active');
      return;
    }

    try {
      AppLogger.i('🎯 Starting tracking for beat plan: $beatPlanId');
      AppLogger.i('📊 Progress: $visitedDirectories/$totalDirectories directories');

      // Check notification permission (required for background service on Android 13+)
      final notificationPermission = NotificationPermissionService.instance;
      final hasPermission = await notificationPermission.isGranted();

      if (!hasPermission) {
        AppLogger.w('⚠️ Notification permission not granted, requesting...');
        final granted = await notificationPermission.requestPermission();

        if (!granted) {
          AppLogger.e('❌ Notification permission denied - tracking notifications will not work');
          // Continue anyway - tracking will still work, just no notifications
        }
      }

      _currentBeatPlanId = beatPlanId;
      _trackingStartTime = DateTime.now();
      _isTracking = true;
      _totalDirectories = totalDirectories;
      _visitedDirectories = visitedDirectories;

      // Save progress to SharedPreferences for recovery after app restart
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('totalDirectories', totalDirectories);
      await prefs.setInt('visitedDirectories', visitedDirectories);

      // Update state
      _emitState(TrackingState.starting);

      // Try to connect to tracking server (optional - works offline too)
      bool connected = false;
      try {
        connected = await _socketService.connect().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            AppLogger.w('⚠️ Socket connection timeout, continuing in offline mode');
            return false;
          },
        );

        if (connected) {
          AppLogger.i('✅ Socket connected, real-time streaming enabled');
          await _socketService.startTracking(beatPlanId);
        } else {
          AppLogger.w('⚠️ Socket connection failed, will queue locations offline');
        }
      } catch (e) {
        AppLogger.e('❌ Socket connection error: $e');
        AppLogger.i('📥 Continuing in offline mode - locations will be queued');
        connected = false;
      }

      // Start location tracking
      await _locationService.startTracking(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10.0,
        enableBackgroundUpdates: true,
      );

      // Start background service with progress info
      await _backgroundService.startTracking(
        beatPlanId,
        totalDirectories: totalDirectories,
        visitedDirectories: visitedDirectories,
      );

      // Subscribe to location updates from foreground service
      _locationSubscription = _locationService.locationStream.listen(
        _handleLocationUpdate,
        onError: (error) {
          AppLogger.e('❌ Location stream error: $error');
          _emitState(TrackingState.error);
        },
      );

      // Subscribe to location updates from background service
      // This is the PRIMARY source of location data when app is backgrounded
      _backgroundServiceSubscription = _backgroundService.onServiceUpdate.listen(
        _handleBackgroundServiceUpdate,
        onError: (error) {
          AppLogger.e('❌ Background service stream error: $error');
        },
      );

      // Subscribe to tracking stopped event
      _trackingStoppedSubscription = _socketService.onTrackingStopped.listen(
        _handleTrackingStopped,
      );

      // Subscribe to socket errors
      _socketErrorSubscription = _socketService.onError.listen(
        _handleSocketError,
      );

      // Start periodic sync timer
      _startSyncTimer();

      // Update state
      _emitState(TrackingState.active);

      AppLogger.i('✅ Tracking started successfully');
    } catch (e, stack) {
      AppLogger.e('❌ Error starting tracking: $e');
      AppLogger.e('Stack trace: $stack');
      _isTracking = false;
      _currentBeatPlanId = null;
      _emitState(TrackingState.error);
      rethrow;
    }
  }

  /// Stop tracking
  Future<void> stopTracking() async {
    if (!_isTracking) {
      AppLogger.w('⚠️ Tracking not active');
      return;
    }

    try {
      AppLogger.i('🛑 Stopping tracking...');

      _emitState(TrackingState.stopping);

      // Stop location tracking
      await _locationService.stopTracking();

      // Stop background service
      await _backgroundService.stopTracking();

      // Send stop command to server (if connected)
      if (_socketService.isConnected && _currentBeatPlanId != null) {
        await _socketService.stopTracking(_currentBeatPlanId!);
      }

      // Sync any remaining queued locations
      if (_socketService.isConnected) {
        await _queueService.syncQueue(socketService: _socketService);
        await _queueService.clearSynced();
      }

      // Disconnect from server
      await _socketService.disconnect();

      // Cancel subscriptions
      await _locationSubscription?.cancel();
      await _backgroundServiceSubscription?.cancel();
      await _trackingStoppedSubscription?.cancel();
      await _trackingForceStoppedSubscription?.cancel();
      await _socketErrorSubscription?.cancel();
      _syncTimer?.cancel();

      // Reset state
      _isTracking = false;
      _currentBeatPlanId = null;
      _trackingStartTime = null;
      _totalDirectories = 0;
      _visitedDirectories = 0;

      // Clear all tracking data from SharedPreferences to prevent stale data on resume
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('totalDirectories');
      await prefs.remove('visitedDirectories');
      await prefs.remove('beatPlanId');
      await prefs.remove('sessionId');
      await prefs.remove('isTracking');

      _emitState(TrackingState.stopped);

      AppLogger.i('✅ Tracking stopped successfully');
    } catch (e, stack) {
      AppLogger.e('❌ Error stopping tracking: $e');
      AppLogger.e('Stack trace: $stack');
      _emitState(TrackingState.error);
    }
  }

  /// Pause tracking
  Future<void> pauseTracking() async {
    if (!_isTracking) {
      AppLogger.w('⚠️ Tracking not active');
      return;
    }

    try {
      AppLogger.i('⏸️ Pausing tracking...');

      // Pause location tracking
      await _locationService.pauseTracking();

      // Pause background service
      await _backgroundService.pauseTracking();

      // Send pause command to server (if connected)
      if (_socketService.isConnected && _currentBeatPlanId != null) {
        await _socketService.pauseTracking(_currentBeatPlanId!);
      }

      _emitState(TrackingState.paused);

      AppLogger.i('✅ Tracking paused');
    } catch (e, stack) {
      AppLogger.e('❌ Error pausing tracking: $e');
      AppLogger.e('Stack trace: $stack');
    }
  }

  /// Resume tracking
  Future<void> resumeTracking() async {
    if (!_isTracking) {
      AppLogger.w('⚠️ Tracking not active');
      return;
    }

    try {
      AppLogger.i('▶️ Resuming tracking...');

      // Resume location tracking
      await _locationService.resumeTracking(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10.0,
        enableBackgroundUpdates: true,
      );

      // Resume background service
      await _backgroundService.resumeTracking();

      // Send resume command to server (if connected)
      if (_socketService.isConnected && _currentBeatPlanId != null) {
        await _socketService.resumeTracking(_currentBeatPlanId!);
      }

      _emitState(TrackingState.active);

      AppLogger.i('✅ Tracking resumed');
    } catch (e, stack) {
      AppLogger.e('❌ Error resuming tracking: $e');
      AppLogger.e('Stack trace: $stack');
    }
  }

  /// Update visit progress (call when user marks a directory as visited)
  /// This updates the notification to show real-time progress
  /// and automatically stops tracking when all directories are visited
  Future<void> updateVisitProgress(int visitedDirectories) async {
    if (!_isTracking) {
      AppLogger.w('⚠️ Tracking not active');
      return;
    }

    try {
      AppLogger.i('📊 Updating visit progress: $visitedDirectories/$_totalDirectories');

      // Validate input
      if (visitedDirectories < 0) {
        AppLogger.e('❌ Invalid visitedDirectories: $visitedDirectories (negative)');
        return;
      }

      // Check for stale data that would cause premature auto-stop
      if (visitedDirectories > _totalDirectories && _totalDirectories > 0) {
        AppLogger.e('❌ Invalid progress: visited($visitedDirectories) > total($_totalDirectories)');
        AppLogger.w('⚠️ Skipping auto-stop check due to invalid data');
        // Still update the value and emit stats, but don't auto-stop
        _visitedDirectories = visitedDirectories;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('visitedDirectories', visitedDirectories);
        await _backgroundService.updateProgress(visitedDirectories);
        _emitStats();
        return;
      }

      // Update visited count
      _visitedDirectories = visitedDirectories;

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('visitedDirectories', visitedDirectories);

      // Update background service notification
      await _backgroundService.updateProgress(visitedDirectories);

      // Emit stats update
      _emitStats();

      AppLogger.i('✅ Progress updated successfully');

      // Auto-stop when all directories are visited
      if (_totalDirectories > 0 && _visitedDirectories >= _totalDirectories) {
        AppLogger.i('🎉 All directories visited! Auto-stopping tracking...');
        await Future.delayed(const Duration(seconds: 2)); // Brief delay for notification
        await stopTracking();
      }
    } catch (e, stack) {
      AppLogger.e('❌ Error updating progress: $e');
      AppLogger.e('Stack trace: $stack');
    }
  }

  /// Handle location update from foreground service
  void _handleLocationUpdate(LocationUpdate update) async {
    if (!_isTracking || _currentBeatPlanId == null) return;

    try {
      AppLogger.d('📍 Foreground location update: ${update.latitude}, ${update.longitude}');

      // Send to server if connected
      if (_socketService.isConnected) {
        _socketService.updateLocation(
          beatPlanId: _currentBeatPlanId!,
          latitude: update.latitude,
          longitude: update.longitude,
          accuracy: update.accuracy,
          speed: update.speed,
          heading: update.heading,
        );
      } else {
        // Queue for later sync
        AppLogger.d('📥 Queueing location (offline)');
        await _queueService.queueLocation(
          beatPlanId: _currentBeatPlanId!,
          latitude: update.latitude,
          longitude: update.longitude,
          accuracy: update.accuracy,
          speed: update.speed,
          heading: update.heading,
        );
      }

      // Emit stats update
      _emitStats();
    } catch (e) {
      AppLogger.e('❌ Error handling location update: $e');
    }
  }

  /// Handle location update from background service
  /// This is the PRIMARY source when app is in background
  void _handleBackgroundServiceUpdate(Map<String, dynamic>? data) async {
    if (data == null || !_isTracking || _currentBeatPlanId == null) return;

    try {
      // Use 'num' to accept both int and double, then convert to double
      final latitude = (data['latitude'] as num?)?.toDouble();
      final longitude = (data['longitude'] as num?)?.toDouble();
      final accuracy = (data['accuracy'] as num?)?.toDouble();
      final speed = (data['speed'] as num?)?.toDouble();
      final heading = (data['heading'] as num?)?.toDouble();
      final address = data['address'] as Map<String, dynamic>?;

      if (latitude == null || longitude == null) {
        AppLogger.w('⚠️ Background update missing coordinates');
        return;
      }

      AppLogger.d('📍 Background location update: $latitude, $longitude ${address != null ? "(with address)" : ""}');

      // Send to server if connected
      if (_socketService.isConnected) {
        _socketService.updateLocation(
          beatPlanId: _currentBeatPlanId!,
          latitude: latitude,
          longitude: longitude,
          accuracy: accuracy ?? 0.0,
          speed: speed ?? 0.0,
          heading: heading ?? 0.0,
          address: address, // Pass address to socket
        );
        AppLogger.d('✅ Background location sent to server via socket ${address != null ? "(with address)" : ""}');
      } else {
        // Queue for later sync (though background service already saved to Hive)
        AppLogger.d('📥 Socket not connected, background service has queued to Hive');
      }

      // Emit stats update
      _emitStats();
    } catch (e) {
      AppLogger.e('❌ Error handling background service update: $e');
    }
  }

  /// Handle tracking stopped event from server
  void _handleTrackingStopped(TrackingStoppedEvent event) {
    AppLogger.i('🛑 Tracking stopped by server: ${event.message}');
    stopTracking();
  }

  /// Handle tracking force-stopped event (beat plan completed/cancelled)
  void _handleTrackingForceStopped(TrackingForceStoppedEvent event) {
    AppLogger.w('⚠️ Tracking force-stopped by server!');
    AppLogger.w('   Reason: ${event.reason}');
    AppLogger.w('   Message: ${event.message}');
    AppLogger.i('📊 Final Summary:');
    AppLogger.i('   Distance: ${event.totalDistance ?? 0}km');
    AppLogger.i('   Duration: ${event.totalDuration ?? 0}min');
    AppLogger.i('   Avg Speed: ${event.averageSpeed ?? 0}km/h');

    // Gracefully stop tracking
    stopTracking();

    // Emit a special state to notify UI
    _emitState(TrackingState.forceStopped);

    // Could also show a notification to user here
    // For now, the UI listening to state changes will handle it
  }

  /// Handle socket error
  void _handleSocketError(String error) {
    AppLogger.e('❌ Socket error: $error');
    // Continue tracking offline, queue will sync when connection restored
  }

  /// Handle connectivity change
  void _handleConnectivityChange(List<ConnectivityResult> results) async {
    final wasOnline = _isOnline;
    _isOnline = results.first != ConnectivityResult.none;

    AppLogger.i('📶 Connectivity changed: ${_isOnline ? "Online" : "Offline"}');

    if (!wasOnline && _isOnline) {
      // Just came back online
      AppLogger.i('✅ Connection restored, syncing queued locations...');

      // Reconnect socket
      if (_isTracking) {
        final connected = await _socketService.connect();
        if (connected && _currentBeatPlanId != null) {
          await _socketService.startTracking(_currentBeatPlanId!);
        }
      }

      // Sync queued locations
      if (_socketService.isConnected) {
        final synced = await _queueService.syncQueue(socketService: _socketService);
        AppLogger.i('✅ Synced $synced queued locations');
        await _queueService.clearSynced();
      }
    }

    _emitStats();
  }

  /// Start periodic sync timer
  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (timer) async {
      if (!_isTracking) {
        timer.cancel();
        return;
      }

      // Attempt to sync queued locations
      if (_socketService.isConnected && _queueService.queueCount > 0) {
        AppLogger.d('🔄 Periodic sync: ${_queueService.queueCount} pending');
        final synced = await _queueService.syncQueue(socketService: _socketService);
        if (synced > 0) {
          AppLogger.i('✅ Synced $synced locations');
          await _queueService.clearSynced();
        }
      }

      _emitStats();
    });
  }

  /// Emit tracking state
  void _emitState(TrackingState state) {
    _currentState = state;
    _stateController.add(state);
  }

  /// Emit tracking stats
  void _emitStats() {
    final stats = TrackingStats(
      beatPlanId: _currentBeatPlanId ?? '',
      isTracking: _isTracking,
      isOnline: _isOnline,
      isSocketConnected: _socketService.isConnected,
      queuedLocations: _queueService.queueCount,
      trackingDuration: _trackingStartTime != null
          ? DateTime.now().difference(_trackingStartTime!)
          : Duration.zero,
      totalDirectories: _totalDirectories,
      visitedDirectories: _visitedDirectories,
    );

    _statsController.add(stats);
  }

  /// Dispose resources
  Future<void> dispose() async {
    await stopTracking();
    await _locationSubscription?.cancel();
    await _backgroundServiceSubscription?.cancel();
    await _trackingStoppedSubscription?.cancel();
    await _socketErrorSubscription?.cancel();
    await _connectivitySubscription?.cancel();
    await _stateController.close();
    await _statsController.close();
    _syncTimer?.cancel();
    AppLogger.d('TrackingCoordinator disposed');
  }
}

// ============================================================================
// MODELS
// ============================================================================

/// Tracking State Enum
enum TrackingState {
  idle,
  starting,
  active,
  paused,
  stopping,
  stopped,
  forceStopped, // When server forcefully stops tracking (e.g., beat plan completed)
  error,
}

/// Tracking Statistics
class TrackingStats {
  final String beatPlanId;
  final bool isTracking;
  final bool isOnline;
  final bool isSocketConnected;
  final int queuedLocations;
  final Duration trackingDuration;
  final int totalDirectories;
  final int visitedDirectories;

  TrackingStats({
    required this.beatPlanId,
    required this.isTracking,
    required this.isOnline,
    required this.isSocketConnected,
    required this.queuedLocations,
    required this.trackingDuration,
    this.totalDirectories = 0,
    this.visitedDirectories = 0,
  });

  @override
  String toString() {
    return 'TrackingStats('
        'beatPlan: $beatPlanId, '
        'tracking: $isTracking, '
        'online: $isOnline, '
        'socketConnected: $isSocketConnected, '
        'queued: $queuedLocations, '
        'duration: ${trackingDuration.inMinutes}m, '
        'progress: $visitedDirectories/$totalDirectories'
        ')';
  }
}
