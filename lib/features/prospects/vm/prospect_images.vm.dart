
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/features/prospects/models/prospect_images.model.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'prospect_images.vm.g.dart';

// ============================================================================
// Providers
// ============================================================================

/// Provider to get all images for a specific prospect from API
@riverpod
Future<List<ProspectImage>> prospectImages(Ref ref, String prospectId) async {
  try {
    AppLogger.i('📸 Fetching images for prospect: $prospectId');

    // Get Dio instance
    final dio = ref.read(dioClientProvider);

    // Make API call to get prospect details (which includes images)
    final response = await dio.get(ApiEndpoints.prospectsById(prospectId));

    AppLogger.d('API Response: ${response.data}');

    // Check success
    if (response.data == null || !(response.data['success'] == true)) {
      throw Exception('Failed to fetch prospect images');
    }

    // Extract images array from response
    final data = response.data['data'];
    final imagesData = data['images'] as List<dynamic>?;

    if (imagesData == null) {
      return []; // No images yet
    }

    // Convert API images to ProspectImage model
    final prospectImages = imagesData.map((json) {
      final imageJson = json as Map<String, dynamic>;
      return ProspectImage(
        id: imageJson['_id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        prospectId: prospectId,
        imageUrl: imageJson['imageUrl'] as String,
        imageOrder: imageJson['imageNumber'] as int,
        uploadedAt: DateTime.now(),
        caption: null,
        isUploaded: true,
      );
    }).toList();

    // Sort by image number
    prospectImages.sort((a, b) => a.imageOrder.compareTo(b.imageOrder));

    AppLogger.i('✅ Successfully fetched ${prospectImages.length} images');

    return prospectImages;
  } on DioException catch (e) {
    AppLogger.e('❌ DioException fetching prospect images: ${e.message}');
    AppLogger.e('Response data: ${e.response?.data}');

    // Extract error message from response if available
    String errorMessage = 'Failed to fetch prospect images';
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        errorMessage = data['message'] ?? errorMessage;
      }
    }

    throw Exception(errorMessage);
  } catch (e, stackTrace) {
    AppLogger.e('❌ Error fetching prospect images: $e');
    AppLogger.e('Stack trace: $stackTrace');
    throw Exception('Failed to fetch prospect images: $e');
  }
}

/// Provider to get image count for a prospect
@riverpod
Future<int> prospectImageCount(Ref ref, String prospectId) async {
  final images = await ref.watch(prospectImagesProvider(prospectId).future);
  return images.length;
}

// ============================================================================
// Prospect Images ViewModel - Manages all image operations
// ============================================================================

@riverpod
class ProspectImagesViewModel extends _$ProspectImagesViewModel {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Add a new image to a prospect via API
  Future<ProspectImage> addImage({
    required String prospectId,
    required File imageFile,
    String? caption,
  }) async {
    try {
      AppLogger.i('📸 Uploading new image for prospect: $prospectId');

      // Get existing images to determine next image number
      final existingImages = await ref.read(prospectImagesProvider(prospectId).future);

      if (existingImages.length >= 5) {
        AppLogger.w('⚠️ Maximum 5 photos limit reached for prospect: $prospectId');
        throw Exception('Maximum 5 photos allowed per prospect');
      }

      // Calculate next image number - fill gaps first
      int nextImageNumber = 1;
      if (existingImages.isNotEmpty) {
        // Get list of existing image numbers
        final existingNumbers = existingImages
            .map((img) => img.imageOrder)
            .toList()
          ..sort();

        // Find the first gap in the sequence (1, 2, 3, 4, 5)
        for (int i = 1; i <= 5; i++) {
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
        'imageNumber': nextImageNumber,
      });

      // Make API call
      final response = await dio.post(
        ApiEndpoints.uploadProspectImage(prospectId),
        data: formData,
      );

      AppLogger.d('API Response: ${response.data}');

      // Validate response data
      if (response.data == null) {
        throw Exception('Invalid response from server');
      }

      // Parse response
      final uploadResponse = UploadProspectImageResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!uploadResponse.success) {
        throw Exception(uploadResponse.message);
      }

      // Create ProspectImage from response
      final newImage = ProspectImage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        prospectId: prospectId,
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

  /// Delete an image from a prospect
  Future<void> deleteImage(String imageId, String prospectId, int imageNumber) async {
    try {
      AppLogger.i('🗑️ Deleting image: $imageId (number: $imageNumber) from prospect: $prospectId');

      // Get Dio instance
      final dio = ref.read(dioClientProvider);

      // Make API call to delete image
      final response = await dio.delete(
        ApiEndpoints.deleteProspectImage(prospectId, imageNumber),
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
}
