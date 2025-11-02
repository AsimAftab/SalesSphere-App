import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/features/catalog/vm/catalog_item.vm.dart';
import 'package:sales_sphere/widget/universal_list_card.dart';

class CategoryItemListScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryItemListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  ConsumerState<CategoryItemListScreen> createState() =>
      _CategoryItemListScreenState();
}

class _CategoryItemListScreenState
    extends ConsumerState<CategoryItemListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(itemListSearchQueryProvider.notifier).updateQuery(query);
  }

  void _navigateToItemDetails(String itemId) {
    context.pushNamed(
      'catalog_item_details',
      pathParameters: {
        'categoryId': widget.categoryId, // Pass the current categoryId
        'itemId': itemId,                  // Pass the selected itemId
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(itemListSearchQueryProvider);
    final searchedItemsAsync =
    ref.watch(searchedCategoryItemsProvider(widget.categoryId));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textdark),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.categoryName,
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
              height: 160.h,
            ),
          ),
          Column(
            children: [
              Container(
                height: 100.h, // Spacer height
                color: Colors.transparent,
              ),
              Container(
                color: Colors.transparent,
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search within ${widget.categoryName}',
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
                      borderSide:
                      BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Items',
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
                child: searchedItemsAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64.sp,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              searchQuery.isEmpty
                                  ? 'No items found in this category'
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
                        await ref
                            .read(categoryItemListViewModelProvider(
                            widget.categoryId)
                            .notifier)
                            .refresh();
                      },
                      color: AppColors.primary,
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return UniversalListCard(
                            leadingImageAsset: item.imageAssetPath,
                            isLeadingCircle: false,
                            leadingSize: 56.w,
                            leadingBackgroundColor: Colors.transparent, // Or light grey
                            title: item.name,
                            subtitle: item.subCategory ?? 'View Details',
                            secondarySubtitle: item.sku,
                            showArrow: true,
                            arrowColor: AppColors.primary,
                            onTap: () => _navigateToItemDetails(item.id),
                          );
                        },
                      ),
                    );
                  },
                  // --- UPDATED LOADING BLOCK ---
                  loading: () => Skeletonizer(
                    enabled: true,
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
                      itemCount: 8, // Number of skeleton items
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        // Use your REAL card with placeholder data
                        // This card matches your item list (with 2 subtitles)
                        return UniversalListCard(
                          leadingImageAsset: null,
                          isLeadingCircle: false,
                          leadingSize: 56.w,
                          leadingBackgroundColor: Colors.transparent,
                          title: "Item Name Placeholder",
                          subtitle: "Category Placeholder",
                          secondarySubtitle: "SKU-XXXXXX",
                          showArrow: true,
                          arrowColor: AppColors.transparent,
                          onTap: () {},
                        );
                      },
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Padding( // Add padding around error
                      padding: EdgeInsets.all(32.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          SizedBox(height: 16.h),
                          Text(
                            'Failed to load items',
                            style: TextStyle(fontSize: 16.sp, color: AppColors.textdark),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            error.toString(),
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                            textAlign: TextAlign.center,
                          ),
                          // Optionally add a retry button
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: () => ref.invalidate(searchedCategoryItemsProvider(widget.categoryId)),
                            child: const Text('Retry'),
                          )
                        ],
                      ),
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