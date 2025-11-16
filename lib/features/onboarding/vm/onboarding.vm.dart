import 'dart:async';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/providers/shared_prefs_provider.dart';
import 'package:sales_sphere/core/router/route_handler.dart';

import 'package:sales_sphere/features/onboarding/models/onboarding.model.dart';

part 'onboarding.vm.g.dart';

@riverpod
class OnboardingVM extends _$OnboardingVM {
  Timer? _autoAdvanceTimer;

  @override
  OnboardingState build() {
    final controller = PageController();

    // Schedule cleanup safely
    ref.onDispose(() {
      _autoAdvanceTimer?.cancel();
      controller.dispose(); // use local variable, not state
    });

    // Schedule timer start after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoAdvanceTimer();
    });

    return OnboardingState(
      currentPage: 0,
      pageController: PageController(),
      pages: const [
        OnboardingModel(
          title: 'Welcome to SalesSphere!',
          description:
          'Your complete platform to manage sales, track leads, and plan your day. This is your new all-in-one sales toolkit.',
          imagePath: 'assets/images/onboarding_welcome.svg',
        ),
        OnboardingModel(
          title: 'Follow Your Beat Plan',
          description:
          'Never miss a customer visit. Easily see your daily route, manage your meetings, and check in at every location.',
          imagePath: 'assets/images/onboarding_beat_plan.svg',
        ),
        OnboardingModel(
          title: 'Track Your Performance',
          description:
          'Effortlessly log attendance and manage all your sales orders. Monitor your progress and achieve your goals with ease.',
          imagePath: 'assets/images/onboarding_performance.svg',
        ),
      ],
    );
  }

  // Start auto-advance timer
  void _startAutoAdvanceTimer() {
    // Cancel any existing timer
    _autoAdvanceTimer?.cancel();

    // Don't start timer on the last page
    if (state.currentPage >= state.pages.length - 1) {
      return;
    }

    // Start new timer for 4 seconds
    _autoAdvanceTimer = Timer(const Duration(seconds: 4), () {
      // Auto-advance to next page
      if (state.currentPage < state.pages.length - 1) {
        state.pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // onPageChanged
  void onPageChanged(int index) {
    state = state.copyWith(currentPage: index);
    _startAutoAdvanceTimer(); // Restart timer for new page
  }

  // onNextPressed
  void onNextPressed() {
    _autoAdvanceTimer?.cancel(); // Cancel auto-advance when user manually navigates

    if (state.currentPage < state.pages.length - 1) {
      state.pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to main app
      onComplete();
    }
  }

  // onSkipPressed
  void onSkipPressed() {
    _autoAdvanceTimer?.cancel(); // Cancel auto-advance when user skips
    onComplete();
  }

  void goToPage(int pageIndex) {
    _autoAdvanceTimer?.cancel(); // Cancel auto-advance when user manually navigates

    if (pageIndex >= 0 && pageIndex < state.pages.length) {
      state.pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Use router provider instead of ref.context
  Future<void> onComplete() async {
    _autoAdvanceTimer?.cancel(); // Cancel timer when completing

    try {
      // Mark onboarding as completed in SharedPreferences
      final prefs = ref.read(sharedPrefsProvider);
      await prefs.setBool('hasSeenOnboarding', true);

      // Get the router instance
      final router = ref.read(goRouterProvider);

      // Check if user is already logged in
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      if (isLoggedIn) {
        // Navigate to home if already logged in
        router.go('/home');
      } else {
        // Navigate to login screen
        router.go('/');
      }
    } catch (e) {
      // If there's an error, still navigate to login
      final router = ref.read(goRouterProvider);
      router.go('/');
    }
  }
}

// State class
class OnboardingState {
  final int currentPage;
  final PageController pageController;
  final List<OnboardingModel> pages;

  const OnboardingState({
    required this.currentPage,
    required this.pageController,
    required this.pages,
  });

  OnboardingState copyWith({
    int? currentPage,
    PageController? pageController,
    List<OnboardingModel>? pages,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      pageController: pageController ?? this.pageController,
      pages: pages ?? this.pages,
    );
  }
}