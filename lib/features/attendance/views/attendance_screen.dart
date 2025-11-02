import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
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
    final todayAttendance = ref.watch(todayAttendanceViewModelProvider);
    final attendanceHistory = ref.watch(attendanceHistoryViewModelProvider);

    // Calculate monthly summary for current month
    final monthlyRecords = attendanceHistory.where((record) =>
        record.date.year == _focusedDay.year &&
        record.date.month == _focusedDay.month).toList();

    final monthlyPresentDays = monthlyRecords
        .where((r) => r.status == AttendanceStatus.present)
        .length;
    final monthlyAbsentDays = monthlyRecords
        .where((r) => r.status == AttendanceStatus.absent)
        .length;
    final monthlyLeaveDays = monthlyRecords
        .where((r) => r.status == AttendanceStatus.onLeave)
        .length;
    final monthlyHalfDays = monthlyRecords
        .where((r) => r.status == AttendanceStatus.halfDay)
        .length;

    // Count Saturdays in the current month as weekends
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    int monthlyWeekendDays = 0;
    for (var day = firstDayOfMonth; day.isBefore(lastDayOfMonth.add(const Duration(days: 1))); day = day.add(const Duration(days: 1))) {
      if (day.weekday == DateTime.saturday) {
        monthlyWeekendDays++;
      }
    }

    final monthlyTotalDays = monthlyRecords.length;
    final monthlyAttendancePercentage = monthlyTotalDays > 0
        ? (monthlyPresentDays / monthlyTotalDays * 100)
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
                Icon(Icons.notifications_outlined, size: 26.sp, color: AppColors.textPrimary),
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
            child: CircleAvatar(
              radius: 18.r,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, color: Colors.white, size: 20.sp),
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

            // Check In Button
            _buildCheckInButton(todayAttendance),

            SizedBox(height: 24.h),

            // Calendar Card
            _buildCalendarCard(attendanceHistory),

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

  Widget _buildTodayStatusBadge(TodayAttendance todayAttendance) {
    String statusText = 'Not Checked In';
    Color badgeColor = AppColors.textSecondary;
    String? timeInfo;

    if (todayAttendance.isCheckedIn && !todayAttendance.isCheckedOut) {
      statusText = 'Checked In';
      badgeColor = AppColors.success;
      if (todayAttendance.checkInTime != null) {
        timeInfo = DateFormat('hh:mm a').format(todayAttendance.checkInTime!);
      }
    } else if (todayAttendance.isCheckedOut) {
      statusText = 'Checked Out';
      badgeColor = AppColors.info;
      if (todayAttendance.checkInTime != null && todayAttendance.checkOutTime != null) {
        final checkIn = DateFormat('hh:mm a').format(todayAttendance.checkInTime!);
        final checkOut = DateFormat('hh:mm a').format(todayAttendance.checkOutTime!);
        timeInfo = '$checkIn | $checkOut';
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
              Icon(Icons.access_time, size: 20.sp, color: AppColors.textSecondary),
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

  Widget _buildCheckInButton(TodayAttendance todayAttendance) {
    if (todayAttendance.isCheckedOut) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: () async {
          if (!todayAttendance.isCheckedIn) {
            await ref.read(todayAttendanceViewModelProvider.notifier).checkIn();
          } else {
            await ref.read(todayAttendanceViewModelProvider.notifier).checkOut();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              todayAttendance.isCheckedIn ? Icons.logout : Icons.login,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              todayAttendance.isCheckedIn ? 'Check Out' : 'Check In',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard(List<AttendanceRecord> attendanceHistory) {
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
            color: AppColors.textSecondary.withValues(alpha:0.5),
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
            color: AppColors.primary.withValues(alpha:0.2),
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          outsideTextStyle: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary.withValues(alpha:0.3),
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
            return _buildCalendarDay(day, attendanceHistory, false);
          },
          selectedBuilder: (context, day, focusedDay) {
            return _buildCalendarDay(day, attendanceHistory, true);
          },
          todayBuilder: (context, day, focusedDay) {
            return _buildCalendarDay(day, attendanceHistory, false, isToday: true);
          },
          outsideBuilder: (context, day, focusedDay) {
            return _buildCalendarDay(day, attendanceHistory, false, isOutside: true);
          },
        ),
      ),
    );
  }

  Widget _buildCalendarDay(
    DateTime day,
    List<AttendanceRecord> attendanceHistory,
    bool isSelected, {
    bool isToday = false,
    bool isOutside = false,
  }) {
    final record = attendanceHistory.firstWhere(
      (r) => isSameDay(r.date, day),
      orElse: () => AttendanceRecord(
        id: '',
        date: day,
        status: AttendanceStatus.absent,
      ),
    );

    Color? backgroundColor;
    Color textColor = AppColors.textPrimary;
    Color? dotColor;

    // Saturday is weekend (not Sunday)
    final isWeekend = day.weekday == DateTime.saturday;

    if (isWeekend && record.id.isNotEmpty) {
      // Saturday with attendance record - show the status dot
      switch (record.status) {
        case AttendanceStatus.present:
          dotColor = AppColors.success;
          break;
        case AttendanceStatus.late:
          dotColor = AppColors.success; // Treat as present
          break;
        case AttendanceStatus.absent:
          dotColor = AppColors.error;
          break;
        case AttendanceStatus.halfDay:
          dotColor = const Color(0xFFFFEB3B); // Bright yellow
          break;
        case AttendanceStatus.onLeave:
          dotColor = const Color(0xFFFF9800); // Orange for leave
          break;
      }
    } else if (isWeekend) {
      // Saturday without record - grey weekend dot
      dotColor = AppColors.textSecondary;
    } else if (record.id.isNotEmpty) {
      // Regular working day with attendance record
      switch (record.status) {
        case AttendanceStatus.present:
          dotColor = AppColors.success;
          break;
        case AttendanceStatus.late:
          dotColor = AppColors.success; // Treat as present
          break;
        case AttendanceStatus.absent:
          dotColor = AppColors.error;
          break;
        case AttendanceStatus.halfDay:
          dotColor = const Color(0xFFFFEB3B); // Bright yellow
          break;
        case AttendanceStatus.onLeave:
          dotColor = const Color(0xFFFF9800); // Orange for leave
          break;
      }
    }

    if (isSelected) {
      backgroundColor = AppColors.primary;
      textColor = Colors.white;
    } else if (isToday) {
      backgroundColor = AppColors.primary.withValues(alpha:0.15);
    }

    if (isOutside) {
      textColor = AppColors.textSecondary.withValues(alpha:0.3);
      dotColor = null; // Don't show dots for outside days
    }

    return Container(
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
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
            _buildLegendItem('Present', AppColors.success),
            _buildLegendItem('Absent', AppColors.error),
            _buildLegendItem('Half-Day', const Color(0xFFFFEB3B)),
          ],
        ),
        SizedBox(height: 12.h),
        // Second row: Leave, Weekend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegendItem('Leave', const Color(0xFFFF9800)),
            _buildLegendItem('Weekend', AppColors.textSecondary),
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
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
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
              _buildSummaryItem(presentDays.toString(), 'Present', filter: AttendanceFilter.present),
              Container(
                width: 1.w,
                height: 40.h,
                color: AppColors.border,
              ),
              _buildSummaryItem(absentDays.toString(), 'Absent', filter: AttendanceFilter.absent),
              Container(
                width: 1.w,
                height: 40.h,
                color: AppColors.border,
              ),
              _buildSummaryItem(leaveDays.toString(), 'Leave', filter: AttendanceFilter.leave),
            ],
          ),
          SizedBox(height: 16.h),
          // Second row: Half-Day, Weekend, Attendance %
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(halfDays.toString(), 'Half-Day', filter: AttendanceFilter.halfDay),
              Container(
                width: 1.w,
                height: 40.h,
                color: AppColors.border,
              ),
              _buildSummaryItem(weekendDays.toString(), 'Weekend', filter: AttendanceFilter.weekend),
              Container(
                width: 1.w,
                height: 40.h,
                color: AppColors.border,
              ),
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
                  extra: {
                    'month': _focusedDay,
                    'filter': null,
                  },
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

  Widget _buildSummaryItem(String value, String label, {AttendanceFilter? filter}) {
    return InkWell(
      onTap: filter != null
          ? () {
              context.push(
                '/attendance/monthly-details',
                extra: {
                  'month': _focusedDay,
                  'filter': filter,
                },
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
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
