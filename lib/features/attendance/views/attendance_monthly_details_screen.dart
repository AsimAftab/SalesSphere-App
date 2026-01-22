import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/exceptions/offline_exception.dart';
import 'package:sales_sphere/widget/no_internet_screen.dart';
import '../models/attendance.models.dart';
import '../vm/attendance.vm.dart';
import 'attendance_detail_screen.dart';

enum AttendanceFilter {
  all,
  present,
  absent,
  leave,
  halfDay,
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
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false; // Prevent multiple loadMore calls

  // Cache current provider to prevent multiple instances
  AttendanceSearchViewModelProvider? _currentProvider;

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialMonth ?? DateTime.now();
    _activeFilter = widget.filter ?? AttendanceFilter.all;

    // Setup pagination scroll listener
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Guard 1: Prevent concurrent loadMore calls
    if (_isLoadingMore) return;

    // Guard 2: Only trigger if scroll controller is attached
    if (!_scrollController.hasClients) return;

    // Guard 3: Only trigger if there's scrollable content
    if (_scrollController.position.maxScrollExtent <= 0) return;

    // Guard 4: Check if current provider data has next page
    // This prevents scroll detection when there's no utilities data to load
    if (_currentProvider != null) {
      final currentState = ref.read(_currentProvider!);
      final hasNextPage = currentState.maybeWhen(
        data: (response) => response.pagination.hasNextPage,
        orElse: () => false,
      );

      if (!hasNextPage) return;
    }

    // Trigger loadMore when user scrolls to 80% of the list
    // The loadMore method in ViewModel has its own guards for hasNextPage
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    // Use cached provider instance to avoid creating new ones
    if (_currentProvider == null) return;

    // Double-check that there's actually a next page before loading
    final currentState = ref.read(_currentProvider!);
    final hasNextPage = currentState.maybeWhen(
      data: (response) => response.pagination.hasNextPage,
      orElse: () => false,
    );

    if (!hasNextPage) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await ref.read(_currentProvider!.notifier).loadMore();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  /// Get status codes for API filter
  /// Uses const lists to maintain identity across builds (prevents provider recreation)
  List<String>? _getStatusCodes() {
    switch (_activeFilter) {
      case AttendanceFilter.all:
        return null; // No filter = all statuses
      case AttendanceFilter.present:
        return const ['P']; // const ensures same instance across calls
      case AttendanceFilter.absent:
        return const ['A'];
      case AttendanceFilter.leave:
        return const ['L'];
      case AttendanceFilter.halfDay:
        return const ['H'];
    }
  }

  /// Get the appropriate search provider based on filters
  AttendanceSearchViewModelProvider _getSearchProvider() {
    return attendanceSearchViewModelProvider(
      status: _getStatusCodes(), // const lists maintain identity
      month: _selectedMonth.month,
      year: _selectedMonth.year,
      page: 1,
      limit: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cache the provider instance to avoid multiple calls
    final provider = _getSearchProvider();
    _currentProvider = provider; // Store for use in _loadMore
    final searchResult = ref.watch(provider);

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
            child: searchResult.when(
              data: (response) {
                // Always wrap in RefreshIndicator, even for empty state
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(provider);
                  },
                  child: response.data.isEmpty
                      ? SingleChildScrollView(
                          // Don't use scroll controller for empty state
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: _buildEmptyState(),
                          ),
                        )
                      : ListView.builder(
                          // Only attach scroll controller when there's data
                          controller: response.pagination.hasNextPage
                              ? _scrollController
                              : null,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: response.data.length +
                              (response.pagination.hasNextPage ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == response.data.length) {
                              // Loading indicator for pagination
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            return _buildAttendanceCard(response.data[index]);
                          },
                        ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState(error),
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

  Widget _buildAttendanceCard(SearchedAttendance record) {
    // Parse date string to DateTime (convert UTC to local)
    final recordDate = DateTime.parse(record.date).toLocal();
    final dateStr = DateFormat('MMM d, yyyy').format(recordDate);

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (record.status) {
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

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AttendanceDetailScreen(attendance: record),
          ),
        );
      },
      child: Container(
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
                    record.dayOfWeek,
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
                        ? DateFormat('hh:mm a')
                            .format(DateTime.parse(record.checkInTime!).toLocal())
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
                        ? DateFormat('hh:mm a')
                            .format(DateTime.parse(record.checkOutTime!).toLocal())
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
                    record.hoursWorked != null
                        ? '${record.hoursWorked!.toStringAsFixed(1)}h'
                        : '--',
                    AppColors.secondary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildDetailItem(
                    Icons.location_on,
                    'Location',
                    record.checkInAddress ?? 'Not available',
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
                        Icon(Icons.list,
                            size: 18.sp, color: AppColors.textPrimary),
                        SizedBox(width: 8.w),
                        const Text('All Days'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: AttendanceFilter.present,
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            size: 18.sp, color: AppColors.success),
                        SizedBox(width: 8.w),
                        const Text('Present'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: AttendanceFilter.absent,
                    child: Row(
                      children: [
                        Icon(Icons.cancel,
                            size: 18.sp, color: AppColors.error),
                        SizedBox(width: 8.w),
                        const Text('Absent'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: AttendanceFilter.leave,
                    child: Row(
                      children: [
                        Icon(Icons.event_busy,
                            size: 18.sp, color: const Color(0xFFFF9800)),
                        SizedBox(width: 8.w),
                        const Text('Leave'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: AttendanceFilter.halfDay,
                    child: Row(
                      children: [
                        Icon(Icons.schedule,
                            size: 18.sp, color: const Color(0xFFFFEB3B)),
                        SizedBox(width: 8.w),
                        const Text('Half-Day'),
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

  Widget _buildErrorState(Object error) {
    // Check if error is OfflineException (typed exception)
    final isOffline = error is OfflineException ||
        (error is DioException && error.error is OfflineException);

    if (isOffline) {
      return NoInternetScreen(
        onRetry: () => ref.invalidate(_getSearchProvider()),
      );
    }

    // Show generic error state for other errors
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: AppColors.error.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'Error loading attendance',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(_getSearchProvider());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
