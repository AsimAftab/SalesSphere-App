import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sales_sphere/features/prospects/models/prospects.model.dart';

part 'add_prospect.model.freezed.dart';
part 'add_prospect.model.g.dart';

// ============================================================================
// Create Prospect Request Models
// ============================================================================

/// Create prospect request model
@freezed
abstract class CreateProspectRequest with _$CreateProspectRequest {
  const factory CreateProspectRequest({
    required String name,
    required String ownerName,
    required String dateJoined,
    String? panVatNumber,
    required CreateProspectContact contact,
    required CreateProspectLocation location,
    String? notes,
  }) = _CreateProspectRequest;

  factory CreateProspectRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateProspectRequestFromJson(json);
}

/// Contact info for create prospect
@freezed
abstract class CreateProspectContact with _$CreateProspectContact {
  const factory CreateProspectContact({
    required String phone,
    String? email,
  }) = _CreateProspectContact;

  factory CreateProspectContact.fromJson(Map<String, dynamic> json) =>
      _$CreateProspectContactFromJson(json);
}

/// Location info for create prospect
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

// ============================================================================
// Helper Extension
// ============================================================================

extension CreateProspectRequestExtension on CreateProspectRequest {
  /// Convert to Prospects model for adding to local list
  Prospects toProspects(String id) {
    return Prospects(
      id: id,
      name: name,
      location: location.address,
      ownerName: ownerName,
      phoneNumber: contact.phone,
      email: contact.email,
      panVatNumber: panVatNumber,
      latitude: location.latitude,
      longitude: location.longitude,
      notes: notes,
      dateJoined: dateJoined,
      isActive: true,
      createdAt: DateTime.now(),
    );
  }
}