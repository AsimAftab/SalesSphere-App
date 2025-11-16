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
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        // Gradient background using app theme colors
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary, // Main blue
            AppColors.secondary, // Secondary blue/accent
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header section (Icon, Title, Percentage)
          Row(
            children: [
              Icon(
                Icons.navigation_outlined,
                color: Colors.white,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Route Progress',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(), // Pushes percentage to the right
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15), // Light pill background
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '$progressPercentage%',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Progress bar
          Stack(
            children: [
              // Track
              Container(
                height: 8.h,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2), // Darker track
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              // Progress
              FractionallySizedBox(
                widthFactor: progressPercentage / 100,
                child: Container(
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: Colors.white, // White progress bar
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Statistics row
          Row(
            children: [
              _buildStatColumn(
                label: 'Total',
                value: totalParties.toString(),
              ),
              _buildStatColumn(
                label: 'Visited',
                value: visitedParties.toString(),
              ),
              _buildStatColumn(
                label: 'Pending',
                value: pendingParties.toString(),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Auto-stop notice
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18.sp,
                  color: Colors.white,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    visitedParties == totalParties && totalParties > 0
                        ? 'All directories visited! Tracking will stop automatically.'
                        : 'Tracking will automatically stop when all directories are visited.',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Simplified helper widget for stats, matching the modern gradient design
  Widget _buildStatColumn({
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white.withValues(alpha: 0.7), // Lighter white for label
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
