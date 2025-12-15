import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/features/utilities/models/utilities.model.dart';
import 'package:sales_sphere/features/utilities/vm/utilities.vm.dart';
import 'package:sales_sphere/core/providers/user_controller.dart';

class UtilitiesScreen extends ConsumerWidget {
  const UtilitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final utilities = ref.watch(utilitiesViewModelProvider);
    final user = ref.watch(userControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Utilities',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1C1E),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Access additional field tools and actions',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  // Avatar
                  Container(
                    height: 48.w,
                    width: 48.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person,
                        color: Colors.grey.shade400,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 32.h),

              // Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: utilities.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  // Adjusted aspect ratio for card sizing
                  childAspectRatio: 0.99,
                ),
                itemBuilder: (context, index) {
                  final item = utilities[index];
                  return _buildUtilityCard(context, item);
                },
              ),

              SizedBox(height: 80.h), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUtilityCard(BuildContext context, UtilityItem item) {
    return GestureDetector(
      onTap: () => context.push(item.routePath),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          // Border color matches the icon color with opacity
          border: Border.all(color: item.color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: item.backgroundColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                item.icon,
                color: item.color,
                size: 22.sp,
              ),
            ),
            SizedBox(height: 10.h),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1C1E),
                      fontFamily: 'Poppins',
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Flexible(
                    child: Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey.shade600,
                        height: 1.2,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}