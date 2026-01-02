import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';
import 'package:sales_sphere/features/notes/models/notes.model.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'notes.vm.g.dart';

@Riverpod(keepAlive: true)
class NotesViewModel extends _$NotesViewModel {
  List<NoteListItem> _currentNotes = [];

  @override
  FutureOr<List<NoteListItem>> build() async {
    if (_currentNotes.isEmpty) {
      _currentNotes = await _fetchInitialMockNotes();
    }
    return _currentNotes;
  }

  Future<List<NoteListItem>> _fetchInitialMockNotes() async {
    AppLogger.i('📝 Fetching initial mock notes');
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      const NoteListItem(id: '1', title: 'Client Meeting Follow-up', name: 'Party A', date: '2024-12-28'),
      const NoteListItem(id: '2', title: 'Product Feedback', name: 'Prospect 2', date: '2024-12-27'),
      const NoteListItem(id: '3', title: 'Service Issue Report', name: 'Downtown Office', date: '2024-12-26'),
    ];
  }

  void addNoteLocally(NoteListItem newNote) {
    _currentNotes = [newNote, ..._currentNotes];
    state = AsyncValue.data(List.from(_currentNotes));
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 500));
    state = AsyncValue.data(_currentNotes);
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

  return allNotes.where((note) =>
  note.title.toLowerCase().contains(query) ||
      note.name.toLowerCase().contains(query)
  ).toList();
}