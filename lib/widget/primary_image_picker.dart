import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';

/// Reusable Image Picker Component
///
/// A polished image picker widget that supports single or multiple image uploads.
/// Features:
/// - Empty state with add prompt
/// - Image thumbnails with preview
/// - Remove functionality
/// - Full-screen image preview with zoom/pan
/// - Customizable max images
/// - Network image support for edit scenarios
///
/// Usage for single image with network support (Party edit):
/// ```dart
/// PrimaryImagePicker(
///   images: _selectedImage != null ? [_selectedImage!] : [],
///   networkImageUrl: _currentParty?.imageUrl,
///   maxImages: 1,
///   label: 'Party Image',
///   enabled: _isEditMode,
///   onPick: _pickImage,
///   onRemove: (index) => setState(() => _selectedImage = null),
///   onReplace: () => _pickImage(),
/// )
/// ```
///
/// Usage for new image (Party add, Expense):
/// ```dart
/// PrimaryImagePicker(
///   images: _selectedImage != null ? [_selectedImage!] : [],
///   maxImages: 1,
///   label: 'Receipt Image',
///   onPick: _pickImage,
///   onRemove: (index) => setState(() => _selectedImage = null),
/// )
/// ```
///
/// Usage for multiple images (Notes):
/// ```dart
/// PrimaryImagePicker(
///   images: _selectedImages,
///   maxImages: 2,
///   label: 'Upload Images (Optional)',
///   onPick: _pickImage,
///   onRemove: (index) => setState(() => _selectedImages.removeAt(index)),
/// )
/// ```
class PrimaryImagePicker extends StatelessWidget {
  /// List of selected local images
  final List<XFile> images;

  /// Network image URL (for edit scenarios showing existing image)
  final String? networkImageUrl;

  /// Maximum number of images allowed
  final int maxImages;

  /// Label text above the picker
  final String? label;

  /// Empty state hint text
  final String? hintText;

  /// Callback when pick is triggered
  final VoidCallback onPick;

  /// Callback when an image is removed
  final void Function(int index) onRemove;

  /// Callback when replacing network image with new one
  final VoidCallback? onReplace;

  /// Whether the picker is enabled for editing
  final bool enabled;

  /// Whether to show the label
  final bool showLabel;

  const PrimaryImagePicker({
    super.key,
    required this.images,
    this.networkImageUrl,
    this.maxImages = 1,
    this.label,
    this.hintText,
    required this.onPick,
    required this.onRemove,
    this.onReplace,
    this.enabled = true,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocalImage = images.isNotEmpty;
    final hasNetworkImage = networkImageUrl != null && networkImageUrl!.isNotEmpty;
    final hasAnyImage = hasLocalImage || hasNetworkImage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && showLabel) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 8.h),
        ],

        // Show network image if exists and no local image selected
        if (hasNetworkImage && !hasLocalImage)
          _buildNetworkImageThumbnail(context),

        // Show local images
        ...List.generate(images.length, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 0),
            child: _buildImageThumbnail(context, images[index], index),
          );
        }),

        // Show empty state only if NO images at all (no network, no local)
        if (!hasAnyImage) _buildEmptyState(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPick : null,
      child: Container(
        height: maxImages == 1 ? 120.h : 100.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: enabled ? const Color(0xFFE0E0E0) : Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: maxImages == 1 ? 40.sp : 32.sp,
              color: enabled ? Colors.grey.shade400 : Colors.grey.shade300,
            ),
            SizedBox(height: maxImages == 1 ? 8.h : 4.h),
            Text(
              hintText ??
                  (maxImages == 1
                      ? 'Tap to add image'
                      : 'Tap to add image (${images.length}/$maxImages)'),
              style: TextStyle(
                fontSize: 12.sp,
                color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(BuildContext context, XFile imageFile, int index) {
    final isSingleImage = maxImages == 1;

    return GestureDetector(
      onTap: () => _showImagePreview(context, imageFile),
      child: Container(
        height: isSingleImage ? 200.h : 140.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.file(
                File(imageFile.path),
                width: double.infinity,
                height: isSingleImage ? 200.h : 140.h,
                fit: BoxFit.cover,
              ),
            ),
            // Preview overlay indicator (only for single image)
            if (isSingleImage)
              Positioned(
                bottom: 8.h,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.zoom_in,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Tap to preview',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Preview tag for multiple images
            if (!isSingleImage)
              Positioned(
                bottom: 8.h,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.zoom_in, color: Colors.white, size: 14.sp),
                      SizedBox(width: 4.w),
                      Text(
                        'Preview',
                        style: TextStyle(color: Colors.white, fontSize: 10.sp),
                      ),
                    ],
                  ),
                ),
              ),
            // Close button
            Positioned(
              top: 8.h,
              right: 8.w,
              child: GestureDetector(
                onTap: () => onRemove(index),
                child: Container(
                  padding: EdgeInsets.all(isSingleImage ? 6.w : 4.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: isSingleImage ? 20.sp : 16.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkImageThumbnail(BuildContext context) {
    return GestureDetector(
      onTap: () => _showNetworkImagePreview(context),
      child: Container(
        height: 200.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                networkImageUrl!,
                width: double.infinity,
                height: 200.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          size: 40.sp,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Failed to load image",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Preview overlay indicator
            Positioned(
              bottom: 8.h,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.zoom_in,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Tap to preview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Change/remove button (only if enabled)
            if (enabled)
              Positioned(
                top: 8.h,
                right: 8.w,
                child: GestureDetector(
                  onTap: onReplace,
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showImagePreview(BuildContext context, XFile imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(16.w),
          child: Stack(
            children: [
              // Image container
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.file(
                      File(imageFile.path),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              // Close button
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
              // Info text at bottom
              Positioned(
                bottom: 16.h,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'Pinch to zoom • Drag to pan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNetworkImagePreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(16.w),
          child: Stack(
            children: [
              // Image container
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.network(
                      networkImageUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                size: 40.sp,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                "Failed to load image",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Close button
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
              // Info text at bottom
              Positioned(
                bottom: 16.h,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'Pinch to zoom • Drag to pan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Helper function to show image picker bottom sheet
Future<XFile?> showImagePickerSheet(BuildContext context) async {
  final picker = ImagePicker();
  XFile? image;

  await showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                context.pop();
                image = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 70,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () async {
                context.pop();
                image = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 70,
                );
              },
            ),
          ],
        ),
      );
    },
  );

  return image;
}
