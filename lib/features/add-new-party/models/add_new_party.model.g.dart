// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_new_party.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AddPartyRequest _$AddPartyRequestFromJson(Map<String, dynamic> json) =>
    _AddPartyRequest(
      companyName: json['companyName'] as String,
      ownerName: json['ownerName'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      email: json['email'] as String,
      panVatNumber: json['panVatNumber'] as String,
      googleMapLink: json['googleMapLink'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$AddPartyRequestToJson(_AddPartyRequest instance) =>
    <String, dynamic>{
      'companyName': instance.companyName,
      'ownerName': instance.ownerName,
      'phone': instance.phone,
      'address': instance.address,
      'email': instance.email,
      'panVatNumber': instance.panVatNumber,
      'googleMapLink': instance.googleMapLink,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

_AddPartyResponse _$AddPartyResponseFromJson(Map<String, dynamic> json) =>
    _AddPartyResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      data: Party.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AddPartyResponseToJson(_AddPartyResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'data': instance.data,
    };

_Party _$PartyFromJson(Map<String, dynamic> json) => _Party(
  id: json['_id'] as String,
  companyName: json['companyName'] as String,
  ownerName: json['ownerName'] as String,
  phone: json['phone'] as String,
  address: json['address'] as String,
  email: json['email'] as String,
  panVatNumber: json['panVatNumber'] as String,
  googleMapLink: json['googleMapLink'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  organizationId: json['organizationId'] as String,
  isActive: json['isActive'] as bool,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
  version: (json['__v'] as num).toInt(),
);

Map<String, dynamic> _$PartyToJson(_Party instance) => <String, dynamic>{
  '_id': instance.id,
  'companyName': instance.companyName,
  'ownerName': instance.ownerName,
  'phone': instance.phone,
  'address': instance.address,
  'email': instance.email,
  'panVatNumber': instance.panVatNumber,
  'googleMapLink': instance.googleMapLink,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'organizationId': instance.organizationId,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  '__v': instance.version,
};
