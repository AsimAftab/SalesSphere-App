import 'dart:io';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/notes/models/notes.model.dart';

part 'edit_notes.vm.g.dart';

@riverpod
class EditNoteViewModel extends _$EditNoteViewModel {
  Object? _link;

  @override
  void build() {
    ref.onDispose(() => _release());
  }

  void _keepAlive() => _link ??= ref.keepAlive();

  void _release() {
    if (_link != null) {
      (_link as dynamic).close();
      _link = null;
    }
  }

  Future<void> updateNote({
    required String noteId,
    required String title,
    required String description,
    String? partyId,
    String? prospectId,
    String? siteId,
  }) async {
    _keepAlive();
    try {
      final dio = ref.read(dioClientProvider);

      final data = UpdateNoteRequest(
        title: title,
        description: description,
        party: partyId,
        prospect: prospectId,
        site: siteId,
      ).toJson();

      await dio.put('/api/v1/notes/$noteId', data: data);
      AppLogger.i('✅ Note updated successfully');
    } catch (e) {
      AppLogger.e('❌ Error updating note: $e');
      rethrow;
    } finally {
      // Check mounted before releasing to prevent "Ref disposed" error
      if (ref.mounted) _release();
    }
  }

  /// FIXED: Added missing method required by edit_notes_screen.dart
  Future<void> uploadNoteImages(String noteId, List<File> images) async {
    _keepAlive();
    try {
      final dio = ref.read(dioClientProvider);
      final formData = FormData();

      for (var i = 0; i < images.length; i++) {
        formData.files.add(MapEntry(
          'images',
          await MultipartFile.fromFile(
            images[i].path,
            filename: 'note_update_${noteId}_$i.jpg',
          ),
        ));
      }

      await dio.post('/api/v1/notes/$noteId/upload', data: formData);
      AppLogger.i('✅ Note images updated successfully');
    } catch (e) {
      AppLogger.e('❌ Error uploading updated note images: $e');
      rethrow;
    } finally {
      if (ref.mounted) _release();
    }
  }
}