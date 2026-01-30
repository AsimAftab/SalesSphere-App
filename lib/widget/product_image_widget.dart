import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/catalog/models/catalog.models.dart';

/// Widget to display product images with initials fallback
///
/// Shows:
/// - Cloudinary image if available (item.image.url)
/// - Local asset image if available (item.imageAssetPath)
/// - Product name initials with colored background if no image
/// - Placeholder icon if no name or image
///
/// Tap on image opens full-screen preview with zoom
class ProductImageWidget extends StatefulWidget {
  final CatalogItem item;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const ProductImageWidget({
    super.key,
    required this.item,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  @override
  State<ProductImageWidget> createState() => _ProductImageWidgetState();
}

class _ProductImageWidgetState extends State<ProductImageWidget> {
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

  /// Get the image URL or asset path
  String? get _imageUrl {
    if (widget.item.image?.url != null && widget.item.image!.url!.isNotEmpty) {
      return widget.item.image!.url;
    }
    if (widget.item.imageAssetPath != null && widget.item.imageAssetPath!.isNotEmpty) {
      return widget.item.imageAssetPath;
    }
    return null;
  }

  /// Check if image is available for preview
  bool get _hasImage => _imageUrl != null;

  /// Show full-screen image preview dialog
  void _showImagePreview(BuildContext context) {
    if (!_hasImage) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black,
      builder: (context) => _ImagePreviewDialog(
        imageUrl: _imageUrl!,
        isNetworkImage: widget.item.image?.url != null && widget.item.image!.url!.isNotEmpty,
        productName: widget.item.name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = widget.borderRadius ?? BorderRadius.circular(12.r);

    // Priority 1: Show Cloudinary image if available
    if (widget.item.image?.url != null && widget.item.image!.url!.isNotEmpty) {
      AppLogger.d('📷 Loading image for ${widget.item.name}: ${widget.item.image!.url}');
      return GestureDetector(
        onTap: () => _showImagePreview(context),
        child: ClipRRect(
          borderRadius: effectiveBorderRadius,
          child: SizedBox(
            width: double.infinity,
            child: Image.network(
              widget.item.image!.url!,
              fit: widget.fit,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey.shade100,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2.5,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                AppLogger.e('❌ Error loading image for ${widget.item.name}: $error');
                return _buildInitialsWidget();
              },
            ),
          ),
        ),
      );
    }

    // Log when no image URL found
    AppLogger.d('⚠️ No image URL for ${widget.item.name}, image object: ${widget.item.image}');

    // Priority 2: Show local asset image if available
    if (widget.item.imageAssetPath != null && widget.item.imageAssetPath!.isNotEmpty) {
      return GestureDetector(
        onTap: () => _showImagePreview(context),
        child: ClipRRect(
          borderRadius: effectiveBorderRadius,
          child: SizedBox(
            width: double.infinity,
            child: widget.item.imageAssetPath!.endsWith('.svg')
                ? SvgPicture.asset(
                    widget.item.imageAssetPath!,
                    fit: widget.fit,
                    placeholderBuilder: (context) => _buildInitialsWidget(),
                  )
                : Image.asset(
                    widget.item.imageAssetPath!,
                    fit: widget.fit,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildInitialsWidget(),
                  ),
          ),
        ),
      );
    }

    // Priority 3: Show product name initials
    return _buildInitialsWidget();
  }

  /// Build widget showing product initials with colored background
  Widget _buildInitialsWidget() {
    final initials = _getInitials(widget.item.name);
    final backgroundColor = _getColorFromName(widget.item.name);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12.r),
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

/// Full-screen image preview dialog with zoom support
class _ImagePreviewDialog extends StatelessWidget {
  final String imageUrl;
  final bool isNetworkImage;
  final String productName;

  const _ImagePreviewDialog({
    required this.imageUrl,
    required this.isNetworkImage,
    required this.productName,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full-screen image viewer
        Positioned.fill(
          child: PhotoView(
            imageProvider: isNetworkImage ? NetworkImage(imageUrl) : AssetImage(imageUrl) as ImageProvider,
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 4,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 64.sp, color: Colors.white54),
                      SizedBox(height: 16.h),
                      Text(
                        'Failed to load image',
                        style: TextStyle(color: Colors.white54, fontSize: 14.sp),
                      ),
                    ],
                  ),
                ),
              );
            },
            loadingBuilder: (context, event) {
              return Container(
                color: Colors.black,
                child: Center(
                  child: CircularProgressIndicator(
                    value: event == null
                        ? 0
                        : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ),

        // Top bar with close button
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 28.sp),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      productName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
