import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/services/tracking_coordinator.dart';

/// Tracking Controls Widget
/// Displays tracking information and auto-stop notice
/// (Pause/Stop buttons removed - tracking auto-stops when all directories are visited)
class TrackingControlsWidget extends StatefulWidget {
  const TrackingControlsWidget({super.key});

  @override
  State<TrackingControlsWidget> createState() => _TrackingControlsWidgetState();
}

class _TrackingControlsWidgetState extends State<TrackingControlsWidget> {
  TrackingStats? _currentStats;

  @override
  void initState() {
    super.initState();
    _subscribeToStats();
  }

  void _subscribeToStats() {
    TrackingCoordinator.instance.onStatsChanged.listen((stats) {
      if (mounted) {
        setState(() {
          _currentStats = stats;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!TrackingCoordinator.instance.isTracking) {
      return const SizedBox.shrink();
    }

    final visitedCount = _currentStats?.visitedDirectories ?? 0;
    final totalCount = _currentStats?.totalDirectories ?? 0;
    final hasProgress = totalCount > 0;
    final progressPercent = hasProgress
        ? ((visitedCount / totalCount) * 100).round()
        : 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.success.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress Section
          if (hasProgress) ...[
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.location_on,
                    size: 24.sp,
                    color: AppColors.success,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visit Progress',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '$visitedCount of $totalCount directories',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Progress Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '$progressPercent%',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: LinearProgressIndicator(
                value: visitedCount / totalCount,
                minHeight: 8.h,
                backgroundColor: AppColors.greyLight,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
              ),
            ),
            SizedBox(height: 12.h),
            Divider(height: 1, color: AppColors.greyLight),
            SizedBox(height: 12.h),
          ],

          // Auto-Stop Notice
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  hasProgress && visitedCount == totalCount
                      ? 'All directories visited! Tracking will stop automatically.'
                      : 'Tracking will automatically stop when all directories are visited.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
