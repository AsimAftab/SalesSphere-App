import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import '../models/attendance.models.dart';
import '../vm/attendance.vm.dart';

class AttendanceDashboardScreen extends ConsumerWidget {
  const AttendanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAttendance = ref.watch(todayAttendanceViewModelProvider);
    final summary = ref.watch(attendanceSummaryViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Attendance',
          style: TextStyle(
            fontSize: 18.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Colors.white, size: 24.sp),
            onPressed: () => context.push('/attendance/history'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Card with gradient
            _buildHeaderCard(context, todayAttendance),

            SizedBox(height: 16.h),

            // Check-in/Check-out section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildCheckInOutSection(context, ref, todayAttendance),
            ),

            SizedBox(height: 24.h),

            // Summary Stats
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildSummaryStats(context, summary),
            ),

            SizedBox(height: 24.h),

            // Quick Actions
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildQuickActions(context),
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, TodayAttendance todayAttendance) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
      child: Column(
        children: [
          Text(
            dateFormat.format(now),
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: 16.h),
          _buildStatusCard(todayAttendance),
        ],
      ),
    );
  }

  Widget _buildStatusCard(TodayAttendance todayAttendance) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (!todayAttendance.isCheckedIn) {
      statusText = 'Not Checked In';
      statusColor = AppColors.warning;
      statusIcon = Icons.access_time;
    } else if (todayAttendance.isCheckedIn && !todayAttendance.isCheckedOut) {
      statusText = 'Checked In';
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle;
    } else {
      statusText = 'Checked Out';
      statusColor = AppColors.info;
      statusIcon = Icons.done_all;
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(statusIcon, size: 48.sp, color: statusColor),
          SizedBox(height: 12.h),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 20.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
          if (todayAttendance.checkInTime != null) ...[
            SizedBox(height: 8.h),
            Text(
              'Check-in: ${DateFormat('hh:mm a').format(todayAttendance.checkInTime!)}',
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: 'Poppins',
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (todayAttendance.checkOutTime != null) ...[
            SizedBox(height: 4.h),
            Text(
              'Check-out: ${DateFormat('hh:mm a').format(todayAttendance.checkOutTime!)}',
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: 'Poppins',
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckInOutSection(
    BuildContext context,
    WidgetRef ref,
    TodayAttendance todayAttendance,
  ) {
    return Column(
      children: [
        if (!todayAttendance.isCheckedIn)
          PrimaryButton(
            label: 'Check In',
            leadingIcon: Icons.login,
            onPressed: () async {
              await ref.read(todayAttendanceViewModelProvider.notifier).checkIn();
            },
            size: ButtonSize.large,
          )
        else if (!todayAttendance.isCheckedOut)
          PrimaryButton(
            label: 'Check Out',
            leadingIcon: Icons.logout,
            onPressed: () async {
              await ref.read(todayAttendanceViewModelProvider.notifier).checkOut();
            },
            size: ButtonSize.large,
          )
        else
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 24.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s attendance completed',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                      Text(
                        'Hours worked: ${todayAttendance.hoursWorked}h',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: 'Poppins',
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryStats(BuildContext context, AttendanceSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This Month Summary',
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Present',
                '${summary.presentDays}',
                AppColors.success,
                Icons.check_circle,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                'Absent',
                '${summary.absentDays}',
                AppColors.error,
                Icons.cancel,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Late',
                '${summary.lateDays}',
                AppColors.warning,
                Icons.access_time,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                'Leave',
                '${summary.leaveDays}',
                AppColors.info,
                Icons.event_busy,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _buildFullStatCard(
          'Attendance %',
          '${summary.attendancePercentage.toStringAsFixed(1)}%',
          AppColors.primary,
          Icons.bar_chart,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24.sp, color: color),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'Poppins',
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32.sp, color: color),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Poppins',
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        _buildActionButton(
          context,
          'View History',
          'See your attendance calendar',
          Icons.calendar_month,
          () => context.push('/attendance/history'),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, size: 24.sp, color: AppColors.primary),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: 'Poppins',
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
