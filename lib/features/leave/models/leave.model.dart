import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'leave.model.freezed.dart';
part 'leave.model.g.dart';

// ============================================================================
// API Response Models
// ============================================================================

@freezed
abstract class LeaveApiResponse with _$LeaveApiResponse {
  const factory LeaveApiResponse({
    required bool success,
    int? count,
    required List<LeaveApiData> data,
  }) = _LeaveApiResponse;

  factory LeaveApiResponse.fromJson(Map<String, dynamic> json) =>
      _$LeaveApiResponseFromJson(json);
}

@freezed
abstract class LeaveApiData with _$LeaveApiData {
  const factory LeaveApiData({
    @JsonKey(name: '_id') required String id,
    @JsonKey(name: 'category') required String leaveType,
    required String startDate,
    required String endDate,
    required String status,
    String? reason,
    String? createdAt,
    int? leaveDays,
  }) = _LeaveApiData;

  factory LeaveApiData.fromJson(Map<String, dynamic> json) =>
      _$LeaveApiDataFromJson(json);
}

@freezed
abstract class AddLeaveApiResponse with _$AddLeaveApiResponse {
  const factory AddLeaveApiResponse({
    required bool success,
    required LeaveApiData data,
    int? leaveDays,
  }) = _AddLeaveApiResponse;

  factory AddLeaveApiResponse.fromJson(Map<String, dynamic> json) =>
      _$AddLeaveApiResponseFromJson(json);
}

@freezed
abstract class LeaveDetailApiResponse with _$LeaveDetailApiResponse {
  const factory LeaveDetailApiResponse({
    required bool success,
    required LeaveApiData data,
  }) = _LeaveDetailApiResponse;

  factory LeaveDetailApiResponse.fromJson(Map<String, dynamic> json) =>
      _$LeaveDetailApiResponseFromJson(json);
}

// ============================================================================
// Request Models
// ============================================================================

@freezed
abstract class AddLeaveRequest with _$AddLeaveRequest {
  const factory AddLeaveRequest({
    @JsonKey(name: 'category') required String leaveType,
    required String startDate,
    @JsonKey(includeIfNull: false) String? endDate,
    required String reason,
  }) = _AddLeaveRequest;

  factory AddLeaveRequest.fromJson(Map<String, dynamic> json) =>
      _$AddLeaveRequestFromJson(json);
}

// ============================================================================
// App Models
// ============================================================================

@freezed
abstract class LeaveListItem with _$LeaveListItem {
  const LeaveListItem._();

  const factory LeaveListItem({
    required String id,
    required String leaveType,
    required String startDate,
    required String endDate,
    required String status,
    String? reason,
    int? leaveDays,
  }) = _LeaveListItem;

  factory LeaveListItem.fromApiData(LeaveApiData apiData) {
    return LeaveListItem(
      id: apiData.id,
      leaveType: apiData.leaveType,
      startDate: apiData.startDate,
      endDate: apiData.endDate,
      status: apiData.status,
      reason: apiData.reason,
      leaveDays: apiData.leaveDays,
    );
  }

  LeaveCategory get category => LeaveCategory.fromValue(leaveType);

  String get displayLeaveType => category.displayName;

  IconData get leaveIcon => category.icon;
}

enum LeaveFilter { all, pending, approved, rejected }

enum LeaveCategory {
  sickLeave('sick_leave'),
  maternityLeave('maternity_leave'),
  paternityLeave('paternity_leave'),
  compassionateLeave('compassionate_leave'),
  religiousHolidays('religious_holidays'),
  familyResponsibility('family_responsibility'),
  miscellaneous('miscellaneous');

  final String value;

  const LeaveCategory(this.value);

  static LeaveCategory fromValue(String value) {
    return LeaveCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => LeaveCategory.miscellaneous,
    );
  }

  String get displayName {
    switch (this) {
      case LeaveCategory.sickLeave:
        return 'Sick Leave';
      case LeaveCategory.maternityLeave:
        return 'Maternity Leave';
      case LeaveCategory.paternityLeave:
        return 'Paternity Leave';
      case LeaveCategory.familyResponsibility:
        return 'Family Responsibility Leave';
      case LeaveCategory.compassionateLeave:
        return 'Compassionate Leave';
      case LeaveCategory.religiousHolidays:
        return 'Leave for religious holidays';
      case LeaveCategory.miscellaneous:
        return 'Miscellaneous/Others';
    }
  }

  IconData get icon {
    switch (this) {
      case LeaveCategory.sickLeave:
        return Icons.medical_services_outlined;
      case LeaveCategory.maternityLeave:
        return Icons.face_retouching_natural;
      case LeaveCategory.paternityLeave:
        return Icons.face_outlined;
      case LeaveCategory.familyResponsibility:
        return Icons.groups_outlined;
      case LeaveCategory.compassionateLeave:
        return Icons.volunteer_activism_outlined;
      case LeaveCategory.religiousHolidays:
        return Icons.church_outlined;
      case LeaveCategory.miscellaneous:
        return Icons.more_horiz_outlined;
    }
  }
}
