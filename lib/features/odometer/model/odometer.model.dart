import 'package:freezed_annotation/freezed_annotation.dart';

part 'odometer.model.freezed.dart';
part 'odometer.model.g.dart';

// ============================================================================
// API Response Models
// ============================================================================

/// API Response for today's odometer status
/// Now supports multiple trips per day
@freezed
abstract class OdometerTodayStatusResponse with _$OdometerTodayStatusResponse {
  const factory OdometerTodayStatusResponse({
    required bool success,
    @Default([]) List<OdometerReading> trips,
    @Default(0) int totalTrips,
    @Default(false) bool hasActiveTrip,
    String? message,
    String? status, // "not_started", "in_progress"
    String? organizationTimezone,
  }) = _OdometerTodayStatusResponse;

  factory OdometerTodayStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$OdometerTodayStatusResponseFromJson(json);
}

/// Start location object from API
@freezed
abstract class StartLocation with _$StartLocation {
  const factory StartLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) = _StartLocation;

  factory StartLocation.fromJson(Map<String, dynamic> json) =>
      _$StartLocationFromJson(json);
}

/// Stop location object from API
@freezed
abstract class StopLocation with _$StopLocation {
  const factory StopLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) = _StopLocation;

  factory StopLocation.fromJson(Map<String, dynamic> json) =>
      _$StopLocationFromJson(json);
}

// ============================================================================
// Legacy API Response Models (kept for list/details endpoints)
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
    @Default(1) int tripNumber,
    required DateTime startTime,
    DateTime? stopTime,
    required double startReading,
    double? stopReading,
    @JsonKey(name: 'distance') @Default(0.0) double distanceTravelled,
    @JsonKey(name: 'startUnit') @Default('KM') String unit,
    @JsonKey(name: 'startDescription') String? description,
    @JsonKey(name: 'stopDescription') String? stopDescription,
    @JsonKey(name: 'startImage') String? startReadingImage,
    @JsonKey(name: 'stopImage') String? stopReadingImage,
    @JsonKey(name: 'startLocation') StartLocation? startLocation,
    @JsonKey(name: 'stopLocation') StopLocation? stopLocation,
    @JsonKey(name: 'status') String? status,
    String? date,
    String? employee,
    String? organizationId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _OdometerDetails;

  factory OdometerDetails.fromJson(Map<String, dynamic> json) =>
      _$OdometerDetailsFromJson(json);

  const OdometerDetails._();

  /// Get start location as display string
  String get startLocationDisplay =>
      startLocation?.address ?? 'Unknown location';

  /// Get stop location as display string
  String get stopLocationDisplay => stopLocation?.address ?? 'Unknown location';

  /// Get start description (use startDescription if not available)
  String get displayStartDescription => description ?? 'No description provided';

  /// Get stop description
  String get displayStopDescription => stopDescription ?? 'No description provided';
}

/// Lightweight model for Odometer history list display
@freezed
abstract class OdometerListItem with _$OdometerListItem {
  const factory OdometerListItem({
    @JsonKey(name: '_id') required String id,
    required DateTime date,
    @Default(1) int tripNumber,
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
    @Default(1) int tripNumber,
    @Default(0.0) double startReading,
    @JsonKey(name: 'startUnit')
    @Default('KM') String unit, // 'km' or 'miles' from API
    @JsonKey(name: 'startDescription') String? description,
    @JsonKey(name: 'startImage') String? startReadingImage,
    double? stopReading,
    @JsonKey(name: 'stopUnit') String? stopUnit,
    @JsonKey(name: 'stopImage') String? stopReadingImage,
    DateTime? startTime,
    DateTime? stopTime,
    @JsonKey(name: 'distance') @Default(0.0) double distanceTravelled,
    @JsonKey(name: 'status') String? tripStatus, // "in_progress", "completed"
    StartLocation? startLocation,
    StopLocation? stopLocation,
    String? date,
    String? employee,
    String? organizationId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _OdometerReading;

  factory OdometerReading.fromJson(Map<String, dynamic> json) =>
      _$OdometerReadingFromJson(json);

  const OdometerReading._();

  /// Check if trip is currently in progress
  bool get isInProgress => tripStatus == 'in_progress' || stopReading == null;

  /// Check if trip is completed
  bool get isCompleted => tripStatus == 'completed' || stopReading != null;
}

// ============================================================================
// Summary Models
// ============================================================================

/// Model for the monthly statistics summary from API
@freezed
abstract class OdometerMonthlySummary with _$OdometerMonthlySummary {
  const factory OdometerMonthlySummary({
    @Default(0) int daysRecorded,
    @Default(0) int daysCompleted,
    @Default(0) int daysInProgress,
    required double totalDistance,
    @Default(0.0) double avgDailyDistance,
    @Default('KM') String unit,
  }) = _OdometerMonthlySummary;

  factory OdometerMonthlySummary.fromJson(Map<String, dynamic> json) =>
      _$OdometerMonthlySummaryFromJson(json);
}

/// API Response for monthly odometer report
@freezed
abstract class OdometerMonthlyReportResponse
    with _$OdometerMonthlyReportResponse {
  const factory OdometerMonthlyReportResponse({
    required bool success,
    required int month,
    required int year,
    required Map<String, dynamic> odometer,
    required OdometerMonthlySummary summary,
    String? organizationTimezone,
  }) = _OdometerMonthlyReportResponse;

  factory OdometerMonthlyReportResponse.fromJson(Map<String, dynamic> json) =>
      _$OdometerMonthlyReportResponseFromJson(json);
}

/// Daily odometer entry from monthly report
@freezed
abstract class DailyOdometerEntry with _$DailyOdometerEntry {
  const factory DailyOdometerEntry({
    @JsonKey(name: '_id') String? id,
    required String status, // "not_started", "in_progress", "completed"
    double? startReading,
    @JsonKey(name: 'startUnit') String? unit,
    double? stopReading,
    @JsonKey(name: 'stopUnit') String? stopUnit,
    double? distance,
    DateTime? startTime,
    DateTime? stopTime,
  }) = _DailyOdometerEntry;

  factory DailyOdometerEntry.fromJson(Map<String, dynamic> json) =>
      _$DailyOdometerEntryFromJson(json);
}
