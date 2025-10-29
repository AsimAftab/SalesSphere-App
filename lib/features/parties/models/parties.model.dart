import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sales_sphere/features/parties/models/edit_party_details.model.dart';

part 'parties.model.freezed.dart';
part 'parties.model.g.dart';

@freezed
abstract class PartyListItem with _$PartyListItem {
  const factory PartyListItem({
    required String id,
    required String name,
    required String ownerName,
    @JsonKey(name: 'full_address') required String fullAddress,
    @JsonKey(name: 'phone_number') required String phoneNumber,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _PartyListItem;

  factory PartyListItem.fromJson(Map<String, dynamic> json) =>
      _$PartyListItemFromJson(json);

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