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
    // OPTIMIZED: Skip expensive network calls during startup
    // Just check if token exists locally (super fast)
    final tokenStorage = ref.read(tokenStorageServiceProvider);
    final hasToken = await tokenStorage.hasToken();

    if (hasToken) {
      // Token exists - try to load cached user data
      final user = await _loadCachedUser();
      AppLogger.i('✅ Loaded cached user data: ${user?.name ?? "none"}');

      return AppStartupState(
        hasInternet: true, // Assume true, check lazily later
        user: user,
      );
    }

    // No token - user needs to login
    AppLogger.i('ℹ️ No token found - showing login');
    return const AppStartupState(hasInternet: true);
  }

  // Load user from cached storage (no network call)
  Future<User?> _loadCachedUser() async {
    try {
      final tokenStorage = ref.read(tokenStorageServiceProvider);
      final userDataMap = await tokenStorage.getUserData();

      if (userDataMap != null) {
        final user = User.fromJson(userDataMap);

        // Update global user controller
        ref.read(userControllerProvider.notifier).setUser(user);

        return user;
      }
    } catch (e) {
      AppLogger.e('❌ Error loading cached user', e);
    }
    return null;
  }

  // Token validation with network call (used later, not on startup)
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
