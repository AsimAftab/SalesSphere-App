import 'package:freezed_annotation/freezed_annotation.dart';

part 'odometer.model.freezed.dart';

part 'odometer.model.g.dart';

// ============================================================================
// API Response Models
// ============================================================================

/// API Response wrapper for the odometer list endpoint
@freezed
abstract class OdometerListApiResponse with _$OdometerListApiResponse {
  const factory OdometerListApiResponse({
    required bool success,
    required int count,
    required List<OdometerListItem> data,
  }) = _OdometerListApiResponse;

  factory OdometerListApiResponse.fromJson(Map<String, dynamic> json) =>
      _$OdometerListApiResponseFromJson(json);
}

/// API Response wrapper for single odometer details endpoint
@freezed
abstract class OdometerDetailsApiResponse with _$OdometerDetailsApiResponse {
  const factory OdometerDetailsApiResponse({
    required bool success,
    required OdometerDetails data,
  }) = _OdometerDetailsApiResponse;

  factory OdometerDetailsApiResponse.fromJson(Map<String, dynamic> json) =>
      _$OdometerDetailsApiResponseFromJson(json);
}

// ============================================================================
// Request Models
// ============================================================================

/// Request model for starting a new odometer reading
@freezed
abstract class StartOdometerRequest with _$StartOdometerRequest {
  const factory StartOdometerRequest({
    required double startReading,
    required String unit,
    String? description,
    // Note: Image is usually sent as MultipartFile, not in this JSON request
  }) = _StartOdometerRequest;

  factory StartOdometerRequest.fromJson(Map<String, dynamic> json) =>
      _$StartOdometerRequestFromJson(json);
}

/// Request model for stopping an active odometer reading
@freezed
abstract class StopOdometerRequest with _$StopOdometerRequest {
  const factory StopOdometerRequest({
    required double stopReading,
    String? description,
  }) = _StopOdometerRequest;

  factory StopOdometerRequest.fromJson(Map<String, dynamic> json) =>
      _$StopOdometerRequestFromJson(json);
}

// ============================================================================
// App Models
// ============================================================================

/// Comprehensive model for Odometer Details view
@freezed
abstract class OdometerDetails with _$OdometerDetails {
  const factory OdometerDetails({
    @JsonKey(name: '_id') required String id,
    required DateTime startTime,
    required DateTime stopTime,
    required double startReading,
    required double stopReading,
    required double distanceTravelled,
    required String startLocation,
    required String stopLocation,
    String? description,
    String? startReadingImage,
    String? stopReadingImage,
    @Default('KM') String unit,
  }) = _OdometerDetails;

  factory OdometerDetails.fromJson(Map<String, dynamic> json) =>
      _$OdometerDetailsFromJson(json);
}

/// Lightweight model for Odometer history list display
@freezed
abstract class OdometerListItem with _$OdometerListItem {
  const factory OdometerListItem({
    @JsonKey(name: '_id') required String id,
    required DateTime date,
    required double startReading,
    required double endReading,
    required double totalDistance,
    @Default('KM') String unit,
  }) = _OdometerListItem;

  factory OdometerListItem.fromJson(Map<String, dynamic> json) =>
      _$OdometerListItemFromJson(json);
}

/// Active Odometer state model (Used during an ongoing trip)
@freezed
abstract class OdometerReading with _$OdometerReading {
  const factory OdometerReading({
    @JsonKey(name: '_id') String? id,
    required double startReading,
    String? startReadingImage,
    required String unit, // 'KM' or 'MILES'
    double? stopReading,
    String? stopReadingImage,
    String? description,
    DateTime? startTime,
    DateTime? stopTime,
    @Default(0.0) double distanceTravelled,
  }) = _OdometerReading;

  factory OdometerReading.fromJson(Map<String, dynamic> json) =>
      _$OdometerReadingFromJson(json);
}

// ============================================================================
// Summary Models
// ============================================================================

/// API Response wrapper for the monthly summary endpoint
@freezed
abstract class OdometerSummaryApiResponse with _$OdometerSummaryApiResponse {
  const factory OdometerSummaryApiResponse({
    required bool success,
    required OdometerMonthlySummary data,
  }) = _OdometerSummaryApiResponse;

  factory OdometerSummaryApiResponse.fromJson(Map<String, dynamic> json) =>
      _$OdometerSummaryApiResponseFromJson(json);
}

/// Model for the monthly statistics shown on the Odometer Home Screen
@freezed
abstract class OdometerMonthlySummary with _$OdometerMonthlySummary {
  const factory OdometerMonthlySummary({
    required int totalReadings,
    required double totalDistance,
    @Default('KM') String unit,
  }) = _OdometerMonthlySummary;

  factory OdometerMonthlySummary.fromJson(Map<String, dynamic> json) =>
      _$OdometerMonthlySummaryFromJson(json);
}
