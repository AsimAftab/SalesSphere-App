// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance.models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttendanceRecord _$AttendanceRecordFromJson(Map<String, dynamic> json) =>
    _AttendanceRecord(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      checkInTime: json['checkInTime'] == null
          ? null
          : DateTime.parse(json['checkInTime'] as String),
      checkOutTime: json['checkOutTime'] == null
          ? null
          : DateTime.parse(json['checkOutTime'] as String),
      status: $enumDecode(_$AttendanceStatusEnumMap, json['status']),
      notes: json['notes'] as String?,
      location: json['location'] as String?,
      totalHoursWorked: (json['totalHoursWorked'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$AttendanceRecordToJson(_AttendanceRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'checkInTime': instance.checkInTime?.toIso8601String(),
      'checkOutTime': instance.checkOutTime?.toIso8601String(),
      'status': _$AttendanceStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'location': instance.location,
      'totalHoursWorked': instance.totalHoursWorked,
    };

const _$AttendanceStatusEnumMap = {
  AttendanceStatus.present: 'present',
  AttendanceStatus.absent: 'absent',
  AttendanceStatus.late: 'late',
  AttendanceStatus.halfDay: 'half_day',
  AttendanceStatus.onLeave: 'on_leave',
};

_AttendanceSummary _$AttendanceSummaryFromJson(Map<String, dynamic> json) =>
    _AttendanceSummary(
      totalDays: (json['totalDays'] as num).toInt(),
      presentDays: (json['presentDays'] as num).toInt(),
      absentDays: (json['absentDays'] as num).toInt(),
      lateDays: (json['lateDays'] as num).toInt(),
      leaveDays: (json['leaveDays'] as num).toInt(),
      attendancePercentage: (json['attendancePercentage'] as num).toDouble(),
      totalHoursWorked: (json['totalHoursWorked'] as num).toInt(),
    );

Map<String, dynamic> _$AttendanceSummaryToJson(_AttendanceSummary instance) =>
    <String, dynamic>{
      'totalDays': instance.totalDays,
      'presentDays': instance.presentDays,
      'absentDays': instance.absentDays,
      'lateDays': instance.lateDays,
      'leaveDays': instance.leaveDays,
      'attendancePercentage': instance.attendancePercentage,
      'totalHoursWorked': instance.totalHoursWorked,
    };

_TodayAttendance _$TodayAttendanceFromJson(Map<String, dynamic> json) =>
    _TodayAttendance(
      checkInTime: json['checkInTime'] == null
          ? null
          : DateTime.parse(json['checkInTime'] as String),
      checkOutTime: json['checkOutTime'] == null
          ? null
          : DateTime.parse(json['checkOutTime'] as String),
      isCheckedIn: json['isCheckedIn'] as bool? ?? false,
      isCheckedOut: json['isCheckedOut'] as bool? ?? false,
      location: json['location'] as String?,
      hoursWorked: (json['hoursWorked'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TodayAttendanceToJson(_TodayAttendance instance) =>
    <String, dynamic>{
      'checkInTime': instance.checkInTime?.toIso8601String(),
      'checkOutTime': instance.checkOutTime?.toIso8601String(),
      'isCheckedIn': instance.isCheckedIn,
      'isCheckedOut': instance.isCheckedOut,
      'location': instance.location,
      'hoursWorked': instance.hoursWorked,
    };
