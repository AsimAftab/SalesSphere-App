import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sales_sphere/core/services/location_tracking_service.dart';
import 'package:sales_sphere/core/services/tracking_socket_service.dart';
import 'package:sales_sphere/core/services/offline_queue_service.dart';
import 'package:sales_sphere/core/services/background_tracking_service.dart';
import 'package:sales_sphere/core/utils/logger.dart';

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
  StreamSubscription<TrackingStoppedEvent>? _trackingStoppedSubscription;
  StreamSubscription<String>? _socketErrorSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Tracking state
  bool _isTracking = false;
  String? _currentBeatPlanId;
  DateTime? _trackingStartTime;

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

  /// Get current beat plan ID
  String? get currentBeatPlanId => _currentBeatPlanId;

  /// Initialize coordinator
  Future<void> initialize() async {
    try {
      AppLogger.i('🔧 Initializing TrackingCoordinator...');

      // Initialize all services
      await _queueService.initialize();
      await _backgroundService.initialize();

      // Listen to connectivity changes
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_handleConnectivityChange);

      // Check initial connectivity
      final connectivity = await Connectivity().checkConnectivity();
      _isOnline = connectivity.first != ConnectivityResult.none;

      AppLogger.i('✅ TrackingCoordinator initialized (Online: $_isOnline)');
    } catch (e, stack) {
      AppLogger.e('❌ Error initializing TrackingCoordinator: $e');
      AppLogger.e('Stack trace: $stack');
      rethrow;
    }
  }

  /// Start tracking a beat plan
  Future<void> startTracking(String beatPlanId) async {
    if (_isTracking) {
      AppLogger.w('⚠️ Tracking already active');
      return;
    }

    try {
      AppLogger.i('🎯 Starting tracking for beat plan: $beatPlanId');

      _currentBeatPlanId = beatPlanId;
      _trackingStartTime = DateTime.now();
      _isTracking = true;

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

      // Start background service
      await _backgroundService.startTracking(beatPlanId);

      // Subscribe to location updates
      _locationSubscription = _locationService.locationStream.listen(
        _handleLocationUpdate,
        onError: (error) {
          AppLogger.e('❌ Location stream error: $error');
          _emitState(TrackingState.error);
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
      await _trackingStoppedSubscription?.cancel();
      await _socketErrorSubscription?.cancel();
      _syncTimer?.cancel();

      // Reset state
      _isTracking = false;
      _currentBeatPlanId = null;
      _trackingStartTime = null;

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

  /// Handle location update
  void _handleLocationUpdate(LocationUpdate update) async {
    if (!_isTracking || _currentBeatPlanId == null) return;

    try {
      AppLogger.d('📍 Location update: ${update.latitude}, ${update.longitude}');

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

  /// Handle tracking stopped event from server
  void _handleTrackingStopped(TrackingStoppedEvent event) {
    AppLogger.i('🛑 Tracking stopped by server: ${event.message}');
    stopTracking();
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
    );

    _statsController.add(stats);
  }

  /// Dispose resources
  Future<void> dispose() async {
    await stopTracking();
    await _locationSubscription?.cancel();
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

  TrackingStats({
    required this.beatPlanId,
    required this.isTracking,
    required this.isOnline,
    required this.isSocketConnected,
    required this.queuedLocations,
    required this.trackingDuration,
  });

  @override
  String toString() {
    return 'TrackingStats('
        'beatPlan: $beatPlanId, '
        'tracking: $isTracking, '
        'online: $isOnline, '
        'socketConnected: $isSocketConnected, '
        'queued: $queuedLocations, '
        'duration: ${trackingDuration.inMinutes}m'
        ')';
  }
}
