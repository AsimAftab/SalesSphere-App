import 'package:freezed_annotation/freezed_annotation.dart';

part 'active_tracking_session.models.freezed.dart';
part 'active_tracking_session.models.g.dart';

/// Active Tracking Session Response
@freezed
abstract class ActiveTrackingSessionResponse with _$ActiveTrackingSessionResponse {
  const factory ActiveTrackingSessionResponse({
    required bool success,
    required List<ActiveTrackingSession> data,
  }) = _ActiveTrackingSessionResponse;

  factory ActiveTrackingSessionResponse.fromJson(Map<String, dynamic> json) =>
      _$ActiveTrackingSessionResponseFromJson(json);
}

/// Active Tracking Session
@freezed
abstract class ActiveTrackingSession with _$ActiveTrackingSession {
  const factory ActiveTrackingSession({
    required String sessionId,
    required ActiveBeatPlan beatPlan,
    required ActiveUser user,
    required CurrentLocation currentLocation,
  }) = _ActiveTrackingSession;

  factory ActiveTrackingSession.fromJson(Map<String, dynamic> json) =>
      _$ActiveTrackingSessionFromJson(json);
}

/// Active Beat Plan (minimal data)
@freezed
abstract class ActiveBeatPlan with _$ActiveBeatPlan {
  const factory ActiveBeatPlan({
    @JsonKey(name: '_id') required String id,
    required String name,
    required String status,
    required BeatSchedule schedule,
    @Default(ActiveBeatPlanProgress()) ActiveBeatPlanProgress progress,
  }) = _ActiveBeatPlan;

  factory ActiveBeatPlan.fromJson(Map<String, dynamic> json) =>
      _$ActiveBeatPlanFromJson(json);
}

/// Active Beat Plan Progress
@freezed
abstract class ActiveBeatPlanProgress with _$ActiveBeatPlanProgress {
  const factory ActiveBeatPlanProgress({
    @Default(0) int totalDirectories,
    @Default(0) int visitedDirectories,
    @Default(0) int unvisitedDirectories,
    @Default(0) int percentage,
    @Default(0) int totalParties,
    @Default(0) int totalSites,
    @Default(0) int totalProspects,
  }) = _ActiveBeatPlanProgress;

  factory ActiveBeatPlanProgress.fromJson(Map<String, dynamic> json) =>
      _$ActiveBeatPlanProgressFromJson(json);
}

/// Beat Schedule
@freezed
abstract class BeatSchedule with _$BeatSchedule {
  const factory BeatSchedule({
    required String frequency,
    required String startDate,
    @Default([]) List<int> daysOfWeek,
  }) = _BeatSchedule;

  factory BeatSchedule.fromJson(Map<String, dynamic> json) =>
      _$BeatScheduleFromJson(json);
}

/// Active User (minimal data)
@freezed
abstract class ActiveUser with _$ActiveUser {
  const factory ActiveUser({
    @JsonKey(name: '_id') required String id,
    required String name,
    required String email,
    required String role,
    required String phone,
    String? avatarUrl,
  }) = _ActiveUser;

  factory ActiveUser.fromJson(Map<String, dynamic> json) =>
      _$ActiveUserFromJson(json);
}

/// Current Location
@freezed
abstract class CurrentLocation with _$CurrentLocation {
  const factory CurrentLocation({
    required double latitude,
    required double longitude,
    @Default({}) Map<String, dynamic> address,
  }) = _CurrentLocation;

  factory CurrentLocation.fromJson(Map<String, dynamic> json) =>
      _$CurrentLocationFromJson(json);
}
