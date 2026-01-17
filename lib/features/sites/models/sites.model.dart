// lib/features/sites/models/sites.model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sites.model.freezed.dart';
part 'sites.model.g.dart';

// ============================================================================
// CORE DOMAIN MODELS
// ============================================================================

/// Main Sites model - Core entity
@freezed
abstract class Sites with _$Sites {
  const Sites._();

  const factory Sites({
    required String id,
    required String name,
    required String location,
    String? ownerName,
    String? phoneNumber,
    String? email,
    String? panVatNumber,
    double? latitude,
    double? longitude,
    String? notes,
    String? dateJoined,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Sites;

  factory Sites.fromJson(Map<String, dynamic> json) => _$SitesFromJson(json);
}

/// Enhanced site details model for detail/edit screens
@freezed
abstract class SiteDetails with _$SiteDetails {
  const SiteDetails._();

  const factory SiteDetails({
    required String id,
    required String name,
    required String managerName,
    required String phoneNumber,
    String? email,
    required String fullAddress,
    double? latitude,
    double? longitude,
    String? notes,
    @Default(true) bool isActive,
    String? dateJoined,
    String? subOrganization,
    @Default([]) List<SiteInterest> siteInterest,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _SiteDetails;

  factory SiteDetails.fromJson(Map<String, dynamic> json) =>
      _$SiteDetailsFromJson(json);

  /// Convert from Sites model
  factory SiteDetails.fromSites(Sites site) {
    return SiteDetails(
      id: site.id,
      name: site.name,
      managerName: site.ownerName ?? '',
      phoneNumber: site.phoneNumber ?? '',
      email: site.email,
      fullAddress: site.location,
      latitude: site.latitude,
      longitude: site.longitude,
      notes: site.notes,
      dateJoined: site.dateJoined,
      subOrganization: null,
      siteInterest: const [],
      isActive: site.isActive,
      createdAt: site.createdAt,
      updatedAt: site.updatedAt,
    );
  }

  /// Convert from FetchSiteData model
  factory SiteDetails.fromFetchSiteData(FetchSiteData data) {
    return SiteDetails(
      id: data.id,
      name: data.siteName,
      managerName: data.ownerName,
      phoneNumber: data.contact.phone,
      email: data.contact.email,
      fullAddress: data.location.address,
      latitude: data.location.latitude,
      longitude: data.location.longitude,
      notes: data.description,
      dateJoined: data.dateJoined,
      subOrganization: data.subOrganization,
      siteInterest: data.siteInterest,
      isActive: true,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  /// Convert back to Sites model
  Sites toSites() {
    return Sites(
      id: id,
      name: name,
      location: fullAddress,
      ownerName: managerName,
      phoneNumber: phoneNumber,
      email: email,
      panVatNumber: null,
      latitude: latitude,
      longitude: longitude,
      notes: notes,
      dateJoined: dateJoined,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Site image model for photo management
@freezed
abstract class SiteImage with _$SiteImage {
  const SiteImage._();

  const factory SiteImage({
    required String id,
    required String siteId,
    required String imageUrl, // Local file path or network URL
    required int imageOrder, // 1-9 for ordering
    required DateTime uploadedAt,
    String? caption,
    @Default(false) bool isUploaded, // Track if synced to server
  }) = _SiteImage;

  factory SiteImage.fromJson(Map<String, dynamic> json) =>
      _$SiteImageFromJson(json);

  /// Create a new site image with auto-generated ID
  factory SiteImage.create({
    required String siteId,
    required String imageUrl,
    required int imageOrder,
    String? caption,
  }) {
    return SiteImage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      siteId: siteId,
      imageUrl: imageUrl,
      imageOrder: imageOrder,
      uploadedAt: DateTime.now(),
      caption: caption,
      isUploaded: false,
    );
  }
}

// ============================================================================
// SUPPORTING MODELS - SUB-ORGANIZATION & SITE INTEREST
// ============================================================================

/// Technician model
@freezed
abstract class SiteTechnician with _$SiteTechnician {
  const factory SiteTechnician({
    required String name,
    required String phone,
    @JsonKey(name: '_id', includeIfNull: false) String? id,
  }) = _SiteTechnician;

  factory SiteTechnician.fromJson(Map<String, dynamic> json) =>
      _$SiteTechnicianFromJson(json);
}

/// Site interest model
@freezed
abstract class SiteInterest with _$SiteInterest {
  const factory SiteInterest({
    required String category,
    required List<String> brands,
    required List<SiteTechnician> technicians,
    @JsonKey(name: '_id', includeIfNull: false) String? id,
  }) = _SiteInterest;

  factory SiteInterest.fromJson(Map<String, dynamic> json) =>
      _$SiteInterestFromJson(json);
}

/// Sub-organization model
@freezed
abstract class SubOrganization with _$SubOrganization {
  const factory SubOrganization({
    @JsonKey(name: '_id') required String id,
    required String name,
  }) = _SubOrganization;

  factory SubOrganization.fromJson(Map<String, dynamic> json) =>
      _$SubOrganizationFromJson(json);
}

/// Site category model (from GET /sites/categories)
@freezed
abstract class SiteCategory with _$SiteCategory {
  const factory SiteCategory({
    @JsonKey(name: '_id') required String id,
    required String name,
    required List<String> brands,
    required List<SiteTechnician> technicians,
    required String organizationId,
    required DateTime createdAt,
    required DateTime updatedAt,
    @JsonKey(name: '__v') int? v,
  }) = _SiteCategory;

  factory SiteCategory.fromJson(Map<String, dynamic> json) =>
      _$SiteCategoryFromJson(json);
}

// ============================================================================
// API REQUEST MODELS - CREATE
// ============================================================================

/// Create site request (POST /sites)
@freezed
abstract class CreateSiteRequest with _$CreateSiteRequest {
  const CreateSiteRequest._();

  const factory CreateSiteRequest({
    required String siteName,
    required String ownerName,
    @JsonKey(includeIfNull: false) String? subOrganization,
    required String dateJoined,
    required CreateSiteContact contact,
    required CreateSiteLocation location,
    @JsonKey(includeIfNull: false) String? description,
    @Default([]) @JsonKey(includeIfNull: false) List<SiteInterest> siteInterest,
  }) = _CreateSiteRequest;

  factory CreateSiteRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSiteRequestFromJson(json);

  /// Convert to Sites model for local storage
  Sites toSites(String id) {
    return Sites(
      id: id,
      name: siteName,
      location: location.address,
      ownerName: ownerName,
      phoneNumber: contact.phone,
      email: contact.email,
      panVatNumber: null,
      latitude: location.latitude,
      longitude: location.longitude,
      notes: description,
      dateJoined: dateJoined,
      isActive: true,
      createdAt: DateTime.now(),
    );
  }
}
/// Contact info for create site request
@freezed
abstract class CreateSiteContact with _$CreateSiteContact {
  const factory CreateSiteContact({
    required String phone,
    String? email,
  }) = _CreateSiteContact;

  factory CreateSiteContact.fromJson(Map<String, dynamic> json) =>
      _$CreateSiteContactFromJson(json);
}

/// Location info for create site request
@freezed
abstract class CreateSiteLocation with _$CreateSiteLocation {
  const factory CreateSiteLocation({
    required String address,
    required double latitude,
    required double longitude,
  }) = _CreateSiteLocation;

  factory CreateSiteLocation.fromJson(Map<String, dynamic> json) =>
      _$CreateSiteLocationFromJson(json);
}

// ============================================================================
// API REQUEST MODELS - UPDATE
// ============================================================================

/// Update site request (PUT /sites/:id)
@freezed
abstract class UpdateSiteRequest with _$UpdateSiteRequest {
  const UpdateSiteRequest._();

  const factory UpdateSiteRequest({
    required String siteName,
    required String ownerName,
    @JsonKey(includeIfNull: false) String? subOrganization,
    required String dateJoined,
    required CreateSiteContact contact,
    required CreateSiteLocation location,
    @JsonKey(includeIfNull: false) String? description,
    @Default([]) @JsonKey(includeIfNull: false) List<SiteInterest> siteInterest,
  }) = _UpdateSiteRequest;

  factory UpdateSiteRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateSiteRequestFromJson(json);

  /// Create from SiteDetails
  factory UpdateSiteRequest.fromSiteDetails(SiteDetails site) {
    return UpdateSiteRequest(
      siteName: site.name,
      ownerName: site.managerName,
      subOrganization: site.subOrganization,
      dateJoined: site.dateJoined ?? '',
      contact: CreateSiteContact(
        phone: site.phoneNumber,
        email: site.email,
      ),
      location: CreateSiteLocation(
        address: site.fullAddress,
        latitude: site.latitude ?? 0.0,
        longitude: site.longitude ?? 0.0,
      ),
      description: site.notes,
      siteInterest: site.siteInterest,
    );
  }
}

// ============================================================================
// API REQUEST MODELS - IMAGES
// ============================================================================

/// Add site image request (POST /sites/:id/images)
@freezed
abstract class AddSiteImageRequest with _$AddSiteImageRequest {
  const factory AddSiteImageRequest({
    required String siteId,
    required String imageData, // Base64 encoded image
    required int imageOrder,
    String? caption,
  }) = _AddSiteImageRequest;

  factory AddSiteImageRequest.fromJson(Map<String, dynamic> json) =>
      _$AddSiteImageRequestFromJson(json);
}

// ============================================================================
// API RESPONSE MODELS
// ============================================================================

/// Response for single site (GET /sites/:id)
@freezed
abstract class SiteResponse with _$SiteResponse {
  const SiteResponse._();

  const factory SiteResponse({
    required String id,
    required String name,
    required String location,
    String? ownerName,
    String? phoneNumber,
    String? email,
    String? panVatNumber,
    double? latitude,
    double? longitude,
    String? notes,
    String? dateJoined,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _SiteResponse;

  factory SiteResponse.fromJson(Map<String, dynamic> json) =>
      _$SiteResponseFromJson(json);

  /// Convert to Sites model
  Sites toSites() {
    return Sites(
      id: id,
      name: name,
      location: location,
      ownerName: ownerName,
      phoneNumber: phoneNumber,
      email: email,
      panVatNumber: panVatNumber,
      latitude: latitude,
      longitude: longitude,
      notes: notes,
      dateJoined: dateJoined,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Response for list of sites (GET /sites)
@freezed
abstract class SitesListResponse with _$SitesListResponse {
  const factory SitesListResponse({
    required List<Sites> sites,
    required int total,
    int? page,
    int? pageSize,
  }) = _SitesListResponse;

  factory SitesListResponse.fromJson(Map<String, dynamic> json) =>
      _$SitesListResponseFromJson(json);
}

/// Response for site images (GET /sites/:id/images)
@freezed
abstract class SiteImagesResponse with _$SiteImagesResponse {
  const factory SiteImagesResponse({
    required String siteId,
    required List<SiteImage> images,
    required int totalCount,
  }) = _SiteImagesResponse;

  factory SiteImagesResponse.fromJson(Map<String, dynamic> json) =>
      _$SiteImagesResponseFromJson(json);
}

/// Response for create site (POST /sites)
@freezed
abstract class CreateSiteResponse with _$CreateSiteResponse {
  const CreateSiteResponse._();

  const factory CreateSiteResponse({
    required bool success,
    required String message,
    required CreateSiteResponseData data,
  }) = _CreateSiteResponse;

  factory CreateSiteResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateSiteResponseFromJson(json);

  /// Convert to Sites model
  Sites toSites() {
    return Sites(
      id: data.id,
      name: data.siteName,
      location: data.location.address,
      ownerName: data.ownerName,
      phoneNumber: data.contact.phone,
      email: data.contact.email,
      latitude: data.location.latitude,
      longitude: data.location.longitude,
      notes: data.description,
      dateJoined: data.dateJoined,
      isActive: true,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }
}

/// Response for fetch all sites (GET /sites)
@freezed
abstract class FetchSitesResponse with _$FetchSitesResponse {
  const FetchSitesResponse._();

  const factory FetchSitesResponse({
    required bool success,
    required int count,
    required List<FetchSiteData> data,
  }) = _FetchSitesResponse;

  factory FetchSitesResponse.fromJson(Map<String, dynamic> json) =>
      _$FetchSitesResponseFromJson(json);

  /// Convert to list of Sites models
  List<Sites> toSitesList() {
    return data.map((siteData) => siteData.toSites()).toList();
  }
}

/// Individual site data in fetch all sites response
@freezed
abstract class FetchSiteData with _$FetchSiteData {
  const FetchSiteData._();

  const factory FetchSiteData({
    @JsonKey(name: '_id') required String id,
    required String siteName,
    required String ownerName,
    String? subOrganization,
    required String dateJoined,
    required CreateSiteContact contact,
    required CreateSiteLocation location,
    String? description,
    @Default([]) List<SiteInterest> siteInterest,
    required String organizationId,
    required SiteCreatedBy createdBy,
    @Default([]) List<SiteImageData> images,
    required DateTime createdAt,
    required DateTime updatedAt,
    @JsonKey(name: '__v') int? v,
  }) = _FetchSiteData;

  factory FetchSiteData.fromJson(Map<String, dynamic> json) =>
      _$FetchSiteDataFromJson(json);

  /// Convert to Sites model
  Sites toSites() {
    return Sites(
      id: id,
      name: siteName,
      location: location.address,
      ownerName: ownerName,
      phoneNumber: contact.phone,
      email: contact.email,
      latitude: location.latitude,
      longitude: location.longitude,
      notes: description,
      dateJoined: dateJoined,
      isActive: true,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// User who created the site
@freezed
abstract class SiteCreatedBy with _$SiteCreatedBy {
  const factory SiteCreatedBy({
    @JsonKey(name: '_id') required String userId,
    required String name,
    required String email,
    required String id,
  }) = _SiteCreatedBy;

  factory SiteCreatedBy.fromJson(Map<String, dynamic> json) =>
      _$SiteCreatedByFromJson(json);
}

/// Site image data in API response
@freezed
abstract class SiteImageData with _$SiteImageData {
  const factory SiteImageData({
    required int imageNumber,
    required String imageUrl,
    @JsonKey(name: '_id') required String id,
  }) = _SiteImageData;

  factory SiteImageData.fromJson(Map<String, dynamic> json) =>
      _$SiteImageDataFromJson(json);
}

/// Response for get site by ID (GET /sites/:id)
@freezed
abstract class GetSiteResponse with _$GetSiteResponse {
  const GetSiteResponse._();

  const factory GetSiteResponse({
    required bool success,
    required GetSiteData data,
  }) = _GetSiteResponse;

  factory GetSiteResponse.fromJson(Map<String, dynamic> json) =>
      _$GetSiteResponseFromJson(json);

  /// Convert to SiteDetails model
  SiteDetails toSiteDetails() {
    return SiteDetails(
      id: data.id,
      name: data.siteName,
      managerName: data.ownerName,
      phoneNumber: data.contact.phone,
      email: data.contact.email,
      fullAddress: data.location.address,
      latitude: data.location.latitude,
      longitude: data.location.longitude,
      notes: data.description,
      isActive: true,
      dateJoined: data.dateJoined,
      subOrganization: data.subOrganization,
      siteInterest: data.siteInterest,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }
}

/// Get site data
@freezed
abstract class GetSiteData with _$GetSiteData {
  const factory GetSiteData({
    @JsonKey(name: '_id') required String id,
    required String siteName,
    required String ownerName,
    String? subOrganization,
    required String dateJoined,
    required CreateSiteContact contact,
    required CreateSiteLocation location,
    String? description,
    @Default([]) List<SiteInterest> siteInterest,
    required String organizationId,
    required SiteCreatedBy createdBy,
    @Default([]) List<SiteImageData> images,
    required DateTime createdAt,
    required DateTime updatedAt,
    @JsonKey(name: '__v') int? v,
  }) = _GetSiteData;

  factory GetSiteData.fromJson(Map<String, dynamic> json) =>
      _$GetSiteDataFromJson(json);
}

/// Response for update site (PUT /sites/:id)
@freezed
abstract class UpdateSiteResponse with _$UpdateSiteResponse {
  const UpdateSiteResponse._();

  const factory UpdateSiteResponse({
    required bool success,
    required String message,
    required UpdateSiteResponseData data,
  }) = _UpdateSiteResponse;

  factory UpdateSiteResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateSiteResponseFromJson(json);

  /// Convert to SiteDetails model
  SiteDetails toSiteDetails() {
    return SiteDetails(
      id: data.id,
      name: data.siteName,
      managerName: data.ownerName,
      phoneNumber: data.contact.phone,
      email: data.contact.email,
      fullAddress: data.location.address,
      latitude: data.location.latitude,
      longitude: data.location.longitude,
      notes: data.description,
      isActive: true,
      dateJoined: data.dateJoined,
      subOrganization: data.subOrganization,
      siteInterest: data.siteInterest,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }
}

/// Update site response data
@freezed
abstract class UpdateSiteResponseData with _$UpdateSiteResponseData {
  const factory UpdateSiteResponseData({
    @JsonKey(name: '_id') required String id,
    required String siteName,
    required String ownerName,
    String? subOrganization,
    required String dateJoined,
    required CreateSiteContact contact,
    required CreateSiteLocation location,
    String? description,
    @Default([]) List<SiteInterest> siteInterest,
    required String organizationId,
    required SiteCreatedBy createdBy,
    @Default([]) List<SiteImageData> images,
    required DateTime createdAt,
    required DateTime updatedAt,
    @JsonKey(name: '__v') int? v,
  }) = _UpdateSiteResponseData;

  factory UpdateSiteResponseData.fromJson(Map<String, dynamic> json) =>
      _$UpdateSiteResponseDataFromJson(json);
}

/// Data field of create site response
@freezed
abstract class CreateSiteResponseData with _$CreateSiteResponseData {
  const factory CreateSiteResponseData({
    @JsonKey(name: '_id') required String id,
    required String siteName,
    required String ownerName,
    String? subOrganization,
    required String dateJoined,
    required CreateSiteContact contact,
    required CreateSiteLocation location,
    String? description,
    @Default([]) List<SiteInterest> siteInterest,
    required String organizationId,
    required String createdBy,
    @Default([]) List<String> assignedUsers,
    required String assignedBy,
    required DateTime assignedAt,
    @Default([]) List<SiteImageData> images,
    required DateTime createdAt,
    required DateTime updatedAt,
    @JsonKey(name: '__v') int? v,
  }) = _CreateSiteResponseData;

  factory CreateSiteResponseData.fromJson(Map<String, dynamic> json) =>
      _$CreateSiteResponseDataFromJson(json);
}

/// Response for upload site image (POST /sites/:id/images)
@freezed
abstract class UploadSiteImageResponse with _$UploadSiteImageResponse {
  const UploadSiteImageResponse._();

  const factory UploadSiteImageResponse({
    required bool success,
    required String message,
    required UploadSiteImageData data,
  }) = _UploadSiteImageResponse;

  factory UploadSiteImageResponse.fromJson(Map<String, dynamic> json) =>
      _$UploadSiteImageResponseFromJson(json);
}

/// Data field of upload site image response
@freezed
abstract class UploadSiteImageData with _$UploadSiteImageData {
  const factory UploadSiteImageData({
    required int imageNumber,
    required String imageUrl,
  }) = _UploadSiteImageData;

  factory UploadSiteImageData.fromJson(Map<String, dynamic> json) =>
      _$UploadSiteImageDataFromJson(json);
}

// ============================================================================
// API RESPONSE MODELS - SUB-ORGANIZATIONS & CATEGORIES
// ============================================================================

/// Response for get sub-organizations (GET /sites/sub-organizations)
@freezed
abstract class SubOrganizationsResponse with _$SubOrganizationsResponse {
  const SubOrganizationsResponse._();

  const factory SubOrganizationsResponse({
    required bool success,
    required int count,
    required List<SubOrganization> data,
  }) = _SubOrganizationsResponse;

  factory SubOrganizationsResponse.fromJson(Map<String, dynamic> json) =>
      _$SubOrganizationsResponseFromJson(json);
}

/// Response for get site categories (GET /sites/categories)
@freezed
abstract class SiteCategoriesResponse with _$SiteCategoriesResponse {
  const SiteCategoriesResponse._();

  const factory SiteCategoriesResponse({
    required bool success,
    required int count,
    required List<SiteCategory> data,
  }) = _SiteCategoriesResponse;

  factory SiteCategoriesResponse.fromJson(Map<String, dynamic> json) =>
      _$SiteCategoriesResponseFromJson(json);
}

// ============================================================================
// VALIDATION & UTILITIES
// ============================================================================

/// Validation extensions for CreateSiteRequest
extension SiteValidation on CreateSiteRequest {
  bool get isValid {
    return siteName.trim().isNotEmpty &&
        ownerName.trim().isNotEmpty &&
        contact.phone.trim().isNotEmpty &&
        location.address.trim().isNotEmpty;
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (siteName.trim().isEmpty) errors.add('Site name is required');
    if (ownerName.trim().isEmpty) errors.add('Owner name is required');
    if (contact.phone.trim().isEmpty) errors.add('Phone number is required');
    if (location.address.trim().isEmpty) errors.add('Address is required');
    return errors;
  }
}

/// Validation extensions for UpdateSiteRequest
extension UpdateSiteValidation on UpdateSiteRequest {
  bool get isValid {
    return siteName.trim().isNotEmpty &&
        ownerName.trim().isNotEmpty &&
        contact.phone.trim().isNotEmpty &&
        location.address.trim().isNotEmpty;
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (siteName.trim().isEmpty) errors.add('Site name is required');
    if (ownerName.trim().isEmpty) errors.add('Owner name is required');
    if (contact.phone.trim().isEmpty) errors.add('Phone number is required');
    if (location.address.trim().isEmpty) errors.add('Address is required');
    return errors;
  }
}