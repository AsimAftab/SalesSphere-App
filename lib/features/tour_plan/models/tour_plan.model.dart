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