import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/features/catalog/models/catalog.models.dart';
import 'package:sales_sphere/features/catalog/vm/catalog.vm.dart';
import 'package:sales_sphere/features/catalog/vm/catalog_item.vm.dart';
import 'package:sales_sphere/core/providers/order_controller.dart';
import 'package:sales_sphere/widget/product_image_widget.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _categoryScrollController = ScrollController();
  String? _previousSelectedCategoryId;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedCategory(String? selectedCategoryId, List categories) {
    if (selectedCategoryId == null) {
      // Scroll to "All" which is at index 0
      _categoryScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    // Find the index of the selected category (+1 because "All" is at index 0)
    final categoryIndex = categories.indexWhere((c) => c.id == selectedCategoryId);
    if (categoryIndex != -1) {
      // Calculate approximate scroll position
      // Each chip is roughly 100-120 pixels wide with 8 pixels padding
      final scrollPosition = (categoryIndex + 1) * 108.w - 100.w;

      _categoryScrollController.animateTo(
        scrollPosition.clamp(0.0, _categoryScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch all state from Riverpod
    final categoriesAsync = ref.watch(categoriesWithProductsProvider);
    final allItemsAsync = ref.watch(allCatalogItemsProvider);
    final selectedCategoryId = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(catalogSearchQueryProvider);

    // Update controller text when search query changes from external source
    if (_searchController.text != searchQuery) {
      _searchController.text = searchQuery;
    }

    // Auto-scroll to selected category when it changes
    if (_previousSelectedCategoryId != selectedCategoryId) {
      _previousSelectedCategoryId = selectedCategoryId;
      // Schedule scroll after build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_categoryScrollController.hasClients) {
          final categories = categoriesAsync.value ?? [];
          if (categories.isNotEmpty) {
            _scrollToSelectedCategory(selectedCategoryId, categories);
          }
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4FC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
              child: Text(
                'Catalogs',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF202020),
                  fontFamily: 'Poppins',
                ),
              ),
            ),

            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (query) {
                  ref.read(catalogSearchQueryProvider.notifier).updateQuery(query);
                },
                decoration: InputDecoration(
                  hintText: 'Search products or categories...',
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
                            ref.read(catalogSearchQueryProvider.notifier).clearQuery();
                            _searchFocusNode.unfocus();
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
                    borderSide: const BorderSide(color: Color(0xFF1C548C), width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // Horizontal Categories
            categoriesAsync.when(
              data: (categories) {
                final filteredCategories = searchQuery.isEmpty
                    ? categories
                    : categories
                        .where((c) => c.name.toLowerCase().contains(searchQuery.toLowerCase()))
                        .toList();

                return SizedBox(
                  height: 62.h,
                  child: ListView.builder(
                    controller: _categoryScrollController,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: filteredCategories.length + 1, // +1 for "All" button
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // "Select Category" button - navigates to category grid
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: _buildCategoryChip(
                            name: 'All',
                            isSelected: selectedCategoryId == null,
                            onTap: () {
                              _searchFocusNode.unfocus();
                              context.pushNamed('category_selection');
                            },
                          ),
                        );
                      }

                      final category = filteredCategories[index - 1];
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: _buildCategoryChip(
                          name: category.name,
                          imageAssetPath: category.imageAssetPath,
                          isSelected: selectedCategoryId == category.id,
                          onTap: () {
                            ref.read(selectedCategoryProvider.notifier).selectCategory(category.id);
                            ref.read(catalogSearchQueryProvider.notifier).clearQuery();
                          },
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => SizedBox(
                height: 62.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: Container(
                        width: 100.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                    );
                  },
                ),
              ),
              error: (error, stack) => const SizedBox.shrink(),
            ),

            SizedBox(height: 12.h),

            // Products Grid - Optimized to watch only allItems and filter locally
            Expanded(
              child: allItemsAsync.when(
                data: (allItems) {
                  // Filter items by category and search query locally (no provider recreation)
                  var filteredItems = allItems;

                  // Filter by selected category
                  if (selectedCategoryId != null) {
                    filteredItems = filteredItems
                        .where((item) => item.category.id == selectedCategoryId)
                        .toList();
                  }

                  // Filter by search query
                  if (searchQuery.isNotEmpty) {
                    final lowerQuery = searchQuery.toLowerCase();
                    filteredItems = filteredItems.where((item) {
                      return item.name.toLowerCase().contains(lowerQuery) ||
                          (item.sku?.toLowerCase().contains(lowerQuery) ?? false);
                    }).toList();
                  }

                  if (filteredItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64.sp,
                            color: const Color(0xFF7D848D),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No products found',
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: const Color(0xFF7D848D),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          if (searchQuery.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            Text(
                              'Try a different search',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFFA0A0A0),
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  // Build grid
                  return GridView.builder(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.62,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return _ProductCard(item: item);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                      SizedBox(height: 16.h),
                      Text(
                        'Failed to load items',
                        style: TextStyle(fontSize: 16.sp, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String name,
    String? imageAssetPath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1C548C) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            if (imageAssetPath != null) ...[
              ClipOval(
                child: Container(
                  width: 32.w,
                  height: 32.h,
                  color: Colors.grey.shade100,
                  child: imageAssetPath.endsWith('.svg')
                      ? Padding(
                          padding: EdgeInsets.all(4.w),
                          child: SvgPicture.asset(
                            imageAssetPath,
                            fit: BoxFit.contain,
                            placeholderBuilder: (context) => Icon(
                              Icons.category,
                              size: 16.sp,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Image.asset(
                          imageAssetPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.category,
                            size: 16.sp,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
              SizedBox(width: 8.w),
            ],
            Text(
              name,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF4B5563),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Separate widget for product card to optimize rebuilds
class _ProductCard extends ConsumerWidget {
  final CatalogItem item;

  const _ProductCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the order controller to get quantity for this item
    final orderController = ref.watch(orderControllerProvider);
    final quantity = orderController[item.id]?.quantity ?? 0;
    final remainingQty = (item.quantity ?? 0) - quantity;

    return Container(
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
          // Product Image
          Expanded(
            flex: 5,
            child: ProductImageWidget(
              item: item,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
              fit: BoxFit.cover,
            ),
          ),

          // Product Info
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product Name
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0C0C0C),
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),

                  // Price and Quantity Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: remainingQty > 0 ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          remainingQty > 0 ? 'Qty: $remainingQty' : 'Out of Stock',
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w500,
                            color: remainingQty > 0 ? Colors.green.shade700 : Colors.red.shade700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      Text(
                        '₹${(item.price).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1C548C),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Quantity Controls
                  if (quantity > 0)
                    Container(
                      height: 30.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C548C),
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              ref.read(orderControllerProvider.notifier).updateQuantity(item.id, quantity - 1);
                            },
                            child: Container(
                              width: 26.w,
                              height: 26.h,
                              margin: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                quantity == 1 ? Icons.delete_outline : Icons.remove,
                                size: 14.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            '$quantity',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          GestureDetector(
                            onTap: remainingQty > 0
                                ? () {
                                    ref.read(orderControllerProvider.notifier).addItem(item, 1);
                                  }
                                : null,
                            child: Container(
                              width: 26.w,
                              height: 26.h,
                              margin: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: remainingQty > 0
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Colors.grey.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add,
                                size: 14.sp,
                                color: remainingQty > 0 ? Colors.white : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: remainingQty > 0
                          ? () {
                              ref.read(orderControllerProvider.notifier).addItem(item, 1);
                            }
                          : null,
                      child: Container(
                        height: 30.h,
                        decoration: BoxDecoration(
                          color: remainingQty > 0 ? const Color(0xFF1C548C) : Colors.grey,
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              remainingQty > 0 ? Icons.add : Icons.block,
                              size: 14.sp,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              remainingQty > 0 ? 'Add' : 'Out',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
