import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/notes/models/notes.model.dart';
import 'package:sales_sphere/features/notes/vm/notes.vm.dart';

part 'add_notes.vm.g.dart';

@riverpod
class AddNoteViewModel extends _$AddNoteViewModel {
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

  Future<String> createNote({
    required String title,
    required String description,
    String? partyId,
    String? prospectId,
    String? siteId,
  }) async {
    _keepAlive();
    try {
      AppLogger.i('🚀 Creating Mock Note');

      await Future.delayed(const Duration(seconds: 1));

      // ERROR FIX: Check if provider is still active after async gap
      if (!ref.mounted) {
        AppLogger.w('⚠️ Provider disposed. Aborting state update.');
        return '';
      }

      final String mockId = DateTime.now().millisecondsSinceEpoch.toString();

      final newNote = NoteListItem(
        id: mockId,
        title: title,
        name: partyId ?? prospectId ?? siteId ?? 'General Note',
        date: DateTime.now().toIso8601String(),
        content: description,
      );

      // Successfully update the local persistent list
      ref.read(notesViewModelProvider.notifier).addNoteLocally(newNote);

      return mockId;
    } catch (e) {
      AppLogger.e('⛔ Error creating mock note: $e');
      rethrow;
    } finally {
      if (ref.mounted) _release();
    }
  }

  Future<void> uploadNoteImages(String noteId, List<File> images) async {
    _keepAlive();
    try {
      AppLogger.i('📸 Mock uploading ${images.length} images');
      await Future.delayed(const Duration(seconds: 1));

      if (!ref.mounted) return;
      AppLogger.i('✅ Mock image upload complete');
    } catch (e) {
      AppLogger.e('Error uploading images: $e');
      rethrow;
    } finally {
      if (ref.mounted) _release();
    }
  }
}