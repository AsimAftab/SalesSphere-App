import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sales_sphere/core/utils/logger.dart';

class LocationService {
  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check and request location permissions
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      AppLogger.i('Location permission denied, requesting...');
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        AppLogger.w('Location permission denied by user');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      AppLogger.e('Location permissions are permanently denied');
      return false;
    }

    AppLogger.i('Location permission granted');
    return true;
  }

  /// Get current location
  Future<LatLng?> getCurrentLocation() async {
    try {
      // Check if location service is enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppLogger.w('Location services are disabled');
        return null;
      }

      // Check permissions
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        AppLogger.w('Location permission not granted');
        return null;
      }

      // Get current position
      AppLogger.i('Getting current location...');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      AppLogger.i(
        'Current location: ${position.latitude}, ${position.longitude}',
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      AppLogger.e('Error getting current location: $e');
      return null;
    }
  }

  /// Open app settings for location permissions
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Open app settings for app permissions
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
