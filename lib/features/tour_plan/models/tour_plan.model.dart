import 'package:freezed_annotation/freezed_annotation.dart';

part 'tour_plan.model.freezed.dart';
part 'tour_plan.model.g.dart';

// ============================================================================
// API Response Models
// ============================================================================

@freezed
abstract class TourPlanApiResponse with _$TourPlanApiResponse {
  const factory TourPlanApiResponse({
    required bool success,
    required int count,
    required List<TourPlanApiData> data,
  }) = _TourPlanApiResponse;

  factory TourPlanApiResponse.fromJson(Map<String, dynamic> json) =>
      _$TourPlanApiResponseFromJson(json);
}

@freezed
abstract class TourPlanApiData with _$TourPlanApiData {
  const factory TourPlanApiData({
    @JsonKey(name: '_id') required String id,
    required String placeOfVisit,
    required String startDate,
    required String endDate,
    required String purposeOfVisit,
    required String status,
    String? createdAt,
  }) = _TourPlanApiData;

  factory TourPlanApiData.fromJson(Map<String, dynamic> json) =>
      _$TourPlanApiDataFromJson(json);
}

// ============================================================================
// App Models
// ============================================================================

@freezed
abstract class TourPlanListItem with _$TourPlanListItem {
  const factory TourPlanListItem({
    required String id,
    required String placeOfVisit,
    required String startDate,
    required String endDate,
    required String status,
    required int durationDays,
  }) = _TourPlanListItem;

  /// Converts API data and calculates duration inclusive of both start and end dates.
  factory TourPlanListItem.fromApiData(TourPlanApiData apiData) {
    final start = DateTime.tryParse(apiData.startDate) ?? DateTime.now();
    final end = DateTime.tryParse(apiData.endDate) ?? DateTime.now();

    // Difference in days + 1 to include the end date as a working day
    final duration = end.difference(start).inDays + 1;

    return TourPlanListItem(
      id: apiData.id,
      placeOfVisit: apiData.placeOfVisit,
      startDate: apiData.startDate,
      endDate: apiData.endDate,
      status: apiData.status,
      durationDays: duration,
    );
  }
}

// ============================================================================
// Add Tour Models
// ============================================================================

@freezed
abstract class CreateTourRequest with _$CreateTourRequest {
  const factory CreateTourRequest({
    required String placeOfVisit,
    required String startDate,
    required String endDate,
    required String purposeOfVisit,
  }) = _CreateTourRequest;

  factory CreateTourRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTourRequestFromJson(json);
}

@freezed
abstract class CreateTourResponse with _$CreateTourResponse {
  const factory CreateTourResponse({
    required bool success,
    required CreateTourData data,
  }) = _CreateTourResponse;

  factory CreateTourResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateTourResponseFromJson(json);
}

@freezed
abstract class CreateTourData with _$CreateTourData {
  const factory CreateTourData({
    @JsonKey(name: '_id') required String id,
    required String placeOfVisit,
    required String startDate,
    required String endDate,
    required String purposeOfVisit,
    required String status,
    required String organizationId,
    required CreatedByUser createdBy,
    required String createdAt,
    required String updatedAt,
  }) = _CreateTourData;

  factory CreateTourData.fromJson(Map<String, dynamic> json) =>
      _$CreateTourDataFromJson(json);
}

@freezed
abstract class CreatedByUser with _$CreatedByUser {
  const factory CreatedByUser({
    @JsonKey(name: '_id') required String id,
    required String name,
    required String email,
  }) = _CreatedByUser;

  factory CreatedByUser.fromJson(Map<String, dynamic> json) =>
      _$CreatedByUserFromJson(json);
}

@freezed
abstract class TourListItem with _$TourListItem {
  const factory TourListItem({
    required String id,
    required String placeOfVisit,
    required String startDate,
    required String endDate,
    required String purposeOfVisit,
  }) = _TourListItem;

  factory TourListItem.fromJson(Map<String, dynamic> json) =>
      _$TourListItemFromJson(json);
}

// ============================================================================
// Edit Tour Models
// ============================================================================

@freezed
abstract class TourDetails with _$TourDetails {
  const TourDetails._();

  const factory TourDetails({
    required String id,
    required String placeOfVisit,
    required String startDate,
    required String endDate,
    required String purposeOfVisit,
    @Default('Pending') String status,
    String? createdAt,
    String? updatedAt,
  }) = _TourDetails;

  factory TourDetails.fromJson(Map<String, dynamic> json) =>
      _$TourDetailsFromJson(json);

  factory TourDetails.fromApi(Map<String, dynamic> json) {
    return TourDetails(
      id: json['_id'] ?? '',
      placeOfVisit: json['placeOfVisit'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      purposeOfVisit: json['purposeOfVisit'] ?? '',
      status: json['status'] ?? 'Pending',
    );
  }

  factory TourDetails.fromUpdateData(UpdateTourData data) {
    return TourDetails(
      id: data.id,
      placeOfVisit: data.placeOfVisit,
      startDate: data.startDate,
      endDate: data.endDate,
      purposeOfVisit: data.purposeOfVisit,
      status: data.status,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }
}

@freezed
abstract class UpdateTourRequest with _$UpdateTourRequest {
  const factory UpdateTourRequest({
    required String placeOfVisit,
    required String startDate,
    required String endDate,
    required String purposeOfVisit,
  }) = _UpdateTourRequest;

  factory UpdateTourRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateTourRequestFromJson(json);
}

@freezed
abstract class UpdateTourResponse with _$UpdateTourResponse {
  const factory UpdateTourResponse({
    required bool success,
    required UpdateTourData data,
  }) = _UpdateTourResponse;

  factory UpdateTourResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateTourResponseFromJson(json);
}

@freezed
abstract class UpdateTourData with _$UpdateTourData {
  const factory UpdateTourData({
    @JsonKey(name: '_id') required String id,
    required String placeOfVisit,
    required String startDate,
    required String endDate,
    required String purposeOfVisit,
    required String status,
    required String organizationId,
    required CreatedByUser createdBy,
    required String createdAt,
    required String updatedAt,
  }) = _UpdateTourData;

  factory UpdateTourData.fromJson(Map<String, dynamic> json) =>
      _$UpdateTourDataFromJson(json);
}
