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
    required int count,
    required List<LeaveApiData> data,
  }) = _LeaveApiResponse;

  factory LeaveApiResponse.fromJson(Map<String, dynamic> json) =>
      _$LeaveApiResponseFromJson(json);
}

@freezed
abstract class LeaveApiData with _$LeaveApiData {
  const factory LeaveApiData({
    @JsonKey(name: '_id') required String id,
    required String leaveType,
    required String startDate,
    required String endDate,
    required String status,
    String? reason,
    String? createdAt,
  }) = _LeaveApiData;

  factory LeaveApiData.fromJson(Map<String, dynamic> json) =>
      _$LeaveApiDataFromJson(json);
}

@freezed
abstract class AddLeaveApiResponse with _$AddLeaveApiResponse {
  const factory AddLeaveApiResponse({
    required bool success,
    required String message,
  }) = _AddLeaveApiResponse;

  factory AddLeaveApiResponse.fromJson(Map<String, dynamic> json) =>
      _$AddLeaveApiResponseFromJson(json);
}

// ============================================================================
// Request Models
// ============================================================================

@freezed
abstract class AddLeaveRequest with _$AddLeaveRequest {
  const factory AddLeaveRequest({
    required String leaveType,
    required String startDate,
    required String endDate,
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
  const factory LeaveListItem({
    required String id,
    required String leaveType,
    required String startDate,
    required String endDate,
    required String status,
    String? reason,
  }) = _LeaveListItem;

  factory LeaveListItem.fromApiData(LeaveApiData apiData) {
    return LeaveListItem(
      id: apiData.id,
      leaveType: apiData.leaveType,
      startDate: apiData.startDate,
      endDate: apiData.endDate,
      status: apiData.status,
      reason: apiData.reason,
    );
  }
}