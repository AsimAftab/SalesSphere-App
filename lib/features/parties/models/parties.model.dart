import 'package:freezed_annotation/freezed_annotation.dart';

part 'parties.model.freezed.dart';
part 'parties.model.g.dart';

// ============================================================================
// API Response Models
// ============================================================================

/// Party Type model
@freezed
abstract class PartyType with _$PartyType {
  const factory PartyType({
    @JsonKey(name: '_id') required String id,
    required String name,
  }) = _PartyType;

  factory PartyType.fromJson(Map<String, dynamic> json) =>
      _$PartyTypeFromJson(json);
}

/// API Response wrapper for party types endpoint
@freezed
abstract class PartyTypesApiResponse with _$PartyTypesApiResponse {
  const factory PartyTypesApiResponse({
    required bool success,
    required int count,
    required List<PartyType> data,
  }) = _PartyTypesApiResponse;

  factory PartyTypesApiResponse.fromJson(Map<String, dynamic> json) =>
      _$PartyTypesApiResponseFromJson(json);
}

/// Image upload response data
@freezed
abstract class PartyImageUploadData with _$PartyImageUploadData {
  const factory PartyImageUploadData({required String imageUrl}) =
      _PartyImageUploadData;

  factory PartyImageUploadData.fromJson(Map<String, dynamic> json) =>
      _$PartyImageUploadDataFromJson(json);
}

/// API Response wrapper for party image upload
@freezed
abstract class PartyImageUploadResponse with _$PartyImageUploadResponse {
  const factory PartyImageUploadResponse({
    required bool success,
    required String message,
    required PartyImageUploadData data,
  }) = _PartyImageUploadResponse;

  factory PartyImageUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$PartyImageUploadResponseFromJson(json);
}

/// User info for assignedBy field
@freezed
abstract class AssignedBy with _$AssignedBy {
  const factory AssignedBy({
    @JsonKey(name: '_id') required String id,
    required String name,
  }) = _AssignedBy;

  factory AssignedBy.fromJson(Map<String, dynamic> json) =>
      _$AssignedByFromJson(json);
}

/// Assigned party data from /api/v1/parties/my-assigned
@freezed
abstract class AssignedPartyApiData with _$AssignedPartyApiData {
  const factory AssignedPartyApiData({
    @JsonKey(name: '_id') required String id,
    required String partyName,
    required String ownerName,
    PartyLocation? location,
    AssignedBy? assignedBy,
    String? assignedAt,
  }) = _AssignedPartyApiData;

  factory AssignedPartyApiData.fromJson(Map<String, dynamic> json) =>
      _$AssignedPartyApiDataFromJson(json);
}

/// API Response wrapper for assigned parties endpoint
@freezed
abstract class AssignedPartiesApiResponse with _$AssignedPartiesApiResponse {
  const factory AssignedPartiesApiResponse({
    required bool success,
    required int count,
    required List<AssignedPartyApiData> data,
  }) = _AssignedPartiesApiResponse;

  factory AssignedPartiesApiResponse.fromJson(Map<String, dynamic> json) =>
      _$AssignedPartiesApiResponseFromJson(json);
}

/// API Response wrapper for parties list endpoint
@freezed
abstract class PartiesApiResponse with _$PartiesApiResponse {
  const factory PartiesApiResponse({
    required bool success,
    required int count,
    required List<PartyApiData> data,
  }) = _PartiesApiResponse;

  factory PartiesApiResponse.fromJson(Map<String, dynamic> json) =>
      _$PartiesApiResponseFromJson(json);
}

/// Individual party data from API (list view)
@freezed
abstract class PartyApiData with _$PartyApiData {
  const factory PartyApiData({
    @JsonKey(name: '_id') required String id,
    required String partyName,
    required String ownerName,
    PartyLocation? location,
  }) = _PartyApiData;

  factory PartyApiData.fromJson(Map<String, dynamic> json) =>
      _$PartyApiDataFromJson(json);
}

/// API Response wrapper for single party details endpoint
@freezed
abstract class PartyDetailApiResponse with _$PartyDetailApiResponse {
  const factory PartyDetailApiResponse({
    required bool success,
    required PartyDetailApiData data,
  }) = _PartyDetailApiResponse;

  factory PartyDetailApiResponse.fromJson(Map<String, dynamic> json) =>
      _$PartyDetailApiResponseFromJson(json);
}

/// Full party data from API (details view)
@freezed
abstract class PartyDetailApiData with _$PartyDetailApiData {
  const factory PartyDetailApiData({
    @JsonKey(name: '_id') required String id,
    required String partyName,
    required String ownerName,
    String? dateJoined,
    required String panVatNumber,
    String? partyType,
    String? image,
    required PartyContact contact,
    required PartyLocationDetail location,
    String? description,
    String? organizationId,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
  }) = _PartyDetailApiData;

  factory PartyDetailApiData.fromJson(Map<String, dynamic> json) =>
      _$PartyDetailApiDataFromJson(json);
}

/// Contact information for party
@freezed
abstract class PartyContact with _$PartyContact {
  const factory PartyContact({required String phone, String? email}) =
      _PartyContact;

  factory PartyContact.fromJson(Map<String, dynamic> json) =>
      _$PartyContactFromJson(json);
}

/// Location data for party (list view - address only)
@freezed
abstract class PartyLocation with _$PartyLocation {
  const factory PartyLocation({required String address}) = _PartyLocation;

  factory PartyLocation.fromJson(Map<String, dynamic> json) =>
      _$PartyLocationFromJson(json);
}

/// Location data for party (detail view - with coordinates)
@freezed
abstract class PartyLocationDetail with _$PartyLocationDetail {
  const factory PartyLocationDetail({
    required String address,
    double? latitude,
    double? longitude,
  }) = _PartyLocationDetail;

  factory PartyLocationDetail.fromJson(Map<String, dynamic> json) =>
      _$PartyLocationDetailFromJson(json);
}

// ============================================================================
// Update Request Models
// ============================================================================

/// Update party request model for PUT /api/v1/parties/:id
@freezed
abstract class UpdatePartyRequest with _$UpdatePartyRequest {
  const factory UpdatePartyRequest({
    required String partyName,
    required String ownerName,
    required String panVatNumber,
    @JsonKey(includeIfNull: false) String? partyType,
    required UpdatePartyContact contact,
    required UpdatePartyLocation location,
    @JsonKey(includeIfNull: false) String? description,
  }) = _UpdatePartyRequest;

  factory UpdatePartyRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdatePartyRequestFromJson(json);

  // Helper to create from PartyDetails
  factory UpdatePartyRequest.fromPartyDetails(PartyDetails party) {
    return UpdatePartyRequest(
      partyName: party.name,
      ownerName: party.ownerName,
      panVatNumber: party.panVatNumber,
      partyType: party.partyType,
      contact: UpdatePartyContact(phone: party.phoneNumber, email: party.email),
      location: UpdatePartyLocation(
        address: party.fullAddress,
        latitude: party.latitude,
        longitude: party.longitude,
      ),
      description: party.notes,
    );
  }
}

/// Contact info for update request
@freezed
abstract class UpdatePartyContact with _$UpdatePartyContact {
  const factory UpdatePartyContact({
    required String phone,
    @JsonKey(includeIfNull: false) String? email,
  }) = _UpdatePartyContact;

  factory UpdatePartyContact.fromJson(Map<String, dynamic> json) =>
      _$UpdatePartyContactFromJson(json);
}

/// Location info for update request
@freezed
abstract class UpdatePartyLocation with _$UpdatePartyLocation {
  const factory UpdatePartyLocation({
    required String address,
    double? latitude,
    double? longitude,
  }) = _UpdatePartyLocation;

  factory UpdatePartyLocation.fromJson(Map<String, dynamic> json) =>
      _$UpdatePartyLocationFromJson(json);
}

// ============================================================================
// Create Request Models
// ============================================================================

/// Create party request model for POST /api/v1/parties
@freezed
abstract class CreatePartyRequest with _$CreatePartyRequest {
  const factory CreatePartyRequest({
    required String partyName,
    required String ownerName,
    required String dateJoined,
    required String panVatNumber,
    @JsonKey(includeIfNull: false) String? partyType,
    required CreatePartyContact contact,
    required CreatePartyLocation location,
    @JsonKey(includeIfNull: false) String? description,
  }) = _CreatePartyRequest;

  factory CreatePartyRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePartyRequestFromJson(json);
}

/// Contact info for create request
@freezed
abstract class CreatePartyContact with _$CreatePartyContact {
  const factory CreatePartyContact({
    required String phone,
    @JsonKey(includeIfNull: false) String? email,
  }) = _CreatePartyContact;

  factory CreatePartyContact.fromJson(Map<String, dynamic> json) =>
      _$CreatePartyContactFromJson(json);
}

/// Location info for create request
@freezed
abstract class CreatePartyLocation with _$CreatePartyLocation {
  const factory CreatePartyLocation({
    required String address,
    required double latitude,
    required double longitude,
  }) = _CreatePartyLocation;

  factory CreatePartyLocation.fromJson(Map<String, dynamic> json) =>
      _$CreatePartyLocationFromJson(json);
}

/// API Response wrapper for create party endpoint
@freezed
abstract class CreatePartyApiResponse with _$CreatePartyApiResponse {
  const factory CreatePartyApiResponse({
    required bool success,
    required PartyDetailApiData data,
  }) = _CreatePartyApiResponse;

  factory CreatePartyApiResponse.fromJson(Map<String, dynamic> json) =>
      _$CreatePartyApiResponseFromJson(json);
}

// ============================================================================
// App Models
// ============================================================================

/// Lightweight model for party list display
@freezed
abstract class PartyListItem with _$PartyListItem {
  const factory PartyListItem({
    required String id,
    required String name,
    required String ownerName,
    @JsonKey(name: 'full_address') required String fullAddress,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _PartyListItem;

  factory PartyListItem.fromJson(Map<String, dynamic> json) =>
      _$PartyListItemFromJson(json);

  // Helper method to convert from API data
  factory PartyListItem.fromApiData(PartyApiData apiData) {
    return PartyListItem(
      id: apiData.id,
      name: apiData.partyName,
      ownerName: apiData.ownerName,
      fullAddress: apiData.location?.address ?? '',
      phoneNumber: null,
      isActive: true,
    );
  }

  // Helper method to convert from PartyDetails
  factory PartyListItem.fromPartyDetails(PartyDetails party) {
    return PartyListItem(
      id: party.id,
      name: party.name,
      ownerName: party.ownerName,
      fullAddress: party.fullAddress,
      phoneNumber: party.phoneNumber,
      isActive: party.isActive,
    );
  }
}

/// Full party details model (for edit/view screens)
@freezed
abstract class PartyDetails with _$PartyDetails {
  const PartyDetails._();

  const factory PartyDetails({
    required String id,
    required String name,
    required String ownerName,
    required String panVatNumber,
    String? partyType,
    String? imageUrl,
    required String phoneNumber,
    String? email,
    required String fullAddress,
    double? latitude,
    double? longitude,
    String? notes,
    @Default(true) bool isActive,
    String? dateJoined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PartyDetails;

  factory PartyDetails.fromJson(Map<String, dynamic> json) =>
      _$PartyDetailsFromJson(json);

  // Helper method to convert from API detail data
  factory PartyDetails.fromApiDetail(PartyDetailApiData apiData) {
    return PartyDetails(
      id: apiData.id,
      name: apiData.partyName,
      ownerName: apiData.ownerName,
      panVatNumber: apiData.panVatNumber,
      partyType: apiData.partyType,
      imageUrl: apiData.image,
      phoneNumber: apiData.contact.phone,
      email: apiData.contact.email,
      fullAddress: apiData.location.address,
      latitude: apiData.location.latitude,
      longitude: apiData.location.longitude,
      notes: apiData.description,
      dateJoined: apiData.dateJoined,
      isActive: true,
      createdAt: apiData.createdAt != null
          ? DateTime.tryParse(apiData.createdAt!)
          : null,
      updatedAt: apiData.updatedAt != null
          ? DateTime.tryParse(apiData.updatedAt!)
          : null,
    );
  }
}
