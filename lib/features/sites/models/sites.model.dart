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
      isActive: site.isActive,
      createdAt: site.createdAt,
      updatedAt: site.updatedAt,
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
// API REQUEST MODELS - CREATE
// ============================================================================

/// Create site request (POST /sites)
@freezed
abstract class CreateSiteRequest with _$CreateSiteRequest {
  const CreateSiteRequest._();

  const factory CreateSiteRequest({
    required String name,
    required String managerName,
    required String phoneNumber,
    String? email,
    required String dateJoined,
    required CreateSiteLocation location,
    String? notes,
  }) = _CreateSiteRequest;

  factory CreateSiteRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSiteRequestFromJson(json);

  /// Convert to Sites model for local storage
  Sites toSites(String id) {
    return Sites(
      id: id,
      name: name,
      location: location.address,
      ownerName: managerName,
      phoneNumber: phoneNumber,
      email: email,
      panVatNumber: null,
      latitude: location.latitude,
      longitude: location.longitude,
      notes: notes,
      dateJoined: dateJoined,
      isActive: true,
      createdAt: DateTime.now(),
    );
  }
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
    required String name,
    required String managerName,
    required UpdateSiteContact contact,
    required UpdateSiteLocation location,
    String? notes,
    bool? isActive,
  }) = _UpdateSiteRequest;

  factory UpdateSiteRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateSiteRequestFromJson(json);

  /// Create from SiteDetails
  factory UpdateSiteRequest.fromSiteDetails(SiteDetails site) {
    return UpdateSiteRequest(
      name: site.name,
      managerName: site.managerName,
      contact: UpdateSiteContact(
        phone: site.phoneNumber,
        email: site.email,
      ),
      location: UpdateSiteLocation(
        address: site.fullAddress,
        latitude: site.latitude,
        longitude: site.longitude,
      ),
      notes: site.notes,
      isActive: site.isActive,
    );
  }
}

/// Contact info for update request
@freezed
abstract class UpdateSiteContact with _$UpdateSiteContact {
  const factory UpdateSiteContact({
    required String phone,
    String? email,
  }) = _UpdateSiteContact;

  factory UpdateSiteContact.fromJson(Map<String, dynamic> json) =>
      _$UpdateSiteContactFromJson(json);
}

/// Location info for update request
@freezed
abstract class UpdateSiteLocation with _$UpdateSiteLocation {
  const factory UpdateSiteLocation({
    required String address,
    double? latitude,
    double? longitude,
  }) = _UpdateSiteLocation;

  factory UpdateSiteLocation.fromJson(Map<String, dynamic> json) =>
      _$UpdateSiteLocationFromJson(json);
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

// ============================================================================
// VALIDATION & UTILITIES
// ============================================================================

/// Validation extensions for CreateSiteRequest
extension SiteValidation on CreateSiteRequest {
  bool get isValid {
    return name.trim().isNotEmpty &&
        managerName.trim().isNotEmpty &&
        phoneNumber.trim().isNotEmpty &&
        location.address.trim().isNotEmpty;
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (name.trim().isEmpty) errors.add('Site name is required');
    if (managerName.trim().isEmpty) errors.add('Manager name is required');
    if (phoneNumber.trim().isEmpty) errors.add('Phone number is required');
    if (location.address.trim().isEmpty) errors.add('Address is required');
    return errors;
  }
}

/// Validation extensions for UpdateSiteRequest
extension UpdateSiteValidation on UpdateSiteRequest {
  bool get isValid {
    return name.trim().isNotEmpty &&
        managerName.trim().isNotEmpty &&
        contact.phone.trim().isNotEmpty &&
        location.address.trim().isNotEmpty;
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (name.trim().isEmpty) errors.add('Site name is required');
    if (managerName.trim().isEmpty) errors.add('Manager name is required');
    if (contact.phone.trim().isEmpty) errors.add('Phone number is required');
    if (location.address.trim().isEmpty) errors.add('Address is required');
    return errors;
  }
}