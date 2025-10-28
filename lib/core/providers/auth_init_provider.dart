import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sales_sphere/features/auth/models/login.models.dart';
import '../network_layer/token_storage_service.dart';
import '../utils/logger.dart';
import '../constants/storage_keys.dart';
import 'user_controller.dart';

part 'auth_init_provider.g.dart';

/// Auth Initialization Provider
/// Checks for stored token and user data on app startup
@riverpod
Future<bool> authInit(Ref ref) async {
  try {
    final tokenStorage = ref.read(tokenStorageServiceProvider);

    // Check if token exists
    final hasToken = await tokenStorage.hasToken();

    if (!hasToken) {
      AppLogger.i('ℹ️ No stored token found - User not logged in');
      return false;
    }

    // Token exists, now try to load user data
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(StorageKeys.userData);

    if (userDataString != null && userDataString.isNotEmpty) {
      try {
        // Parse stored user data
        final userMap = jsonDecode(userDataString) as Map<String, dynamic>;
        final user = User.fromJson(userMap);

        // Set user in controller
        ref.read(userControllerProvider.notifier).setUser(user);

        AppLogger.i('✅ User data loaded from storage: ${user.name}');
        return true;
      } catch (e, stack) {
        AppLogger.e('❌ Error parsing stored user data', e, stack);
        // Clear corrupted data
        await tokenStorage.clearAuthData();
        return false;
      }
    } else {
      AppLogger.w('⚠️ Token exists but no user data found - clearing auth');
      // Token exists but no user data, clear everything
      await tokenStorage.clearAuthData();
      return false;
    }
  } catch (e, stack) {
    AppLogger.e('❌ Error during auth initialization', e, stack);
    return false;
  }
}
