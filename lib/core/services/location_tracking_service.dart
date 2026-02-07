import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:sales_sphere/core/utils/logger.dart';

/// Location Tracking Service
/// Handles GPS location tracking with battery optimization for real-time beat plan tracking
class LocationTrackingService {
  LocationTrackingService._();

  static final LocationTrackingService instance = LocationTrackingService._();

  // Position stream subscription
  StreamSubscription<Position>? _positionSubscription;

  // Position stream controller
  final StreamController<LocationUpdate> _locationController =
      StreamController<LocationUpdate>.broadcast();

  // Tracking state
  bool _isTracking = false;
  Position? _lastPosition;
  DateTime? _lastUpdateTime;

  // Configuration
  static const int _normalUpdateInterval = 10; // seconds
  static const int _stationaryUpdateInterval =
      30; // seconds (reduced for testing - was 30)
  static const double _stationarySpeedThreshold = 0.5; // m/s (~1.8 km/h)
  static const double _minDistanceFilter =
      10.0; // meters (reduced for testing - was 10.0)

  /// Get location update stream
  Stream<LocationUpdate> get locationStream => _locationController.stream;

  /// Check if tracking is active
  bool get isTracking => _isTracking;

  /// Get last known position
  Position? get lastPosition => _lastPosition;

  /// Start location tracking
  ///
  /// Parameters:
  /// - accuracy: Desired location accuracy (default: high)
  /// - distanceFilter: Minimum distance between updates in meters (default: 10m)
  /// - enableBackgroundUpdates: Keep tracking when app is backgrounded (default: true)
  Future<void> startTracking({
    LocationAccuracy accuracy = LocationAccuracy.high,
    double distanceFilter = _minDistanceFilter,
    bool enableBackgroundUpdates = true,
  }) async {
    if (_isTracking) {
      AppLogger.w('⚠️ Location tracking already active');
      return;
    }

    try {
      AppLogger.i('🎯 Starting location tracking...');

      // Configure location settings
      final locationSettings = _getLocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        enableBackgroundUpdates: enableBackgroundUpdates,
      );

      // Start position stream
      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: locationSettings,
          ).listen(
            _handlePositionUpdate,
            onError: _handlePositionError,
            cancelOnError: false,
          );

      _isTracking = true;
      AppLogger.i('✅ Location tracking started successfully');

      // Get initial position immediately
      await _getInitialPosition(accuracy);
    } catch (e, stack) {
      AppLogger.e('❌ Error starting location tracking: $e');
      AppLogger.e('Stack trace: $stack');
      _isTracking = false;
      rethrow;
    }
  }

  /// Stop location tracking
  Future<void> stopTracking() async {
    if (!_isTracking) {
      AppLogger.w('⚠️ Location tracking not active');
      return;
    }

    try {
      AppLogger.i('🛑 Stopping location tracking...');

      await _positionSubscription?.cancel();
      _positionSubscription = null;

      _isTracking = false;
      _lastPosition = null;
      _lastUpdateTime = null;

      AppLogger.i('✅ Location tracking stopped successfully');
    } catch (e, stack) {
      AppLogger.e('❌ Error stopping location tracking: $e');
      AppLogger.e('Stack trace: $stack');
    }
  }

  /// Pause location tracking (keeps service alive but stops updates)
  Future<void> pauseTracking() async {
    if (!_isTracking) {
      AppLogger.w('⚠️ Location tracking not active');
      return;
    }

    try {
      AppLogger.i('⏸️ Pausing location tracking...');

      await _positionSubscription?.cancel();
      _positionSubscription = null;

      AppLogger.i('✅ Location tracking paused');
    } catch (e, stack) {
      AppLogger.e('❌ Error pausing location tracking: $e');
      AppLogger.e('Stack trace: $stack');
    }
  }

  /// Resume location tracking after pause
  Future<void> resumeTracking({
    LocationAccuracy accuracy = LocationAccuracy.high,
    double distanceFilter = _minDistanceFilter,
    bool enableBackgroundUpdates = true,
  }) async {
    if (!_isTracking) {
      AppLogger.w(
        '⚠️ Location tracking not active, use startTracking() instead',
      );
      return;
    }

    if (_positionSubscription != null) {
      AppLogger.w('⚠️ Location tracking already active');
      return;
    }

    try {
      AppLogger.i('▶️ Resuming location tracking...');

      // Configure location settings
      final locationSettings = _getLocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        enableBackgroundUpdates: enableBackgroundUpdates,
      );

      // Restart position stream
      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: locationSettings,
          ).listen(
            _handlePositionUpdate,
            onError: _handlePositionError,
            cancelOnError: false,
          );

      AppLogger.i('✅ Location tracking resumed');
    } catch (e, stack) {
      AppLogger.e('❌ Error resuming location tracking: $e');
      AppLogger.e('Stack trace: $stack');
    }
  }

  /// Get current location (one-time)
  Future<Position?> getCurrentLocation({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      AppLogger.d('📍 Getting current location...');

      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: timeout,
        ),
      );

      AppLogger.d(
        '✅ Current location: ${position.latitude}, ${position.longitude}',
      );
      return position;
    } catch (e) {
      AppLogger.e('❌ Error getting current location: $e');
      return null;
    }
  }

  /// Get initial position when starting tracking
  Future<void> _getInitialPosition(LocationAccuracy accuracy) async {
    try {
      final position = await getCurrentLocation(accuracy: accuracy);

      if (position != null) {
        _handlePositionUpdate(position);
      }
    } catch (e) {
      AppLogger.w('Failed to get initial position: $e');
    }
  }

  /// Handle position update from stream
  void _handlePositionUpdate(Position position) {
    try {
      // Check if we should skip this update (battery optimization)
      if (_shouldSkipUpdate(position)) {
        return;
      }

      // Update last position
      _lastPosition = position;
      _lastUpdateTime = DateTime.now();

      // Calculate distance from last position
      double? distanceFromLast;
      if (_lastPosition != null && _lastPosition != position) {
        distanceFromLast = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );
      }

      // Create location update
      final update = LocationUpdate(
        position: position,
        timestamp: DateTime.now(),
        distanceFromLast: distanceFromLast,
        isStationary: _isStationary(position),
      );

      // Emit update to stream
      _locationController.add(update);

      AppLogger.d(
        '📍 Location update: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)} '
        '| Accuracy: ±${position.accuracy.toStringAsFixed(1)}m '
        '| Speed: ${(position.speed * 3.6).toStringAsFixed(1)} km/h',
      );
    } catch (e) {
      AppLogger.e('Error handling position update: $e');
    }
  }

  /// Handle position stream errors
  void _handlePositionError(dynamic error) {
    AppLogger.e('❌ Location stream error: $error');

    // Emit error to stream
    _locationController.addError(error);
  }

  /// Check if we should skip this update (battery optimization)
  bool _shouldSkipUpdate(Position position) {
    if (_lastPosition == null || _lastUpdateTime == null) {
      return false; // Always send first update
    }

    // Check time since last update
    final timeSinceLastUpdate = DateTime.now().difference(_lastUpdateTime!);

    // If stationary, only send updates every 30 seconds
    if (_isStationary(position)) {
      if (timeSinceLastUpdate.inSeconds < _stationaryUpdateInterval) {
        AppLogger.d('⏭️ Skipping update (stationary, too soon)');
        return true;
      }
    }

    // Check distance from last position
    final distance = Geolocator.distanceBetween(
      _lastPosition!.latitude,
      _lastPosition!.longitude,
      position.latitude,
      position.longitude,
    );

    // Skip if movement is less than minimum distance filter
    if (distance < _minDistanceFilter) {
      AppLogger.d('⏭️ Skipping update (distance < ${_minDistanceFilter}m)');
      return true;
    }

    return false;
  }

  /// Check if user is stationary (not moving significantly)
  bool _isStationary(Position position) {
    return position.speed < _stationarySpeedThreshold;
  }

  /// Get location settings based on platform and requirements
  LocationSettings _getLocationSettings({
    required LocationAccuracy accuracy,
    required double distanceFilter,
    required bool enableBackgroundUpdates,
  }) {
    if (enableBackgroundUpdates) {
      // Background tracking settings - NO timeout (runs continuously)
      return LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter.toInt(),
        // No timeLimit - tracking continues indefinitely until stopped
      );
    } else {
      // Foreground only settings - NO timeout (runs continuously)
      return LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter.toInt(),
        // No timeLimit - tracking continues indefinitely until stopped
      );
    }
  }

  /// Calculate distance between two positions in meters
  static double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Calculate distance between two positions in kilometers
  static double calculateDistanceInKm({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    return calculateDistance(lat1: lat1, lon1: lon1, lat2: lat2, lon2: lon2) /
        1000;
  }

  /// Convert speed from m/s to km/h
  static double speedToKmh(double speedMs) {
    return speedMs * 3.6;
  }

  /// Convert speed from km/h to m/s
  static double speedToMs(double speedKmh) {
    return speedKmh / 3.6;
  }

  /// Dispose resources
  Future<void> dispose() async {
    await stopTracking();
    await _locationController.close();
  }
}

/// Location Update Model
/// Contains position data and metadata
class LocationUpdate {
  final Position position;
  final DateTime timestamp;
  final double? distanceFromLast; // meters
  final bool isStationary;

  LocationUpdate({
    required this.position,
    required this.timestamp,
    this.distanceFromLast,
    required this.isStationary,
  });

  /// Get latitude
  double get latitude => position.latitude;

  /// Get longitude
  double get longitude => position.longitude;

  /// Get accuracy in meters
  double get accuracy => position.accuracy;

  /// Get speed in m/s
  double get speed => position.speed;

  /// Get speed in km/h
  double get speedKmh => LocationTrackingService.speedToKmh(position.speed);

  /// Get heading/bearing in degrees
  double get heading => position.heading;

  /// Get altitude in meters
  double get altitude => position.altitude;

  @override
  String toString() {
    return 'LocationUpdate('
        'lat: ${latitude.toStringAsFixed(6)}, '
        'lng: ${longitude.toStringAsFixed(6)}, '
        'accuracy: ±${accuracy.toStringAsFixed(1)}m, '
        'speed: ${speedKmh.toStringAsFixed(1)} km/h, '
        'stationary: $isStationary'
        ')';
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'speed': speed,
      'heading': heading,
      'altitude': altitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Location Accuracy Presets
extension LocationAccuracyPresets on LocationAccuracy {
  /// High accuracy mode (best for active tracking)
  /// Battery impact: High
  static const LocationAccuracy tracking = LocationAccuracy.high;

  /// Balanced accuracy mode (good for most cases)
  /// Battery impact: Medium
  static const LocationAccuracy balanced = LocationAccuracy.medium;

  /// Low power mode (reduced accuracy)
  /// Battery impact: Low
  static const LocationAccuracy powerSaving = LocationAccuracy.low;

  /// Get user-friendly name
  String get displayName {
    switch (this) {
      case LocationAccuracy.lowest:
        return 'Very Low';
      case LocationAccuracy.low:
        return 'Low (Power Saving)';
      case LocationAccuracy.medium:
        return 'Medium (Balanced)';
      case LocationAccuracy.high:
        return 'High (Tracking)';
      case LocationAccuracy.best:
        return 'Best';
      case LocationAccuracy.bestForNavigation:
        return 'Best for Navigation';
      default:
        return 'Unknown';
    }
  }

  /// Get estimated accuracy range in meters
  String get accuracyRange {
    switch (this) {
      case LocationAccuracy.lowest:
        return '~500m';
      case LocationAccuracy.low:
        return '~100m';
      case LocationAccuracy.medium:
        return '~50m';
      case LocationAccuracy.high:
        return '~10m';
      case LocationAccuracy.best:
        return '~5m';
      case LocationAccuracy.bestForNavigation:
        return '~3m';
      default:
        return 'Unknown';
    }
  }
}
