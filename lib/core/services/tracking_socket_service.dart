import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sales_sphere/core/constants/storage_keys.dart';
import 'package:sales_sphere/core/utils/logger.dart';

/// Tracking Socket Service
/// Handles WebSocket connection for real-time beat plan tracking
class TrackingSocketService {
  TrackingSocketService._();
  static final TrackingSocketService instance = TrackingSocketService._();

  // Socket instance
  io.Socket? _socket;

  // Connection state
  bool _isConnected = false;
  bool _isConnecting = false;

  // Reconnection state
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const int _baseReconnectDelay = 1000; // milliseconds
  Timer? _reconnectTimer;

  // Stream controllers for events
  final StreamController<TrackingStartedEvent> _trackingStartedController =
      StreamController<TrackingStartedEvent>.broadcast();
  final StreamController<LocationUpdateEvent> _locationUpdateController =
      StreamController<LocationUpdateEvent>.broadcast();
  final StreamController<TrackingStatusUpdateEvent> _statusUpdateController =
      StreamController<TrackingStatusUpdateEvent>.broadcast();
  final StreamController<TrackingStoppedEvent> _trackingStoppedController =
      StreamController<TrackingStoppedEvent>.broadcast();
  final StreamController<TrackingForceStoppedEvent> _trackingForceStoppedController =
      StreamController<TrackingForceStoppedEvent>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  // Getters
  bool get isConnected => _isConnected;
  io.Socket? get socket => _socket;

  // Event streams
  Stream<TrackingStartedEvent> get onTrackingStarted =>
      _trackingStartedController.stream;
  Stream<LocationUpdateEvent> get onLocationUpdate =>
      _locationUpdateController.stream;
  Stream<TrackingStatusUpdateEvent> get onStatusUpdate =>
      _statusUpdateController.stream;
  Stream<TrackingStoppedEvent> get onTrackingStopped =>
      _trackingStoppedController.stream;
  Stream<TrackingForceStoppedEvent> get onTrackingForceStopped =>
      _trackingForceStoppedController.stream;
  Stream<String> get onError => _errorController.stream;

  /// Connect to tracking server
  Future<bool> connect() async {
    if (_isConnected) {
      AppLogger.w('⚠️ Socket already connected');
      return true;
    }

    if (_isConnecting) {
      AppLogger.w('⚠️ Socket connection already in progress');
      return false;
    }

    try {
      _isConnecting = true;
      AppLogger.i('🔌 Connecting to tracking server...');

      // Get JWT token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.accessToken);
      if (token == null) {
        throw Exception('No authentication token found');
      }

      // Get base URL and path from environment
      // IMPORTANT: URL must NOT include port for HTTPS (uses default 443)
      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000';
      final socketPath = dotenv.env['WEBSOCKET_PATH'] ?? '/live/tracking';

      AppLogger.i('🔌 Socket URL: $baseUrl');
      AppLogger.i('🔌 Socket Path: $socketPath');
      AppLogger.d('🔐 Using JWT token for authentication');

      // Create socket connection matching working test configuration
      _socket = io.io(
        baseUrl,
        io.OptionBuilder()
            .setPath(socketPath) // e.g. /api/tracking (nginx proxies to backend /tracking)
            .setTransports(['websocket', 'polling']) // Try WebSocket first, fallback to polling
            .setAuth({'token': token}) // JWT authentication
            .disableAutoConnect() // Manual connection control
            .build(),
      );

      // Setup event listeners
      _setupEventListeners();

      // Connect
      _socket!.connect();

      // Wait for connection or timeout
      final connected = await _waitForConnection();

      if (connected) {
        _isConnected = true;
        _reconnectAttempts = 0;
        AppLogger.i('✅ Connected to tracking server');
        return true;
      } else {
        throw Exception('Connection timeout');
      }
    } catch (e, stack) {
      AppLogger.e('❌ Error connecting to tracking server: $e');
      AppLogger.e('Stack trace: $stack');
      _isConnected = false;
      _errorController.add('Failed to connect: $e');
      return false;
    } finally {
      _isConnecting = false;
    }
  }

  /// Disconnect from tracking server
  Future<void> disconnect() async {
    if (!_isConnected) {
      AppLogger.w('⚠️ Socket not connected');
      return;
    }

    try {
      AppLogger.i('🔌 Disconnecting from tracking server...');

      _reconnectTimer?.cancel();
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
      _isConnected = false;
      _reconnectAttempts = 0;

      AppLogger.i('✅ Disconnected from tracking server');
    } catch (e) {
      AppLogger.e('❌ Error disconnecting: $e');
    }
  }

  /// Setup socket event listeners
  void _setupEventListeners() {
    if (_socket == null) return;

    AppLogger.d('🔧 Setting up socket event listeners...');

    // Connection events
    _socket!.onConnect((_) {
      AppLogger.i('✅ Socket connected successfully!');
      _isConnected = true;
      _reconnectAttempts = 0;
    });

    _socket!.onDisconnect((reason) {
      AppLogger.w('⚠️ Socket disconnected. Reason: $reason');
      _isConnected = false;
      _handleDisconnection();
    });

    _socket!.onConnectError((error) {
      AppLogger.e('❌ Connection error: $error');
      AppLogger.e('❌ Error type: ${error.runtimeType}');
      _errorController.add('Connection error: $error');
    });

    _socket!.onError((error) {
      AppLogger.e('❌ Socket error: $error');
      AppLogger.e('❌ Error type: ${error.runtimeType}');
      _errorController.add('Socket error: $error');
    });

    // Additional debugging events
    _socket!.on('connect_timeout', (_) {
      AppLogger.e('❌ Connection timeout');
    });

    _socket!.on('reconnect', (attemptNumber) {
      AppLogger.i('🔄 Reconnected after $attemptNumber attempts');
    });

    _socket!.on('reconnect_attempt', (attemptNumber) {
      AppLogger.d('🔄 Reconnection attempt #$attemptNumber');
    });

    _socket!.on('reconnect_error', (error) {
      AppLogger.e('❌ Reconnection error: $error');
    });

    _socket!.on('reconnect_failed', (_) {
      AppLogger.e('❌ Reconnection failed completely');
    });

    // Tracking events
    _socket!.on('tracking-started', _handleTrackingStarted);
    _socket!.on('location-update', _handleLocationUpdate);
    _socket!.on('tracking-paused', _handleTrackingPaused);
    _socket!.on('tracking-resumed', _handleTrackingResumed);
    _socket!.on('tracking-stopped', _handleTrackingStopped);
    _socket!.on('tracking-force-stopped', _handleTrackingForceStopped);
    _socket!.on('tracking-status-update', _handleStatusUpdate);
    _socket!.on('tracking-error', _handleTrackingError);

    // Watch beat plan events (for web dashboard)
    _socket!.on('watch-started', _handleWatchStarted);

    AppLogger.d('Socket event listeners setup complete');
  }

  /// Wait for socket connection (with timeout)
  Future<bool> _waitForConnection({Duration timeout = const Duration(seconds: 10)}) async {
    final completer = Completer<bool>();
    Timer? timeoutTimer;

    void onConnect(_) {
      if (!completer.isCompleted) {
        completer.complete(true);
        timeoutTimer?.cancel();
      }
    }

    void onError(_) {
      if (!completer.isCompleted) {
        completer.complete(false);
        timeoutTimer?.cancel();
      }
    }

    _socket!.onConnect(onConnect);
    _socket!.onConnectError(onError);

    timeoutTimer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    return completer.future;
  }

  /// Handle disconnection with auto-reconnect
  void _handleDisconnection() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      AppLogger.e('❌ Max reconnection attempts reached');
      _errorController.add('Connection lost. Please restart tracking.');
      return;
    }

    // Exponential backoff: 1s, 2s, 4s, 8s, 16s
    final delay = _baseReconnectDelay * (1 << _reconnectAttempts);
    _reconnectAttempts++;

    AppLogger.i('🔄 Reconnecting in ${delay}ms (attempt $_reconnectAttempts/$_maxReconnectAttempts)');

    _reconnectTimer = Timer(Duration(milliseconds: delay), () {
      connect();
    });
  }

  /// Start tracking a beat plan
  Future<void> startTracking(String beatPlanId, {String? sessionId}) async {
    if (!_isConnected) {
      throw Exception('Socket not connected. Call connect() first.');
    }

    try {
      AppLogger.i('🎯 Starting tracking for beat plan: $beatPlanId');
      if (sessionId != null) {
        AppLogger.i('🔑 Reconnecting to existing session: $sessionId');
      }

      final data = <String, dynamic>{'beatPlanId': beatPlanId};
      if (sessionId != null) {
        data['sessionId'] = sessionId;
      }

      _socket!.emit('start-tracking', data);
    } catch (e) {
      AppLogger.e('❌ Error starting tracking: $e');
      rethrow;
    }
  }

  /// Update location
  void updateLocation({
    required String beatPlanId,
    required double latitude,
    required double longitude,
    required double accuracy,
    required double speed,
    required double heading,
    Map<String, dynamic>? address,
  }) {
    if (!_isConnected) {
      AppLogger.w('⚠️ Cannot update location: Socket not connected');
      return;
    }

    try {
      final payload = {
        'beatPlanId': beatPlanId,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'speed': speed,
        'heading': heading,
        if (address != null) 'address': address,
      };

      _socket!.emit('update-location', payload);

      AppLogger.d('📍 Location update sent: $latitude, $longitude ${address != null ? "(with address)" : ""}');
    } catch (e) {
      AppLogger.e('❌ Error updating location: $e');
    }
  }

  /// Pause tracking
  Future<void> pauseTracking(String beatPlanId) async {
    if (!_isConnected) {
      throw Exception('Socket not connected');
    }

    try {
      AppLogger.i('⏸️ Pausing tracking for beat plan: $beatPlanId');

      _socket!.emit('pause-tracking', {'beatPlanId': beatPlanId});
    } catch (e) {
      AppLogger.e('❌ Error pausing tracking: $e');
      rethrow;
    }
  }

  /// Resume tracking
  Future<void> resumeTracking(String beatPlanId) async {
    if (!_isConnected) {
      throw Exception('Socket not connected');
    }

    try {
      AppLogger.i('▶️ Resuming tracking for beat plan: $beatPlanId');

      _socket!.emit('resume-tracking', {'beatPlanId': beatPlanId});
    } catch (e) {
      AppLogger.e('❌ Error resuming tracking: $e');
      rethrow;
    }
  }

  /// Stop tracking
  Future<void> stopTracking(String beatPlanId) async {
    if (!_isConnected) {
      throw Exception('Socket not connected');
    }

    try {
      AppLogger.i('🛑 Stopping tracking for beat plan: $beatPlanId');

      _socket!.emit('stop-tracking', {'beatPlanId': beatPlanId});
    } catch (e) {
      AppLogger.e('❌ Error stopping tracking: $e');
      rethrow;
    }
  }

  /// Watch beat plan (for web dashboard)
  void watchBeatPlan(String beatPlanId) {
    if (!_isConnected) {
      AppLogger.w('⚠️ Cannot watch beat plan: Socket not connected');
      return;
    }

    try {
      AppLogger.i('👁️ Watching beat plan: $beatPlanId');

      _socket!.emit('watch-beatplan', {'beatPlanId': beatPlanId});
    } catch (e) {
      AppLogger.e('❌ Error watching beat plan: $e');
    }
  }

  /// Unwatch beat plan
  void unwatchBeatPlan(String beatPlanId) {
    if (!_isConnected) return;

    try {
      AppLogger.i('👁️ Unwatching beat plan: $beatPlanId');

      _socket!.emit('unwatch-beatplan', {'beatPlanId': beatPlanId});
    } catch (e) {
      AppLogger.e('❌ Error unwatching beat plan: $e');
    }
  }

  // Event handlers

  void _handleTrackingStarted(dynamic data) {
    try {
      AppLogger.i('✅ Tracking started: $data');

      final event = TrackingStartedEvent(
        success: data['success'] ?? true,
        trackingSessionId: data['trackingSessionId'] ?? '',
        beatPlanId: data['beatPlanId'] ?? '',
        message: data['message'] ?? '',
      );

      _trackingStartedController.add(event);
    } catch (e) {
      AppLogger.e('Error handling tracking-started event: $e');
    }
  }

  void _handleLocationUpdate(dynamic data) {
    try {
      AppLogger.d('📍 Location update received from server');

      final event = LocationUpdateEvent(
        beatPlanId: data['beatPlanId'] ?? '',
        userId: data['userId'] ?? '',
        location: data['location'] ?? {},
        nearestDirectory: data['nearestDirectory'],
      );

      _locationUpdateController.add(event);
    } catch (e) {
      AppLogger.e('Error handling location-update event: $e');
    }
  }

  void _handleTrackingPaused(dynamic data) {
    try {
      AppLogger.i('⏸️ Tracking paused: $data');

      final event = TrackingStatusUpdateEvent(
        beatPlanId: data['beatPlanId'] ?? '',
        userId: data['userId'] ?? '',
        status: 'paused',
      );

      _statusUpdateController.add(event);
    } catch (e) {
      AppLogger.e('Error handling tracking-paused event: $e');
    }
  }

  void _handleTrackingResumed(dynamic data) {
    try {
      AppLogger.i('▶️ Tracking resumed: $data');

      final event = TrackingStatusUpdateEvent(
        beatPlanId: data['beatPlanId'] ?? '',
        userId: data['userId'] ?? '',
        status: 'active',
      );

      _statusUpdateController.add(event);
    } catch (e) {
      AppLogger.e('Error handling tracking-resumed event: $e');
    }
  }

  void _handleTrackingStopped(dynamic data) {
    try {
      AppLogger.i('🛑 Tracking stopped: $data');

      final event = TrackingStoppedEvent(
        success: data['success'] ?? true,
        summary: data['summary'] ?? {},
        message: data['message'] ?? '',
      );

      _trackingStoppedController.add(event);
    } catch (e) {
      AppLogger.e('Error handling tracking-stopped event: $e');
    }
  }

  void _handleTrackingForceStopped(dynamic data) {
    try {
      AppLogger.w('⚠️ Tracking force-stopped by server: $data');

      final event = TrackingForceStoppedEvent(
        beatPlanId: data['beatPlanId'] ?? '',
        userId: data['userId'] ?? '',
        trackingSessionId: data['trackingSessionId'] ?? '',
        reason: data['reason'] ?? 'unknown',
        message: data['message'] ?? 'Tracking was stopped by the server',
        summary: data['summary'] ?? {},
      );

      _trackingForceStoppedController.add(event);
    } catch (e) {
      AppLogger.e('Error handling tracking-force-stopped event: $e');
    }
  }

  void _handleStatusUpdate(dynamic data) {
    try {
      AppLogger.d('📊 Status update: $data');

      final event = TrackingStatusUpdateEvent(
        beatPlanId: data['beatPlanId'] ?? '',
        userId: data['userId'] ?? '',
        status: data['status'] ?? '',
      );

      _statusUpdateController.add(event);
    } catch (e) {
      AppLogger.e('Error handling tracking-status-update event: $e');
    }
  }

  void _handleTrackingError(dynamic data) {
    try {
      final message = data['message'] ?? 'Unknown tracking error';
      AppLogger.e('❌ Tracking error: $message');

      _errorController.add(message);
    } catch (e) {
      AppLogger.e('Error handling tracking-error event: $e');
    }
  }

  void _handleWatchStarted(dynamic data) {
    try {
      AppLogger.i('👁️ Watch started: $data');
    } catch (e) {
      AppLogger.e('Error handling watch-started event: $e');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await disconnect();
    await _trackingStartedController.close();
    await _locationUpdateController.close();
    await _statusUpdateController.close();
    await _trackingStoppedController.close();
    await _trackingForceStoppedController.close();
    await _errorController.close();
    _reconnectTimer?.cancel();
  }
}

// ============================================================================
// EVENT MODELS
// ============================================================================

/// Tracking Started Event
class TrackingStartedEvent {
  final bool success;
  final String trackingSessionId;
  final String beatPlanId;
  final String message;

  TrackingStartedEvent({
    required this.success,
    required this.trackingSessionId,
    required this.beatPlanId,
    required this.message,
  });

  @override
  String toString() {
    return 'TrackingStartedEvent(success: $success, sessionId: $trackingSessionId, beatPlanId: $beatPlanId)';
  }
}

/// Location Update Event
class LocationUpdateEvent {
  final String beatPlanId;
  final String userId;
  final Map<String, dynamic> location;
  final Map<String, dynamic>? nearestDirectory;

  LocationUpdateEvent({
    required this.beatPlanId,
    required this.userId,
    required this.location,
    this.nearestDirectory,
  });

  double? get latitude => location['latitude'];
  double? get longitude => location['longitude'];
  double? get accuracy => location['accuracy'];
  double? get speed => location['speed'];
  String? get timestamp => location['timestamp'];

  String? get nearestDirectoryId => nearestDirectory?['id'];
  String? get nearestDirectoryType => nearestDirectory?['type'];
  String? get nearestDirectoryName => nearestDirectory?['name'];
  double? get distanceToNearest => nearestDirectory?['distance'];

  @override
  String toString() {
    return 'LocationUpdateEvent(beatPlanId: $beatPlanId, lat: $latitude, lng: $longitude, nearest: $nearestDirectoryName)';
  }
}

/// Tracking Status Update Event
class TrackingStatusUpdateEvent {
  final String beatPlanId;
  final String userId;
  final String status; // pending, active, paused, completed

  TrackingStatusUpdateEvent({
    required this.beatPlanId,
    required this.userId,
    required this.status,
  });

  @override
  String toString() {
    return 'TrackingStatusUpdateEvent(beatPlanId: $beatPlanId, status: $status)';
  }
}

/// Tracking Stopped Event
class TrackingStoppedEvent {
  final bool success;
  final Map<String, dynamic> summary;
  final String message;

  TrackingStoppedEvent({
    required this.success,
    required this.summary,
    required this.message,
  });

  double? get totalDistance => summary['totalDistance'];
  double? get totalDuration => summary['totalDuration'];
  double? get averageSpeed => summary['averageSpeed'];
  int? get directoriesVisited => summary['directoriesVisited'];

  @override
  String toString() {
    return 'TrackingStoppedEvent(success: $success, distance: ${totalDistance}km, duration: ${totalDuration}min)';
  }
}

/// Tracking Force Stopped Event
/// Emitted when tracking is forcefully stopped by the server
/// (e.g., when beat plan is completed by another user/admin)
class TrackingForceStoppedEvent {
  final String beatPlanId;
  final String userId;
  final String trackingSessionId;
  final String reason; // e.g., 'beat_plan_completed', 'session_expired', etc.
  final String message;
  final Map<String, dynamic> summary;

  TrackingForceStoppedEvent({
    required this.beatPlanId,
    required this.userId,
    required this.trackingSessionId,
    required this.reason,
    required this.message,
    required this.summary,
  });

  double? get totalDistance => summary['totalDistance'];
  double? get totalDuration => summary['totalDuration'];
  double? get averageSpeed => summary['averageSpeed'];
  int? get directoriesVisited => summary['directoriesVisited'];

  @override
  String toString() {
    return 'TrackingForceStoppedEvent(reason: $reason, beatPlanId: $beatPlanId, message: $message)';
  }
}
