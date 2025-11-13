import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/features/onboarding/vm/onboarding.vm.dart';
import 'package:sales_sphere/widget/onboarding_screen_widget.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  String _getWaveSvgPath(int currentPage) {
    switch (currentPage) {
      case 0:
        return 'assets/images/onboarding_first_page_wave.svg';
      case 1:
        return 'assets/images/onboarding_second_page_wave.svg';
      case 2:
        return 'assets/images/onboarding_third_page_wave.svg';
      default:
        return 'assets/images/onboarding_first_page_wave.svg';
    }
  }

  // Get wave height based on current page
  double _getWaveHeight(int currentPage) {
    switch (currentPage) {
      case 0:
        return 250.h; // First page
      case 1:
        return 170.h; // Second page
      case 2:
        return 250.h; // Third page
      default:
        return 250.h;
    }
  }

  // Get header section height based on current page
  double _getHeaderHeight(int currentPage) {
    switch (currentPage) {
      case 0:
        return 160.h; // First page header
      case 1:
        return 40.h;  // Second page header
      case 2:
        return 160.h; // Third page header
      default:
        return 160.h;
    }
  }

  // Determine if should show header text
  bool _shouldShowHeaderText(int currentPage) {
    return currentPage == 0 || currentPage == 2;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingVMProvider);
    final vm = ref.read(onboardingVMProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // === WAVE BACKGROUND (All Pages) ===
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              _getWaveSvgPath(state.currentPage),
              fit: BoxFit.fill,
              width: MediaQuery.of(context).size.width,
              height: _getWaveHeight(state.currentPage),
            ),
          ),

          // === MAIN CONTENT ===
          SafeArea(
            child: Column(
              children: [
                // === TOP SECTION: Header (NO Skip Button) ===
                SizedBox(
                  height: _getHeaderHeight(state.currentPage),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                  ),
                ),

                // === PAGEVIEW (Main Content) ===
                Expanded(
                  child: PageView.builder(
                    controller: state.pageController,
                    itemCount: state.pages.length,
                    onPageChanged: vm.onPageChanged,
                    itemBuilder: (context, index) {
                      return OnboardingPageWidget(
                        pageModel: state.pages[index],
                        pageIndex: index,
                      );
                    },
                  ),
                ),

                // === BOTTOM CONTROLS ===
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 20.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ✅ ADDED: Skip button on bottom-left (pages 0 and 1 only)
                      SizedBox(
                        width: 50.w,
                        child: state.currentPage < 2 // Show skip on pages 0 and 1
                            ? TextButton(
                          onPressed: vm.onSkipPressed,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        )
                            : const SizedBox.shrink(), // No skip on page 3
                      ),

                      // Page Indicator Dots (center)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          state.pages.length,
                              (index) {
                            final isActive = state.currentPage == index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              width: isActive ? 28.w : 8.w,
                              height: 8.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.r),
                                color: isActive
                                    ? AppColors.primary
                                    : AppColors.primary.withValues(alpha: 0.25),
                              ),
                            );
                          },
                        ),
                      ),

                      // Next/Get Started button (right)
                      TextButton(
                        onPressed: vm.onNextPressed,
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: state.currentPage == state.pages.length - 1
                                ? 16.w // Shorter padding for "Get Started"
                                : 24.w,
                            vertical: 10.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          state.currentPage == state.pages.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}