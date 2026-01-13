import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';

/// Widget to show when user doesn't have permission to access a feature
class PermissionDeniedWidget extends StatelessWidget {
  final String? message;
  final String? feature;
  final VoidCallback? onRetry;

  const PermissionDeniedWidget({
    super.key,
    this.message,
    this.feature,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final displayMessage = message ??
        'You don\'t have permission to access ${feature ?? 'this feature'}';

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lock Icon
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline,
                size: 60.sp,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 24.h),

            // Title
            Text(
              'Access Denied',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),

            // Message
            Text(
              displayMessage,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),

            // Additional Info
            Text(
              'Please contact your administrator to request access',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textHint,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            // Retry Button (optional)
            if (onRetry != null) ...[
              SizedBox(height: 32.h),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh, size: 18.sp),
                label: Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
