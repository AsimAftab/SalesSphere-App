import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sales_sphere/core/utils/logger.dart';

/// Location Permission Service
/// Handles all location permission requests and checks for real-time tracking
class LocationPermissionService {
  LocationPermissionService._();
  static final LocationPermissionService instance = LocationPermissionService._();

  /// Check if location services are enabled on device
  Future<bool> isLocationServiceEnabled() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      AppLogger.d('Location service enabled: $enabled');
      return enabled;
    } catch (e) {
      AppLogger.e('Error checking location service: $e');
      return false;
    }
  }

  /// Get current location permission status
  Future<LocationPermission> checkPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      AppLogger.d('Current location permission: $permission');
      return permission;
    } catch (e) {
      AppLogger.e('Error checking location permission: $e');
      return LocationPermission.denied;
    }
  }

  /// Request location permission (when-in-use)
  Future<LocationPermission> requestPermission() async {
    try {
      AppLogger.i('Requesting location permission...');
      final permission = await Geolocator.requestPermission();
      AppLogger.i('Location permission result: $permission');
      return permission;
    } catch (e) {
      AppLogger.e('Error requesting location permission: $e');
      return LocationPermission.denied;
    }
  }

  /// Request background location permission (Android 10+)
  /// iOS: Automatically handled when requesting "always" permission
  Future<bool> requestBackgroundPermission() async {
    try {
      AppLogger.i('Requesting background location permission...');

      // First check if we have foreground permission
      final foregroundStatus = await checkPermission();

      if (foregroundStatus == LocationPermission.denied ||
          foregroundStatus == LocationPermission.deniedForever) {
        AppLogger.w('Need foreground permission before background permission');
        return false;
      }

      // Request background location permission
      final status = await Permission.locationAlways.request();

      AppLogger.i('Background location permission result: $status');
      return status.isGranted;
    } catch (e) {
      AppLogger.e('Error requesting background location permission: $e');
      return false;
    }
  }

  /// Check if we have permission for real-time tracking
  /// Returns true if we have "while using" or "always" permission
  Future<bool> hasTrackingPermission() async {
    try {
      final permission = await checkPermission();

      final hasPermission = permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      AppLogger.d('Has tracking permission: $hasPermission');
      return hasPermission;
    } catch (e) {
      AppLogger.e('Error checking tracking permission: $e');
      return false;
    }
  }

  /// Check if we have background location permission
  Future<bool> hasBackgroundPermission() async {
    try {
      final permission = await checkPermission();
      final hasPermission = permission == LocationPermission.always;

      AppLogger.d('Has background permission: $hasPermission');
      return hasPermission;
    } catch (e) {
      AppLogger.e('Error checking background permission: $e');
      return false;
    }
  }

  /// Complete permission flow for real-time tracking
  /// 1. Check location service
  /// 2. Request foreground permission
  /// 3. Optionally request background permission
  Future<LocationPermissionResult> requestTrackingPermissions({
    required BuildContext context,
    bool requireBackground = true,
  }) async {
    try {
      // Step 1: Check if location services are enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppLogger.w('Location services are disabled');
        return LocationPermissionResult(
          success: false,
          error: LocationPermissionError.serviceDisabled,
          message: 'Please enable location services in your device settings',
        );
      }

      // Step 2: Check current permission
      LocationPermission permission = await checkPermission();

      // Step 3: If denied, request permission
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
      }

      // Step 4: Handle permanent denial
      if (permission == LocationPermission.deniedForever) {
        AppLogger.w('Location permission denied forever');
        return LocationPermissionResult(
          success: false,
          error: LocationPermissionError.deniedForever,
          message: 'Location permission is permanently denied. Please enable it in app settings.',
        );
      }

      // Step 5: Check if we got at least "while using" permission
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        AppLogger.w('Location permission denied by user');
        return LocationPermissionResult(
          success: false,
          error: LocationPermissionError.denied,
          message: 'Location permission is required for real-time tracking',
        );
      }

      // Step 6: Request background permission if required
      bool hasBackground = permission == LocationPermission.always;

      if (requireBackground && !hasBackground) {
        AppLogger.i('Requesting background location permission...');
        hasBackground = await requestBackgroundPermission();

        if (!hasBackground) {
          AppLogger.w('Background permission not granted, tracking may stop when app is backgrounded');
        }
      }

      AppLogger.i('✅ Location permissions granted successfully');
      return LocationPermissionResult(
        success: true,
        hasBackgroundPermission: hasBackground,
        message: 'Location permissions granted',
      );
    } catch (e, stack) {
      AppLogger.e('Error in requestTrackingPermissions: $e');
      AppLogger.e('Stack trace: $stack');

      return LocationPermissionResult(
        success: false,
        error: LocationPermissionError.unknown,
        message: 'An error occurred while requesting location permissions',
      );
    }
  }

  /// Open app settings for user to manually grant permissions
  Future<bool> openAppSettings() async {
    try {
      AppLogger.i('Opening app settings...');
      final opened = await Geolocator.openAppSettings();
      AppLogger.d('App settings opened: $opened');
      return opened;
    } catch (e) {
      AppLogger.e('Error opening app settings: $e');
      return false;
    }
  }

  /// Open location settings for user to enable GPS
  Future<bool> openLocationSettings() async {
    try {
      AppLogger.i('Opening location settings...');
      final opened = await Geolocator.openLocationSettings();
      AppLogger.d('Location settings opened: $opened');
      return opened;
    } catch (e) {
      AppLogger.e('Error opening location settings: $e');
      return false;
    }
  }

  /// Check battery optimization status (important for background tracking)
  Future<bool> isBatteryOptimizationDisabled() async {
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      final isDisabled = status.isGranted;

      AppLogger.d('Battery optimization disabled: $isDisabled');
      return isDisabled;
    } catch (e) {
      AppLogger.e('Error checking battery optimization: $e');
      return false;
    }
  }

  /// Request to disable battery optimization for reliable background tracking
  Future<bool> requestDisableBatteryOptimization() async {
    try {
      AppLogger.i('Requesting to disable battery optimization...');
      final status = await Permission.ignoreBatteryOptimizations.request();

      AppLogger.i('Battery optimization request result: $status');
      return status.isGranted;
    } catch (e) {
      AppLogger.e('Error requesting battery optimization exemption: $e');
      return false;
    }
  }

  /// Get user-friendly permission status message
  String getPermissionStatusMessage(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.denied:
        return 'Location permission denied. Tap to grant permission.';
      case LocationPermission.deniedForever:
        return 'Location permission permanently denied. Please enable in settings.';
      case LocationPermission.whileInUse:
        return 'Location allowed while using the app';
      case LocationPermission.always:
        return 'Location allowed always (including background)';
      default:
        return 'Location permission status unknown';
    }
  }
}

/// Result of location permission request
class LocationPermissionResult {
  final bool success;
  final bool hasBackgroundPermission;
  final LocationPermissionError? error;
  final String message;

  LocationPermissionResult({
    required this.success,
    this.hasBackgroundPermission = false,
    this.error,
    required this.message,
  });

  @override
  String toString() {
    return 'LocationPermissionResult(success: $success, hasBackground: $hasBackgroundPermission, error: $error, message: $message)';
  }
}

/// Location permission error types
enum LocationPermissionError {
  serviceDisabled,
  denied,
  deniedForever,
  unknown,
}
