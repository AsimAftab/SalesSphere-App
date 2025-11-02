// lib/features/prospects/models/edit_prospect_details.model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sales_sphere/features/prospects/models/prospects.model.dart';

part 'edit_prospect_details.model.freezed.dart';
part 'edit_prospect_details.model.g.dart';

// ============================================================================
// Prospect Details Model (Enhanced for Edit Screen)
// ============================================================================

/// Full prospect details model for edit/view screen
@freezed
abstract class ProspectDetails with _$ProspectDetails {
  const ProspectDetails._();

  const factory ProspectDetails({
    required String id,
    required String name,
    required String ownerName,
    String? panVatNumber, // ✅ Optional
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
  }) = _ProspectDetails;

  factory ProspectDetails.fromJson(Map<String, dynamic> json) =>
      _$ProspectDetailsFromJson(json);

  // Helper method to convert from Prospects model
  factory ProspectDetails.fromProspects(Prospects prospect) {
    return ProspectDetails(
      id: prospect.id,
      name: prospect.name,
      ownerName: prospect.ownerName ?? '',
      panVatNumber: prospect.panVatNumber,
      phoneNumber: prospect.phoneNumber ?? '',
      email: prospect.email,
      fullAddress: prospect.location,
      latitude: prospect.latitude,
      longitude: prospect.longitude,
      notes: prospect.notes,
      dateJoined: prospect.dateJoined,
      isActive: prospect.isActive,
      createdAt: prospect.createdAt,
      updatedAt: null,
    );
  }

  // Helper method to convert back to Prospects model
  Prospects toProspects() {
    return Prospects(
      id: id,
      name: name,
      location: fullAddress,
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
    );
  }
}

// ============================================================================
// Update Request Model (For Future API)
// ============================================================================

/// Update prospect request model (for future API)
@freezed
abstract class UpdateProspectDetailsRequest with _$UpdateProspectDetailsRequest {
  const factory UpdateProspectDetailsRequest({
    required String name,
    required String ownerName,
    String? panVatNumber, // ✅ Optional
    required UpdateProspectDetailsContact contact,
    required UpdateProspectDetailsLocation location,
    String? notes,
  }) = _UpdateProspectDetailsRequest;

  factory UpdateProspectDetailsRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProspectDetailsRequestFromJson(json);

  // Helper to create from ProspectDetails
  factory UpdateProspectDetailsRequest.fromProspectDetails(ProspectDetails prospect) {
    return UpdateProspectDetailsRequest(
      name: prospect.name,
      ownerName: prospect.ownerName,
      panVatNumber: prospect.panVatNumber,
      contact: UpdateProspectDetailsContact(
        phone: prospect.phoneNumber,
        email: prospect.email,
      ),
      location: UpdateProspectDetailsLocation(
        address: prospect.fullAddress,
        latitude: prospect.latitude,
        longitude: prospect.longitude,
      ),
      notes: prospect.notes,
    );
  }
}

/// Contact info for update request
@freezed
abstract class UpdateProspectDetailsContact with _$UpdateProspectDetailsContact {
  const factory UpdateProspectDetailsContact({
    required String phone,
    String? email,
  }) = _UpdateProspectDetailsContact;

  factory UpdateProspectDetailsContact.fromJson(Map<String, dynamic> json) =>
      _$UpdateProspectDetailsContactFromJson(json);
}

/// Location info for update request
@freezed
abstract class UpdateProspectDetailsLocation with _$UpdateProspectDetailsLocation {
  const factory UpdateProspectDetailsLocation({
    required String address,
    double? latitude,
    double? longitude,
  }) = _UpdateProspectDetailsLocation;

  factory UpdateProspectDetailsLocation.fromJson(Map<String, dynamic> json) =>
      _$UpdateProspectDetailsLocationFromJson(json);
}