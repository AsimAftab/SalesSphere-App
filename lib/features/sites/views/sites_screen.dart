// lib/features/sites/views/sites_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/features/sites/vm/sites.vm.dart';
import 'package:sales_sphere/widget/universal_list_card.dart';

class SitesScreen extends ConsumerStatefulWidget {
  const SitesScreen({super.key});

  @override
  ConsumerState<SitesScreen> createState() => _SitesScreenState();
}

class _SitesScreenState extends ConsumerState<SitesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(siteSearchQueryProvider.notifier).updateQuery(query);
  }

  void _navigateToSiteDetails(String siteId) {
    context.pushNamed(
      'edit_site_details_screen',
      pathParameters: {'siteId': siteId},
    );
  }

  void _navigateToAddSite() {
    context.push('/add-site');
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(siteSearchQueryProvider);
    final searchedSitesAsync = ref.watch(searchedSitesProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Sites',
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
              // Header
              Container(
                color: Colors.transparent,
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sites',
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
              // Sites List
              Expanded(
                child: searchedSitesAsync.when(
                  data: (sites) {
                    if (sites.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_city_outlined,
                              size: 64.sp,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              searchQuery.isEmpty
                                  ? 'No sites found'
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
                        await ref.read(siteViewModelProvider.notifier).refresh();
                      },
                      color: AppColors.primary,
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
                        itemCount: sites.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final site = sites[index];
                          return UniversalListCard(
                            leadingIcon: Icon(
                              Icons.location_city,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                            isLeadingCircle: true,
                            leadingBackgroundColor: AppColors.primary,
                            leadingSize: 48.w,
                            title: site.name,
                            subtitle: site.location,
                            onTap: () => _navigateToSiteDetails(site.id),
                            showArrow: true,
                            arrowColor: AppColors.primary,
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
                            Icons.location_city,
                            color: AppColors.primary,
                            size: 24.sp,
                          ),
                          isLeadingCircle: true,
                          leadingBackgroundColor: Colors.transparent,
                          leadingSize: 48.w,
                          title: "Site Name Placeholder",
                          subtitle: "Location placeholder",
                          onTap: () {},
                          showArrow: true,
                          arrowColor: Colors.transparent,
                        );
                      },
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64.sp,
                          color: AppColors.error,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Failed to load sites',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.textdark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32.w),
                          child: Text(
                            error.toString(),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(siteViewModelProvider.notifier).refresh();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddSite,
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: Icon(
          Icons.add,
          color: Colors.white,
          size: 20.sp,
        ),
        label: Text(
          'Add Site',
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
