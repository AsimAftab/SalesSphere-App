import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sales_sphere/features/catalog/models/catalog.models.dart';

/// Widget to display product images with initials fallback
///
/// Shows:
/// - Cloudinary image if available (item.image.url)
/// - Local asset image if available (item.imageAssetPath)
/// - Product name initials with colored background if no image
/// - Placeholder icon if no name or image
class ProductImageWidget extends StatelessWidget {
  final CatalogItem item;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const ProductImageWidget({
    super.key,
    required this.item,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  /// Extract initials from product name
  /// Examples: "Premium Cement" -> "PC", "shirt" -> "S", "Red T-Shirt" -> "RT"
  String _getInitials(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return '?';

    final words = trimmedName.split(RegExp(r'\s+'));

    if (words.length >= 2) {
      // Multiple words: take first letter of first two words
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else {
      // Single word: take first letter or first two letters if long enough
      return trimmedName.length > 1
          ? trimmedName.substring(0, 2).toUpperCase()
          : trimmedName[0].toUpperCase();
    }
  }

  /// Generate a consistent color based on product name
  Color _getColorFromName(String name) {
    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFFEC4899), // Pink
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFFF97316), // Orange
      const Color(0xFF14B8A6), // Teal
      const Color(0xFFEF4444), // Red
      const Color(0xFF3B82F6), // Blue
    ];

    // Use hashCode to consistently pick same color for same name
    final index = name.hashCode.abs() % colors.length;
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12.r);

    // Priority 1: Show Cloudinary image if available
    if (item.image?.url != null && item.image!.url!.isNotEmpty) {
      return ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: Image.network(
          item.image!.url!,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2.5,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            // On network error, show initials fallback
            return _buildInitialsWidget();
          },
        ),
      );
    }

    // Priority 2: Show local asset image if available
    if (item.imageAssetPath != null && item.imageAssetPath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: item.imageAssetPath!.endsWith('.svg')
            ? SvgPicture.asset(
                item.imageAssetPath!,
                fit: fit,
                placeholderBuilder: (context) => _buildInitialsWidget(),
              )
            : Image.asset(
                item.imageAssetPath!,
                fit: fit,
                errorBuilder: (context, error, stackTrace) =>
                    _buildInitialsWidget(),
              ),
      );
    }

    // Priority 3: Show product name initials
    return _buildInitialsWidget();
  }

  /// Build widget showing product initials with colored background
  Widget _buildInitialsWidget() {
    final initials = _getInitials(item.name);
    final backgroundColor = _getColorFromName(item.name);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: 'Poppins',
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
