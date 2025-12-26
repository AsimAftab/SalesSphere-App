import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/features/miscellaneous/vm/miscellaneous_list.vm.dart';
import 'package:sales_sphere/widget/universal_list_card.dart';
import 'package:sales_sphere/widget/error_handler_widget.dart';

class MiscellaneousListScreen extends ConsumerStatefulWidget {
  const MiscellaneousListScreen({super.key});

  @override
  ConsumerState<MiscellaneousListScreen> createState() => _MiscellaneousListScreenState();
}

class _MiscellaneousListScreenState extends ConsumerState<MiscellaneousListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(miscListSearchQueryProvider.notifier).updateQuery(query);
  }

  void _navigateToWorkDetails(String workId) {
    // Find the work data by ID and navigate to edit screen
    final worksAsync = ref.read(miscellaneousListViewModelProvider);
    worksAsync.whenData((works) {
      final work = works.firstWhere((w) => w.id == workId);
      context.push('/edit-miscellaneous-work', extra: work);
    });
  }

  void _navigateToAddWork() {
    context.push('/add-miscellaneous-work');
  }

  String _extractLocation(String fullAddress) {
    final parts = fullAddress.split(',');
    if (parts.length >= 2) {
      return '${parts[0].trim()}, ${parts[1].trim()}';
    }
    return fullAddress.length > 30
        ? '${fullAddress.substring(0, 30)}...'
        : fullAddress;
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(miscListSearchQueryProvider);
    final searchedWorksAsync = ref.watch(searchedMiscWorksProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Miscellaneous Work',
          style: TextStyle(
            color: AppColors.textdark,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
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
              Container(
                height: 120.h,
                color: Colors.transparent,
              ),
              // Search Bar Section
              Container(
                color: Colors.transparent,
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search',
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
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey.shade400,
                        size: 20.sp,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
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
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ),
              // Work List Header
              Container(
                color: Colors.transparent,
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Work Items',
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
              // Work List
              Expanded(
                child: searchedWorksAsync.when(
                  data: (works) {
                    if (works.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.work_outline,
                              size: 64.sp,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              searchQuery.isEmpty
                                  ? 'No work items found'
                                  : 'No results for "$searchQuery"',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey.shade600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(miscellaneousListViewModelProvider.notifier).refresh();
                      },
                      color: AppColors.primary,
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
                        itemCount: works.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final work = works[index];
                          return UniversalListCard(
                            leadingIcon: Icon(
                              Icons.work_outline,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                            isLeadingCircle: true,
                            leadingBackgroundColor: const Color(0xFFFF9100), // Orange
                            leadingSize: 48.w,
                            title: work.natureOfWork,
                            subtitle: _extractLocation(work.address),
                            secondarySubtitle: 'Assigned by: ${work.assignedBy}',
                            onTap: () => _navigateToWorkDetails(work.id),
                            showArrow: true,
                            arrowColor: const Color(0xFFFF9100), // Orange arrow
                          );
                        },
                      ),
                    );
                  },
                  loading: () => Skeletonizer(
                    enabled: true,
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
                      itemCount: 7,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        return UniversalListCard(
                          leadingIcon: Icon(
                            Icons.work_outline,
                            color: AppColors.primary,
                            size: 24.sp,
                          ),
                          isLeadingCircle: true,
                          leadingBackgroundColor: Colors.transparent,
                          leadingSize: 48.w,
                          title: "Work Item Placeholder",
                          subtitle: "Address placeholder",
                          onTap: () {},
                          showArrow: true,
                          arrowColor: Colors.transparent,
                        );
                      },
                    ),
                  ),
                  error: (error, stack) => ErrorHandlerConsumer(
                    error: error,
                    onRefresh: (ref) => ref.invalidate(miscellaneousListViewModelProvider),
                    title: 'Failed to load work items',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddWork,
        backgroundColor: const Color(0xFFFF9100), // Orange
        elevation: 4,
        icon: Icon(
          Icons.add,
          color: Colors.white,
          size: 20.sp,
        ),
        label: Text(
          'Add Work',
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
}
