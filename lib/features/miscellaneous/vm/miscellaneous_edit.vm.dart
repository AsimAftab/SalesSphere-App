import 'dart:io';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/miscellaneous/models/miscellaneous.model.dart';

part 'miscellaneous_edit.vm.g.dart';

// ============================================================================
// MISCELLANEOUS WORK EDIT VIEW MODEL
// Handles: Update miscellaneous work, upload/delete images
// ============================================================================

@riverpod
class MiscellaneousEditViewModel extends _$MiscellaneousEditViewModel {
  @override
  void build() {
    ref.onDispose(() {
      AppLogger.d('🧹 MiscellaneousEditViewModel disposed');
    });
  }

  /// Update Miscellaneous Work
  Future<void> updateWork(
    Dio dio, {
    required String workId,
    required CreateMiscellaneousWorkRequest request,
  }) async {
    try {
      AppLogger.i('📝 Updating misc work: $workId');

      await dio.put(
        ApiEndpoints.updateMiscellaneousWork(workId),
        data: request.toJson(),
      );

      AppLogger.i('✅ Miscellaneous work updated successfully');
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error updating misc work: ${e.message}');
      throw Exception(_handleDioError(e));
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error updating misc work: $e');
      AppLogger.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Upload Image to Miscellaneous Work
  Future<void> uploadImage(
    Dio dio, {
    required String workId,
    required File imageFile,
    required int imageNumber,
  }) async {
    try {
      AppLogger.i('📸 Uploading image $imageNumber for work: $workId');

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        'imageNumber': imageNumber.toString(),
      });

      await dio.post(
        ApiEndpoints.uploadMiscellaneousWorkImage(workId),
        data: formData,
      );

      AppLogger.i('✅ Image $imageNumber uploaded successfully');
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error uploading image: ${e.message}');
      
      // Handle specific error for imageNumber validation
      if (e.response?.statusCode == 400) {
        final errorMsg = e.response?.data['message'] ?? 'Invalid request';
        throw Exception(errorMsg);
      }
      
      throw Exception(_handleDioError(e));
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error uploading image: $e');
      AppLogger.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Delete Image from Miscellaneous Work
  Future<void> deleteImage(
    Dio dio, {
    required String workId,
    required int imageNumber,
  }) async {
    try {
      AppLogger.i('🗑️ Deleting image $imageNumber for work: $workId');

      await dio.delete(
        ApiEndpoints.deleteMiscellaneousWorkImage(workId, imageNumber),
      );

      AppLogger.i('✅ Image $imageNumber deleted successfully');
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error deleting image: ${e.message}');
      throw Exception(_handleDioError(e));
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error deleting image: $e');
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
