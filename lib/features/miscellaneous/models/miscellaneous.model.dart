import 'package:freezed_annotation/freezed_annotation.dart';

part 'miscellaneous.model.freezed.dart';
part 'miscellaneous.model.g.dart';

// ============================================================================
// Request Models
// ============================================================================

/// Request model for creating miscellaneous work
@freezed
abstract class CreateMiscellaneousWorkRequest with _$CreateMiscellaneousWorkRequest {
  const factory CreateMiscellaneousWorkRequest({
    required String natureOfWork,
    required String address,
    required double latitude,
    required double longitude,
    required String workDate, // Format: "YYYY-MM-DD"
    required String assignedBy,
  }) = _CreateMiscellaneousWorkRequest;

  factory CreateMiscellaneousWorkRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateMiscellaneousWorkRequestFromJson(json);
}

// ============================================================================
// Response Models
// ============================================================================

/// API Response wrapper for create/update
@freezed
abstract class MiscWorkApiResponse with _$MiscWorkApiResponse {
  const factory MiscWorkApiResponse({
    required bool success,
    required String message,
    MiscWorkCreateData? data,
  }) = _MiscWorkApiResponse;

  factory MiscWorkApiResponse.fromJson(Map<String, dynamic> json) =>
      _$MiscWorkApiResponseFromJson(json);
}

/// Created work data (simplified version returned from create endpoint)
@freezed
abstract class MiscWorkCreateData with _$MiscWorkCreateData {
  const factory MiscWorkCreateData({
    @JsonKey(name: '_id') required String id,
    required String employeeId, // String in create response
    required String natureOfWork,
    required String address,
    required double latitude,
    required double longitude,
    required String assignedBy,
    String? organizationId,
    String? workDate,
    @Default([]) List<dynamic> images, // Empty array in create response
    String? createdAt,
    String? updatedAt,
  }) = _MiscWorkCreateData;

  factory MiscWorkCreateData.fromJson(Map<String, dynamic> json) =>
      _$MiscWorkCreateDataFromJson(json);
}

/// API Response wrapper for image upload
@freezed
abstract class MiscWorkImageUploadResponse with _$MiscWorkImageUploadResponse {
  const factory MiscWorkImageUploadResponse({
    required bool success,
    required String message,
    required MiscWorkImageUploadData data,
  }) = _MiscWorkImageUploadResponse;

  factory MiscWorkImageUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$MiscWorkImageUploadResponseFromJson(json);
}

/// Image upload data
@freezed
abstract class MiscWorkImageUploadData with _$MiscWorkImageUploadData {
  const factory MiscWorkImageUploadData({
    required int imageNumber,
    required String imageUrl,
  }) = _MiscWorkImageUploadData;

  factory MiscWorkImageUploadData.fromJson(Map<String, dynamic> json) =>
      _$MiscWorkImageUploadDataFromJson(json);
}

/// API Response wrapper for list endpoint
@freezed
abstract class MiscWorkListApiResponse with _$MiscWorkListApiResponse {
  const factory MiscWorkListApiResponse({
    required bool success,
    required int count,
    required List<MiscWorkData> data,
    String? organizationTimezone,
  }) = _MiscWorkListApiResponse;

  factory MiscWorkListApiResponse.fromJson(Map<String, dynamic> json) =>
      _$MiscWorkListApiResponseFromJson(json);
}

/// Full miscellaneous work data from API
@freezed
abstract class MiscWorkData with _$MiscWorkData {
  const factory MiscWorkData({
    @JsonKey(name: '_id') required String id,
    required String natureOfWork,
    required String address,
    required String assignedBy, // Changed to String
    @JsonKey(name: 'employeeId') required EmployeeInfo employee,
    String? organizationId,
    String? workDate,
    @Default([]) List<MiscWorkImage> images, // Changed to List<MiscWorkImage>
    String? createdAt,
    String? updatedAt,
    int? sNo,
  }) = _MiscWorkData;

  factory MiscWorkData.fromJson(Map<String, dynamic> json) =>
      _$MiscWorkDataFromJson(json);
}

/// Image info for miscellaneous work
@freezed
abstract class MiscWorkImage with _$MiscWorkImage {
  const factory MiscWorkImage({
    @JsonKey(name: '_id') required String id,
    required int imageNumber,
    required String imageUrl,
  }) = _MiscWorkImage;

  factory MiscWorkImage.fromJson(Map<String, dynamic> json) =>
      _$MiscWorkImageFromJson(json);
}

/// Employee info for assigned by and employee fields
@freezed
abstract class EmployeeInfo with _$EmployeeInfo {
  const factory EmployeeInfo({
    @JsonKey(name: '_id') required String id,
    required String name,
    String? role,
    String? avatarUrl,
  }) = _EmployeeInfo;

  factory EmployeeInfo.fromJson(Map<String, dynamic> json) =>
      _$EmployeeInfoFromJson(json);
}

// ============================================================================
// App Models
// ============================================================================

/// Lightweight model for miscellaneous work list display
@freezed
abstract class MiscWorkListItem with _$MiscWorkListItem {
  const factory MiscWorkListItem({
    required String id,
    required String natureOfWork,
    required String assignedBy,
    required String address,
    String? workDate,
  }) = _MiscWorkListItem;

  factory MiscWorkListItem.fromJson(Map<String, dynamic> json) =>
      _$MiscWorkListItemFromJson(json);

  // Helper method to convert from API data
  factory MiscWorkListItem.fromApiData(MiscWorkData apiData) {
    return MiscWorkListItem(
      id: apiData.id,
      natureOfWork: apiData.natureOfWork,
      assignedBy: apiData.assignedBy, // Now directly a string
      address: apiData.address,
      workDate: apiData.workDate,
    );
  }
}