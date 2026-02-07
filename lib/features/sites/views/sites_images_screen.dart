import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/sites/models/sites.model.dart';
import 'package:sales_sphere/features/sites/views/sites_images_viewer_screen.dart';
import 'package:sales_sphere/features/sites/vm/sites_images.vm.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

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
  String? _uploadProgress;

  /// Request gallery/photos permission for Android 13+
  Future<bool> _requestGalleryPermission() async {
    if (Platform.isAndroid) {
      // Android 13+ (API 33+) uses photos permission
      final androidInfo = await _getAndroidVersion();
      if (androidInfo >= 33) {
        final status = await Permission.photos.status;
        if (status.isGranted) {
          return true;
        }
        final result = await Permission.photos.request();
        if (result.isGranted) {
          return true;
        }
        // If permanently denied, show settings dialog
        if (result.isPermanentlyDenied) {
          _showPermissionSettingsDialog('Photos');
          return false;
        }
        return false;
      } else {
        // Android < 13 uses storage permission
        final status = await Permission.storage.status;
        if (status.isGranted) {
          return true;
        }
        final result = await Permission.storage.request();
        if (result.isGranted) {
          return true;
        }
        if (result.isPermanentlyDenied) {
          _showPermissionSettingsDialog('Storage');
          return false;
        }
        return false;
      }
    } else if (Platform.isIOS) {
      // iOS uses photos permission
      final status = await Permission.photos.status;
      if (status.isGranted) {
        return true;
      }
      final result = await Permission.photos.request();
      return result.isGranted;
    }
    return true; // Other platforms might not need explicit permission
  }

  /// Request camera permission
  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      return true;
    }
    final result = await Permission.camera.request();
    if (result.isGranted) {
      return true;
    }
    if (result.isPermanentlyDenied) {
      _showPermissionSettingsDialog('Camera');
      return false;
    }
    return false;
  }

  /// Get Android SDK version (approximate)
  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      // Try to get Android version from device info
      // Default to 33 (Android 13) if we can't determine
      try {
        // This is a simplified check - in production you'd use device_info_plus
        return 33;
      } catch (e) {
        return 33;
      }
    }
    return 0;
  }

  /// Show dialog to open app settings
  void _showPermissionSettingsDialog(String permissionType) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Permission Required',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        content: Text(
          '$permissionType permission is permanently denied. Please enable it in app settings.',
          style: TextStyle(fontSize: 14.sp, fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
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
            onPressed: () {
              context.pop();
              openAppSettings();
            },
            child: Text(
              'Open Settings',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Pick and upload multiple images (up to 9)
  Future<void> _pickMultipleImages() async {
    try {
      // Request gallery permission first
      final hasPermission = await _requestGalleryPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: const Text(
                      'Gallery permission is required to select photos',
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
        return;
      }

      // Get current images to check available slots
      final currentImages = await ref.read(
        siteImagesProvider(widget.siteId).future,
      );
      final availableSlots = 9 - currentImages.length;

      if (availableSlots <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(child: const Text('Maximum 9 photos allowed')),
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
        return;
      }

      // Check if widget is still mounted before proceeding
      if (!mounted) return;

      // Pick multiple images using wechat_assets_picker with visual limit
      // Shows "X/availableSlots" counter in the picker UI
      final List<AssetEntity>? pickedAssets = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          maxAssets: availableSlots,
          requestType: RequestType.image,
          textDelegate: const EnglishAssetPickerTextDelegate(),
          specialPickerType: SpecialPickerType.noPreview,
          selectedAssets: [],
        ),
      );

      if (pickedAssets == null || pickedAssets.isEmpty) return;

      // Convert AssetEntity to File for upload
      final List<File> imageFiles = <File>[];
      for (final asset in pickedAssets) {
        final file = await asset.file;
        if (file != null) {
          imageFiles.add(file);
        }
      }

      if (imageFiles.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No images selected'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              margin: EdgeInsets.all(16.w),
            ),
          );
        }
        return;
      }

      final int filesToUpload = imageFiles.length;

      setState(() {
        _isUploading = true;
        _uploadProgress = '0/$filesToUpload';
      });

      // Get dioClient once before the loop to avoid provider disposal issues
      final dio = ref.read(dioClientProvider);
      int successCount = 0;
      int failureCount = 0;

      // Get existing image numbers ONCE before the upload loop (reuse currentImages from earlier)
      final usedImageNumbers = currentImages
          .map((img) => img.imageOrder)
          .toSet();

      // Upload each image
      for (int i = 0; i < imageFiles.length; i++) {
        // Check if widget is still mounted before each upload
        if (!mounted) break;

        try {
          setState(() {
            _uploadProgress = '${i + 1}/$filesToUpload';
          });

          // Find the next available image number (1-9)
          int nextImageNumber = 1;
          for (int j = 1; j <= 9; j++) {
            if (!usedImageNumbers.contains(j)) {
              nextImageNumber = j;
              break;
            }
          }

          // Mark this number as used for subsequent uploads
          usedImageNumbers.add(nextImageNumber);

          // Create multipart form data
          final formData = FormData.fromMap({
            'image': await MultipartFile.fromFile(
              imageFiles[i].path,
              filename: imageFiles[i].path.split(RegExp(r'[\\/]')).last,
            ),
            'imageNumber': nextImageNumber,
          });

          // Make API call directly with dio
          final response = await dio.post(
            ApiEndpoints.uploadSiteImage(widget.siteId),
            data: formData,
          );

          if (response.data != null && response.data['success'] == true) {
            successCount++;
          } else {
            failureCount++;
          }
        } catch (e) {
          failureCount++;
          AppLogger.e('Failed to upload image ${i + 1}: $e');
        }
      }

      // Refresh the images list
      if (mounted) {
        ref.invalidate(siteImagesProvider(widget.siteId));
      }

      if (mounted) {
        setState(() {
          _uploadProgress = null;
        });

        // Show result message
        if (successCount > 0 && failureCount == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                  SizedBox(width: 12.w),
                  Text(
                    '$successCount photo${successCount > 1 ? 's' : ''} added',
                  ),
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
        } else if (successCount > 0 && failureCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white, size: 20.sp),
                  SizedBox(width: 12.w),
                  Text('$successCount added, $failureCount failed'),
                ],
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              margin: EdgeInsets.all(16.w),
            ),
          );
        } else if (failureCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 20.sp),
                  SizedBox(width: 12.w),
                  const Text('Failed to upload photos'),
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
          _uploadProgress = null;
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
              'Add Photos',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: AppColors.textdark,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Select up to 9 photos total',
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade600,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: Icon(
                Icons.photo_library_rounded,
                color: AppColors.primary,
                size: 28.sp,
              ),
              title: Text(
                'Choose Multiple Photos',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
              subtitle: Text(
                'Select multiple photos from gallery',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                  fontFamily: 'Poppins',
                ),
              ),
              onTap: () {
                context.pop();
                _pickMultipleImages();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.camera_alt,
                color: AppColors.primary,
                size: 28.sp,
              ),
              title: Text(
                'Take Photo',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
              subtitle: Text(
                'Take a photo with camera',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                  fontFamily: 'Poppins',
                ),
              ),
              onTap: () {
                context.pop();
                _pickCameraImage();
              },
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  /// Pick single image from camera
  Future<void> _pickCameraImage() async {
    try {
      // Request camera permission first
      final hasPermission = await _requestCameraPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: const Text(
                      'Camera permission is required to take photos',
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
        return;
      }

      // Get current images to check available slots
      final currentImages = await ref.read(
        siteImagesProvider(widget.siteId).future,
      );
      final availableSlots = 9 - currentImages.length;

      if (availableSlots <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(child: const Text('Maximum 9 photos allowed')),
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
        return;
      }

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
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
                const Text('Photo added successfully'),
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
          style: TextStyle(fontSize: 14.sp, fontFamily: 'Poppins'),
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

  Widget _buildImageCard(
    SiteImage image,
    int index,
    List<SiteImage> allImages,
  ) {
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
                child:
                    image.imageUrl.startsWith('http') ||
                        image.imageUrl.startsWith('https')
                    ? Image.network(
                        image.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade300,
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
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
                top: 6.h,
                right: 6.w,
                child: GestureDetector(
                  onTap: () => _confirmDelete(image),
                  child: Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 16.sp),
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
        child: Bone.square(size: 150.sp),
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
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 40.sp,
                      height: 40.sp,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                    ),
                    if (_uploadProgress != null) ...[
                      SizedBox(height: 8.h),
                      Text(
                        _uploadProgress!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 40.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Add Photos',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
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
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 12.w,
                                mainAxisSpacing: 12.h,
                                childAspectRatio: 0.75,
                              ),
                          itemCount: canAddMore ? imageCount + 1 : imageCount,
                          itemBuilder: (context, index) {
                            if (index < imageCount) {
                              return _buildImageCard(
                                images[index],
                                index,
                                images,
                              );
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
                        Bone.text(words: 3, fontSize: 24.sp),
                        SizedBox(height: 8.h),

                        // Skeleton description
                        Bone.text(words: 8, fontSize: 14.sp),
                        SizedBox(height: 24.h),

                        // Skeleton grid
                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 12.w,
                                  mainAxisSpacing: 12.h,
                                  childAspectRatio: 0.75,
                                ),
                            itemCount: 9,
                            itemBuilder: (context, index) =>
                                _buildSkeletonCard(),
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
