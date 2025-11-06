import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/features/catalog/vm/catalog_item_details.vm.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CatalogItemDetailsScreen extends ConsumerWidget {
  final String itemId;

  const CatalogItemDetailsScreen({
    super.key,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemDetailsAsync = ref.watch(catalogItemDetailsProvider(itemId));

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
          // Show "Details" while loading, then show the item name
          itemDetailsAsync.maybeWhen(
            data: (item) => item.name,
            orElse: () => 'Details',
          ),
          style: TextStyle(
            color: AppColors.textdark,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: itemDetailsAsync.when(
        data: (item) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280.h,
                flexibleSpace: FlexibleSpaceBar(
                  background: item.imageAssetPath != null
                      ? Image.asset(
                          item.imageAssetPath!,
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                            return _buildImagePlaceholder();
                          },
                        )
                      : _buildImagePlaceholder(),
                ),
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.r),
                      topRight: Radius.circular(24.r),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Item Name and Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textdark,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Rs ${item.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),

                        // Category and SKU
                        Text(
                          'Category: ${item.subCategory ?? item.categoryName}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            item.sku ?? 'N/A',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Material and Origin Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                title: 'Material',
                                value: item.material ?? 'N/A',
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: _buildInfoCard(
                                title: 'Origin',
                                value: item.origin ?? 'N/A',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        // Key Features
                        Text(
                          'Key Features',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textdark,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 12.h),
                        if (item.material != null) _buildBulletPoint('Material: ${item.material}'),
                        if (item.finish != null) _buildBulletPoint('Finish: ${item.finish}'),
                        if (item.application != null) _buildBulletPoint('Application: ${item.application}'),
                        if (item.durability != null) _buildBulletPoint('Durability: ${item.durability}'),
                        SizedBox(height: 24.h),

                        // In Stock
                        Text(
                          'In Stock: ${item.inStockSqFt} sq ft',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textdark,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => Skeletonizer(
          enabled: true,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280.h,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: Colors.grey.shade300,
                  ),
                ),
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.r),
                      topRight: Radius.circular(24.r),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Item Name Placeholder',
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                            Text(
                              'Rs 000.00',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Category: SubCategory Placeholder',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'SKU-XXXXXX',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Row(
                          children: [
                            Expanded(child: _buildInfoCard(title: 'Material', value: 'Placeholder')),
                            SizedBox(width: 16.w),
                            Expanded(child: _buildInfoCard(title: 'Origin', value: 'Placeholder')),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          'Key Features',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _buildBulletPoint('Material: Placeholder'),
                        _buildBulletPoint('Finish: Placeholder'),
                        _buildBulletPoint('Application: Placeholder'),
                        _buildBulletPoint('Durability: Placeholder'),
                        SizedBox(height: 24.h),
                        Text(
                          'In Stock: 0000 sq ft',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16.h),
                Text(
                  'Failed to load item details',
                  style: TextStyle(fontSize: 16.sp, color: AppColors.textdark),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  error.toString(),
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => ref.invalidate(catalogItemDetailsProvider(itemId)),
                  child: const Text('Retry'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for Material/Origin cards
  Widget _buildInfoCard({required String title, required String value}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
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

  // Helper widget for bullet points in Key Features
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6.h), // Align bullet with text
            child: Icon(Icons.circle, size: 6.sp, color: AppColors.textdark),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.textdark,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A placeholder widget to display when the item image fails to load.
  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        // Use a clean gradient
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.8),
            AppColors.secondary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined, // A generic "product" icon
          color: Colors.white.withValues(alpha: 0.7),
          size: 80.sp,
        ),
      ),
    );
  }
}