// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_prospect.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateProspectRequest _$CreateProspectRequestFromJson(
  Map<String, dynamic> json,
) => _CreateProspectRequest(
  name: json['name'] as String,
  ownerName: json['ownerName'] as String,
  dateJoined: json['dateJoined'] as String,
  panVatNumber: json['panVatNumber'] as String?,
  contact: CreateProspectContact.fromJson(
    json['contact'] as Map<String, dynamic>,
  ),
  location: CreateProspectLocation.fromJson(
    json['location'] as Map<String, dynamic>,
  ),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$CreateProspectRequestToJson(
  _CreateProspectRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'ownerName': instance.ownerName,
  'dateJoined': instance.dateJoined,
  'panVatNumber': instance.panVatNumber,
  'contact': instance.contact,
  'location': instance.location,
  'notes': instance.notes,
};

_CreateProspectContact _$CreateProspectContactFromJson(
  Map<String, dynamic> json,
) => _CreateProspectContact(
  phone: json['phone'] as String,
  email: json['email'] as String?,
);

Map<String, dynamic> _$CreateProspectContactToJson(
  _CreateProspectContact instance,
) => <String, dynamic>{'phone': instance.phone, 'email': instance.email};

_CreateProspectLocation _$CreateProspectLocationFromJson(
  Map<String, dynamic> json,
) => _CreateProspectLocation(
  address: json['address'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
);

Map<String, dynamic> _$CreateProspectLocationToJson(
  _CreateProspectLocation instance,
) => <String, dynamic>{
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};
