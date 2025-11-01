// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prospects.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Prospects _$ProspectsFromJson(Map<String, dynamic> json) => _Prospects(
  id: json['id'] as String,
  name: json['name'] as String,
  location: json['location'] as String,
  ownerName: json['ownerName'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  email: json['email'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ProspectsToJson(_Prospects instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'location': instance.location,
      'ownerName': instance.ownerName,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
