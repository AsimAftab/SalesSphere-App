import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/features/beat_plan/models/beat_plan.models.dart';

/// Beat Plan Summary Card
/// Displays minimal beat plan information for list view
class BeatPlanSummaryCard extends StatelessWidget {
  final BeatPlanSummary beatPlan;
  final VoidCallback? onTap;
  final VoidCallback? onStartBeatPlan;
  final bool isLoadingStart;

  const BeatPlanSummaryCard({
    super.key,
    required this.beatPlan,
    this.onTap,
    this.onStartBeatPlan,
    this.isLoadingStart = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: _getStatusColor().withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor().withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Column(
          children: [
            // Colored header stripe
            Container(
              height: 5.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getStatusColor(),
                    _getStatusColor().withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Wrap card content (not button) with GestureDetector
                  GestureDetector(
                    onTap: onTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Name + Status badge
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                beatPlan.name,
                                style: TextStyle(
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            // Status badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _getStatusColor().withValues(alpha: 0.2),
                                    _getStatusColor().withValues(alpha: 0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: _getStatusColor().withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6.w,
                                    height: 6.w,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    _getStatusText(),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: _getStatusColor(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 18.h),

                        // Progress indicator
                        Row(
                          children: [
                            // Circular progress
                            SizedBox(
                              width: 50.w,
                              height: 50.w,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: beatPlan.progressPercentage / 100,
                                    strokeWidth: 5.w,
                                    backgroundColor: AppColors.greyLight,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _getProgressColor(),
                                    ),
                                  ),
                                  Text(
                                    '${beatPlan.progressPercentage}%',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(width: 16.w),

                            // Stats
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStat(
                                    label: 'Total',
                                    value: beatPlan.totalDirectories.toString(),
                                    color: AppColors.primary,
                                  ),
                                  _buildStat(
                                    label: 'Visited',
                                    value: beatPlan.visitedDirectories.toString(),
                                    color: AppColors.success,
                                  ),
                                  _buildStat(
                                    label: 'Pending',
                                    value: beatPlan.unvisitedDirectories.toString(),
                                    color: AppColors.warning,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 14.h),

                        // Assigned date
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Assigned: ${_formatDate(beatPlan.assignedDate)}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        // Started/Completed time if available
                        if (beatPlan.startedAt != null || beatPlan.completedAt != null) ...[
                          SizedBox(height: 8.h),
                          if (beatPlan.startedAt != null)
                            Row(
                              children: [
                                Icon(
                                  Icons.play_circle_outline_rounded,
                                  size: 14.sp,
                                  color: AppColors.info,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'Started: ${_formatDate(beatPlan.startedAt!)}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          if (beatPlan.completedAt != null)
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 14.sp,
                                  color: AppColors.success,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'Completed: ${_formatDate(beatPlan.completedAt!)}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ],
                    ),
                  ),

                  // Start Beat Plan button (outside GestureDetector, wrapped in AbsorbPointer)
                  if (onStartBeatPlan != null) ...[
                    SizedBox(height: 18.h),
                    AbsorbPointer(
                      absorbing: false,
                      child: GestureDetector(
                        onTap: () {
                          // Prevent tap propagation to parent
                        },
                        child: ElevatedButton(
                          onPressed: isLoadingStart ? null : onStartBeatPlan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.secondary.withValues(alpha: 0.6),
                            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 24.w),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 2,
                            shadowColor: AppColors.shadow,
                          ),
                          child: isLoadingStart
                              ? SizedBox(
                                  height: 20.h,
                                  width: 20.w,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.play_arrow_rounded,
                                      size: 20.sp,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Start Beat Plan',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (beatPlan.status.toLowerCase()) {
      case 'active':
      case 'in-progress':
        return AppColors.secondary;
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.greyMedium;
    }
  }

  String _getStatusText() {
    switch (beatPlan.status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'in-progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      default:
        return beatPlan.status;
    }
  }

  Color _getProgressColor() {
    if (beatPlan.progressPercentage == 100) return AppColors.success;
    if (beatPlan.progressPercentage >= 50) return AppColors.secondary;
    return AppColors.warning;
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
