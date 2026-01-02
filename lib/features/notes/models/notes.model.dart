import 'package:freezed_annotation/freezed_annotation.dart';

part 'notes.model.freezed.dart';
part 'notes.model.g.dart';

// ============================================================================
// API Response Models
// ============================================================================

/// API Response wrapper for the notes list endpoint
@freezed
abstract class NotesApiResponse with _$NotesApiResponse {
  const factory NotesApiResponse({
    required bool success,
    required int count,
    required List<NoteListItem> data,
  }) = _NotesApiResponse;

  factory NotesApiResponse.fromJson(Map<String, dynamic> json) =>
      _$NotesApiResponseFromJson(json);
}

/// API Response wrapper for single note details endpoint
@freezed
abstract class NoteDetailApiResponse with _$NoteDetailApiResponse {
  const factory NoteDetailApiResponse({
    required bool success,
    required NoteDetailData data,
  }) = _NoteDetailApiResponse;

  factory NoteDetailApiResponse.fromJson(Map<String, dynamic> json) =>
      _$NoteDetailApiResponseFromJson(json);
}

/// Full note data structure from API
@freezed
abstract class NoteDetailData with _$NoteDetailData {
  const factory NoteDetailData({
    @JsonKey(name: '_id') required String id,
    required String title,
    required String description,
    dynamic party,
    dynamic prospect,
    dynamic site,
    List<String>? images,
    String? createdAt,
    String? updatedAt,
  }) = _NoteDetailData;

  factory NoteDetailData.fromJson(Map<String, dynamic> json) =>
      _$NoteDetailDataFromJson(json);
}

/// Generic API Response for Add Note
@freezed
abstract class AddNoteApiResponse with _$AddNoteApiResponse {
  const factory AddNoteApiResponse({
    required bool success,
    required String message,
    @JsonKey(name: 'data') Map<String, dynamic>? data,
  }) = _AddNoteApiResponse;

  factory AddNoteApiResponse.fromJson(Map<String, dynamic> json) =>
      _$AddNoteApiResponseFromJson(json);
}

// ============================================================================
// Request Models
// ============================================================================

/// Create note request model for POST /api/v1/notes
@freezed
abstract class AddNoteRequest with _$AddNoteRequest {
  const factory AddNoteRequest({
    required String title,
    required String description,
    String? party,
    String? prospect,
    String? site,
  }) = _AddNoteRequest;

  factory AddNoteRequest.fromJson(Map<String, dynamic> json) =>
      _$AddNoteRequestFromJson(json);
}

/// Update note request model for PUT /api/v1/notes/:id
@freezed
abstract class UpdateNoteRequest with _$UpdateNoteRequest {
  const factory UpdateNoteRequest({
    required String title,
    required String description,
    String? party,
    String? prospect,
    String? site,
  }) = _UpdateNoteRequest;

  factory UpdateNoteRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateNoteRequestFromJson(json);
}

// ============================================================================
// App Models
// ============================================================================

/// Lightweight model for note list display in the UI
@freezed
abstract class NoteListItem with _$NoteListItem {
  const factory NoteListItem({
    @JsonKey(name: '_id') required String id,
    required String title,
    required String name,
    required String date,
    String? content,
  }) = _NoteListItem;

  factory NoteListItem.fromJson(Map<String, dynamic> json) =>
      _$NoteListItemFromJson(json);

  /// Helper to convert full API detail into a list item
  factory NoteListItem.fromDetailData(NoteDetailData detail) {
    return NoteListItem(
      id: detail.id,
      title: detail.title,
      name: (detail.party?['partyName'] ??
          detail.prospect?['name'] ??
          detail.site?['name'] ?? 'General'),
      date: detail.updatedAt ?? detail.createdAt ?? '',
      content: detail.description,
    );
  }
}