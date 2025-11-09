import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import '../models/attendance.models.dart';
import '../vm/attendance.vm.dart';

enum AttendanceFilter {
  all,
  present,
  absent,
  leave,
  halfDay,
  weekend,
}

class AttendanceMonthlyDetailsScreen extends ConsumerStatefulWidget {
  final DateTime? initialMonth;
  final AttendanceFilter? filter;

  const AttendanceMonthlyDetailsScreen({
    super.key,
    this.initialMonth,
    this.filter,
  });

  @override
  ConsumerState<AttendanceMonthlyDetailsScreen> createState() =>
      _AttendanceMonthlyDetailsScreenState();
}

class _AttendanceMonthlyDetailsScreenState
    extends ConsumerState<AttendanceMonthlyDetailsScreen> {
  late DateTime _selectedMonth;
  late AttendanceFilter _activeFilter;

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialMonth ?? DateTime.now();
    _activeFilter = widget.filter ?? AttendanceFilter.all;
  }

  @override
  Widget build(BuildContext context) {
    final attendanceHistory = ref.watch(attendanceHistoryViewModelProvider);

    // Filter records for selected month
    var monthlyRecords = attendanceHistory
        .where((record) =>
            record.date.year == _selectedMonth.year &&
            record.date.month == _selectedMonth.month)
        .toList();

    // Apply status filter
    monthlyRecords = _applyFilter(monthlyRecords);

    // Sort by date (latest first)
    monthlyRecords.sort((a, b) => b.date.compareTo(a.date));

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
      body: Column(
        children: [
          // Month Selector
          _buildMonthSelector(),

          SizedBox(height: 12.h),

          // Filter Dropdown
          _buildFilterDropdown(),

          SizedBox(height: 12.h),

          // Records List
          Expanded(
            child: monthlyRecords.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: monthlyRecords.length,
                    itemBuilder: (context, index) {
                      return _buildAttendanceCard(monthlyRecords[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: AppColors.textPrimary),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month - 1,
                );
              });
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(_selectedMonth),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: AppColors.textPrimary),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month + 1,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(AttendanceRecord record) {
    final dayName = DateFormat('EEEE').format(record.date);
    final dateStr = DateFormat('MMM d, yyyy').format(record.date);
    final isWeekend = record.date.weekday == DateTime.saturday;

    Color statusColor;
    String statusText;
    IconData statusIcon;
    statusColor = record.status.backgroundColor;
    statusText = record.status.displayName;

    switch (record.status) {
      case AttendanceStatus.present:
        statusIcon = Icons.check_circle;
        break;
      case AttendanceStatus.absent:
        statusIcon = Icons.cancel;
        break;
      case AttendanceStatus.halfDay:
        statusIcon = Icons.schedule;
        break;
      case AttendanceStatus.onLeave:
        statusIcon = Icons.event_busy;
        break;
      case AttendanceStatus.weeklyOff:
        statusIcon = Icons.weekend;
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
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
          // Date and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, size: 14.sp, color: statusColor),
                    SizedBox(width: 4.w),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (isWeekend) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.weekend,
                    size: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Weekend',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Time and Location Details (if present/half-day)
          if (record.status == AttendanceStatus.present ||
              record.status == AttendanceStatus.halfDay) ...[
            SizedBox(height: 12.h),
            Divider(color: AppColors.border, height: 1),
            SizedBox(height: 12.h),

            // Check-in and Check-out times
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.login,
                    'Check-in',
                    record.checkInTime != null
                        ? DateFormat('hh:mm a').format(record.checkInTime!)
                        : '--:--',
                    AppColors.success,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildDetailItem(
                    Icons.logout,
                    'Check-out',
                    record.checkOutTime != null
                        ? DateFormat('hh:mm a').format(record.checkOutTime!)
                        : '--:--',
                    AppColors.error,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Hours worked and Location
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.access_time,
                    'Hours Worked',
                    '${record.totalHoursWorked}h',
                    AppColors.secondary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildDetailItem(
                    Icons.location_on,
                    'Location',
                    record.location ?? 'Not available',
                    AppColors.info,
                  ),
                ),
              ],
            ),
          ],

          // Notes (if any)
          if (record.notes != null && record.notes!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Divider(color: AppColors.border, height: 1),
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.note,
                  size: 16.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        record.notes!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: color),
        SizedBox(width: 6.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<AttendanceRecord> _applyFilter(List<AttendanceRecord> records) {
    switch (_activeFilter) {
      case AttendanceFilter.all:
        return records;
      case AttendanceFilter.present:
        return records
            .where((r) => r.status == AttendanceStatus.present)
            .toList();
      case AttendanceFilter.absent:
        return records
            .where((r) => r.status == AttendanceStatus.absent)
            .toList();
      case AttendanceFilter.leave:
        return records
            .where((r) => r.status == AttendanceStatus.onLeave)
            .toList();
      case AttendanceFilter.halfDay:
        return records
            .where((r) => r.status == AttendanceStatus.halfDay)
            .toList();
      case AttendanceFilter.weekend:
        // Filter Saturdays
        return records
            .where((r) => r.date.weekday == DateTime.saturday)
            .toList();
    }
  }

  Widget _buildFilterDropdown() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
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
          Icon(Icons.filter_list, size: 20.sp, color: AppColors.secondary),
          SizedBox(width: 12.w),
          Text(
            'Filter:',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<AttendanceFilter>(
                value: _activeFilter,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.secondary,
                  size: 24.sp,
                ),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                items: [
                  DropdownMenuItem(
                    value: AttendanceFilter.all,
                    child: Row(
                      children: [
                        Icon(Icons.list, size: 18.sp, color: AppColors.textPrimary),
                        SizedBox(width: 8.w),
                        Text('All Days'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: AttendanceFilter.present,
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 18.sp, color: AppColors.success),
                        SizedBox(width: 8.w),
                        Text('Present'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: AttendanceFilter.absent,
                    child: Row(
                      children: [
                        Icon(Icons.cancel, size: 18.sp, color: AppColors.error),
                        SizedBox(width: 8.w),
                        Text('Absent'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: AttendanceFilter.leave,
                    child: Row(
                      children: [
                        Icon(Icons.event_busy, size: 18.sp, color: const Color(0xFFFF9800)),
                        SizedBox(width: 8.w),
                        Text('Leave'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: AttendanceFilter.halfDay,
                    child: Row(
                      children: [
                        Icon(Icons.schedule, size: 18.sp, color: const Color(0xFFFFEB3B)),
                        SizedBox(width: 8.w),
                        Text('Half-Day'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: AttendanceFilter.weekend,
                    child: Row(
                      children: [
                        Icon(Icons.weekend, size: 18.sp, color: AppColors.textSecondary),
                        SizedBox(width: 8.w),
                        Text('Weekend'),
                      ],
                    ),
                  ),
                ],
                onChanged: (AttendanceFilter? newFilter) {
                  if (newFilter != null) {
                    setState(() {
                      _activeFilter = newFilter;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 64.sp,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'No attendance records',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'for ${DateFormat('MMMM yyyy').format(_selectedMonth)}',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
