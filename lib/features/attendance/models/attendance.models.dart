import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance.models.freezed.dart';
part 'attendance.models.g.dart';

// ========================================
// ATTENDANCE STATUS ENUM
// ========================================
enum AttendanceStatus {
  @JsonValue('present')
  present,
  @JsonValue('absent')
  absent,
  @JsonValue('late')
  late,
  @JsonValue('half_day')
  halfDay,
  @JsonValue('on_leave')
  onLeave,
}

// Extension for status display
extension AttendanceStatusExtension on AttendanceStatus {
  String get displayName {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.halfDay:
        return 'Half Day';
      case AttendanceStatus.onLeave:
        return 'On Leave';
    }
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
    required int lateDays,
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
    DateTime? checkInTime,
    DateTime? checkOutTime,
    @Default(false) bool isCheckedIn,
    @Default(false) bool isCheckedOut,
    String? location,
    @Default(0) int hoursWorked,
  }) = _TodayAttendance;

  factory TodayAttendance.fromJson(Map<String, dynamic> json) =>
      _$TodayAttendanceFromJson(json);
}
