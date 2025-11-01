// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parties.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PartiesApiResponse _$PartiesApiResponseFromJson(Map<String, dynamic> json) =>
    _PartiesApiResponse(
      success: json['success'] as bool,
      count: (json['count'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) => PartyApiData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PartiesApiResponseToJson(_PartiesApiResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'count': instance.count,
      'data': instance.data,
    };

_PartyApiData _$PartyApiDataFromJson(Map<String, dynamic> json) =>
    _PartyApiData(
      id: json['_id'] as String,
      partyName: json['partyName'] as String,
      ownerName: json['ownerName'] as String,
      location: PartyLocation.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$PartyApiDataToJson(_PartyApiData instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'partyName': instance.partyName,
      'ownerName': instance.ownerName,
      'location': instance.location,
    };

_PartyDetailApiResponse _$PartyDetailApiResponseFromJson(
  Map<String, dynamic> json,
) => _PartyDetailApiResponse(
  success: json['success'] as bool,
  data: PartyDetailApiData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PartyDetailApiResponseToJson(
  _PartyDetailApiResponse instance,
) => <String, dynamic>{'success': instance.success, 'data': instance.data};

_PartyDetailApiData _$PartyDetailApiDataFromJson(Map<String, dynamic> json) =>
    _PartyDetailApiData(
      id: json['_id'] as String,
      partyName: json['partyName'] as String,
      ownerName: json['ownerName'] as String,
      dateJoined: json['dateJoined'] as String?,
      panVatNumber: json['panVatNumber'] as String,
      contact: PartyContact.fromJson(json['contact'] as Map<String, dynamic>),
      location: PartyLocationDetail.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      description: json['description'] as String?,
      organizationId: json['organizationId'] as String?,
      createdBy: json['createdBy'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$PartyDetailApiDataToJson(_PartyDetailApiData instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'partyName': instance.partyName,
      'ownerName': instance.ownerName,
      'dateJoined': instance.dateJoined,
      'panVatNumber': instance.panVatNumber,
      'contact': instance.contact,
      'location': instance.location,
      'description': instance.description,
      'organizationId': instance.organizationId,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

_PartyContact _$PartyContactFromJson(Map<String, dynamic> json) =>
    _PartyContact(
      phone: json['phone'] as String,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$PartyContactToJson(_PartyContact instance) =>
    <String, dynamic>{'phone': instance.phone, 'email': instance.email};

_PartyLocation _$PartyLocationFromJson(Map<String, dynamic> json) =>
    _PartyLocation(address: json['address'] as String);

Map<String, dynamic> _$PartyLocationToJson(_PartyLocation instance) =>
    <String, dynamic>{'address': instance.address};

_PartyLocationDetail _$PartyLocationDetailFromJson(Map<String, dynamic> json) =>
    _PartyLocationDetail(
      address: json['address'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PartyLocationDetailToJson(
  _PartyLocationDetail instance,
) => <String, dynamic>{
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};

_UpdatePartyRequest _$UpdatePartyRequestFromJson(Map<String, dynamic> json) =>
    _UpdatePartyRequest(
      partyName: json['partyName'] as String,
      ownerName: json['ownerName'] as String,
      panVatNumber: json['panVatNumber'] as String,
      contact: UpdatePartyContact.fromJson(
        json['contact'] as Map<String, dynamic>,
      ),
      location: UpdatePartyLocation.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$UpdatePartyRequestToJson(_UpdatePartyRequest instance) =>
    <String, dynamic>{
      'partyName': instance.partyName,
      'ownerName': instance.ownerName,
      'panVatNumber': instance.panVatNumber,
      'contact': instance.contact,
      'location': instance.location,
      'description': instance.description,
    };

_UpdatePartyContact _$UpdatePartyContactFromJson(Map<String, dynamic> json) =>
    _UpdatePartyContact(
      phone: json['phone'] as String,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$UpdatePartyContactToJson(_UpdatePartyContact instance) =>
    <String, dynamic>{'phone': instance.phone, 'email': instance.email};

_UpdatePartyLocation _$UpdatePartyLocationFromJson(Map<String, dynamic> json) =>
    _UpdatePartyLocation(
      address: json['address'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$UpdatePartyLocationToJson(
  _UpdatePartyLocation instance,
) => <String, dynamic>{
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};

_CreatePartyRequest _$CreatePartyRequestFromJson(Map<String, dynamic> json) =>
    _CreatePartyRequest(
      partyName: json['partyName'] as String,
      ownerName: json['ownerName'] as String,
      dateJoined: json['dateJoined'] as String,
      panVatNumber: json['panVatNumber'] as String,
      contact: CreatePartyContact.fromJson(
        json['contact'] as Map<String, dynamic>,
      ),
      location: CreatePartyLocation.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$CreatePartyRequestToJson(_CreatePartyRequest instance) =>
    <String, dynamic>{
      'partyName': instance.partyName,
      'ownerName': instance.ownerName,
      'dateJoined': instance.dateJoined,
      'panVatNumber': instance.panVatNumber,
      'contact': instance.contact,
      'location': instance.location,
      'description': instance.description,
    };

_CreatePartyContact _$CreatePartyContactFromJson(Map<String, dynamic> json) =>
    _CreatePartyContact(
      phone: json['phone'] as String,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$CreatePartyContactToJson(_CreatePartyContact instance) =>
    <String, dynamic>{'phone': instance.phone, 'email': instance.email};

_CreatePartyLocation _$CreatePartyLocationFromJson(Map<String, dynamic> json) =>
    _CreatePartyLocation(
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$CreatePartyLocationToJson(
  _CreatePartyLocation instance,
) => <String, dynamic>{
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};

_CreatePartyApiResponse _$CreatePartyApiResponseFromJson(
  Map<String, dynamic> json,
) => _CreatePartyApiResponse(
  success: json['success'] as bool,
  data: PartyDetailApiData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CreatePartyApiResponseToJson(
  _CreatePartyApiResponse instance,
) => <String, dynamic>{'success': instance.success, 'data': instance.data};

_PartyListItem _$PartyListItemFromJson(Map<String, dynamic> json) =>
    _PartyListItem(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerName: json['ownerName'] as String,
      fullAddress: json['full_address'] as String,
      phoneNumber: json['phone_number'] as String?,
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

_PartyDetails _$PartyDetailsFromJson(Map<String, dynamic> json) =>
    _PartyDetails(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerName: json['ownerName'] as String,
      panVatNumber: json['panVatNumber'] as String,
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

Map<String, dynamic> _$PartyDetailsToJson(_PartyDetails instance) =>
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
