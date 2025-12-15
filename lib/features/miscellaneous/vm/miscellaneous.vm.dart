import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/miscellaneous/models/miscellaneous.model.dart';

part 'miscellaneous.vm.g.dart';

@riverpod
class MiscellaneousViewModel extends _$MiscellaneousViewModel {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Create Miscellaneous Work with Images
  Future<void> createWork({
    required CreateMiscellaneousWorkRequest request,
    required List<XFile> images,
  }) async {
    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i('Creating miscellaneous work: ${request.natureOfWork}');

      // 1. Create FormData for Multipart upload
      final FormData formData = FormData.fromMap({
        'natureOfWork': request.natureOfWork,
        'assignedBy': request.assignedBy,
        // Nesting location data - backend specific, usually sent as JSON string or individual fields
        'location[address]': request.location.address,
        'location[latitude]': request.location.latitude,
        'location[longitude]': request.location.longitude,
      });

      // 2. Attach Images
      if (images.isNotEmpty) {
        for (var file in images) {
          String fileName = file.path.split('/').last;
          formData.files.add(
            MapEntry(
              'images', // Key expected by backend (e.g., 'images', 'files')
              await MultipartFile.fromFile(file.path, filename: fileName),
            ),
          );
        }
      }

      // 3. Send Request
      // Assuming you will add 'createMiscWork' to your ApiEndpoints class
      final response = await dio.post(
        // Replace with your actual endpoint string if not in constants yet
        '/api/v1/miscellaneous-work',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.i('✅ Miscellaneous work created successfully');
        return;
      } else {
        throw Exception('Failed to submit work: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error creating misc work: ${e.message}');
      throw Exception(_handleDioError(e));
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error creating misc work: $e');
      AppLogger.e('Stack trace: $stackTrace');
      throw Exception('Failed to create work: $e');
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