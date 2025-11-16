import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/services/tracking_coordinator.dart';
import 'package:sales_sphere/features/beat_plan/models/beat_plan.models.dart';

/// Beat Plan Summary Card
/// Displays minimal beat plan information for list view with modern, clean design
class BeatPlanSummaryCard extends StatefulWidget {
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
  State<BeatPlanSummaryCard> createState() => _BeatPlanSummaryCardState();
}

class _BeatPlanSummaryCardState extends State<BeatPlanSummaryCard> {
  StreamSubscription<TrackingState>? _trackingStateSubscription;

  @override
  void initState() {
    super.initState();
    // Listen to tracking state changes to hide/show button
    _trackingStateSubscription = TrackingCoordinator.instance.onStateChanged.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _trackingStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine status and colors
    final status = widget.beatPlan.status.toLowerCase();
    final statusColor = _getStatusColor(status);
    final progressColor = _getProgressColor(status, widget.beatPlan.progressPercentage);
    final statusText = _getStatusText(status);

    // Check if tracking is active for this beat plan
    final isTrackingThisPlan = TrackingCoordinator.instance.isTracking &&
        TrackingCoordinator.instance.currentBeatPlanId == widget.beatPlan.id;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wrap main content (not button) with GestureDetector for navigation
          GestureDetector(
            onTap: widget.onTap,
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Name + Status badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.beatPlan.name,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Simplified Status badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 14.h),

                // Date information
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Assigned: ${_formatDate(widget.beatPlan.assignedDate)}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // Started time if available
                if ((status == 'in-progress' || status == 'active') && widget.beatPlan.startedAt != null) ...[
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined, // Clock icon
                        size: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Started: ${_formatDate(widget.beatPlan.startedAt!)}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],

                SizedBox(height: 16.h),

                // Progress section
                Row(
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${widget.beatPlan.progressPercentage}%',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: progressColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                // Simplified progress bar
                Stack(
                  children: [
                    // Track
                    Container(
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: AppColors.greyLight.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    // Progress
                    FractionallySizedBox(
                      widthFactor: widget.beatPlan.progressPercentage / 100,
                      child: Container(
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: progressColor, // Solid color
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Stats & Action Button Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Wrap stats in Expanded to prevent overflow
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStat(
                      label: 'Total',
                      value: widget.beatPlan.totalDirectories.toString(),
                    ),
                    _buildStat(
                      label: 'Visited',
                      value: widget.beatPlan.visitedDirectories.toString(),
                      valueColor: AppColors.success,
                    ),
                    _buildStat(
                      label: 'Pending',
                      value: widget.beatPlan.unvisitedDirectories.toString(),
                      valueColor: AppColors.warning,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              // Action Button (no icon, not full-width) - hide when tracking is active
              if (!isTrackingThisPlan) _buildActionButton(status, statusColor),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the action button based on the beat plan status
  Widget _buildActionButton(String status, Color statusColor) {
    if (status == 'pending' && widget.onStartBeatPlan != null) {
      // "Start Beat Plan" Button
      return ElevatedButton(
        onPressed: widget.isLoadingStart ? null : widget.onStartBeatPlan,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.secondary.withValues(alpha: 0.6),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: widget.isLoadingStart
            ? SizedBox(
                height: 20.h,
                width: 20.w,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                'Start Beat Plan',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      );
    } else if (status == 'completed') {
      // "View Details" Button
      return OutlinedButton(
        onPressed: widget.onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(
            color: AppColors.greyLight.withValues(alpha: 0.9),
            width: 1.5,
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: Text(
          'View Details',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      // "Beat Plan" (In Progress) Button
      return ElevatedButton(
        onPressed: widget.onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: statusColor, // Uses status color (blue)
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: Text(
          'Beat Plan',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
  }

  /// Builds a single stat column (e.g., Total, Visited, Pending)
  Widget _buildStat({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500
          ),
        ),
      ],
    );
  }

  // --- Helper Functions ---

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
      case 'in-progress':
        return AppColors.primary; // Blue for 'In Progress'
      case 'completed':
        return AppColors.success; // Green for 'Completed'
      case 'pending':
        return AppColors.warning; // Orange for 'Pending'
      default:
        return AppColors.greyMedium;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'in-progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      default:
        return status;
    }
  }

  Color _getProgressColor(String status, int percentage) {
    if (status == 'completed' || percentage == 100) return AppColors.success;
    if (status == 'in-progress' || status == 'active') return AppColors.secondary;
    // For pending (0%), the widthFactor will be 0, so color doesn't matter
    return AppColors.greyLight;
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      // Format as "Nov 14, 2024"
      return DateFormat('MMM d, y').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
