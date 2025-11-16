import 'package:permission_handler/permission_handler.dart';
import 'package:sales_sphere/core/utils/logger.dart';

/// Notification Permission Service
/// Handles runtime notification permission for Android 13+ (API 33+)
class NotificationPermissionService {
  NotificationPermissionService._();
  static final NotificationPermissionService instance = NotificationPermissionService._();

  /// Request notification permission (Android 13+)
  /// Returns true if permission is granted, false otherwise
  Future<bool> requestPermission() async {
    try {
      // Check if permission is already granted
      final status = await Permission.notification.status;

      if (status.isGranted) {
        AppLogger.i('✅ Notification permission already granted');
        return true;
      }

      if (status.isPermanentlyDenied) {
        AppLogger.w('⚠️ Notification permission permanently denied');
        return false;
      }

      // Request permission
      AppLogger.i('📱 Requesting notification permission...');
      final result = await Permission.notification.request();

      if (result.isGranted) {
        AppLogger.i('✅ Notification permission granted');
        return true;
      } else if (result.isPermanentlyDenied) {
        AppLogger.w('⚠️ Notification permission permanently denied');
        return false;
      } else {
        AppLogger.w('⚠️ Notification permission denied');
        return false;
      }
    } catch (e, stack) {
      AppLogger.e('❌ Error requesting notification permission: $e', e, stack);
      return false;
    }
  }

  /// Check if notification permission is granted
  Future<bool> isGranted() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      AppLogger.e('❌ Error checking notification permission: $e');
      return false;
    }
  }

  /// Open app settings (if user permanently denied permission)
  Future<void> openSettings() async {
    try {
      AppLogger.i('📱 Opening app settings...');
      await openAppSettings();
    } catch (e) {
      AppLogger.e('❌ Error opening app settings: $e');
    }
  }
}
