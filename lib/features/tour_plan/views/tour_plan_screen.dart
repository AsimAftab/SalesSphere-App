import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sales_sphere/features/tour_plan/models/tour_plan.model.dart';
import 'package:sales_sphere/features/tour_plan/vm/tour_plan.vm.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';

enum TourFilter { all, pending, approved, rejected }

class TourPlanScreen extends ConsumerStatefulWidget {
  const TourPlanScreen({super.key});

  @override
  ConsumerState<TourPlanScreen> createState() => _TourPlanScreenState();
}

class _TourPlanScreenState extends ConsumerState<TourPlanScreen> {
  final TextEditingController _searchController = TextEditingController();
  TourFilter _activeFilter = TourFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDateRange(String start, String end) {
    try {
      final startDate = DateTime.parse(start);
      final endDate = DateTime.parse(end);
      final formatter = DateFormat('MMM dd, yyyy');
      return '${formatter.format(startDate)} - ${formatter.format(endDate)}';
    } catch (e) {
      return '$start - $end';
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
    final tourPlansAsync = ref.watch(filteredTourPlansProvider);
    final searchQuery = ref.watch(tourSearchQueryProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Tour Plans',
          style: TextStyle(
            color: AppColors.textdark,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textdark),
          onPressed: () => context.pop(),
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
              Container(
                height: 120.h,
                color: Colors.transparent,
              ),
              // Search Bar Section - Matched to Expense Claims
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => ref.read(tourSearchQueryProvider.notifier).update(v),
                  decoration: InputDecoration(
                    hintText: 'Search tours',
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
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey.shade400, size: 20.sp),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(tourSearchQueryProvider.notifier).update('');
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                ),
              ),

              // Filter Dropdown - Matched to Expense Claims
              _buildFilterDropdown(),

              SizedBox(height: 12.h),

              Container(
                color: Colors.transparent,
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                child: Row(
                  children: [
                    Text(
                      'My Plans',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textdark,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: tourPlansAsync.when(
                  data: (plans) {
                    final filtered = _applyStatusFilter(plans);
                    if (filtered.isEmpty) {
                      return Center(child: Text("No tour plans found"));
                    }
                    return RefreshIndicator(
                      onRefresh: () => ref.read(tourPlanViewModelProvider.notifier).refresh(),
                      color: AppColors.primary,
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) => _buildTourCard(filtered[index]),
                      ),
                    );
                  },
                  loading: () => Skeletonizer(
                    enabled: true,
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
                      itemCount: 5,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        return Container(
                          height: 130.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        );
                      },
                    ),
                  ),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-tour'),
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: Icon(Icons.add, color: Colors.white, size: 20.sp),
        label: Text(
          'Add Tour',
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

  Widget _buildTourCard(TourPlanListItem plan) {
    final statusColor = _getStatusColor(plan.status);

    return GestureDetector(
      onTap: () => context.pushNamed('edit-tour', pathParameters: {'tourId': plan.id}),
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
            // Row 1: Title and Status Tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    plan.placeOfVisit,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textdark,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    plan.status.isNotEmpty
                        ? '${plan.status[0].toUpperCase()}${plan.status.substring(1)}'
                        : '',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Row 2: Date Range
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16.sp,
                  color: Colors.grey.shade400,
                ),
                SizedBox(width: 8.w),
                Text(
                  _formatDateRange(plan.startDate, plan.endDate),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Row 3: Duration
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16.sp,
                  color: Colors.grey.shade400,
                ),
                SizedBox(width: 8.w),
                Text(
                  '${plan.durationDays} days',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<TourPlanListItem> _applyStatusFilter(List<TourPlanListItem> plans) {
    if (_activeFilter == TourFilter.all) return plans;
    return plans.where((p) => p.status.toLowerCase() == _activeFilter.name).toList();
  }

  Widget _buildFilterDropdown() {
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
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<TourFilter>(
                value: _activeFilter,
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
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                items: [
                  DropdownMenuItem(
                    value: TourFilter.all,
                    child: Row(
                      children: [
                        Icon(Icons.list, size: 18.sp, color: AppColors.textdark),
                        SizedBox(width: 8.w),
                        const Text('All Plans'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: TourFilter.pending,
                    child: Row(
                      children: [
                        Icon(Icons.pending, size: 18.sp, color: Colors.orange),
                        SizedBox(width: 8.w),
                        const Text('Pending'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: TourFilter.approved,
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 18.sp, color: Colors.green),
                        SizedBox(width: 8.w),
                        const Text('Approved'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: TourFilter.rejected,
                    child: Row(
                      children: [
                        Icon(Icons.cancel, size: 18.sp, color: Colors.red),
                        SizedBox(width: 8.w),
                        const Text('Rejected'),
                      ],
                    ),
                  ),
                ],
                onChanged: (TourFilter? newFilter) {
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
}