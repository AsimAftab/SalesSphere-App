import 'package:freezed_annotation/freezed_annotation.dart';

part 'beat_plan.models.freezed.dart';
part 'beat_plan.models.g.dart';

// ============================================================================
// LIST ENDPOINT MODELS (/api/v1/beat-plans/my-beatplans)
// Minimal data for displaying beat plan cards
// ============================================================================

/// Beat Plan Summary Response (List)
@freezed
abstract class BeatPlanSummaryResponse with _$BeatPlanSummaryResponse {
  const factory BeatPlanSummaryResponse({
    required bool success,
    required List<BeatPlanSummary> data,
    required BeatPlanPagination pagination,
  }) = _BeatPlanSummaryResponse;

  factory BeatPlanSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$BeatPlanSummaryResponseFromJson(json);
}

/// Beat Plan Pagination
@freezed
abstract class BeatPlanPagination with _$BeatPlanPagination {
  const factory BeatPlanPagination({
    required int total,
    required int page,
    required int limit,
    required int pages,
  }) = _BeatPlanPagination;

  factory BeatPlanPagination.fromJson(Map<String, dynamic> json) =>
      _$BeatPlanPaginationFromJson(json);
}

/// Beat Plan Summary (Minimal data for cards)
@freezed
abstract class BeatPlanSummary with _$BeatPlanSummary {
  const factory BeatPlanSummary({
    @JsonKey(name: '_id') required String id,
    required String name,
    required String status,
    required String assignedDate,
    required int totalDirectories,
    required int visitedDirectories,
    required int unvisitedDirectories,
    required int progressPercentage,
    required int totalParties,
    required int totalSites,
    required int totalProspects,
    String? startedAt,
    String? completedAt,
  }) = _BeatPlanSummary;

  factory BeatPlanSummary.fromJson(Map<String, dynamic> json) =>
      _$BeatPlanSummaryFromJson(json);
}

// ============================================================================
// DETAIL ENDPOINT MODELS (/api/v1/beat-plans/{id}/details)
// Full data when opening a beat plan
// ============================================================================

/// Beat Plan Detail Response
@freezed
abstract class BeatPlanDetailResponse with _$BeatPlanDetailResponse {
  const factory BeatPlanDetailResponse({
    required bool success,
    required BeatPlanDetail data,
  }) = _BeatPlanDetailResponse;

  factory BeatPlanDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$BeatPlanDetailResponseFromJson(json);
}

/// Beat Plan Detail (Full data)
@freezed
abstract class BeatPlanDetail with _$BeatPlanDetail {
  const factory BeatPlanDetail({
    @JsonKey(name: '_id') required String id,
    required String name,
    required String status,
    required BeatSchedule schedule,
    required BeatProgress progress,
    required List<BeatEmployee> employees,
    required List<BeatDirectory> directories, // All directories (parties, sites, prospects)
    required List<BeatDirectory> parties, // Filtered parties
    required List<BeatDirectory> sites, // Filtered sites
    required List<BeatDirectory> prospects, // Filtered prospects
    required BeatCreator createdBy,
    required double totalRouteDistance,
    required String createdAt,
    required String updatedAt,
    String? startedAt,
    String? completedAt,
  }) = _BeatPlanDetail;

  factory BeatPlanDetail.fromJson(Map<String, dynamic> json) =>
      _$BeatPlanDetailFromJson(json);
}

/// Beat Schedule
@freezed
abstract class BeatSchedule with _$BeatSchedule {
  const factory BeatSchedule({
    required String frequency,
    required String startDate,
    required List<String> daysOfWeek,
  }) = _BeatSchedule;

  factory BeatSchedule.fromJson(Map<String, dynamic> json) =>
      _$BeatScheduleFromJson(json);
}

/// Beat Progress
@freezed
abstract class BeatProgress with _$BeatProgress {
  const factory BeatProgress({
    required int totalDirectories,
    required int visitedDirectories,
    required int percentage,
    required int totalParties,
    required int totalSites,
    required int totalProspects,
  }) = _BeatProgress;

  factory BeatProgress.fromJson(Map<String, dynamic> json) =>
      _$BeatProgressFromJson(json);
}

/// Beat Employee
@freezed
abstract class BeatEmployee with _$BeatEmployee {
  const factory BeatEmployee({
    @JsonKey(name: '_id') required String id,
    required String name,
    required String email,
    required String role,
    required String phone,
    String? avatarUrl,
  }) = _BeatEmployee;

  factory BeatEmployee.fromJson(Map<String, dynamic> json) =>
      _$BeatEmployeeFromJson(json);
}

/// Beat Directory (Party, Site, or Prospect)
@freezed
abstract class BeatDirectory with _$BeatDirectory {
  const factory BeatDirectory({
    @JsonKey(name: '_id') required String id,
    required String name,
    required String type, // party, site, prospect
    required String ownerName,
    required BeatDirectoryContact contact,
    required BeatDirectoryLocation location,
    required BeatVisitStatus visitStatus,
    String? panVatNumber,
    double? distanceToNext,
  }) = _BeatDirectory;

  factory BeatDirectory.fromJson(Map<String, dynamic> json) =>
      _$BeatDirectoryFromJson(json);
}

/// Beat Directory Contact
@freezed
abstract class BeatDirectoryContact with _$BeatDirectoryContact {
  const factory BeatDirectoryContact({
    required String phone,
    String? email,  // Optional - some directories don't have email
  }) = _BeatDirectoryContact;

  factory BeatDirectoryContact.fromJson(Map<String, dynamic> json) =>
      _$BeatDirectoryContactFromJson(json);
}

/// Beat Directory Location
@freezed
abstract class BeatDirectoryLocation with _$BeatDirectoryLocation {
  const factory BeatDirectoryLocation({
    required String address,
    required double latitude,
    required double longitude,
  }) = _BeatDirectoryLocation;

  factory BeatDirectoryLocation.fromJson(Map<String, dynamic> json) =>
      _$BeatDirectoryLocationFromJson(json);
}

/// Beat Visit Status (embedded in party)
@freezed
abstract class BeatVisitStatus with _$BeatVisitStatus {
  const factory BeatVisitStatus({
    required String status, // pending, completed, skipped
    String? visitedAt,
    BeatVisitLocation? visitLocation,
  }) = _BeatVisitStatus;

  factory BeatVisitStatus.fromJson(Map<String, dynamic> json) =>
      _$BeatVisitStatusFromJson(json);
}

/// Beat Visit Location (coordinates where visit was marked)
@freezed
abstract class BeatVisitLocation with _$BeatVisitLocation {
  const factory BeatVisitLocation({
    double? latitude,
    double? longitude,
  }) = _BeatVisitLocation;

  factory BeatVisitLocation.fromJson(Map<String, dynamic> json) =>
      _$BeatVisitLocationFromJson(json);
}

/// Beat Creator
@freezed
abstract class BeatCreator with _$BeatCreator {
  const factory BeatCreator({
    @JsonKey(name: '_id') required String id,
    required String name,
    required String email,
  }) = _BeatCreator;

  factory BeatCreator.fromJson(Map<String, dynamic> json) =>
      _$BeatCreatorFromJson(json);
}

// ============================================================================
// START ENDPOINT MODELS (/api/v1/beat-plans/{id}/start)
// Response when starting a beat plan
// ============================================================================

/// Start Beat Plan Response
@freezed
abstract class StartBeatPlanResponse with _$StartBeatPlanResponse {
  const factory StartBeatPlanResponse({
    required bool success,
    required String message,
    required StartBeatPlanData data,
  }) = _StartBeatPlanResponse;

  factory StartBeatPlanResponse.fromJson(Map<String, dynamic> json) =>
      _$StartBeatPlanResponseFromJson(json);
}

/// Start Beat Plan Data
@freezed
abstract class StartBeatPlanData with _$StartBeatPlanData {
  const factory StartBeatPlanData({
    @JsonKey(name: '_id') required String id,
    required String name,
    required String status,
    required BeatSchedule schedule,
    required BeatProgress progress,
    required List<BeatEmployee> employees,
    required List<BeatPartyBasic> parties,
    required List<BeatSiteBasic> sites,
    required List<BeatProspectBasic> prospects,
    required List<BeatVisit> visits,
    required BeatCreator createdBy,
    required String organizationId,
    required String createdAt,
    required String updatedAt,
    String? startedAt,
    String? completedAt,
  }) = _StartBeatPlanData;

  factory StartBeatPlanData.fromJson(Map<String, dynamic> json) =>
      _$StartBeatPlanDataFromJson(json);
}

/// Beat Party Basic (without visit status)
@freezed
abstract class BeatPartyBasic with _$BeatPartyBasic {
  const factory BeatPartyBasic({
    @JsonKey(name: '_id') required String id,
    required String partyName,
    required String ownerName,
    required BeatDirectoryContact contact,
    required BeatDirectoryLocation location,
    String? panVatNumber,
  }) = _BeatPartyBasic;

  factory BeatPartyBasic.fromJson(Map<String, dynamic> json) =>
      _$BeatPartyBasicFromJson(json);
}

/// Beat Site Basic (without visit status)
@freezed
abstract class BeatSiteBasic with _$BeatSiteBasic {
  const factory BeatSiteBasic({
    @JsonKey(name: '_id') required String id,
    required String siteName,
    required String ownerName,
    required BeatDirectoryContact contact,
    required BeatDirectoryLocation location,
  }) = _BeatSiteBasic;

  factory BeatSiteBasic.fromJson(Map<String, dynamic> json) =>
      _$BeatSiteBasicFromJson(json);
}

/// Beat Prospect Basic (without visit status)
@freezed
abstract class BeatProspectBasic with _$BeatProspectBasic {
  const factory BeatProspectBasic({
    @JsonKey(name: '_id') required String id,
    required String prospectName,
    required String ownerName,
    required BeatDirectoryContact contact,
    required BeatDirectoryLocation location,
    String? panVatNumber,
  }) = _BeatProspectBasic;

  factory BeatProspectBasic.fromJson(Map<String, dynamic> json) =>
      _$BeatProspectBasicFromJson(json);
}

/// Beat Visit (from visits array)
@freezed
abstract class BeatVisit with _$BeatVisit {
  const factory BeatVisit({
    @JsonKey(name: '_id') required String id,
    required String directoryId,
    required String directoryType, // party, site, prospect
    required String status, // pending, completed, skipped
  }) = _BeatVisit;

  factory BeatVisit.fromJson(Map<String, dynamic> json) =>
      _$BeatVisitFromJson(json);
}

