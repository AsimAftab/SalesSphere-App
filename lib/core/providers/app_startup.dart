import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/network_layer/token_storage_service.dart';
import 'package:sales_sphere/core/providers/connectivity_provider.dart';
import 'package:sales_sphere/core/providers/user_controller.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/auth/models/login.models.dart';

part 'app_startup.g.dart';

/// App Startup State
/// Represents the result of app initialization
class AppStartupState {
  final bool hasInternet;
  final User? user;

  const AppStartupState({
    required this.hasInternet,
    this.user,
  });
}

/// App Startup Provider
/// Runs ONCE on app launch to:
/// 1. Check connectivity
/// 2. Validate stored token (if connected)
@Riverpod(keepAlive: true)
class AppStartup extends _$AppStartup {
  @override
  Future<AppStartupState> build() async {
    // Step 1: Check connectivity
    final hasInternet = await ref.read(checkInitialConnectivityProvider.future);

    // Step 2: If no internet, return state with no user
    if (!hasInternet) {
      AppLogger.w('⚠️ No internet connection - skipping token validation');
      return const AppStartupState(hasInternet: false);
    }

    // Step 3: Validate token
    final user = await _validateToken();

    return AppStartupState(
      hasInternet: true,
      user: user,
    );
  }

  Future<User?> _validateToken() async {
    final tokenStorage = ref.read(tokenStorageServiceProvider);
    final token = await tokenStorage.getToken();

    if (token != null) {
      // Check if session has expired
      final isExpired = await tokenStorage.isSessionExpired();
      if (isExpired) {
        AppLogger.w('⚠️ Session has expired. Forcing logout...');
        await tokenStorage.clearAuthData();
        return null;
      }

      try {
        AppLogger.i('🔍 Checking token validity...');
        final dio = ref.read(dioClientProvider);
        final response = await dio.get(ApiEndpoints.checkStatus);

        // Check-status endpoint returns: {status: "success", message: "Token is valid.", data: {user}}
        if (response.statusCode == 200 && response.data['status'] == 'success') {
          final checkStatusResponse = CheckStatusResponse.fromJson(response.data);
          final user = checkStatusResponse.data.user;

          // Save session expiry date if present
          if (user.sessionExpiresAt != null) {
            await tokenStorage.saveSessionExpiresAt(user.sessionExpiresAt!);
            AppLogger.i('✅ Session expires at: ${user.sessionExpiresAt}');
          }

          // Save user data to SharedPreferences
          await tokenStorage.saveUserData(user.toJson());

          // Update global user controller
          ref.read(userControllerProvider.notifier).setUser(user);

          AppLogger.i('✅ Token is valid! User restored: ${user.name}');
          AppLogger.i('📱 Auto-login successful. Redirecting to home...');

          // Return the validated user
          return user;
        } else {
          AppLogger.w('⚠️ Token validation failed');
          await tokenStorage.clearAuthData();
        }
      } catch (e, stack) {
        AppLogger.e('❌ Token validation failed', e, stack);
        // Clear invalid token
        await tokenStorage.clearAuthData();
      }
    } else {
      AppLogger.i('ℹ️ No saved token found. Please login.');
    }

    // No valid token
    return null;
  }
}
