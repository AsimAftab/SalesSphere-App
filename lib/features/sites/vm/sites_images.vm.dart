
import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sales_sphere/core/constants/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/features/sites/models/sites.model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'sites_images.vm.g.dart';

// ============================================================================
// Local Storage Key
// ============================================================================
const String _siteImagesStorageKey = 'site_images_storage';

// ============================================================================
// Providers
// ============================================================================

/// Provider to get SharedPreferences instance
@riverpod
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return await SharedPreferences.getInstance();
}

/// Provider to get all images for a specific site from API
@riverpod
Future<List<SiteImage>> siteImages(Ref ref, String siteId) async {
  try {
    AppLogger.i('📸 Fetching images for site: $siteId');

    // Get Dio instance
    final dio = ref.read(dioClientProvider);

    // Make API call to get site details (which includes images)
    final response = await dio.get(ApiEndpoints.siteById(siteId));

    AppLogger.d('API Response: ${response.data}');

    // Parse response
    final getSiteResponse = GetSiteResponse.fromJson(response.data);

    if (!getSiteResponse.success) {
      throw Exception('Failed to fetch site images');
    }

    // Extract images from response
    final apiImages = getSiteResponse.data.images;

    // Convert API images to SiteImage model
    final siteImages = apiImages.map((apiImage) {
      return SiteImage(
        id: apiImage.id,
        siteId: siteId,
        imageUrl: apiImage.imageUrl,
        imageOrder: apiImage.imageNumber,
        uploadedAt: DateTime.now(),
        caption: null,
        isUploaded: true,
      );
    }).toList();

    // Sort by image number
    siteImages.sort((a, b) => a.imageOrder.compareTo(b.imageOrder));

    AppLogger.i('✅ Successfully fetched ${siteImages.length} images');

    return siteImages;
  } on DioException catch (e) {
    AppLogger.e('❌ DioException fetching site images: ${e.message}');
    AppLogger.e('Response data: ${e.response?.data}');

    // Extract error message from response if available
    String errorMessage = 'Failed to fetch site images';
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        errorMessage = data['message'] ?? errorMessage;
      }
    }

    throw Exception(errorMessage);
  } catch (e, stackTrace) {
    AppLogger.e('❌ Error fetching site images: $e');
    AppLogger.e('Stack trace: $stackTrace');
    throw Exception('Failed to fetch site images: $e');
  }
}

/// Provider to get image count for a site
@riverpod
Future<int> siteImageCount(Ref ref, String siteId) async {
  final images = await ref.watch(siteImagesProvider(siteId).future);
  return images.length;
}

// ============================================================================
// Site Images ViewModel - Manages all image operations
// ============================================================================

@riverpod
class SiteImagesViewModel extends _$SiteImagesViewModel {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Add a new image to a site via API
  Future<SiteImage> addImage({
    required String siteId,
    required File imageFile,
    String? caption,
  }) async {
    try {
      AppLogger.i('📸 Uploading new image for site: $siteId');

      // Get existing images to determine next image number
      final existingImages = await ref.read(siteImagesProvider(siteId).future);

      if (existingImages.length >= 9) {
        AppLogger.w('⚠️ Maximum 9 photos limit reached for site: $siteId');
        throw Exception('Maximum 9 photos allowed per site');
      }

      // Calculate next image number - fill gaps first
      int nextImageNumber = 1;
      if (existingImages.isNotEmpty) {
        // Get list of existing image numbers
        final existingNumbers = existingImages
            .map((img) => img.imageOrder)
            .toList()
          ..sort();

        // Find the first gap in the sequence (1, 2, 3, ...)
        for (int i = 1; i <= 9; i++) {
          if (!existingNumbers.contains(i)) {
            nextImageNumber = i;
            break;
          }
        }
      }

      AppLogger.i('📤 Uploading image with imageNumber: $nextImageNumber');

      // Get Dio instance
      final dio = ref.read(dioClientProvider);

      // Create multipart form data
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        'imageNumber': nextImageNumber.toString(),
      });

      // Make API call
      final response = await dio.post(
        ApiEndpoints.uploadSiteImage(siteId),
        data: formData,
      );

      AppLogger.d('API Response: ${response.data}');

      // Validate response data
      if (response.data == null) {
        throw Exception('Invalid response from server');
      }

      // Parse response
      final uploadResponse = UploadSiteImageResponse.fromJson(response.data as Map<String, dynamic>);

      if (!uploadResponse.success) {
        throw Exception(uploadResponse.message);
      }

      // Create SiteImage from response
      final newImage = SiteImage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        siteId: siteId,
        imageUrl: uploadResponse.data.imageUrl,
        imageOrder: uploadResponse.data.imageNumber,
        uploadedAt: DateTime.now(),
        caption: caption,
        isUploaded: true,
      );

      AppLogger.i('✅ ${uploadResponse.message} - Image #${uploadResponse.data.imageNumber}');
      return newImage;
    } on DioException catch (e) {
      AppLogger.e('❌ DioException uploading image: ${e.message}');
      AppLogger.e('Status Code: ${e.response?.statusCode}');
      AppLogger.e('Response data: ${e.response?.data}');

      // Extract error message from response if available
      String errorMessage = 'Failed to upload image';

      if (e.response != null) {
        final statusCode = e.response!.statusCode;

        if (e.response!.data != null && e.response!.data is Map<String, dynamic>) {
          final data = e.response!.data as Map<String, dynamic>;
          errorMessage = data['message'] ?? errorMessage;
        } else if (statusCode == 400) {
          errorMessage = 'Bad request - Please check image format and try again';
        } else if (statusCode == 413) {
          errorMessage = 'Image file is too large';
        } else if (statusCode == 415) {
          errorMessage = 'Unsupported image format';
        }
      }

      throw Exception(errorMessage);
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error uploading image: $e', e, stackTrace);
      rethrow;
    }
  }

  /// Delete an image from a site
  Future<void> deleteImage(String imageId, String siteId, int imageNumber) async {
    try {
      AppLogger.i('🗑️ Deleting image: $imageId (number: $imageNumber) from site: $siteId');

      // Get Dio instance
      final dio = ref.read(dioClientProvider);

      // Make API call to delete image
      final response = await dio.delete(
        ApiEndpoints.deleteSiteImage(siteId, imageNumber),
      );

      AppLogger.d('API Response: ${response.data}');

      // Parse response
      if (response.data is Map<String, dynamic>) {
        final success = response.data['success'] ?? false;
        final message = response.data['message'] ?? 'Image deleted';

        if (!success) {
          throw Exception(message);
        }

        AppLogger.i('✅ $message');
      } else {
        AppLogger.i('✅ Image deleted successfully');
      }
    } on DioException catch (e) {
      AppLogger.e('❌ DioException deleting image: ${e.message}');
      AppLogger.e('Response data: ${e.response?.data}');

      // Extract error message from response if available
      String errorMessage = 'Failed to delete image';
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic>) {
          errorMessage = data['message'] ?? errorMessage;
        }
      }

      throw Exception(errorMessage);
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error deleting image: $e', e, stackTrace);
      rethrow;
    }
  }

  /// Reorder images for a site
  Future<void> reorderImages(String siteId, int oldIndex, int newIndex) async {
    try {
      AppLogger.i('🔄 Reordering images for site: $siteId');

      final prefs = await ref.read(sharedPreferencesProvider.future);

      // Get all stored images
      final storedData = prefs.getString(_siteImagesStorageKey);
      if (storedData == null) return;

      final List<SiteImage> allImages = (json.decode(storedData) as List<dynamic>)
          .map((json) => SiteImage.fromJson(json as Map<String, dynamic>))
          .toList();

      // Get images for this site
      final siteImages = allImages.where((img) => img.siteId == siteId).toList()
        ..sort((a, b) => a.imageOrder.compareTo(b.imageOrder));

      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      final item = siteImages.removeAt(oldIndex);
      siteImages.insert(newIndex, item);

      // Update order
      final reorderedSiteImages = <SiteImage>[];
      for (int i = 0; i < siteImages.length; i++) {
        reorderedSiteImages.add(siteImages[i].copyWith(imageOrder: i + 1));
      }

      // Replace old images with reordered ones
      allImages.removeWhere((img) => img.siteId == siteId);
      allImages.addAll(reorderedSiteImages);

      // Save to SharedPreferences
      final jsonList = allImages.map((img) => img.toJson()).toList();
      await prefs.setString(_siteImagesStorageKey, json.encode(jsonList));

      AppLogger.i('✅ Images reordered successfully');
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error reordering images: $e', e, stackTrace);
      rethrow;
    }
  }
}
