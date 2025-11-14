import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/providers/app_startup.dart';

/// No Internet Connection Screen
/// Displayed when app starts without internet connectivity or when features lose connection
class NoInternetScreen extends ConsumerWidget {
  final VoidCallback? onRetry;

  const NoInternetScreen({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Cloud with lightning icon
                Container(
                  width: 200.w,
                  height: 200.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Cloud icon
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 120.sp,
                        color: AppColors.error.withValues(alpha: 0.8),
                      ),
                      // Small decorative elements
                      Positioned(
                        top: 40.h,
                        right: 30.w,
                        child: Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 60.h,
                        left: 25.w,
                        child: Icon(
                          Icons.star,
                          size: 12.sp,
                          color: AppColors.secondary.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 48.h),

                // Title
                Text(
                  'Ooops!',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 12.h),

                // Subtitle
                Text(
                  'No Internet Connection found',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 8.h),

                // Description
                Text(
                  'Check your connection',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 48.h),

                // Retry Button
                SizedBox(
                  width: 200.w,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if (onRetry != null) {
                        onRetry!();
                      } else {
                        // Default: Invalidate app startup to re-check connectivity
                        ref.invalidate(appStartupProvider);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                    ),
                    child: Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
