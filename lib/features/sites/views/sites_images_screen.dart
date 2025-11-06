
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/features/sites/models/sites.model.dart';
import 'package:sales_sphere/features/sites/vm/sites_images.vm.dart';
import 'package:sales_sphere/features/sites/views/sites_images_viewer_screen.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SitesImagesScreen extends ConsumerStatefulWidget {
  final String siteId;
  final String siteName;

  const SitesImagesScreen({
    super.key,
    required this.siteId,
    required this.siteName,
  });

  @override
  ConsumerState<SitesImagesScreen> createState() => _SitesImagesScreenState();
}

class _SitesImagesScreenState extends ConsumerState<SitesImagesScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        _isUploading = true;
      });

      final viewModel = ref.read(siteImagesViewModelProvider.notifier);
      await viewModel.addImage(
        siteId: widget.siteId,
        imageFile: File(pickedFile.path),
      );

      // Refresh the images list
      ref.invalidate(siteImagesProvider(widget.siteId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                SizedBox(width: 12.w),
                const Text('Image added successfully'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    e.toString().replaceAll('Exception: ', ''),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Photo',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: AppColors.textdark,
              ),
            ),
            SizedBox(height: 24.h),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primary, size: 28.sp),
              title: Text(
                'Take Photo',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
              onTap: () {
                context.pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primary, size: 28.sp),
              title: Text(
                'Choose from Gallery',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
              onTap: () {
                context.pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(SiteImage image) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Delete Photo',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        content: Text(
          'Are you sure you want to delete this photo?',
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textdark,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: Text(
              'Delete',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final viewModel = ref.read(siteImagesViewModelProvider.notifier);
        await viewModel.deleteImage(image.id, widget.siteId, image.imageOrder);

        // Refresh the images list
        ref.invalidate(siteImagesProvider(widget.siteId));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                  SizedBox(width: 12.w),
                  const Text('Image deleted successfully'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              margin: EdgeInsets.all(16.w),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete image: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Widget _buildImageCard(SiteImage image, int index, List<SiteImage> allImages) {
    return GestureDetector(
      onTap: () {
        // Navigate to full-screen viewer
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SitesImagesViewerScreen(
              siteId: widget.siteId,
              initialIndex: index,
              images: allImages,
            ),
          ),
        );
      },
      child: Hero(
        tag: image.id,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image - Handle both network URLs and local files
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: image.imageUrl.startsWith('http') || image.imageUrl.startsWith('https')
                    ? Image.network(
                        image.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade300,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade300,
                            child: Icon(
                              Icons.broken_image,
                              size: 40.sp,
                              color: Colors.grey.shade600,
                            ),
                          );
                        },
                      )
                    : Image.file(
                        File(image.imageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade300,
                            child: Icon(
                              Icons.broken_image,
                              size: 40.sp,
                              color: Colors.grey.shade600,
                            ),
                          );
                        },
                      ),
              ),
              // Delete button
              Positioned(
                top: 6.h,   // ✅ Reduced from 8.h
                right: 6.w, // ✅ Reduced from 8.w
                child: GestureDetector(
                  onTap: () => _confirmDelete(image),
                  child: Container(
                    width: 24.w,  // ✅ Reduced from 32.w
                    height: 24.h, // ✅ Reduced from 32.h
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16.sp, // ✅ Reduced from 20.sp
                    ),
                  ),
                ),
              ),
              // Image order badge
              Positioned(
                bottom: 8.h,
                left: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '${image.imageOrder}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ UPDATED: Skeleton placeholder card using Bone widget
  Widget _buildSkeletonCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Bone.square(
          size: 150.sp,
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _isUploading ? null : _showImageSourceDialog,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: _isUploading
              ? CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          )
              : Icon(
            Icons.add,
            size: 48.sp,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagesAsync = ref.watch(siteImagesProvider(widget.siteId));

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
          'Site Images',
          style: TextStyle(
            color: AppColors.textdark,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: imagesAsync.when(
              data: (images) {
                final totalSlots = 9;
                final imageCount = images.length;
                final canAddMore = imageCount < totalSlots;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.h),

                      // Site name
                      Text(
                        widget.siteName,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textdark,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // Description
                      Text(
                        'Add up to 9 photos to showcase this site',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Grid
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.h,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: canAddMore ? imageCount + 1 : imageCount,
                          itemBuilder: (context, index) {
                            if (index < imageCount) {
                              return _buildImageCard(images[index], index, images);
                            } else {
                              return _buildAddButton();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () {
                return Skeletonizer(
                  enabled: true,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.h),

                        // Skeleton site name
                        Bone.text(
                          words: 3,
                          fontSize: 24.sp,
                        ),
                        SizedBox(height: 8.h),

                        // Skeleton description
                        Bone.text(
                          words: 8,
                          fontSize: 14.sp,
                        ),
                        SizedBox(height: 24.h),

                        // Skeleton grid
                        Expanded(
                          child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12.w,
                              mainAxisSpacing: 12.h,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: 9,
                            itemBuilder: (context, index) => _buildSkeletonCard(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              error: (error, stack) => Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.sp,
                        color: AppColors.error,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Failed to load images',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textdark,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        error.toString(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}