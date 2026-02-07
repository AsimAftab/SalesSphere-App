import 'dart:io';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/parties/models/parties.model.dart';

part 'party_image.vm.g.dart';

// ============================================================================
// PARTY IMAGE VIEW MODEL
// Manages party image upload
// ============================================================================

@riverpod
class PartyImageViewModel extends _$PartyImageViewModel {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Upload party image to API
  Future<String> uploadImage({
    required String partyId,
    required File imageFile,
  }) async {
    try {
      AppLogger.i('📸 Uploading image for party: $partyId');

      // Get Dio instance
      final dio = ref.read(dioClientProvider);

      // Create multipart form data
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split(Platform.pathSeparator).last,
        ),
      });

      // Make API call
      final response = await dio.post(
        ApiEndpoints.uploadPartyImage(partyId),
        data: formData,
      );

      AppLogger.d('API Response: ${response.data}');

      // Validate response data
      if (response.data == null) {
        throw Exception('Invalid response from server');
      }

      // Parse response
      final uploadResponse = PartyImageUploadResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!uploadResponse.success) {
        throw Exception(uploadResponse.message);
      }

      AppLogger.i('✅ ${uploadResponse.message}');
      return uploadResponse.data.imageUrl;
    } on DioException catch (e) {
      AppLogger.e('❌ DioException uploading party image: ${e.message}');
      AppLogger.e('Status Code: ${e.response?.statusCode}');
      AppLogger.e('Response data: ${e.response?.data}');

      // Extract error message from response if available
      String errorMessage = 'Failed to upload image';

      if (e.response != null) {
        final statusCode = e.response!.statusCode;

        if (e.response!.data != null &&
            e.response!.data is Map<String, dynamic>) {
          final data = e.response!.data as Map<String, dynamic>;
          errorMessage = data['message'] ?? errorMessage;
        } else if (statusCode == 400) {
          errorMessage =
              'Bad request - Please check image format and try again';
        } else if (statusCode == 413) {
          errorMessage = 'Image file is too large';
        } else if (statusCode == 415) {
          errorMessage = 'Unsupported image format';
        }
      }

      throw Exception(errorMessage);
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error uploading party image: $e', e, stackTrace);
      rethrow;
    }
  }
}
