import 'package:freezed_annotation/freezed_annotation.dart';

part 'party_details.model.freezed.dart';
part 'party_details.model.g.dart';

@freezed
abstract class PartyDetails with _$PartyDetails {
  const factory PartyDetails({
    required String id,
    required String name,

    @JsonKey(name: 'owner_name') required String ownerName,
    @JsonKey(name: 'pan_vat_number') required String panVatNumber,
    @JsonKey(name: 'phone_number') required String phoneNumber,
    String? email,
    @JsonKey(name: 'full_address') required String fullAddress,
    double? latitude,
    double? longitude,
    String? notes,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _PartyDetails;

  factory PartyDetails.fromJson(Map<String, dynamic> json) =>
      _$PartyDetailsFromJson(json);
}