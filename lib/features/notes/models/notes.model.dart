import 'package:freezed_annotation/freezed_annotation.dart';

part 'notes.model.freezed.dart';
part 'notes.model.g.dart';

Object? _readPartyName(Map json, String key) => json[key] ?? json['name'];

Object? _readProspectName(Map json, String key) =>
    json[key] ?? json['prospectName'];

Object? _readSiteName(Map json, String key) => json[key] ?? json['siteName'];

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
    required CreateNoteData data,
  }) = _AddNoteApiResponse;

  factory AddNoteApiResponse.fromJson(Map<String, dynamic> json) =>
      _$AddNoteApiResponseFromJson(json);
}

/// Generic API Response for Update Note
@freezed
abstract class UpdateNoteApiResponse with _$UpdateNoteApiResponse {
  const factory UpdateNoteApiResponse({
    required bool success,
    String? message,
    required NoteApiData data,
  }) = _UpdateNoteApiResponse;

  factory UpdateNoteApiResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateNoteApiResponseFromJson(json);
}

/// API Response for getting single note details
@freezed
abstract class NoteDetailsApiResponse with _$NoteDetailsApiResponse {
  const factory NoteDetailsApiResponse({
    required bool success,
    required NoteApiData data,
  }) = _NoteDetailsApiResponse;

  factory NoteDetailsApiResponse.fromJson(Map<String, dynamic> json) =>
      _$NoteDetailsApiResponseFromJson(json);
}

/// Data returned when creating a note
@freezed
abstract class CreateNoteData with _$CreateNoteData {
  const factory CreateNoteData({
    @JsonKey(name: '_id') required String id,
    required String title,
    required String description,
    NotePartyRef? party,
    NoteProspectRef? prospect,
    NoteSiteRef? site,
    required String organizationId,
    required NoteCreatedBy createdBy,
    @Default([]) List<NoteImage> images,
    required String createdAt,
    required String updatedAt,
  }) = _CreateNoteData;

  factory CreateNoteData.fromJson(Map<String, dynamic> json) =>
      _$CreateNoteDataFromJson(json);
}

/// Party reference in note response
@freezed
abstract class NotePartyRef with _$NotePartyRef {
  const factory NotePartyRef({
    @JsonKey(name: '_id') required String id,
    @JsonKey(readValue: _readPartyName) required String partyName,
  }) = _NotePartyRef;

  factory NotePartyRef.fromJson(Map<String, dynamic> json) =>
      _$NotePartyRefFromJson(json);
}

/// Prospect reference in note response
@freezed
abstract class NoteProspectRef with _$NoteProspectRef {
  const factory NoteProspectRef({
    @JsonKey(name: '_id') required String id,
    @JsonKey(readValue: _readProspectName) required String name,
  }) = _NoteProspectRef;

  factory NoteProspectRef.fromJson(Map<String, dynamic> json) =>
      _$NoteProspectRefFromJson(json);
}

/// Site reference in note response
@freezed
abstract class NoteSiteRef with _$NoteSiteRef {
  const factory NoteSiteRef({
    @JsonKey(name: '_id') required String id,
    @JsonKey(readValue: _readSiteName) required String name,
  }) = _NoteSiteRef;

  factory NoteSiteRef.fromJson(Map<String, dynamic> json) =>
      _$NoteSiteRefFromJson(json);
}

/// Created by user reference
@freezed
abstract class NoteCreatedBy with _$NoteCreatedBy {
  const factory NoteCreatedBy({
    @JsonKey(name: '_id') required String id,
    required String name,
    String? email,
  }) = _NoteCreatedBy;

  factory NoteCreatedBy.fromJson(Map<String, dynamic> json) =>
      _$NoteCreatedByFromJson(json);
}

/// Image object in note response
@freezed
abstract class NoteImage with _$NoteImage {
  const factory NoteImage({
    required int imageNumber,
    required String imageUrl,
  }) = _NoteImage;

  factory NoteImage.fromJson(Map<String, dynamic> json) =>
      _$NoteImageFromJson(json);
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
    @JsonKey(includeIfNull: false) String? party,
    @JsonKey(includeIfNull: false) String? prospect,
    @JsonKey(includeIfNull: false) String? site,
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
  const NoteListItem._();

  const factory NoteListItem({
    @JsonKey(name: '_id') required String id,
    required String title,
    required String name,
    required String date,
    String? content,
    String? entityType,
  }) = _NoteListItem;

  factory NoteListItem.fromJson(Map<String, dynamic> json) =>
      _$NoteListItemFromJson(json);

  /// Helper to convert full API detail into a list item
  factory NoteListItem.fromDetailData(NoteDetailData detail) {
    return NoteListItem(
      id: detail.id,
      title: detail.title,
      name:
          (detail.party?['partyName'] ??
          detail.prospect?['name'] ??
          detail.site?['name'] ??
          'General'),
      date: detail.updatedAt ?? detail.createdAt ?? '',
      content: detail.description,
    );
  }

  /// Helper to convert API list data into a list item
  factory NoteListItem.fromApiData(NoteApiData data) {
    String name = 'General';
    String? entityType;

    if (data.party != null) {
      name = data.party!.partyName;
      entityType = 'party';
    } else if (data.prospect != null) {
      name = data.prospect!.name;
      entityType = 'prospect';
    } else if (data.site != null) {
      name = data.site!.name;
      entityType = 'site';
    }

    return NoteListItem(
      id: data.id,
      title: data.title,
      name: name,
      date: data.updatedAt ?? data.createdAt,
      content: data.description,
      entityType: entityType,
    );
  }
}

// ============================================================================
// Notes List API Response Models
// ============================================================================

/// API Response for notes list endpoint
@freezed
abstract class NotesListApiResponse with _$NotesListApiResponse {
  const factory NotesListApiResponse({
    required bool success,
    required int count,
    required List<NoteApiData> data,
  }) = _NotesListApiResponse;

  factory NotesListApiResponse.fromJson(Map<String, dynamic> json) =>
      _$NotesListApiResponseFromJson(json);
}

/// Note data from API list response
@freezed
abstract class NoteApiData with _$NoteApiData {
  const factory NoteApiData({
    @JsonKey(name: '_id') required String id,
    required String title,
    required String description,
    NotePartyRef? party,
    NoteProspectRef? prospect,
    NoteSiteRef? site,
    required String organizationId,
    required NoteCreatedBy createdBy,
    @Default([]) List<NoteImage> images,
    required String createdAt,
    String? updatedAt,
  }) = _NoteApiData;

  factory NoteApiData.fromJson(Map<String, dynamic> json) =>
      _$NoteApiDataFromJson(json);
}
