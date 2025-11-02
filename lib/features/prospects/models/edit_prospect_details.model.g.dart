// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_prospect_details.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProspectDetails _$ProspectDetailsFromJson(Map<String, dynamic> json) =>
    _ProspectDetails(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerName: json['ownerName'] as String,
      panVatNumber: json['panVatNumber'] as String?,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String?,
      fullAddress: json['fullAddress'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      dateJoined: json['dateJoined'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ProspectDetailsToJson(_ProspectDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'ownerName': instance.ownerName,
      'panVatNumber': instance.panVatNumber,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'fullAddress': instance.fullAddress,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'notes': instance.notes,
      'isActive': instance.isActive,
      'dateJoined': instance.dateJoined,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_UpdateProspectDetailsRequest _$UpdateProspectDetailsRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateProspectDetailsRequest(
  name: json['name'] as String,
  ownerName: json['ownerName'] as String,
  panVatNumber: json['panVatNumber'] as String?,
  contact: UpdateProspectDetailsContact.fromJson(
    json['contact'] as Map<String, dynamic>,
  ),
  location: UpdateProspectDetailsLocation.fromJson(
    json['location'] as Map<String, dynamic>,
  ),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$UpdateProspectDetailsRequestToJson(
  _UpdateProspectDetailsRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'ownerName': instance.ownerName,
  'panVatNumber': instance.panVatNumber,
  'contact': instance.contact,
  'location': instance.location,
  'notes': instance.notes,
};

_UpdateProspectDetailsContact _$UpdateProspectDetailsContactFromJson(
  Map<String, dynamic> json,
) => _UpdateProspectDetailsContact(
  phone: json['phone'] as String,
  email: json['email'] as String?,
);

Map<String, dynamic> _$UpdateProspectDetailsContactToJson(
  _UpdateProspectDetailsContact instance,
) => <String, dynamic>{'phone': instance.phone, 'email': instance.email};

_UpdateProspectDetailsLocation _$UpdateProspectDetailsLocationFromJson(
  Map<String, dynamic> json,
) => _UpdateProspectDetailsLocation(
  address: json['address'] as String,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$UpdateProspectDetailsLocationToJson(
  _UpdateProspectDetailsLocation instance,
) => <String, dynamic>{
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};
