// lib/widget/cards/universal_list_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';

class UniversalListCard extends StatelessWidget {
  // Leading configuration
  final Widget? leadingIcon;
  final String? leadingImageUrl;
  final String? leadingImageAsset;
  final bool isLeadingCircle; // true for circle (parties), false for rounded rectangle (catalog/items)
  final Color? leadingBackgroundColor;
  final double? leadingSize;

  // Content
  final String title;
  final String? subtitle;
  final String? secondarySubtitle; // For additional info like SKU

  // Styling
  final Color? backgroundColor;
  final Color? arrowColor;
  final bool showArrow;
  final double? borderRadius;

  // Action
  final VoidCallback onTap;

  const UniversalListCard({
    super.key,
    // Leading
    this.leadingIcon,
    this.leadingImageUrl,
    this.leadingImageAsset,
    this.isLeadingCircle = false,
    this.leadingBackgroundColor,
    this.leadingSize,
    // Content
    required this.title,
    this.subtitle,
    this.secondarySubtitle,
    // Styling
    this.backgroundColor,
    this.arrowColor,
    this.showArrow = true,
    this.borderRadius,
    // Action
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? 16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? 16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // Leading Widget (Icon or Image)
                _buildLeading(),

                SizedBox(width: 16.w),

                // Title & Subtitles
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Primary Subtitle
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade600,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Secondary Subtitle (for SKU, additional info)
                      if (secondarySubtitle != null && secondarySubtitle!.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          secondarySubtitle!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade500,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Arrow Button
                if (showArrow) ...[
                  SizedBox(width: 12.w),
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: arrowColor ?? AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build leading widget based on configuration
  Widget _buildLeading() {
    final size = leadingSize ?? (isLeadingCircle ? 48.w : 60.w);

    // Priority 1: Custom Icon Widget
    if (leadingIcon != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: leadingBackgroundColor ?? AppColors.primary,
          shape: isLeadingCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isLeadingCircle ? null : BorderRadius.circular(12.r),
        ),
        child: Center(child: leadingIcon),
      );
    }

    // Priority 2: Network Image
    if (leadingImageUrl != null && leadingImageUrl!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: isLeadingCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isLeadingCircle ? null : BorderRadius.circular(12.r),
        ),
        child: ClipRRect(
          borderRadius: isLeadingCircle
              ? BorderRadius.circular(size / 2)
              : BorderRadius.circular(12.r),
          child: Image.network(
            leadingImageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.image_outlined,
                size: 32.sp,
                color: Colors.grey.shade400,
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    // Priority 3: Asset Image
    if (leadingImageAsset != null && leadingImageAsset!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: isLeadingCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isLeadingCircle ? null : BorderRadius.circular(12.r),
        ),
        child: ClipRRect(
          borderRadius: isLeadingCircle
              ? BorderRadius.circular(size / 2)
              : BorderRadius.circular(12.r),
          child: Image.asset(
            leadingImageAsset!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.image_outlined,
                size: 32.sp,
                color: Colors.grey.shade400,
              );
            },
          ),
        ),
      );
    }

    // Default: Placeholder
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: isLeadingCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isLeadingCircle ? null : BorderRadius.circular(12.r),
      ),
      child: Icon(
        Icons.help_outline,
        color: Colors.grey.shade400,
        size: 24.sp,
      ),
    );
  }
}