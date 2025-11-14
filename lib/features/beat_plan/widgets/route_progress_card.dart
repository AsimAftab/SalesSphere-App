import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';

/// Route Progress Card
/// Displays beat plan progress summary with total/visited/pending statistics
class RouteProgressCard extends StatelessWidget {
  final int totalParties;
  final int visitedParties;
  final int pendingParties;
  final int progressPercentage;

  const RouteProgressCard({
    super.key,
    required this.totalParties,
    required this.visitedParties,
    required this.pendingParties,
    required this.progressPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.05),
            AppColors.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header section with gradient
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.secondary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.route_rounded,
                    size: 26.sp,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Route Progress',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Text(
                            '$progressPercentage%',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: _getProgressColor(),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Complete',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Progress bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Stack(
              children: [
                Container(
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progressPercentage / 100,
                  child: Container(
                    height: 8.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getProgressColor(),
                          _getProgressColor().withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: _getProgressColor().withValues(alpha: 0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Statistics row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w).copyWith(bottom: 20.h),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatColumn(
                    label: 'Total',
                    value: totalParties.toString(),
                    color: AppColors.primary,
                    icon: Icons.location_on_rounded,
                  ),
                ),
                Container(
                  width: 1.w,
                  height: 50.h,
                  color: AppColors.greyLight,
                ),
                Expanded(
                  child: _buildStatColumn(
                    label: 'Visited',
                    value: visitedParties.toString(),
                    color: AppColors.success,
                    icon: Icons.check_circle_rounded,
                  ),
                ),
                Container(
                  width: 1.w,
                  height: 50.h,
                  color: AppColors.greyLight,
                ),
                Expanded(
                  child: _buildStatColumn(
                    label: 'Pending',
                    value: pendingParties.toString(),
                    color: AppColors.warning,
                    icon: Icons.schedule_rounded,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            size: 20.sp,
            color: color,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getProgressColor() {
    if (progressPercentage == 100) return AppColors.success;
    if (progressPercentage >= 50) return AppColors.secondary;
    return AppColors.warning;
  }
}
