import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/features/parties/vm/edit_party.vm.dart';
import 'package:sales_sphere/features/parties/vm/parties.vm.dart';
import 'package:sales_sphere/widget/universal_list_card.dart';

class PartiesScreen extends ConsumerStatefulWidget {
  const PartiesScreen({super.key});

  @override
  ConsumerState<PartiesScreen> createState() => _PartiesScreenState();
}

class _PartiesScreenState extends ConsumerState<PartiesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(searchQueryProvider.notifier).updateQuery(query);
  }

  void _navigateToPartyDetails(String partyId) {
    context.pushNamed(
      'edit_party_details_screen',
      pathParameters: {'partyId': partyId},
    );
  }

  void _navigateToAddParty() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Add Party screen coming soon!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
    final searchQuery = ref.watch(searchQueryProvider);
    final searchedPartiesAsync = ref.watch(searchedPartiesProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Parties',
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
              // Parties Header
              Container(
                color: Colors.transparent,
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Parties',
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
              // Party List
              Expanded(
                child: searchedPartiesAsync.when(
                  data: (parties) {
                    if (parties.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64.sp,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              searchQuery.isEmpty
                                  ? 'No parties found'
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
                        await ref.read(partyViewModelProvider.notifier).refresh();
                      },
                      color: AppColors.primary,
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
                        itemCount: parties.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final party = parties[index];
                          return UniversalListCard(
                            leadingIcon: Icon(
                              Icons.person_outline,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                            isLeadingCircle: true,
                            leadingBackgroundColor: AppColors.primary,
                            leadingSize: 48.w,
                            title: party.name,
                            subtitle: _extractLocation(party.fullAddress),
                            onTap: () => _navigateToPartyDetails(party.id),
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
                        // Use your REAL card with placeholder data
                        return UniversalListCard(
                          leadingIcon: Icon(
                            Icons.person_outline,
                            // 1. SET ICON COLOR (so it's not white)
                            color: AppColors.primary,
                            size: 24.sp,
                          ),
                          isLeadingCircle: true,
                          // 2. SET LEADING BACKGROUND TO TRANSPARENT
                          leadingBackgroundColor: Colors.transparent,
                          leadingSize: 48.w,
                          title: "Party Name Placeholder",
                          subtitle: "Address placeholder",
                          onTap: () {},
                          showArrow: true,
                          // 3. SET ARROW BACKGROUND TO TRANSPARENT
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
                          'Failed to load parties',
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
                            ref.read(partyViewModelProvider.notifier).refresh();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 12.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            'Retry',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
        onPressed: _navigateToAddParty,
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: Icon(
          Icons.add,
          color: Colors.white,
          size: 20.sp,
        ),
        label: Text(
          'Add Party',
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