import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/features/catalog/models/catalog.model.dart';
import 'package:sales_sphere/features/catalog/vm/catalog.vm.dart';
import 'package:sales_sphere/widget/universal_list_card.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(catalogSearchQueryProvider.notifier).updateQuery(query);
  }

  void _navigateToCategoryDetails(CatalogCategory category) {
    context.pushNamed(
      'catalog_items',
      pathParameters: {'categoryId': category.id},
      extra: category.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(catalogSearchQueryProvider);
    final searchedCategoriesAsync = ref.watch(searchedCategoriesProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Catalogs',
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
          // Background Wave
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

          // Main Content
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

              // Categories Header
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categories',
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

              // Category List
              Expanded(
                child: searchedCategoriesAsync.when(
                  data: (categories) {
                    if (categories.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 64.sp,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              searchQuery.isEmpty
                                  ? 'No categories found'
                                  : 'No results for "$searchQuery"',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(catalogViewModelProvider.notifier).refresh();
                      },
                      color: AppColors.primary,
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        itemCount: categories.length,
                        separatorBuilder: (context, index) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final category = categories[index];

                          return UniversalListCard(
                            leadingImageAsset: category.imageAssetPath,
                            isLeadingCircle: false,
                            leadingSize: 56.w,
                            leadingBackgroundColor: Colors.transparent,
                            title: category.name,
                            subtitle: category.itemCount == null
                                ? 'View items'
                                : '${category.itemCount} items',
                            showArrow: true,
                            arrowColor: AppColors.primary,
                            onTap: () => _navigateToCategoryDetails(category),
                          );
                        },
                      ),
                    );
                  },
                  // --- UPDATED LOADING BLOCK ---
                  loading: () => Skeletonizer(
                    enabled: true,
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      itemCount: 8, // Number of skeleton items
                      separatorBuilder: (context, index) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        // Use your REAL card with placeholder data
                        return UniversalListCard(
                          leadingImageAsset: null,
                          isLeadingCircle: false,
                          leadingSize: 56.w,
                          leadingBackgroundColor: Colors.transparent,
                          title: "Category Name",
                          subtitle: "123 items",
                          showArrow: true,
                          arrowColor: Colors.transparent,
                          onTap: () {},
                        );
                      },
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Text(
                      'Failed to load categories',
                      style: TextStyle(fontSize: 16.sp, color: AppColors.error),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}