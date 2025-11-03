// lib/features/prospects/models/prospects.model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'prospects.model.freezed.dart';
part 'prospects.model.g.dart';

@freezed
abstract class ProspectLocation with _$ProspectLocation {
  const factory ProspectLocation({
    required String address,
  }) = _ProspectLocation;

  factory ProspectLocation.fromJson(Map<String, dynamic> json) =>
      _$ProspectLocationFromJson(json);
}

@freezed
abstract class Prospects with _$Prospects {
  const factory Prospects({
    @JsonKey(name: '_id') required String id,
    @JsonKey(name: 'prospectName') required String name,
    required String ownerName,
    required ProspectLocation location,
  }) = _Prospects;

  factory Prospects.fromJson(Map<String, dynamic> json) =>
      _$ProspectsFromJson(json);
}

@freezed
abstract class ProspectsResponse with _$ProspectsResponse {
  const factory ProspectsResponse({
    required bool success,
    required int count,
    required List<Prospects> data,
  }) = _ProspectsResponse;

  factory ProspectsResponse.fromJson(Map<String, dynamic> json) =>
      _$ProspectsResponseFromJson(json);
}

// ============================================================================
// Create Request Models
// ============================================================================

/// Create prospect request model for POST /api/v1/prospects
@freezed
abstract class CreateProspectRequest with _$CreateProspectRequest {
  const factory CreateProspectRequest({
    @JsonKey(name: 'prospectName') required String name,
    required String ownerName,
    required String dateJoined,
    @JsonKey(includeIfNull: false) String? panVatNumber,
    required CreateProspectContact contact,
    required CreateProspectLocation location,
    @JsonKey(name: 'description', includeIfNull: false) String? notes,
  }) = _CreateProspectRequest;

  factory CreateProspectRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateProspectRequestFromJson(json);
}

/// Contact info for create request
@freezed
abstract class CreateProspectContact with _$CreateProspectContact {
  const factory CreateProspectContact({
    required String phone,
    @JsonKey(includeIfNull: false) String? email,
  }) = _CreateProspectContact;

  factory CreateProspectContact.fromJson(Map<String, dynamic> json) =>
      _$CreateProspectContactFromJson(json);
}

/// Location info for create request
@freezed
abstract class CreateProspectLocation with _$CreateProspectLocation {
  const factory CreateProspectLocation({
    required String address,
    required double latitude,
    required double longitude,
  }) = _CreateProspectLocation;

  factory CreateProspectLocation.fromJson(Map<String, dynamic> json) =>
      _$CreateProspectLocationFromJson(json);
}

/// API Response wrapper for create prospect endpoint
@freezed
abstract class CreateProspectApiResponse with _$CreateProspectApiResponse {
  const factory CreateProspectApiResponse({
    required bool success,
    required ProspectDetailApiData data,
  }) = _CreateProspectApiResponse;

  factory CreateProspectApiResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateProspectApiResponseFromJson(json);
}

/// Full prospect data from API (details view)
@freezed
abstract class ProspectDetailApiData with _$ProspectDetailApiData {
  const factory ProspectDetailApiData({
    @JsonKey(name: '_id') required String id,
    @JsonKey(name: 'prospectName') required String name,
    required String ownerName,
    String? dateJoined,
    String? panVatNumber,
    ProspectContact? contact,
    ProspectLocationDetail? location,
    @JsonKey(name: 'description') String? notes,
    String? organizationId,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
    @JsonKey(name: '__v') int? v,
  }) = _ProspectDetailApiData;

  factory ProspectDetailApiData.fromJson(Map<String, dynamic> json) =>
      _$ProspectDetailApiDataFromJson(json);
}

/// Contact information for prospect
@freezed
abstract class ProspectContact with _$ProspectContact {
  const factory ProspectContact({
    String? phone,
    String? email,
  }) = _ProspectContact;

  factory ProspectContact.fromJson(Map<String, dynamic> json) =>
      _$ProspectContactFromJson(json);
}

/// Location data for prospect (detail view - with coordinates)
@freezed
abstract class ProspectLocationDetail with _$ProspectLocationDetail {
  const factory ProspectLocationDetail({
    String? address,
    double? latitude,
    double? longitude,
  }) = _ProspectLocationDetail;

  factory ProspectLocationDetail.fromJson(Map<String, dynamic> json) =>
      _$ProspectLocationDetailFromJson(json);
}

// ============================================================================
// Update Request Models
// ============================================================================

/// Update prospect request model for PUT /api/v1/prospects/:id
@freezed
abstract class UpdateProspectRequest with _$UpdateProspectRequest {
  const factory UpdateProspectRequest({
    required String ownerName,
    required UpdateProspectLocation location,
  }) = _UpdateProspectRequest;

  factory UpdateProspectRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProspectRequestFromJson(json);
}

/// Location info for update request
@freezed
abstract class UpdateProspectLocation with _$UpdateProspectLocation {
  const factory UpdateProspectLocation({
    required String address,
    required double latitude,
    required double longitude,
  }) = _UpdateProspectLocation;

  factory UpdateProspectLocation.fromJson(Map<String, dynamic> json) =>
      _$UpdateProspectLocationFromJson(json);
}

/// API Response wrapper for update prospect endpoint
@freezed
abstract class UpdateProspectApiResponse with _$UpdateProspectApiResponse {
  const factory UpdateProspectApiResponse({
    required bool success,
    required ProspectDetailApiData data,
  }) = _UpdateProspectApiResponse;

  factory UpdateProspectApiResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateProspectApiResponseFromJson(json);
}

// ============================================================================
// PROSPECT DETAILS MODEL (for edit screen)
// ============================================================================

@freezed
abstract class ProspectDetails with _$ProspectDetails {
  const ProspectDetails._();

  const factory ProspectDetails({
    required String id,
    required String name,
    required String ownerName,
    String? dateJoined,
    String? panVatNumber,
    String? phoneNumber,
    String? email,
    required String fullAddress,
    double? latitude,
    double? longitude,
    String? notes,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProspectDetails;

  factory ProspectDetails.fromJson(Map<String, dynamic> json) =>
      _$ProspectDetailsFromJson(json);

  // Helper method to convert from API detail data
  factory ProspectDetails.fromApiDetail(ProspectDetailApiData apiData) {
    return ProspectDetails(
      id: apiData.id,
      name: apiData.name,
      ownerName: apiData.ownerName,
      dateJoined: apiData.dateJoined,
      panVatNumber: apiData.panVatNumber,
      phoneNumber: apiData.contact?.phone,
      email: apiData.contact?.email,
      fullAddress: apiData.location?.address ?? '',
      latitude: apiData.location?.latitude,
      longitude: apiData.location?.longitude,
      notes: apiData.notes,
      isActive: true,
      createdAt: apiData.createdAt != null
          ? DateTime.tryParse(apiData.createdAt!)
          : null,
      updatedAt: apiData.updatedAt != null
          ? DateTime.tryParse(apiData.updatedAt!)
          : null,
    );
  }

  // Helper method to convert from Prospects (list item)
  factory ProspectDetails.fromProspects(Prospects prospect) {
    return ProspectDetails(
      id: prospect.id,
      name: prospect.name,
      ownerName: prospect.ownerName,
      fullAddress: prospect.location.address,
      dateJoined: null,
      panVatNumber: null,
      phoneNumber: null,
      email: null,
      latitude: null,
      longitude: null,
      notes: null,
      isActive: true,
      createdAt: null,
      updatedAt: null,
    );
  }
}

// ============================================================================
// TRANSFER PROSPECT TO PARTY MODELS
// ============================================================================

/// Contact info for transferred party
@freezed
abstract class PartyContact with _$PartyContact {
  const factory PartyContact({
    String? phone,
    String? email,
  }) = _PartyContact;

  factory PartyContact.fromJson(Map<String, dynamic> json) =>
      _$PartyContactFromJson(json);
}

/// Location info for transferred party
@freezed
abstract class PartyLocation with _$PartyLocation {
  const factory PartyLocation({
    String? address,
    double? latitude,
    double? longitude,
  }) = _PartyLocation;

  factory PartyLocation.fromJson(Map<String, dynamic> json) =>
      _$PartyLocationFromJson(json);
}

/// Transferred party data from API
@freezed
abstract class TransferredPartyData with _$TransferredPartyData {
  const factory TransferredPartyData({
    @JsonKey(name: '_id') required String id,
    required String partyName,
    required String ownerName,
    String? dateJoined,
    String? panVatNumber,
    PartyContact? contact,
    PartyLocation? location,
    String? description,
    String? organizationId,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
    @JsonKey(name: '__v') int? v,
  }) = _TransferredPartyData;

  factory TransferredPartyData.fromJson(Map<String, dynamic> json) =>
      _$TransferredPartyDataFromJson(json);
}

/// API Response wrapper for transfer prospect to party endpoint
@freezed
abstract class TransferProspectToPartyResponse with _$TransferProspectToPartyResponse {
  const factory TransferProspectToPartyResponse({
    required bool success,
    required String message,
    required TransferredPartyData data,
  }) = _TransferProspectToPartyResponse;

  factory TransferProspectToPartyResponse.fromJson(Map<String, dynamic> json) =>
      _$TransferProspectToPartyResponseFromJson(json);
}