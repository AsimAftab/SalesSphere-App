import 'dart:async';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/network_layer/network_exceptions.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/notes/models/notes.model.dart';

part 'notes.vm.g.dart';

@Riverpod(keepAlive: true)
class NotesViewModel extends _$NotesViewModel {
  @override
  FutureOr<List<NoteListItem>> build() async {
    return _fetchNotes();
  }

  Future<List<NoteListItem>> _fetchNotes() async {
    try {
      final dio = ref.read(dioClientProvider);
      final response = await dio.get(ApiEndpoints.myNotes);

      final apiResponse = NotesListApiResponse.fromJson(response.data);

      if (apiResponse.success) {
        AppLogger.i('Fetched ${apiResponse.count} notes');
        return apiResponse.data
            .map((e) => NoteListItem.fromApiData(e))
            .toList();
      } else {
        throw Exception('Failed to fetch notes');
      }
    } on DioException catch (e) {
      AppLogger.e('Failed to fetch notes', e);
      // Rethrow the NetworkException directly so UI can handle it
      if (e.error is NetworkException) {
        rethrow;
      }
      throw Exception('Failed to fetch notes');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final notes = await _fetchNotes();
      state = AsyncValue.data(notes);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

@riverpod
class NoteSearchQuery extends _$NoteSearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) => state = query;
}

@riverpod
Future<List<NoteListItem>> searchedNotes(Ref ref) async {
  final query = ref.watch(noteSearchQueryProvider).toLowerCase();
  final allNotes = await ref.watch(notesViewModelProvider.future);

  if (query.isEmpty) return allNotes;

  return allNotes
      .where(
        (note) =>
            note.title.toLowerCase().contains(query) ||
            note.name.toLowerCase().contains(query),
      )
      .toList();
}
