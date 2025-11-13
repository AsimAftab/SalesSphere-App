import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/providers/shared_prefs_provider.dart';
import 'package:sales_sphere/core/router/route_handler.dart';

part 'splash.vm.g.dart';

@riverpod
class SplashVM extends _$SplashVM {
  Timer? _navigationTimer;

  @override
  bool build() {
    // Dispose timer when provider is disposed
    ref.onDispose(() {
      _navigationTimer?.cancel();
    });

    // Start navigation timer after build completes
    Future.microtask(() => _startNavigationTimer());

    return true; // Return a boolean state
  }

  void _startNavigationTimer() {
    // Cancel any existing timer
    _navigationTimer?.cancel();

    // Wait 2.5 seconds (enough for animations to complete)
    _navigationTimer = Timer(const Duration(milliseconds: 4000), () {
      _navigateToNextScreen();
    });
  }

  void _navigateToNextScreen() {
    try {
      final prefs = ref.read(sharedPrefsProvider);
      final router = ref.read(goRouterProvider);

      // Check if user has seen onboarding
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      // Check if user is logged in
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      // Navigation logic
      if (!hasSeenOnboarding) {
        // First time user → Go to onboarding
        router.go('/onboarding');
      } else if (!isLoggedIn) {
        // Seen onboarding but not logged in → Go to login
        router.go('/');
      } else {
        // Logged in user → Go to home
        router.go('/home');
      }
    } catch (e) {
      // If error occurs, default to onboarding
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