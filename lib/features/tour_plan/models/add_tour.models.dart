import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_tour.models.freezed.dart';
part 'add_tour.models.g.dart';

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