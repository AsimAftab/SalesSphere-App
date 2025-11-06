import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import '../models/attendance.models.dart';
import '../vm/attendance.vm.dart';

class AttendanceHistoryScreen extends ConsumerStatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  ConsumerState<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends ConsumerState<AttendanceHistoryScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    // Check if the CURRENT selected month is already at the current month
    final selectedMonthNormalized = DateTime(_selectedMonth.year, _selectedMonth.month);

    // Only allow going forward if we're NOT already at the current month
    if (selectedMonthNormalized.year < currentMonth.year ||
        (selectedMonthNormalized.year == currentMonth.year && selectedMonthNormalized.month < currentMonth.month)) {
      setState(() {
        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceHistory = ref.watch(attendanceHistoryViewModelProvider);
    final monthRecords = attendanceHistory
        .where((record) =>
            record.date.year == _selectedMonth.year &&
            record.date.month == _selectedMonth.month)
        .toList();

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
          'Attendance History',
          style: TextStyle(
            fontSize: 18.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Month selector
          _buildMonthSelector(),

          // Legend
          _buildLegend(),

          SizedBox(height: 16.h),

          // Calendar view
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  _buildCalendar(monthRecords),
                  SizedBox(height: 24.h),
                  _buildRecordsList(monthRecords),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final selectedMonthNormalized = DateTime(_selectedMonth.year, _selectedMonth.month);

    // Check if we're already at current month (can't go forward)
    final isAtCurrentMonth = selectedMonthNormalized.year == currentMonth.year &&
        selectedMonthNormalized.month == currentMonth.month;

    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: Colors.white, size: 28.sp),
            onPressed: _previousMonth,
          ),
          Text(
            DateFormat('MMMM yyyy').format(_selectedMonth),
            style: TextStyle(
              fontSize: 18.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: isAtCurrentMonth ? Colors.white.withValues(alpha: 0.3) : Colors.white,
              size: 28.sp,
            ),
            onPressed: isAtCurrentMonth ? null : _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem('Present', AppColors.success),
          _buildLegendItem('Absent', AppColors.error),
          _buildLegendItem('Late', AppColors.warning),
          _buildLegendItem('Leave', AppColors.info),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.h,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontFamily: 'Poppins',
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar(List<AttendanceRecord> monthRecords) {
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startingWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((day) => SizedBox(
                      width: 40.w,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ))
                .toList(),
          ),
          SizedBox(height: 8.h),
          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: startingWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startingWeekday) {
                return const SizedBox();
              }

              final day = index - startingWeekday + 1;
              final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
              final record = monthRecords.firstWhere(
                (r) => r.date.day == day,
                orElse: () => AttendanceRecord(
                  id: '',
                  date: date,
                  status: AttendanceStatus.absent,
                ),
              );

              return _buildCalendarDay(day, record, date);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(int day, AttendanceRecord? record, DateTime date) {
    Color? backgroundColor;
    final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

    if (record != null && record.id.isNotEmpty && !isWeekend) {
      switch (record.status) {
        case AttendanceStatus.present:
          backgroundColor = AppColors.success.withValues(alpha: 0.2);
          break;
        case AttendanceStatus.absent:
          backgroundColor = AppColors.error.withValues(alpha: 0.2);
          break;
        case AttendanceStatus.late:
          backgroundColor = AppColors.warning.withValues(alpha: 0.2);
          break;
        case AttendanceStatus.onLeave:
          backgroundColor = AppColors.info.withValues(alpha: 0.2);
          break;
        case AttendanceStatus.halfDay:
          backgroundColor = AppColors.warning.withValues(alpha: 0.15);
          break;
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onDoubleTap: record != null && record.id.isNotEmpty
          ? () {
              context.push('/attendance/details', extra: record);
            }
          : null,
      child: Container(
        margin: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.r),
          border: isWeekend ? Border.all(color: AppColors.border.withValues(alpha: 0.3)) : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              color: isWeekend ? AppColors.textHint : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordsList(List<AttendanceRecord> monthRecords) {
    if (monthRecords.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            children: [
              Icon(
                Icons.event_busy,
                size: 64.sp,
                color: AppColors.textHint,
              ),
              SizedBox(height: 16.h),
              Text(
                'No attendance records',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: 'Poppins',
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final sortedRecords = List<AttendanceRecord>.from(monthRecords)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Records',
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        ...sortedRecords.map((record) => _buildRecordItem(record)),
      ],
    );
  }

  Widget _buildRecordItem(AttendanceRecord record) {
    Color statusColor;
    IconData statusIcon;

    switch (record.status) {
      case AttendanceStatus.present:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case AttendanceStatus.absent:
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        break;
      case AttendanceStatus.late:
        statusColor = AppColors.warning;
        statusIcon = Icons.access_time;
        break;
      case AttendanceStatus.onLeave:
        statusColor = AppColors.info;
        statusIcon = Icons.event_busy;
        break;
      case AttendanceStatus.halfDay:
        statusColor = AppColors.warning;
        statusIcon = Icons.timelapse;
        break;
    }

    return GestureDetector(
      onTap: () => context.push('/attendance/details', extra: record),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(statusIcon, size: 24.sp, color: statusColor),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, MMM d').format(record.date),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    record.status.displayName,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: 'Poppins',
                      color: statusColor,
                      fontWeight: FontWeight.w500,
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
