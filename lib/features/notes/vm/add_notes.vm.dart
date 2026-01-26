import 'dart:io';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/network_layer/network_exceptions.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/notes/models/notes.model.dart';

part 'add_notes.vm.g.dart';

/// Notes Add ViewModel
/// Uses ref.keepAlive() to prevent premature disposal during async operations
@riverpod
class AddNoteViewModel extends _$AddNoteViewModel {
  Object? _link;

  @override
  void build() {
    ref.onDispose(() {
      if (_link != null) {
        (_link as dynamic).close();
      }
      AppLogger.d('🧹 AddNoteViewModel disposed');
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

  /// Public method to manually release the provider (call when no images to upload)
  void release() {
    _release();
  }

  Future<String> createNote({
    required String title,
    required String description,
    String? partyId,
    String? prospectId,
    String? siteId,
  }) async {
    // Keep provider alive for subsequent image uploads
    _keepAlive();
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
        // Don't release yet - images might be uploaded next
        return apiResponse.data.id;
      } else {
        _release();
        state = AsyncError(apiResponse.message, StackTrace.current);
        throw Exception(apiResponse.message);
      }
    } on DioException catch (e, stack) {
      AppLogger.e('Failed to create note', e, stack);
      _release();

      String errorMessage = 'Failed to create note';
      if (e.error is NetworkException) {
        final error = e.error as NetworkException;
        errorMessage = error.userFriendlyMessage;
      }

      state = AsyncError(errorMessage, stack);
      throw Exception(errorMessage);
    } catch (e, stack) {
      AppLogger.e('Unexpected error creating note', e, stack);
      _release();
      state = AsyncError(e.toString(), stack);
      rethrow;
    }
  }

  Future<void> uploadNoteImages(String noteId, List<File> images) async {
    if (images.isEmpty) {
      _release();
      return;
    }

    try {
      final dio = ref.read(dioClientProvider);

      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        final imageNumber = i + 1;

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

      // Release after all images uploaded
      _release();
    } on DioException catch (e) {
      AppLogger.e('Failed to upload note images', e);
      _release();
      if (e.error is NetworkException) {
        throw Exception((e.error as NetworkException).userFriendlyMessage);
      }
      throw Exception('Failed to upload images');
    } catch (e) {
      AppLogger.e('Unexpected error uploading images', e);
      _release();
      rethrow;
    }
  }
}
