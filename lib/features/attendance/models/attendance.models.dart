import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';

part 'attendance.models.freezed.dart';
part 'attendance.models.g.dart';

// ========================================
// ATTENDANCE STATUS ENUM
// ========================================
enum AttendanceStatus {
  @JsonValue('P')
  present,
  @JsonValue('A')
  absent,
  @JsonValue('H')
  halfDay,
  @JsonValue('L')
  onLeave,
  @JsonValue('W')
  weeklyOff,
  @JsonValue('NA')
  notMarked, // Not marked/Not applicable - will not be shown in calendar
}

// Extension for status display
extension AttendanceStatusExtension on AttendanceStatus {
  String get displayName {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.halfDay:
        return 'Half Day';
      case AttendanceStatus.onLeave:
        return 'Leave';
      case AttendanceStatus.weeklyOff:
        return 'Weekly Off';
      case AttendanceStatus.notMarked:
        return 'Not Marked';
    }
  }

  /// Get background color for status badge
  Color get backgroundColor {
    switch (this) {
      case AttendanceStatus.present:
        return AppColors.green500;
      case AttendanceStatus.absent:
        return AppColors.red500;
      case AttendanceStatus.weeklyOff:
        return AppColors.blue500;
      case AttendanceStatus.onLeave:
        return AppColors.yellow500;
      case AttendanceStatus.halfDay:
        return AppColors.purple500;
      case AttendanceStatus.notMarked:
        return AppColors.textHint; // Gray for not marked
    }
  }

  /// Get text color for status badge (always white)
  Color get textColor {
    return Colors.white;
  }
}

// ========================================
// ATTENDANCE RECORD MODEL
// ========================================
@freezed
abstract class AttendanceRecord with _$AttendanceRecord {
  const factory AttendanceRecord({
    required String id,
    required DateTime date,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    required AttendanceStatus status,
    String? notes,
    String? location,
    @Default(0) int totalHoursWorked,
  }) = _AttendanceRecord;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      _$AttendanceRecordFromJson(json);
}

// ========================================
// ATTENDANCE SUMMARY MODEL
// ========================================
@freezed
abstract class AttendanceSummary with _$AttendanceSummary {
  const factory AttendanceSummary({
    required int totalDays,
    required int presentDays,
    required int absentDays,
    required int halfDays,
    required int leaveDays,
    required double attendancePercentage,
    required int totalHoursWorked,
  }) = _AttendanceSummary;

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) =>
      _$AttendanceSummaryFromJson(json);
}

// ========================================
// TODAY'S ATTENDANCE MODEL
// ========================================
@freezed
abstract class TodayAttendance with _$TodayAttendance {
  const factory TodayAttendance({
    @JsonKey(name: '_id') String? id,
    String? checkInTime,
    String? checkOutTime,
    String? checkInAddress,
    String? checkOutAddress,
    AttendanceStatus? status,
    String? orgCheckInTime,
    String? orgCheckOutTime,
    String? orgHalfDayCheckOutTime,
    String? orgWeeklyOffDay,
    @Default(false) bool isLate,
    String? expectedCheckInTime,
  }) = _TodayAttendance;

  factory TodayAttendance.fromJson(Map<String, dynamic> json) =>
      _$TodayAttendanceFromJson(json);
}

// ========================================
// TODAY'S ATTENDANCE STATUS RESPONSE
// ========================================
@freezed
abstract class TodayAttendanceStatusResponse
    with _$TodayAttendanceStatusResponse {
  const factory TodayAttendanceStatusResponse({
    required bool success,
    TodayAttendance? data,
    String? message,
    String? organizationTimezone,
    String? organizationCheckInTime,
    String? organizationCheckOutTime,
    String? organizationHalfDayCheckOutTime,
  }) = _TodayAttendanceStatusResponse;

  factory TodayAttendanceStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$TodayAttendanceStatusResponseFromJson(json);
}

// ========================================
// CHECK-IN/OUT REQUEST MODEL
// ========================================
@freezed
abstract class CheckInOutRequest with _$CheckInOutRequest {
  const factory CheckInOutRequest({
    required double latitude,
    required double longitude,
    required String address,
  }) = _CheckInOutRequest;

  factory CheckInOutRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckInOutRequestFromJson(json);
}

// ========================================
// CHECK-IN/OUT RESPONSE MODEL
// ========================================
@freezed
abstract class CheckInOutResponse with _$CheckInOutResponse {
  const factory CheckInOutResponse({
    required bool success,
    required TodayAttendance data,
    bool? isLate,
    String? expectedCheckInTime,
  }) = _CheckInOutResponse;

  factory CheckInOutResponse.fromJson(Map<String, dynamic> json) =>
      _$CheckInOutResponseFromJson(json);
}

// ========================================
// MONTHLY ATTENDANCE DAY MODEL
// ========================================
@freezed
abstract class MonthlyAttendanceDay with _$MonthlyAttendanceDay {
  const factory MonthlyAttendanceDay({
    required AttendanceStatus status,
    String? checkInTime,
    String? checkOutTime,
    String? notes,
  }) = _MonthlyAttendanceDay;

  factory MonthlyAttendanceDay.fromJson(Map<String, dynamic> json) =>
      _$MonthlyAttendanceDayFromJson(json);
}

// ========================================
// MONTHLY ATTENDANCE SUMMARY MODEL
// ========================================
@freezed
abstract class MonthlyAttendanceSummary with _$MonthlyAttendanceSummary {
  const factory MonthlyAttendanceSummary({
    required int totalDays,
    required int present,
    required int absent,
    required int leave,
    required int halfDay,
    required int weeklyOff,
    required int notMarked,
    required int workingDays,
  }) = _MonthlyAttendanceSummary;

  factory MonthlyAttendanceSummary.fromJson(Map<String, dynamic> json) =>
      _$MonthlyAttendanceSummaryFromJson(json);
}

// ========================================
// MONTHLY ATTENDANCE REPORT MODEL
// ========================================
@freezed
abstract class MonthlyAttendanceReport with _$MonthlyAttendanceReport {
  const factory MonthlyAttendanceReport({
    required int month,
    required int year,
    required String weeklyOffDay,
    required Map<String, MonthlyAttendanceDay> attendance,
    required MonthlyAttendanceSummary summary,
  }) = _MonthlyAttendanceReport;

  factory MonthlyAttendanceReport.fromJson(Map<String, dynamic> json) =>
      _$MonthlyAttendanceReportFromJson(json);
}

// ========================================
// API RESPONSE WRAPPER
// ========================================
@freezed
abstract class MonthlyAttendanceResponse with _$MonthlyAttendanceResponse {
  const factory MonthlyAttendanceResponse({
    required bool success,
    required MonthlyAttendanceReport data,
  }) = _MonthlyAttendanceResponse;

  factory MonthlyAttendanceResponse.fromJson(Map<String, dynamic> json) =>
      _$MonthlyAttendanceResponseFromJson(json);
}

// ========================================
// CHECK-IN ERROR RESPONSE
// ========================================
@freezed
abstract class CheckInError with _$CheckInError {
  const factory CheckInError({
    required bool success,
    required String message,
    String? earliestAllowedCheckIn,
    String? latestAllowedCheckIn,
    String? scheduledCheckInTime,
    String? currentTime,
  }) = _CheckInError;

  factory CheckInError.fromJson(Map<String, dynamic> json) =>
      _$CheckInErrorFromJson(json);
}

// ========================================
// CHECKOUT RESTRICTION RESPONSE
// ========================================
@freezed
abstract class CheckoutRestriction with _$CheckoutRestriction {
  const factory CheckoutRestriction({
    required bool success,
    required String message,
    String? allowedFrom,
    String? scheduledCheckout,
    String? checkoutType,
    @Default(false) bool canUseHalfDayFallback,
    String? halfDayAllowedFrom,
    String? halfDayScheduledTime,
    String? halfDayCheckoutClosedAt,
    String? fullDayCheckoutTime,
    String? latestAllowedCheckIn,
    String? currentTime,
  }) = _CheckoutRestriction;

  factory CheckoutRestriction.fromJson(Map<String, dynamic> json) =>
      _$CheckoutRestrictionFromJson(json);
}

// ========================================
// CHECK-IN ERROR EXCEPTION
// ========================================
class CheckInErrorException implements Exception {
  final CheckInError error;

  CheckInErrorException(this.error);

  @override
  String toString() => error.message;
}

// ========================================
// CHECKOUT RESTRICTION EXCEPTION
// ========================================
class CheckoutRestrictionException implements Exception {
  final CheckoutRestriction restriction;

  CheckoutRestrictionException(this.restriction);

  @override
  String toString() => restriction.message;
}

// ========================================
// HALF-DAY WINDOW CLOSED EXCEPTION
// ========================================
class HalfDayWindowClosedException implements Exception {
  final CheckoutRestriction restriction;

  HalfDayWindowClosedException(this.restriction);

  @override
  String toString() => restriction.message;
}

// ========================================
// ATTENDANCE SEARCH MODELS
// ========================================

// Employee Info in Search Response
@freezed
abstract class SearchEmployeeInfo with _$SearchEmployeeInfo {
  const factory SearchEmployeeInfo({
    @JsonKey(name: '_id') required String id,
    required String name,
    required String email,
    required String role,
    String? avatarUrl,
    String? phone,
  }) = _SearchEmployeeInfo;

  factory SearchEmployeeInfo.fromJson(Map<String, dynamic> json) =>
      _$SearchEmployeeInfoFromJson(json);
}

// Searched Attendance Record
@freezed
abstract class SearchedAttendance with _$SearchedAttendance {
  const factory SearchedAttendance({
    @JsonKey(name: '_id') required String id,
    required SearchEmployeeInfo employee,
    required String date,
    required String dayOfWeek,
    required AttendanceStatus status,
    required String statusText,
    String? checkInTime,
    String? checkOutTime,
    double? hoursWorked,
    LocationCoordinates? checkInLocation,
    LocationCoordinates? checkOutLocation,
    String? checkInAddress,
    String? checkOutAddress,
    String? notes,
    SearchEmployeeInfo? markedBy,
  }) = _SearchedAttendance;

  factory SearchedAttendance.fromJson(Map<String, dynamic> json) =>
      _$SearchedAttendanceFromJson(json);
}

// Location Coordinates
@freezed
abstract class LocationCoordinates with _$LocationCoordinates {
  const factory LocationCoordinates({
    required double latitude,
    required double longitude,
  }) = _LocationCoordinates;

  factory LocationCoordinates.fromJson(Map<String, dynamic> json) =>
      _$LocationCoordinatesFromJson(json);
}

// Pagination Info
@freezed
abstract class SearchPagination with _$SearchPagination {
  const factory SearchPagination({
    required int total,
    required int page,
    required int limit,
    required int totalPages,
    required bool hasNextPage,
    required bool hasPrevPage,
  }) = _SearchPagination;

  factory SearchPagination.fromJson(Map<String, dynamic> json) =>
      _$SearchPaginationFromJson(json);
}

// Date Range Filter
@freezed
abstract class DateRangeFilter with _$DateRangeFilter {
  const factory DateRangeFilter({
    required String start,
    required String end,
  }) = _DateRangeFilter;

  factory DateRangeFilter.fromJson(Map<String, dynamic> json) =>
      _$DateRangeFilterFromJson(json);
}

// Search Filters
@freezed
abstract class SearchFilters with _$SearchFilters {
  const factory SearchFilters({
    @JsonKey(fromJson: _statusFromJson) List<String>? status,
    DateRangeFilter? dateRange,
    dynamic location,
  }) = _SearchFilters;

  factory SearchFilters.fromJson(Map<String, dynamic> json) =>
      _$SearchFiltersFromJson(json);
}

// Custom converter to handle both String and List<String> for status
List<String>? _statusFromJson(dynamic json) {
  if (json == null) return null;
  if (json is String) {
    // Backend returns "all" when no filter is applied
    if (json == 'all') return null;
    return [json];
  }
  if (json is List) {
    return json.cast<String>();
  }
  return null;
}

// Attendance Search Response
@freezed
abstract class AttendanceSearchResponse with _$AttendanceSearchResponse {
  const factory AttendanceSearchResponse({
    required bool success,
    required List<SearchedAttendance> data,
    required SearchPagination pagination,
    required SearchFilters filters,
  }) = _AttendanceSearchResponse;

  factory AttendanceSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$AttendanceSearchResponseFromJson(json);
}
