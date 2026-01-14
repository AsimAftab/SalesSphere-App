import 'package:geolocator/geolocator.dart';
import 'package:sales_sphere/core/utils/logger.dart';

/// Geofencing Service
/// Handles geofence validation for directory visits
/// Ensures users can only mark directories as visited when within the geofence radius
class GeofencingService {
  GeofencingService._();
  static final GeofencingService instance = GeofencingService._();

  /// Default geofence radius in meters
  /// Users must be within this distance to mark a directory as visited
  static const double defaultGeofenceRadius = 50.0; // 50 meters

  /// Strict geofence radius for testing or high-accuracy requirements
  static const double strictGeofenceRadius = 20.0; // 20 meters

  /// Attendance geofence radius in meters
  /// Users must be within this distance to mark attendance
  static const double attendanceGeofenceRadius = 100.0; // 100 meters

  /// Calculate distance between two coordinates in meters
  /// Uses the Haversine formula via Geolocator
  double calculateDistance({
    required double userLat,
    required double userLng,
    required double targetLat,
    required double targetLng,
  }) {
    try {
      final distance = Geolocator.distanceBetween(
        userLat,
        userLng,
        targetLat,
        targetLng,
      );

      AppLogger.d(
        '📏 Distance calculated: ${distance.toStringAsFixed(1)}m '
        '(User: $userLat,$userLng → Target: $targetLat,$targetLng)',
      );

      return distance;
    } catch (e) {
      AppLogger.e('❌ Error calculating distance: $e');
      rethrow;
    }
  }

  /// Check if user is within geofence radius of target location
  /// Returns true if within radius, false otherwise
  bool isWithinGeofence({
    required double userLat,
    required double userLng,
    required double targetLat,
    required double targetLng,
    double radius = defaultGeofenceRadius,
  }) {
    final distance = calculateDistance(
      userLat: userLat,
      userLng: userLng,
      targetLat: targetLat,
      targetLng: targetLng,
    );

    final isWithin = distance <= radius;

    if (isWithin) {
      AppLogger.i(
        '✅ Within geofence: ${distance.toStringAsFixed(1)}m / ${radius.toStringAsFixed(0)}m',
      );
    } else {
      AppLogger.w(
        '⚠️ Outside geofence: ${distance.toStringAsFixed(1)}m / ${radius.toStringAsFixed(0)}m '
        '(${(distance - radius).toStringAsFixed(1)}m away)',
      );
    }

    return isWithin;
  }

  /// Get geofence validation result with detailed information
  /// Returns a GeofenceResult object with distance and validation status
  GeofenceResult validateGeofence({
    required double userLat,
    required double userLng,
    required double targetLat,
    required double targetLng,
    double radius = defaultGeofenceRadius,
  }) {
    final distance = calculateDistance(
      userLat: userLat,
      userLng: userLng,
      targetLat: targetLat,
      targetLng: targetLng,
    );

    final isWithin = distance <= radius;
    final distanceAway = isWithin ? 0.0 : distance - radius;

    return GeofenceResult(
      isWithinGeofence: isWithin,
      distance: distance,
      radius: radius,
      distanceOutside: distanceAway,
    );
  }

  /// Format distance for display
  /// Returns a human-readable distance string (e.g., "45m", "1.2km")
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)}m';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)}km';
    }
  }

  /// Get user-friendly geofence message
  String getGeofenceMessage(GeofenceResult result) {
    if (result.isWithinGeofence) {
      return 'You are ${formatDistance(result.distance)} from the location';
    } else {
      return 'You are ${formatDistance(result.distanceOutside)} outside the geofence radius. '
          'Please move closer (within ${formatDistance(result.radius)}) to mark as visited.';
    }
  }
}

/// Geofence validation result
class GeofenceResult {
  /// Whether the user is within the geofence
  final bool isWithinGeofence;

  /// Actual distance from user to target in meters
  final double distance;

  /// Geofence radius in meters
  final double radius;

  /// Distance outside geofence (0 if within)
  final double distanceOutside;

  GeofenceResult({
    required this.isWithinGeofence,
    required this.distance,
    required this.radius,
    required this.distanceOutside,
  });

  @override
  String toString() {
    return 'GeofenceResult('
        'within: $isWithinGeofence, '
        'distance: ${distance.toStringAsFixed(1)}m, '
        'radius: ${radius.toStringAsFixed(0)}m'
        ')';
  }
}
