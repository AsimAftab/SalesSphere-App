// lib/features/sites/views/sites_images_viewer_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/features/sites/models/sites.model.dart';
import 'package:sales_sphere/features/sites/vm/sites_images.vm.dart';

class SitesImagesViewerScreen extends ConsumerStatefulWidget {
  final String siteId;
  final int initialIndex;
  final List<SiteImage> images;

  const SitesImagesViewerScreen({
    super.key,
    required this.siteId,
    required this.initialIndex,
    required this.images,
  });

  @override
  ConsumerState<SitesImagesViewerScreen> createState() =>
      _SitesImagesViewerScreenState();
}

class _SitesImagesViewerScreenState
    extends ConsumerState<SitesImagesViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  Future<void> _confirmDelete() async {
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
            onPressed: () => Navigator.of(context).pop(false),
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
            onPressed: () => Navigator.of(context).pop(true),
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
        final deleteImage = ref.read(deleteSiteImageProvider);
        final imageToDelete = widget.images[_currentIndex];
        await deleteImage(imageToDelete.id, widget.siteId);

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

          // Close viewer if last image deleted
          if (widget.images.length == 1) {
            context.pop();
          } else {
            context.pop();
          }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Photo Gallery
          GestureDetector(
            onTap: _toggleControls,
            child: PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: FileImage(File(widget.images[index].imageUrl)),
                  initialScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 4,
                  heroAttributes: PhotoViewHeroAttributes(
                    tag: widget.images[index].id,
                  ),
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 64.sp,
                            color: Colors.white54,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Failed to load image',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              itemCount: widget.images.length,
              loadingBuilder: (context, event) => Center(
                child: CircularProgressIndicator(
                  value: event == null
                      ? 0
                      : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                  color: Colors.white,
                ),
              ),
              backgroundDecoration: const BoxDecoration(
                color: Colors.black,
              ),
              pageController: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),

          // Top Controls (AppBar)
          if (_showControls)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: AppColors.textdark,
                            size: 24.sp,
                          ),
                          onPressed: () => context.pop(),
                        ),
                        // Image Counter
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            '${_currentIndex + 1} / ${widget.images.length}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        // Delete Button
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                            size: 20.sp,
                          ),
                          onPressed: _confirmDelete,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Bottom Controls (Caption & Navigation Indicators)
          if (_showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Caption
                        if (widget.images[_currentIndex].caption != null &&
                            widget.images[_currentIndex].caption!.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.w),
                            margin: EdgeInsets.only(bottom: 16.h),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              widget.images[_currentIndex].caption!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontFamily: 'Poppins',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        // Page Indicators
                        if (widget.images.length > 1)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              widget.images.length,
                                  (index) => Container(
                                width: _currentIndex == index ? 24.w : 8.w,
                                height: 8.h,
                                margin: EdgeInsets.symmetric(horizontal: 4.w),
                                decoration: BoxDecoration(
                                  color: _currentIndex == index
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                            ),
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