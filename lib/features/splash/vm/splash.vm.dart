import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/network_layer/token_storage_service.dart';
import 'package:sales_sphere/core/providers/shared_prefs_provider.dart';
import 'package:sales_sphere/core/providers/user_controller.dart';
import 'package:sales_sphere/core/router/route_handler.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/auth/models/login.models.dart';

part 'splash.vm.g.dart';

@riverpod
class SplashVM extends _$SplashVM {
  Timer? _navigationTimer;
  bool _tokenValidated = false;
  bool _isLoggedIn = false;

  @override
  bool build() {
    // Dispose timer when provider is disposed
    ref.onDispose(() {
      _navigationTimer?.cancel();
    });

    // Start background token validation AND timer
    Future.microtask(() {
      _validateTokenInBackground();
      _startNavigationTimer();
    });

    return true; // Return a boolean state
  }

  // Validate token in background while splash animations play
  Future<void> _validateTokenInBackground() async {
    try {
      final tokenStorage = ref.read(tokenStorageServiceProvider);
      final token = await tokenStorage.getToken();

      if (token != null) {
        // Check if session has expired locally first
        final isExpired = await tokenStorage.isSessionExpired();
        if (isExpired) {
          AppLogger.w('⚠️ Session expired locally');
          await tokenStorage.clearAuthData();
          _tokenValidated = true;
          _isLoggedIn = false;
          return;
        }

        // Validate with server
        try {
          AppLogger.i('🔍 Validating token in background...');
          final dio = ref.read(dioClientProvider);
          final response = await dio.get(ApiEndpoints.checkStatus);

          if (response.statusCode == 200 &&
              response.data['status'] == 'success') {
            final checkStatusResponse = CheckStatusResponse.fromJson(
              response.data,
            );
            final user = checkStatusResponse.data.user;

            // Save user data
            await tokenStorage.saveUserData(user.toJson());
            if (user.sessionExpiresAt != null) {
              await tokenStorage.saveSessionExpiresAt(user.sessionExpiresAt!);
            }

            // Update user controller
            ref.read(userControllerProvider.notifier).setUser(user);

            _isLoggedIn = true;
            AppLogger.i('✅ Token valid! User: ${user.name}');
          } else {
            AppLogger.w('⚠️ Token invalid - clearing');
            await tokenStorage.clearAuthData();
            _isLoggedIn = false;
          }
        } catch (e) {
          AppLogger.e('❌ Token validation failed', e);
          await tokenStorage.clearAuthData();
          _isLoggedIn = false;
        }
      } else {
        AppLogger.i('ℹ️ No token found');
        _isLoggedIn = false;
      }

      _tokenValidated = true;
    } catch (e) {
      AppLogger.e('❌ Error in token validation', e);
      _tokenValidated = true;
      _isLoggedIn = false;
    }
  }

  void _startNavigationTimer() {
    // Cancel any existing timer
    _navigationTimer?.cancel();

    // 2.5s for animations + token validation
    _navigationTimer = Timer(const Duration(milliseconds: 2500), () {
      _navigateToNextScreen();
    });
  }

  void _navigateToNextScreen() {
    try {
      final prefs = ref.read(sharedPrefsProvider);
      final router = ref.read(goRouterProvider);

      // Check if user has seen onboarding
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      // Use validated token state (from background validation)
      // If validation isn't done yet, use cached value
      final isLoggedIn = _tokenValidated
          ? _isLoggedIn
          : (prefs.getBool('is_logged_in') ?? false);

      // Debug logging
      AppLogger.i('🔍 Splash Navigation Check:');
      AppLogger.i('   hasSeenOnboarding: $hasSeenOnboarding');
      AppLogger.i('   isLoggedIn: $isLoggedIn');
      AppLogger.i('   tokenValidated: $_tokenValidated');

      // Navigation logic
      if (!hasSeenOnboarding) {
        // First time user → Go to onboarding
        AppLogger.i('📱 Navigating to: /onboarding (first time user)');
        router.go('/onboarding');
      } else if (!isLoggedIn) {
        // Seen onboarding but not logged in → Go to login
        AppLogger.i('📱 Navigating to: / (login)');
        router.go('/');
      } else {
        // Logged in user → Go to home
        AppLogger.i('📱 Navigating to: /home');
        router.go('/home');
      }
    } catch (e) {
      // If error occurs, default to onboarding
      AppLogger.e('❌ Error in splash navigation', e);
      final router = ref.read(goRouterProvider);
      router.go('/onboarding');
    }
  }

  // Manual skip (if you want to add a skip button later)
  void skipToNextScreen() {
    _navigationTimer?.cancel();
    _navigateToNextScreen();
  }
}
