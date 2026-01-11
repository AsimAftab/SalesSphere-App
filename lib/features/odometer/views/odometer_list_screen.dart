import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/features/odometer/model/odometer.model.dart';
import '../vm/odometer_list.vm.dart';

class OdometerListScreen extends ConsumerStatefulWidget {
  const OdometerListScreen({super.key});

  @override
  ConsumerState<OdometerListScreen> createState() => _OdometerListScreenState();
}

class _OdometerListScreenState extends ConsumerState<OdometerListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(odometerListSearchQueryProvider);
    final readingsAsync = ref.watch(searchedOdometerReadingsProvider);
    final selectedMonth = ref.watch(selectedOdometerMonthProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textdark),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Odometer Readings',
          style: TextStyle(
            color: AppColors.textdark,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
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
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      Container(height: 100.h, color: Colors.transparent),

                      // Search Bar
                      _buildSearchBar(searchQuery),

                      // Month Selector
                      _buildMonthSelector(selectedMonth),

                      // Section Header
                      SizedBox(height: 20.h),
                      _buildSectionHeader(),

                      readingsAsync.when(
                        data: (items) {
                          if (items.isEmpty) {
                            return Column(
                              children: [
                                // This creates a flexible gap between the header and the empty state
                                SizedBox(height: constraints.maxHeight * 0.15),
                                _buildEmptyState(selectedMonth),
                              ],
                            );
                          }
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
                            itemCount: items.length,
                            separatorBuilder: (_, __) => SizedBox(height: 12.h),
                            itemBuilder: (context, index) =>
                                _buildOdometerCard(items[index]),
                          );
                        },
                        loading: () => _buildSkeletonList(),
                        error: (err, stack) =>
                            Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 40.h),
                                child: Text('Error: $err'),
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(String searchQuery) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      child: TextField(
        controller: _searchController,
        onChanged: (val) =>
            ref.read(odometerListSearchQueryProvider.notifier).updateQuery(val),
        decoration: InputDecoration(
          hintText: 'Search readings',
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14.sp,
            fontFamily: 'Poppins',
          ),
          prefixIcon: Icon(
              Icons.search, color: Colors.grey.shade400, size: 20.sp),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear, color: Colors.grey.shade400, size: 20.sp),
            onPressed: () {
              _searchController.clear();
              ref.read(odometerListSearchQueryProvider.notifier).updateQuery(
                  '');
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
              horizontal: 16.w, vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildMonthSelector(DateTime selectedMonth) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            constraints: const BoxConstraints(),
            padding: EdgeInsets.all(8.w),
            icon: Icon(Icons.chevron_left, size: 24.sp),
            onPressed: () {
              final newMonth = DateTime(
                  selectedMonth.year, selectedMonth.month - 1);
              ref.read(selectedOdometerMonthProvider.notifier).updateMonth(
                  newMonth);
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(selectedMonth),
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textdark,
              fontFamily: 'Poppins',
            ),
          ),
          IconButton(
            constraints: const BoxConstraints(),
            padding: EdgeInsets.all(8.w),
            icon: Icon(Icons.chevron_right, size: 24.sp),
            onPressed: () {
              final newMonth = DateTime(
                  selectedMonth.year, selectedMonth.month + 1);
              ref.read(selectedOdometerMonthProvider.notifier).updateMonth(
                  newMonth);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: Row(
        children: [
          Text(
            'All Readings',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textdark,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(DateTime selectedMonth) {
    final monthYear = DateFormat('MMMM yyyy').format(selectedMonth);
    return Column( // Remove Center() here if called from the Column above
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.calendar_today_outlined, size: 80.sp,
            color: Colors.grey.shade300),
        SizedBox(height: 24.h),
        Text(
          'No odometer readings',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'for $monthYear',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade400,
            fontFamily: 'Poppins',
          ),
        ),
        // REMOVE: SizedBox(height: 100.h),
      ],
    );
  }

  Widget _buildOdometerCard(OdometerListItem item) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return GestureDetector(
      onTap: () => context.push('/odometer-details/${item.id}'),
      child: Container(
        margin: EdgeInsets.only(bottom: 0),
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
              children: [
                Icon(Icons.calendar_today_outlined, size: 16.sp,
                    color: Colors.grey.shade400),
                SizedBox(width: 8.w),
                Text(
                  dateFormat.format(item.date),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textdark,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _buildInfoRow(Icons.speed_outlined, 'Start meter',
                '${item.startReading.toInt()} km'),
            SizedBox(height: 8.h),
            _buildInfoRow(Icons.speed_outlined, 'End meter',
                '${item.endReading.toInt()} km'),
            SizedBox(height: 8.h),
            _buildInfoRow(Icons.route, 'Total Distance',
                '${item.totalDistance.toInt()} km', isHighlight: true),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {bool isHighlight = false}) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey.shade400),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey.shade500,
              fontSize: 13.sp,
              fontFamily: 'Poppins'),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? AppColors.primary : AppColors.textdark,
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13.sp,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonList() {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
        itemCount: 5,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) => _buildSkeletonCard(),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      height: 130.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }
}