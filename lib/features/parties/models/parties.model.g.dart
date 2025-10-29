// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parties.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PartyListItem _$PartyListItemFromJson(Map<String, dynamic> json) =>
    _PartyListItem(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerName: json['ownerName'] as String,
      fullAddress: json['full_address'] as String,
      phoneNumber: json['phone_number'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$PartyListItemToJson(_PartyListItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'ownerName': instance.ownerName,
      'full_address': instance.fullAddress,
      'phone_number': instance.phoneNumber,
      'is_active': instance.isActive,
    };
