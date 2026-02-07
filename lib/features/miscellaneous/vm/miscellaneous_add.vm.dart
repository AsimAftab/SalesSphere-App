import 'dart:io';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/miscellaneous/models/miscellaneous.model.dart';

part 'miscellaneous_add.vm.g.dart';

// ============================================================================
// MISCELLANEOUS WORK ADD VIEW MODEL
// Handles: Create miscellaneous work with images
// Uses Riverpod 3.0 best practices with auto-dispose and ref.mounted checks
// ============================================================================

@riverpod
class MiscellaneousAddViewModel extends _$MiscellaneousAddViewModel {
  Object? _link; // Use Object? for flexibility with keepAlive link

  @override
  void build() {
    // Auto-dispose is default in Riverpod 3.0
    // Cleanup happens automatically when widget is unmounted
    ref.onDispose(() {
      if (_link != null) {
        (_link as dynamic).close();
      }
      AppLogger.d('🧹 MiscellaneousAddViewModel disposed');
    });
  }

  /// Keep provider alive for multi-step operations
  void _keepAlive() {
    _link ??= ref.keepAlive();
  }

  /// Release the keep alive after operations complete
  void _release() {
    if (_link != null) {
      (_link as dynamic).close();
      _link = null;
    }
  }

  /// Create Miscellaneous Work (without images)
  Future<String> createWork({
    required CreateMiscellaneousWorkRequest request,
  }) async {
    // Keep provider alive for subsequent image uploads
    _keepAlive();

    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i('📝 Creating misc work: ${request.natureOfWork}');

      // Send JSON request
      final response = await dio.post(
        ApiEndpoints.createMiscellaneousWork,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.i('✅ Miscellaneous work created successfully');
        final apiResponse = MiscWorkApiResponse.fromJson(response.data);
        return apiResponse.data!.id; // Return work ID
      } else {
        _release();
        throw Exception('Failed to submit work: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _release();
      AppLogger.e('❌ Dio error creating misc work: ${e.message}');
      throw Exception(_handleDioError(e));
    } catch (e, stackTrace) {
      _release();
      AppLogger.e('❌ Error creating misc work: $e');
      AppLogger.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Upload image to miscellaneous work
  Future<MiscWorkImageUploadResponse> uploadImage({
    required String workId,
    required File imageFile,
    required int imageNumber,
    required bool isLastImage,
  }) async {
    try {
      AppLogger.i('📸 Uploading image $imageNumber for work: $workId');

      final dio = ref.read(dioClientProvider);

      // Create multipart form data
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        'imageNumber': imageNumber.toString(),
      });

      // Make API call
      final response = await dio.post(
        ApiEndpoints.uploadMiscellaneousWorkImage(workId),
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.i('✅ Image uploaded successfully');
        final uploadResponse = MiscWorkImageUploadResponse.fromJson(
          response.data,
        );

        // Release keep alive after last image
        if (isLastImage) {
          _release();
        }

        return uploadResponse;
      } else {
        _release();
        throw Exception('Failed to upload image: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _release();
      AppLogger.e('❌ Dio error uploading image: ${e.message}');

      // Handle specific error for imageNumber validation
      if (e.response?.statusCode == 400) {
        final errorMsg = e.response?.data['message'] ?? 'Invalid request';
        throw Exception(errorMsg);
      }

      throw Exception(_handleDioError(e));
    } catch (e, stackTrace) {
      _release();
      AppLogger.e('❌ Error uploading image: $e');
      AppLogger.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Helper error message extractor
  String _handleDioError(DioException error) {
    if (error.response?.data != null && error.response?.data is Map) {
      return error.response?.data['message'] ?? 'Network error occurred';
    }
    return error.message ?? 'Unknown error occurred';
  }
}
