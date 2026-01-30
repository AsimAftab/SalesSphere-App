import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/exceptions/offline_exception.dart';
import 'package:sales_sphere/core/providers/user_controller.dart';
import 'package:sales_sphere/core/services/geofencing_service.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/widget/no_internet_screen.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/attendance.models.dart';
import '../vm/attendance.vm.dart';
import 'attendance_monthly_details_screen.dart' show AttendanceFilter;

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final todayAttendanceAsync = ref.watch(todayAttendanceViewModelProvider);
    final user = ref.watch(userControllerProvider);

    // Fetch monthly attendance report from API
    final monthlyReportAsync = ref.watch(
      monthlyAttendanceReportViewModelProvider(
        _focusedDay.month,
        _focusedDay.year,
      ),
    );

    return todayAttendanceAsync.when(
      data: (todayAttendanceStatus) {
        return monthlyReportAsync.when(
          data: (monthlyReport) => _buildContent(
            context,
            todayAttendanceStatus,
            user,
            monthlyReport,
          ),
          loading: () => _buildLoading(),
          error: (error, stack) => _buildError(error),
        );
      },
      loading: () => _buildLoading(),
      error: (error, stack) => _buildError(error),
    );
  }

  Widget _buildContent(
    BuildContext context,
    TodayAttendanceStatusResponse? todayAttendanceStatus,
    dynamic user,
    MonthlyAttendanceReport monthlyReport,
  ) {
    final todayAttendance = todayAttendanceStatus?.data;
    final monthlyPresentDays = monthlyReport.summary.present;
    final monthlyAbsentDays = monthlyReport.summary.absent;
    final monthlyLeaveDays = monthlyReport.summary.leave;
    final monthlyHalfDays = monthlyReport.summary.halfDay;
    final monthlyWeekendDays = monthlyReport.summary.weeklyOff;

    // Calculate attendance percentage from working days
    final workingDays = monthlyReport.summary.workingDays;
    final monthlyAttendancePercentage = workingDays > 0
        ? (monthlyPresentDays / workingDays * 100)
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Attendance',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: 26.sp,
                  color: AppColors.textPrimary,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8.w,
                    height: 8.h,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
          Padding(
            padding: EdgeInsets.only(right: 12.w, left: 8.w),
            child: GestureDetector(
              onTap: () => context.push('/profile'),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.textOrange, width: 2.5),
                ),
                child: CircleAvatar(
                  radius: 18.r,
                  backgroundColor: AppColors.primary,
                  backgroundImage: user?.avatarUrl != null
                      ? NetworkImage(user!.avatarUrl!)
                      : null,
                  child: user?.avatarUrl == null
                      ? Text(
                          _getInitials(user?.name ?? 'User'),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textWhite,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          children: [
            // Today's Status Badge
            _buildTodayStatusBadge(todayAttendance),

            SizedBox(height: 16.h),

            // Geofence Status Indicator (only show when enabled with valid coordinates)
            if (todayAttendanceStatus?.enableGeoFencingAttendance == true &&
                todayAttendanceStatus?.organizationLocation?.latitude != null &&
                todayAttendanceStatus?.organizationLocation?.longitude != null)
              _buildGeofenceStatusIndicator(todayAttendanceStatus!),

            if (todayAttendanceStatus?.enableGeoFencingAttendance == true &&
                todayAttendanceStatus?.organizationLocation?.latitude != null &&
                todayAttendanceStatus?.organizationLocation?.longitude != null)
              SizedBox(height: 16.h)
            else
              SizedBox(height: 16.h),

            // Check In Button
            _buildCheckInButton(todayAttendanceStatus),

            SizedBox(height: 24.h),

            // Calendar Card
            _buildCalendarCard(monthlyReport),

            SizedBox(height: 16.h),

            // Legend
            _buildLegend(),

            SizedBox(height: 24.h),

            // Monthly Summary
            _buildMonthlySummary(
              monthlyPresentDays,
              monthlyAbsentDays,
              monthlyLeaveDays,
              monthlyHalfDays,
              monthlyWeekendDays,
              monthlyAttendancePercentage,
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayStatusBadge(TodayAttendance? todayAttendance) {
    String statusText = 'Not Checked In';
    Color badgeColor = AppColors.textSecondary;
    String? timeInfo;

    if (todayAttendance != null) {
      if (todayAttendance.checkInTime != null &&
          todayAttendance.checkOutTime == null) {
        statusText = 'Checked In';
        badgeColor = AppColors.success;
        try {
          final checkInDateTime = DateTime.parse(
            todayAttendance.checkInTime!,
          ).toLocal();
          timeInfo = DateFormat('hh:mm a').format(checkInDateTime);
        } catch (e) {
          timeInfo = todayAttendance.checkInTime;
        }
      } else if (todayAttendance.checkInTime != null &&
          todayAttendance.checkOutTime != null) {
        statusText = 'Checked Out';
        badgeColor = AppColors.info;
        try {
          final checkInDateTime = DateTime.parse(
            todayAttendance.checkInTime!,
          ).toLocal();
          final checkOutDateTime = DateTime.parse(
            todayAttendance.checkOutTime!,
          ).toLocal();
          final checkIn = DateFormat('hh:mm a').format(checkInDateTime);
          final checkOut = DateFormat('hh:mm a').format(checkOutDateTime);
          timeInfo = '$checkIn | $checkOut';
        } catch (e) {
          timeInfo =
              '${todayAttendance.checkInTime} | ${todayAttendance.checkOutTime}';
        }
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 20.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 8.w),
              Text(
                'Today\'s Status',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          if (timeInfo != null) ...[
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  timeInfo,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGeofenceStatusIndicator(TodayAttendanceStatusResponse status) {
    final orgLocation = status.organizationLocation!;
    final radius = GeofencingService.attendanceGeofenceRadius;
    final radiusFormatted = GeofencingService.instance.formatDistance(radius);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on_outlined,
              size: 18.sp,
              color: AppColors.info,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Office Location Required',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Within ${radiusFormatted} required',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.info_outline, size: 16.sp, color: AppColors.info),
        ],
      ),
    );
  }

  Widget _buildCheckInButton(
    TodayAttendanceStatusResponse? todayAttendanceStatus,
  ) {
    final todayAttendance = todayAttendanceStatus?.data;
    final isCheckedIn = todayAttendance?.checkInTime != null;
    final isCheckedOut = todayAttendance?.checkOutTime != null;

    // Hide button if already checked out
    if (isCheckedOut) {
      return const SizedBox.shrink();
    }

    // Check if check-in is allowed (within 2 hours before scheduled time)
    final isCheckInAllowed = ref
        .read(todayAttendanceViewModelProvider.notifier)
        .isCheckInAllowed(todayAttendanceStatus);

    // For check-out, always enable the button (backend validates timing)
    final isButtonEnabled = isCheckedIn || isCheckInAllowed;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: isButtonEnabled
                ? () => _handleCheckInOut(isCheckedIn)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isButtonEnabled
                  ? AppColors.secondary
                  : AppColors.textSecondary.withValues(alpha: 0.3),
              foregroundColor: Colors.white,
              elevation: 0,
              disabledBackgroundColor: AppColors.textSecondary.withValues(
                alpha: 0.3,
              ),
              disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isCheckedIn ? Icons.logout : Icons.login, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  isCheckedIn ? 'Check Out' : 'Check In',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isCheckedIn &&
            !isCheckInAllowed &&
            todayAttendanceStatus?.organizationCheckInTime != null) ...[
          SizedBox(height: 8.h),
          Text(
            'Check-in will be available 2 hours before ${todayAttendanceStatus!.organizationCheckInTime}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _handleCheckInOut(bool isCheckedIn) async {
    Position? position;
    String? address;

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Request location permission
      final permission = await Permission.location.request();
      if (!permission.isGranted) {
        if (!mounted) return;
        Navigator.pop(context); // Close loading dialog
        _showErrorSnackbar('Location permission is required for attendance');
        return;
      }

      // Get current position with new LocationSettings API
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Get address from coordinates
      address = 'Unknown location';
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          address = [
            place.street,
            place.locality,
            place.subAdministrativeArea,
            place.postalCode,
            place.country,
          ].where((e) => e != null && e.isNotEmpty).join(', ');
        }
      } catch (e) {
        AppLogger.w('Failed to get address: $e');
        address = '${position.latitude}, ${position.longitude}';
      }

      // Call check-in or check-out
      if (!isCheckedIn) {
        await ref
            .read(todayAttendanceViewModelProvider.notifier)
            .checkIn(
              latitude: position.latitude,
              longitude: position.longitude,
              address: address,
            );
      } else {
        await ref
            .read(todayAttendanceViewModelProvider.notifier)
            .checkOut(
              latitude: position.latitude,
              longitude: position.longitude,
              address: address,
            );
      }

      // Refresh monthly attendance report to update calendar
      ref.invalidate(
        monthlyAttendanceReportViewModelProvider(
          _focusedDay.month,
          _focusedDay.year,
        ),
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      _showSuccessSnackbar(
        isCheckedIn ? 'Checked out successfully!' : 'Checked in successfully!',
      );
    } on GeofenceViolationException catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      AppLogger.w('Geofence violation: ${e.message}');
      _showGeofenceViolationDialog(e.message);
    } on CheckInErrorException catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      AppLogger.w('Check-in time window error: ${e.error.message}');
      _showCheckInErrorDialog(e.error);
    } on HalfDayWindowClosedException catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      AppLogger.w('Half-day window closed: ${e.restriction.message}');
      _showHalfDayWindowClosedDialog(e.restriction);
    } on CheckoutRestrictionException catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      AppLogger.w('Checkout restricted: ${e.restriction.message}');

      // Show half-day option dialog if available and we have position/address
      if (e.restriction.canUseHalfDayFallback &&
          position != null &&
          address != null) {
        _showHalfDayCheckoutDialog(
          restriction: e.restriction,
          position: position,
          address: address,
        );
      } else {
        // Show generic checkout time restriction dialog
        _showCheckoutTimeErrorDialog(e.restriction);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      AppLogger.e('Check-in/out failed: $e');
      _showErrorSnackbar(
        'Failed to ${isCheckedIn ? "check out" : "check in"}. Please try again.',
      );
    }
  }

  void _showCheckInErrorDialog(CheckInError error) {
    // Determine if window is closed (too late) or not yet open (too early)
    final isWindowClosed =
        error.latestAllowedCheckIn != null &&
        error.earliestAllowedCheckIn == null;
    final iconData = isWindowClosed
        ? Icons.lock_clock
        : Icons.access_time_filled;
    final titleText = isWindowClosed
        ? 'Check-In Window Closed'
        : 'Check-In Not Allowed';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(maxWidth: 340.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        iconData,
                        color: AppColors.error,
                        size: 32.sp,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      titleText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      error.message,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    if (error.earliestAllowedCheckIn != null ||
                        error.scheduledCheckInTime != null ||
                        error.latestAllowedCheckIn != null ||
                        error.currentTime != null) ...[
                      SizedBox(height: 16.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.info.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Current Time (for window closed scenario)
                            if (error.currentTime != null &&
                                isWindowClosed) ...[
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                  SizedBox(width: 8.w),
                                  Flexible(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Current Time: ',
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          TextSpan(
                                            text: error.currentTime!,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                            ],
                            // Scheduled Check-In Time
                            if (error.scheduledCheckInTime != null) ...[
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 16.sp,
                                    color: AppColors.info,
                                  ),
                                  SizedBox(width: 8.w),
                                  Flexible(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Scheduled Time: ',
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          TextSpan(
                                            text: error.scheduledCheckInTime!,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                            ],
                            // Latest Allowed (for window closed)
                            if (error.latestAllowedCheckIn != null)
                              Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 16.sp,
                                    color: AppColors.error,
                                  ),
                                  SizedBox(width: 8.w),
                                  Flexible(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: isWindowClosed
                                                ? 'Window Closed At: '
                                                : 'Latest Allowed: ',
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          TextSpan(
                                            text: error.latestAllowedCheckIn!,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            // Earliest Allowed (for too early scenario)
                            if (error.earliestAllowedCheckIn != null) ...[
                              if (error.latestAllowedCheckIn != null)
                                SizedBox(height: 8.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 16.sp,
                                    color: AppColors.success,
                                  ),
                                  SizedBox(width: 8.w),
                                  Flexible(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Earliest Allowed: ',
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          TextSpan(
                                            text: error.earliestAllowedCheckIn!,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.success,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 20.h),
                    // OK button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        child: Text(
                          'OK',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCheckoutTimeErrorDialog(CheckoutRestriction restriction) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(maxWidth: 340.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.schedule_rounded,
                        color: AppColors.warning,
                        size: 32.sp,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Checkout Not Allowed Yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restriction.message,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    if (restriction.allowedFrom != null ||
                        restriction.scheduledCheckout != null) ...[
                      SizedBox(height: 16.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.info.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (restriction.scheduledCheckout != null) ...[
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 16.sp,
                                    color: AppColors.info,
                                  ),
                                  SizedBox(width: 8.w),
                                  Flexible(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Scheduled Checkout: ',
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                restriction.scheduledCheckout!,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                            ],
                            if (restriction.allowedFrom != null)
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 16.sp,
                                    color: AppColors.success,
                                  ),
                                  SizedBox(width: 8.w),
                                  Flexible(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Allowed From: ',
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          TextSpan(
                                            text: restriction.allowedFrom!,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.success,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (restriction.checkoutType != null) ...[
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                  SizedBox(width: 8.w),
                                  Flexible(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Checkout Type: ',
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          TextSpan(
                                            text: restriction.checkoutType!,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 20.h),
                    // OK button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          ref
                              .read(todayAttendanceViewModelProvider.notifier)
                              .refresh();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        child: Text(
                          'OK',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHalfDayWindowClosedDialog(CheckoutRestriction restriction) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(maxWidth: 340.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.block,
                        color: AppColors.error,
                        size: 32.sp,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Half-Day Window Closed',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restriction.message,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    if (restriction.fullDayCheckoutTime != null)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.info.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20.sp,
                              color: AppColors.info,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Please checkout as full-day',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Full-day checkout time: ${restriction.fullDayCheckoutTime}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 20.h),
                    // OK button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          ref
                              .read(todayAttendanceViewModelProvider.notifier)
                              .refresh();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        child: Text(
                          'OK',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGeofenceViolationDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(maxWidth: 340.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.location_off_outlined,
                        color: AppColors.warning,
                        size: 32.sp,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Outside Attendance Geofence',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18.sp,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            message,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    // Retry button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        child: Text(
                          'Retry',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHalfDayCheckoutDialog({
    required CheckoutRestriction restriction,
    required Position position,
    required String address,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            // Refresh provider when dialog is dismissed
            ref.read(todayAttendanceViewModelProvider.notifier).refresh();
          }
        },
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(maxWidth: 340.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.schedule_rounded,
                          color: AppColors.warning,
                          size: 32.sp,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Full-Day Checkout Not Available',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Restriction info
                      if (restriction.allowedFrom != null) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18.sp,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'Full-day checkout is available from ${restriction.allowedFrom}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                      ],
                      // Half-day option highlight
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.check_circle_outline,
                                color: AppColors.success,
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Half-Day Checkout Available',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  if (restriction.halfDayAllowedFrom !=
                                      null) ...[
                                    SizedBox(height: 2.h),
                                    Text(
                                      'Available from ${restriction.halfDayAllowedFrom}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                ref
                                    .read(
                                      todayAttendanceViewModelProvider.notifier,
                                    )
                                    .refresh();
                                Navigator.of(dialogContext).pop();
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: AppColors.border,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                _performHalfDayCheckout(position, address);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: 14.h,
                                  horizontal: 8.w,
                                ),
                              ),
                              child: Text(
                                'Checkout Half-Day',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
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
        ),
      ),
    );
  }

  Future<void> _performHalfDayCheckout(
    Position position,
    String address,
  ) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await ref
          .read(todayAttendanceViewModelProvider.notifier)
          .checkOut(
            latitude: position.latitude,
            longitude: position.longitude,
            address: address,
            isHalfDay: true,
          );

      // Refresh monthly attendance report to update calendar
      ref.invalidate(
        monthlyAttendanceReportViewModelProvider(
          _focusedDay.month,
          _focusedDay.year,
        ),
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      _showSuccessSnackbar('Checked out successfully (Half-day)!');
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      AppLogger.e('Half-day checkout failed: $e');
      _showErrorSnackbar('Failed to checkout as half-day. Please try again.');
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Success',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        duration: const Duration(seconds: 3),
        elevation: 6,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        duration: const Duration(seconds: 3),
        elevation: 6,
      ),
    );
  }

  Widget _buildCalendarCard(MonthlyAttendanceReport monthlyReport) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: true,
          weekendTextStyle: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          defaultTextStyle: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textPrimary,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          outsideTextStyle: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: AppColors.textPrimary,
            size: 24.sp,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: AppColors.textPrimary,
            size: 24.sp,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
          weekendStyle: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            return _buildCalendarDay(day, monthlyReport, false);
          },
          selectedBuilder: (context, day, focusedDay) {
            return _buildCalendarDay(day, monthlyReport, true);
          },
          todayBuilder: (context, day, focusedDay) {
            return _buildCalendarDay(day, monthlyReport, false, isToday: true);
          },
          outsideBuilder: (context, day, focusedDay) {
            return _buildCalendarDay(
              day,
              monthlyReport,
              false,
              isOutside: true,
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendarDay(
    DateTime day,
    MonthlyAttendanceReport monthlyReport,
    bool isSelected, {
    bool isToday = false,
    bool isOutside = false,
  }) {
    Color? backgroundColor;
    Color textColor = AppColors.textPrimary;
    Color? dotColor;

    // Only show dots for days in the current month
    if (!isOutside && day.month == _focusedDay.month) {
      final dayKey = day.day.toString();
      final attendanceDay = monthlyReport.attendance[dayKey];

      if (attendanceDay != null) {
        // Don't show dot for "NA" (notMarked) status
        if (attendanceDay.status != AttendanceStatus.notMarked) {
          dotColor = attendanceDay.status.backgroundColor;
        }
      }
    }

    if (isSelected) {
      backgroundColor = AppColors.primary;
      textColor = Colors.white;
    } else if (isToday) {
      backgroundColor = AppColors.primary.withValues(alpha: 0.15);
    }

    if (isOutside) {
      textColor = AppColors.textSecondary.withValues(alpha: 0.3);
    }

    return Container(
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            SizedBox(height: 2.h),
            Container(
              width: 5.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: dotColor ?? Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      children: [
        // First row: Present, Absent, Half-Day
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegendItem('Present', AppColors.green500),
            _buildLegendItem('Absent', AppColors.red500),
            _buildLegendItem('Half-Day', AppColors.purple500),
          ],
        ),
        SizedBox(height: 12.h),
        // Second row: Leave, Weekly Off
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegendItem('Leave', AppColors.yellow500),
            _buildLegendItem('Weekly Off', AppColors.blue500),
            SizedBox(width: 80.w), // Empty space for alignment
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.h,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildMonthlySummary(
    int presentDays,
    int absentDays,
    int leaveDays,
    int halfDays,
    int weekendDays,
    double attendancePercentage,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
              Icon(Icons.trending_up, size: 20.sp, color: AppColors.secondary),
              SizedBox(width: 8.w),
              Text(
                'Monthly Summary',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // First row: Present, Absent, Leave
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                presentDays.toString(),
                'Present',
                filter: AttendanceFilter.present,
              ),
              Container(width: 1.w, height: 40.h, color: AppColors.border),
              _buildSummaryItem(
                absentDays.toString(),
                'Absent',
                filter: AttendanceFilter.absent,
              ),
              Container(width: 1.w, height: 40.h, color: AppColors.border),
              _buildSummaryItem(
                leaveDays.toString(),
                'Leave',
                filter: AttendanceFilter.leave,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Second row: Half-Day, Weekend, Attendance %
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                halfDays.toString(),
                'Half-Day',
                filter: AttendanceFilter.halfDay,
              ),
              Container(width: 1.w, height: 40.h, color: AppColors.border),
              _buildSummaryItem(weekendDays.toString(), 'Weekend'),
              // No filter for weekend
              Container(width: 1.w, height: 40.h, color: AppColors.border),
              _buildSummaryItem(
                '${attendancePercentage.toStringAsFixed(0)}%',
                'Attendance',
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // View Details Button
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: OutlinedButton(
              onPressed: () {
                context.push(
                  '/attendance/monthly-details',
                  extra: {'month': _focusedDay, 'filter': null},
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.secondary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'View Details',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String value,
    String label, {
    AttendanceFilter? filter,
  }) {
    return InkWell(
      onTap: filter != null
          ? () {
              context.push(
                '/attendance/monthly-details',
                extra: {'month': _focusedDay, 'filter': filter},
              );
            }
          : null,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Attendance',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildError(Object error) {
    // Check if error is OfflineException (typed exception from connectivity check)
    final isOffline =
        error is OfflineException ||
        (error is DioException && error.error is OfflineException);

    if (isOffline) {
      return NoInternetScreen(
        onRetry: () {
          ref.invalidate(todayAttendanceViewModelProvider);
          ref.invalidate(monthlyAttendanceReportViewModelProvider);
        },
      );
    }

    // Show generic error screen for other errors
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Attendance',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              'Failed to load attendance data',
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
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(monthlyAttendanceReportViewModelProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _getInitials(String name) {
  final trimmedName = name.trim();
  if (trimmedName.isNotEmpty) {
    return trimmedName[0].toUpperCase();
  }
  return 'U';
}
