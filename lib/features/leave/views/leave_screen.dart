import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/features/leave/models/leave.model.dart';
import 'package:sales_sphere/features/leave/vm/leave.vm.dart';

class LeaveScreen extends ConsumerStatefulWidget {
  const LeaveScreen({super.key});

  @override
  ConsumerState<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends ConsumerState<LeaveScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date).toLocal();
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return date;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch filteredLeavesProvider which handles both search and status filtering
    final leavesAsync = ref.watch(filteredLeavesProvider);
    final searchQuery = ref.watch(leaveSearchQueryProvider);
    final currentFilter = ref.watch(leaveFilterProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textdark),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Leave Requests',
          style: TextStyle(
            color: AppColors.textdark,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/images/corner_bubble.svg',
              fit: BoxFit.cover,
              height: 180.h,
            ),
          ),
          Column(
            children: [
              SizedBox(height: 110.h),
              _buildSearchBar(searchQuery),
              _buildFilterDropdown(currentFilter),
              SizedBox(height: 12.h),
              Expanded(
                child: leavesAsync.when(
                  data: (items) {
                    return RefreshIndicator(
                      onRefresh: () =>
                          ref.read(leaveViewModelProvider.notifier).refresh(),
                      color: AppColors.primary,
                      child: items.isEmpty
                          ? _buildEmptyState(searchQuery)
                          : ListView.separated(
                              padding: EdgeInsets.fromLTRB(
                                16.w,
                                8.h,
                                16.w,
                                80.h,
                              ),
                              itemCount: items.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: 16.h),
                              itemBuilder: (context, index) =>
                                  _buildLeaveCard(items[index]),
                            ),
                    );
                  },
                  loading: () => _buildLoadingSkeleton(),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/apply-leave');
          // Refresh the list when returning from apply leave screen
          if (mounted) {
            ref.invalidate(leaveViewModelProvider);
          }
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: Icon(Icons.add, color: Colors.white, size: 20.sp),
        label: Text(
          'Apply Leave',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(String query) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      child: TextField(
        controller: _searchController,
        onChanged: (val) =>
            ref.read(leaveSearchQueryProvider.notifier).updateQuery(val),
        decoration: InputDecoration(
          hintText: 'Search leave request',
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14.sp,
            fontFamily: 'Poppins',
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade400,
            size: 20.sp,
          ),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey.shade400,
                    size: 20.sp,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(leaveSearchQueryProvider.notifier).updateQuery('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(LeaveFilter currentFilter) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
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
          Icon(Icons.filter_list, size: 20.sp, color: AppColors.primary),
          SizedBox(width: 12.w),
          Text(
            'Filter:',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textdark,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<LeaveFilter>(
                value: currentFilter,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontFamily: 'Poppins',
                ),
                items: [
                  _dropdownItem(
                    LeaveFilter.all,
                    'All Requests',
                    Icons.list,
                    AppColors.textdark,
                  ),
                  _dropdownItem(
                    LeaveFilter.pending,
                    'Pending',
                    Icons.pending,
                    Colors.orange,
                  ),
                  _dropdownItem(
                    LeaveFilter.approved,
                    'Approved',
                    Icons.check_circle,
                    Colors.green,
                  ),
                  _dropdownItem(
                    LeaveFilter.rejected,
                    'Rejected',
                    Icons.cancel,
                    Colors.red,
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    ref.read(leaveFilterProvider.notifier).setFilter(val);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  DropdownMenuItem<LeaveFilter> _dropdownItem(
    LeaveFilter value,
    String label,
    IconData icon,
    Color color,
  ) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: color),
          SizedBox(width: 8.w),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildLeaveCard(LeaveListItem item) {
    final statusColor = _getStatusColor(item.status);
    final isPending = item.status.toLowerCase() == 'pending';

    return InkWell(
      onTap: () async {
        await context.push('/edit-leave/${item.id}');
        // Refresh the list when returning from edit leave screen
        if (mounted) {
          ref.invalidate(leaveViewModelProvider);
        }
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        item.leaveIcon,
                        size: 20.sp,
                        color: AppColors.textdark,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          item.displayLeaveType,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textdark,
                            fontFamily: 'Poppins',
                            height: 1.2,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    item.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _infoRow(
              Icons.calendar_today_outlined,
              '${_formatDate(item.startDate)} - ${_formatDate(item.endDate)}',
            ),
            if (item.leaveDays != null) ...[
              SizedBox(height: 8.h),
              _infoRow(
                Icons.event_available_outlined,
                '${item.leaveDays} ${item.leaveDays == 1 ? 'day' : 'days'}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey.shade400),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey.shade600,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingSkeleton() => Skeletonizer(
    enabled: true,
    child: ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
      itemCount: 4,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (_, __) => Container(
        height: 120.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    ),
  );

  Widget _buildEmptyState(String query) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.event_busy_outlined,
          size: 64.sp,
          color: Colors.grey.shade300,
        ),
        SizedBox(height: 16.h),
        Text(
          query.isEmpty ? 'No leave requests found' : 'No results for "$query"',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey.shade600,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Pull down to refresh',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade400,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    ),
  );
}
