import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/attendance.models.dart';

class AttendanceDetailScreen extends StatelessWidget {
  final SearchedAttendance attendance;

  const AttendanceDetailScreen({
    super.key,
    required this.attendance,
  });

  @override
  Widget build(BuildContext context) {
    final recordDate = DateTime.parse(attendance.date).toLocal();
    final dateStr = DateFormat('EEEE, MMM d, yyyy').format(recordDate);

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (attendance.status) {
      case AttendanceStatus.present:
        statusColor = AppColors.success;
        statusText = 'Present';
        statusIcon = Icons.check_circle;
        break;
      case AttendanceStatus.absent:
        statusColor = AppColors.error;
        statusText = 'Absent';
        statusIcon = Icons.cancel;
        break;
      case AttendanceStatus.halfDay:
        statusColor = const Color(0xFFFFEB3B);
        statusText = 'Half-Day';
        statusIcon = Icons.schedule;
        break;
      case AttendanceStatus.onLeave:
        statusColor = const Color(0xFFFF9800);
        statusText = 'Leave';
        statusIcon = Icons.event_busy;
        break;
      case AttendanceStatus.weeklyOff:
        statusColor = AppColors.textSecondary;
        statusText = 'Weekend';
        statusIcon = Icons.weekend;
        break;
      case AttendanceStatus.notMarked:
        statusColor = AppColors.textSecondary;
        statusText = 'Not Marked';
        statusIcon = Icons.help_outline;
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Attendance Details',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(dateStr, statusText, statusColor, statusIcon),

            SizedBox(height: 16.h),

            // Hours Worked (if applicable)
            if (attendance.hoursWorked != null) ...[
              _buildHoursWorkedCard(),
              SizedBox(height: 16.h),
            ],

            // Check-in Details
            if (attendance.checkInTime != null) ...[
              _buildCheckInCard(context),
              SizedBox(height: 16.h),
            ],

            // Check-out Details
            if (attendance.checkOutTime != null) ...[
              _buildCheckOutCard(context),
              SizedBox(height: 16.h),
            ],

            // Notes (if present)
            if (attendance.notes != null && attendance.notes!.isNotEmpty) ...[
              _buildNotesCard(),
              SizedBox(height: 16.h),
            ],

            // Marked by (if present)
            if (attendance.markedBy != null) ...[
              _buildMarkedByCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
      String dateStr, String statusText, Color statusColor, IconData statusIcon) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withValues(alpha: 0.1), statusColor.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(statusIcon, size: 48.sp, color: statusColor),
          SizedBox(height: 12.h),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            dateStr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoursWorkedCard() {
    final hours = attendance.hoursWorked!.toStringAsFixed(1);
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.access_time, size: 24.sp, color: AppColors.info),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hours Worked',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '$hours hrs',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInCard(BuildContext context) {
    final checkInTime = DateTime.parse(attendance.checkInTime!).toLocal();
    final timeStr = DateFormat('hh:mm a').format(checkInTime);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.login, size: 20.sp, color: AppColors.success),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Check-In',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (attendance.checkInLocation != null) ...[
            SizedBox(height: 16.h),
            Divider(color: AppColors.border, height: 1),
            SizedBox(height: 16.h),
            _buildLocationDetails(
              context,
              attendance.checkInLocation!,
              attendance.checkInAddress,
              'Check-In Location',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckOutCard(BuildContext context) {
    final checkOutTime = DateTime.parse(attendance.checkOutTime!).toLocal();
    final timeStr = DateFormat('hh:mm a').format(checkOutTime);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.logout, size: 20.sp, color: AppColors.error),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Check-Out',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (attendance.checkOutLocation != null) ...[
            SizedBox(height: 16.h),
            Divider(color: AppColors.border, height: 1),
            SizedBox(height: 16.h),
            _buildLocationDetails(
              context,
              attendance.checkOutLocation!,
              attendance.checkOutAddress,
              'Check-Out Location',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationDetails(
    BuildContext context,
    LocationCoordinates location,
    String? address,
    String title,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, size: 16.sp, color: AppColors.textSecondary),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        if (address != null)
          Text(
            address,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        SizedBox(height: 12.h),
        Text(
          'Coordinates: ${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
          style: TextStyle(
            fontSize: 11.sp,
            color: AppColors.textSecondary,
            fontFamily: 'monospace',
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _openInMaps(location.latitude, location.longitude),
            icon: Icon(Icons.map, size: 18.sp),
            label: Text(
              'Open in Maps',
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary, width: 1.5),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_alt, size: 20.sp, color: AppColors.warning),
              SizedBox(width: 8.w),
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              attendance.notes!,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkedByCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, size: 20.sp, color: AppColors.info),
              SizedBox(width: 8.w),
              Text(
                'Marked By',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  attendance.markedBy!.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attendance.markedBy!.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    attendance.markedBy!.role,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openInMaps(double latitude, double longitude) async {
    // Try Google Maps first
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    }
  }
}
