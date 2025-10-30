import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_new_party.model.freezed.dart';
part 'add_new_party.model.g.dart';

// ========================================
// ADD PARTY REQUEST MODEL
// ========================================
@freezed
abstract class AddPartyRequest with _$AddPartyRequest {
  const factory AddPartyRequest({
    required String companyName,
    required String ownerName,
    required String phone,
    required String address,
    required String email,
    required String panVatNumber,
    String? googleMapLink,
    double? latitude,
    double? longitude,
  }) = _AddPartyRequest;

  factory AddPartyRequest.fromJson(Map<String, dynamic> json) =>
      _$AddPartyRequestFromJson(json);
}

// ========================================
// ADD PARTY RESPONSE MODEL
// ========================================
@freezed
abstract class AddPartyResponse with _$AddPartyResponse {
  const factory AddPartyResponse({
    required String status,
    required String message,
    required Party data,
  }) = _AddPartyResponse;

  factory AddPartyResponse.fromJson(Map<String, dynamic> json) =>
      _$AddPartyResponseFromJson(json);
}

// ========================================
// PARTY MODEL
// ========================================
@freezed
abstract class Party with _$Party {
  const factory Party({
    @JsonKey(name: '_id') required String id,
    required String companyName,
    required String ownerName,
    required String phone,
    required String address,
    required String email,
    required String panVatNumber,
    String? googleMapLink,
    double? latitude,
    double? longitude,
    required String organizationId, // Assumed, based on User model
    required bool isActive,
    required String createdAt,
    required String updatedAt,
    @JsonKey(name: '__v') required int version,
  }) = _Party;

  factory Party.fromJson(Map<String, dynamic> json) => _$PartyFromJson(json);
}