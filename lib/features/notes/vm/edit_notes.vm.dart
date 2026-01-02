import 'dart:io';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/network_layer/network_exceptions.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/notes/models/notes.model.dart';

part 'edit_notes.vm.g.dart';

@riverpod
class EditNoteViewModel extends _$EditNoteViewModel {
  @override
  FutureOr<void> build() => null;

  /// Fetch note details by ID
  Future<NoteApiData> fetchNoteDetails(String noteId) async {
    try {
      final dio = ref.read(dioClientProvider);
      final response = await dio.get(ApiEndpoints.noteById(noteId));

      final apiResponse = NoteDetailsApiResponse.fromJson(response.data);

      if (apiResponse.success) {
        AppLogger.i('Fetched note details: ${apiResponse.data.id}');
        return apiResponse.data;
      } else {
        throw Exception('Failed to fetch note details');
      }
    } on DioException catch (e) {
      AppLogger.e('Failed to fetch note details', e);
      if (e.error is NetworkException) {
        throw Exception((e.error as NetworkException).userFriendlyMessage);
      }
      throw Exception('Failed to fetch note details');
    }
  }

  /// Update note via PATCH
  Future<NoteApiData> updateNote({
    required String noteId,
    required String title,
    required String description,
    String? partyId,
    String? prospectId,
    String? siteId,
  }) async {
    state = const AsyncLoading();

    try {
      final dio = ref.read(dioClientProvider);

      final request = UpdateNoteRequest(
        title: title,
        description: description,
        party: partyId,
        prospect: prospectId,
        site: siteId,
      );

      final response = await dio.patch(
        ApiEndpoints.updateNote(noteId),
        data: request.toJson(),
      );

      final apiResponse = UpdateNoteApiResponse.fromJson(response.data);

      if (apiResponse.success) {
        AppLogger.i('Note updated successfully: ${apiResponse.data.id}');
        if (ref.mounted) {
          state = const AsyncData(null);
        }
        return apiResponse.data;
      } else {
        final errorMsg = apiResponse.message ?? 'Failed to update note';
        if (ref.mounted) {
          state = AsyncError(errorMsg, StackTrace.current);
        }
        throw Exception(errorMsg);
      }
    } on DioException catch (e, stack) {
      AppLogger.e('Failed to update note', e, stack);

      String errorMessage = 'Failed to update note';
      if (e.error is NetworkException) {
        final error = e.error as NetworkException;
        errorMessage = error.userFriendlyMessage;
      }

      if (ref.mounted) {
        state = AsyncError(errorMessage, stack);
      }
      throw Exception(errorMessage);
    } catch (e, stack) {
      AppLogger.e('Unexpected error updating note', e, stack);
      if (ref.mounted) {
        state = AsyncError(e.toString(), stack);
      }
      rethrow;
    }
  }

  /// Upload images to note
  Future<void> uploadNoteImages(String noteId, Map<int, File> images) async {
    if (images.isEmpty) return;

    try {
      final dio = ref.read(dioClientProvider);

      for (final entry in images.entries) {
        final imageNumber = entry.key;
        final file = entry.value;

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

        AppLogger.i('Uploaded image $imageNumber for note $noteId');
      }
    } on DioException catch (e) {
      AppLogger.e('Failed to upload note images', e);
      if (e.error is NetworkException) {
        throw Exception((e.error as NetworkException).userFriendlyMessage);
      }
      throw Exception('Failed to upload images');
    }
  }

  /// Delete image from note
  Future<void> deleteNoteImage(String noteId, int imageNumber) async {
    try {
      final dio = ref.read(dioClientProvider);

      await dio.delete(ApiEndpoints.deleteNoteImage(noteId, imageNumber));

      AppLogger.i('Deleted image $imageNumber from note $noteId');
    } on DioException catch (e) {
      AppLogger.e('Failed to delete note image', e);
      if (e.error is NetworkException) {
        throw Exception((e.error as NetworkException).userFriendlyMessage);
      }
      throw Exception('Failed to delete image');
    }
  }
}
