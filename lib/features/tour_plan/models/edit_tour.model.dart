import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_tour.model.freezed.dart';
part 'edit_tour.model.g.dart';

@freezed
abstract class TourDetails with _$TourDetails {
  const TourDetails._();

  const factory TourDetails({
    required String id,
    required String placeOfVisit,
    required String startDate,
    required String endDate,
    required String purposeOfVisit,
    @Default('Pending') String status, // For the "Tour Plan Status" banner
    String? createdAt,
    String? updatedAt,
  }) = _TourDetails;

  factory TourDetails.fromJson(Map<String, dynamic> json) => _$TourDetailsFromJson(json);

  // Helper to convert from a general API response if needed
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
}

@freezed
abstract class UpdateTourRequest with _$UpdateTourRequest {
  const factory UpdateTourRequest({
    required String placeOfVisit,
    required String startDate,
    required String endDate,
    required String purposeOfVisit,
  }) = _UpdateTourRequest;

  factory UpdateTourRequest.fromJson(Map<String, dynamic> json) => _$UpdateTourRequestFromJson(json);

  factory UpdateTourRequest.fromDetails(TourDetails details) {
    return UpdateTourRequest(
      placeOfVisit: details.placeOfVisit,
      startDate: details.startDate,
      endDate: details.endDate,
      purposeOfVisit: details.purposeOfVisit,
    );
  }
}