import 'package:freezed_annotation/freezed_annotation.dart';

part 'miscellaneous.model.freezed.dart';
part 'miscellaneous.model.g.dart';

// ============================================================================
// Request Models
// ============================================================================

/// Request model for creating miscellaneous work
/// Note: Images are handled separately via FormData in the ViewModel
@freezed
abstract class CreateMiscellaneousWorkRequest with _$CreateMiscellaneousWorkRequest {
  const factory CreateMiscellaneousWorkRequest({
    required String natureOfWork,
    required String assignedBy,
    required MiscLocation location,
  }) = _CreateMiscellaneousWorkRequest;

  factory CreateMiscellaneousWorkRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateMiscellaneousWorkRequestFromJson(json);
}

/// Location info for miscellaneous work
@freezed
abstract class MiscLocation with _$MiscLocation {
  const factory MiscLocation({
    required String address,
    required double latitude,
    required double longitude,
  }) = _MiscLocation;

  factory MiscLocation.fromJson(Map<String, dynamic> json) =>
      _$MiscLocationFromJson(json);
}

// ============================================================================
// Response Models
// ============================================================================

/// API Response wrapper
@freezed
abstract class MiscWorkApiResponse with _$MiscWorkApiResponse {
  const factory MiscWorkApiResponse({
    required bool success,
    required String message,
    MiscWorkData? data,
  }) = _MiscWorkApiResponse;

  factory MiscWorkApiResponse.fromJson(Map<String, dynamic> json) =>
      _$MiscWorkApiResponseFromJson(json);
}

/// Data returned after creation
@freezed
abstract class MiscWorkData with _$MiscWorkData {
  const factory MiscWorkData({
    @JsonKey(name: '_id') required String id,
    required String natureOfWork,
    required String status,
    required String createdAt,
  }) = _MiscWorkData;

  factory MiscWorkData.fromJson(Map<String, dynamic> json) =>
      _$MiscWorkDataFromJson(json);
}