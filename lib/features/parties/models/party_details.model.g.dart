// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'party_details.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PartyDetails _$PartyDetailsFromJson(Map<String, dynamic> json) =>
    _PartyDetails(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerName: json['owner_name'] as String,
      panVatNumber: json['pan_vat_number'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String?,
      fullAddress: json['full_address'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$PartyDetailsToJson(_PartyDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'owner_name': instance.ownerName,
      'pan_vat_number': instance.panVatNumber,
      'phone_number': instance.phoneNumber,
      'email': instance.email,
      'full_address': instance.fullAddress,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'notes': instance.notes,
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
