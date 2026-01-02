import 'dart:io';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/network_layer/network_exceptions.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/notes/models/notes.model.dart';

part 'add_notes.vm.g.dart';

@riverpod
class AddNoteViewModel extends _$AddNoteViewModel {
  @override
  FutureOr<void> build() => null;

  Future<String> createNote({
    required String title,
    required String description,
    String? partyId,
    String? prospectId,
    String? siteId,
  }) async {
    state = const AsyncLoading();

    try {
      final dio = ref.read(dioClientProvider);

      final request = AddNoteRequest(
        title: title,
        description: description,
        party: partyId,
        prospect: prospectId,
        site: siteId,
      );

      final response = await dio.post(
        ApiEndpoints.createNote,
        data: request.toJson(),
      );

      final apiResponse = AddNoteApiResponse.fromJson(response.data);

      if (apiResponse.success) {
        AppLogger.i('Note created successfully: ${apiResponse.data.id}');
        state = const AsyncData(null);
        return apiResponse.data.id;
      } else {
        state = AsyncError(apiResponse.message, StackTrace.current);
        throw Exception(apiResponse.message);
      }
    } on DioException catch (e, stack) {
      AppLogger.e('Failed to create note', e, stack);

      String errorMessage = 'Failed to create note';
      if (e.error is NetworkException) {
        final error = e.error as NetworkException;
        errorMessage = error.userFriendlyMessage;
      }

      state = AsyncError(errorMessage, stack);
      throw Exception(errorMessage);
    } catch (e, stack) {
      AppLogger.e('Unexpected error creating note', e, stack);
      state = AsyncError(e.toString(), stack);
      rethrow;
    }
  }

  Future<void> uploadNoteImages(String noteId, List<File> images) async {
    if (images.isEmpty) return;

    try {
      final dio = ref.read(dioClientProvider);

      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        final imageNumber = i + 1; // 1-based index

        final formData = FormData.fromMap({
          'imageNumber': imageNumber,
          'image': await MultipartFile.fromFile(
            file.path,
            filename: 'note_image_$imageNumber.jpg',
          ),
        });

        await dio.post(
          ApiEndpoints.uploadNoteImages(noteId),
          data: formData,
        );

        AppLogger.i('Uploaded image $imageNumber/${images.length} for note $noteId');
      }
    } on DioException catch (e) {
      AppLogger.e('Failed to upload note images', e);
      if (e.error is NetworkException) {
        throw Exception((e.error as NetworkException).userFriendlyMessage);
      }
      throw Exception('Failed to upload images');
    }
  }
}
