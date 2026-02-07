import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/features/catalog/vm/catalog.vm.dart';

class CategorySelectionScreen extends ConsumerStatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  ConsumerState<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState
    extends ConsumerState<CategorySelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'marble':
        return Icons.countertops;
      case 'paints':
        return Icons.format_paint;
      case 'sanitary':
        return Icons.bathroom;
      case 'cpvc':
        return Icons.plumbing;
      case 'ply':
        return Icons.layers;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'marble':
        return const Color(0xFF8B4513);
      case 'paints':
        return const Color(0xFFE91E63);
      case 'sanitary':
        return const Color(0xFF2196F3);
      case 'cpvc':
        return const Color(0xFF4CAF50);
      case 'ply':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF1C548C);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(catalogViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C548C)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Select Category',
          style: TextStyle(
            color: const Color(0xFF1C548C),
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search categories...',
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
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey.shade400,
                          size: 20.sp,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                          FocusScope.of(context).unfocus();
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
                  borderSide: const BorderSide(
                    color: Color(0xFF1C548C),
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),

          // Grid
          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                // Filter categories based on search query
                final filteredCategories = _searchQuery.isEmpty
                    ? categories
                    : categories
                          .where(
                            (c) => c.name.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ),
                          )
                          .toList();

                if (filteredCategories.isEmpty && _searchQuery.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64.sp,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No categories found for "$_searchQuery"',
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

                return GridView.builder(
                  padding: EdgeInsets.all(20.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                  ),
                  itemCount: filteredCategories.length + 1,
                  // +1 for "All Products"
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // "All Products" tile
                      return _buildCategoryTile(
                        context: context,
                        name: 'All Products',
                        icon: Icons.apps,
                        color: const Color(0xFF1C548C),
                        itemCount: null,
                        imageAssetPath: null,
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          ref
                              .read(selectedCategoryProvider.notifier)
                              .clearSelection();
                          context.pop();
                        },
                      );
                    }

                    final category = filteredCategories[index - 1];
                    return _buildCategoryTile(
                      context: context,
                      name: category.name,
                      icon: _getCategoryIcon(category.name),
                      color: _getCategoryColor(category.name),
                      itemCount: category.itemCount,
                      imageAssetPath: category.imageAssetPath,
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        ref
                            .read(selectedCategoryProvider.notifier)
                            .selectCategory(category.id);
                        context.pop();
                      },
                    );
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
                      'Failed to load categories',
                      style: TextStyle(fontSize: 16.sp, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile({
    required BuildContext context,
    required String name,
    required IconData icon,
    required Color color,
    required int? itemCount,
    required String? imageAssetPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image/Icon Container
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: imageAssetPath != null && imageAssetPath.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: imageAssetPath.endsWith('.svg')
                          ? SvgPicture.asset(
                              imageAssetPath,
                              fit: BoxFit.cover,
                              placeholderBuilder: (context) =>
                                  Icon(icon, size: 48.sp, color: color),
                            )
                          : Image.asset(
                              imageAssetPath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(icon, size: 48.sp, color: color),
                            ),
                    )
                  : Icon(icon, size: 48.sp, color: color),
            ),
            SizedBox(height: 12.h),
            // Category Name
            Text(
              name,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1C548C),
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            if (itemCount != null) ...[
              SizedBox(height: 4.h),
              Text(
                '$itemCount items',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
