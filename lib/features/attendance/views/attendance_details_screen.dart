import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import '../models/attendance.models.dart';

class AttendanceDetailsScreen extends ConsumerWidget {
  final AttendanceRecord record;

  const AttendanceDetailsScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color statusColor;
    IconData statusIcon;
    statusColor = record.status.backgroundColor;

    switch (record.status) {
      case AttendanceStatus.present:
        statusIcon = Icons.check_circle;
        break;
      case AttendanceStatus.absent:
        statusIcon = Icons.cancel;
        break;
      case AttendanceStatus.weeklyOff:
        statusIcon = Icons.weekend;
        break;
      case AttendanceStatus.onLeave:
        statusIcon = Icons.event_busy;
        break;
      case AttendanceStatus.halfDay:
        statusIcon = Icons.timelapse;
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Attendance Details',
          style: TextStyle(
            fontSize: 18.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, statusColor],
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
                  Icon(statusIcon, size: 64.sp, color: Colors.white),
                  SizedBox(height: 16.h),
                  Text(
                    record.status.displayName,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(record.date),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Details Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time Details
                  if (record.checkInTime != null || record.checkOutTime != null)
                    _buildDetailsCard(
                      context,
                      'Time Details',
                      [
                        if (record.checkInTime != null)
                          _buildDetailItem(
                            'Check-in Time',
                            DateFormat('hh:mm a').format(record.checkInTime!),
                            Icons.login,
                            AppColors.success,
                          ),
                        if (record.checkOutTime != null)
                          _buildDetailItem(
                            'Check-out Time',
                            DateFormat('hh:mm a').format(record.checkOutTime!),
                            Icons.logout,
                            AppColors.error,
                          ),
                        if (record.totalHoursWorked > 0)
                          _buildDetailItem(
                            'Hours Worked',
                            '${record.totalHoursWorked} hours',
                            Icons.schedule,
                            AppColors.primary,
                          ),
                      ],
                    ),

                  SizedBox(height: 16.h),

                  // Location Details
                  if (record.location != null)
                    _buildDetailsCard(
                      context,
                      'Location Details',
                      [
                        _buildDetailItem(
                          'Location',
                          record.location!,
                          Icons.location_on,
                          AppColors.info,
                        ),
                      ],
                    ),

                  SizedBox(height: 16.h),

                  // Status Details
                  _buildDetailsCard(
                    context,
                    'Status Information',
                    [
                      _buildDetailItem(
                        'Status',
                        record.status.displayName,
                        statusIcon,
                        statusColor,
                      ),
                      // Show notes only for Absent (informed leave), not for Leave (company holidays)
                      if (record.notes != null && record.status != AttendanceStatus.onLeave)
                        _buildDetailItem(
                          'Notes',
                          record.notes!,
                          Icons.note,
                          AppColors.warning,
                        ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Additional Info
                  _buildDetailsCard(
                    context,
                    'Additional Information',
                    [
                      _buildDetailItem(
                        'Date',
                        DateFormat('EEEE, MMM d, yyyy').format(record.date),
                        Icons.calendar_today,
                        AppColors.secondary,
                      ),
                      _buildDetailItem(
                        'Record ID',
                        record.id,
                        Icons.tag,
                        AppColors.textSecondary,
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 20.sp, color: color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: 'Poppins',
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
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
