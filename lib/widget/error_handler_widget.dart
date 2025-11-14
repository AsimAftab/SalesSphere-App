import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/exceptions/offline_exception.dart';
import 'package:sales_sphere/widget/no_internet_screen.dart';

/// Error Handler Widget
/// Displays NoInternetScreen for OfflineException, generic error for others
class ErrorHandlerWidget extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  final String? title;
  final bool showAsScaffold;

  const ErrorHandlerWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.title,
    this.showAsScaffold = false,
  });

  /// Check if error is an offline error (typed OfflineException)
  bool _isOfflineError(Object error) {
    // Direct OfflineException
    if (error is OfflineException) {
      return true;
    }

    // DioException wrapping OfflineException
    if (error is DioException && error.error is OfflineException) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Check if error is due to no internet connection
    if (_isOfflineError(error)) {
      return NoInternetScreen(onRetry: onRetry);
    }

    // Show generic error for other errors
    final errorContent = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: AppColors.error.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            title ?? 'Something went wrong',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
          ],
        ],
      ),
    );

    if (showAsScaffold) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            title ?? 'Error',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: errorContent,
      );
    }

    return errorContent;
  }
}

/// Consumer variant for Riverpod-specific error handling
/// Uses a callback function to invalidate providers since Riverpod 3.0
/// doesn't have a single ProviderOrFamily type
class ErrorHandlerConsumer extends ConsumerWidget {
  final Object error;
  final void Function(WidgetRef ref) onRefresh;
  final String? title;
  final bool showAsScaffold;

  const ErrorHandlerConsumer({
    super.key,
    required this.error,
    required this.onRefresh,
    this.title,
    this.showAsScaffold = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ErrorHandlerWidget(
      error: error,
      onRetry: () => onRefresh(ref),
      title: title,
      showAsScaffold: showAsScaffold,
    );
  }
}
