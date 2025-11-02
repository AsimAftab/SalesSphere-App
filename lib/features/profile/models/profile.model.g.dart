// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: json['_id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  role: json['role'] as String,
  organizationId: json['organizationId'] as String,
  isActive: json['isActive'] as bool? ?? true,
  phone: json['phone'] as String,
  address: json['address'] as String,
  gender: json['gender'] as String,
  dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
  age: (json['age'] as num).toInt(),
  panNumber: json['panNumber'] as String,
  citizenshipNumber: json['citizenshipNumber'] as String,
  dateJoined: DateTime.parse(json['dateJoined'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  avatarUrl: json['avatarUrl'] as String?,
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'role': instance.role,
  'organizationId': instance.organizationId,
  'isActive': instance.isActive,
  'phone': instance.phone,
  'address': instance.address,
  'gender': instance.gender,
  'dateOfBirth': instance.dateOfBirth.toIso8601String(),
  'age': instance.age,
  'panNumber': instance.panNumber,
  'citizenshipNumber': instance.citizenshipNumber,
  'dateJoined': instance.dateJoined.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'avatarUrl': instance.avatarUrl,
};

_ProfileApiResponse _$ProfileApiResponseFromJson(Map<String, dynamic> json) =>
    _ProfileApiResponse(
      success: json['success'] as bool,
      data: Profile.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProfileApiResponseToJson(_ProfileApiResponse instance) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

_UploadProfileImageData _$UploadProfileImageDataFromJson(
  Map<String, dynamic> json,
) => _UploadProfileImageData(avatarUrl: json['avatarUrl'] as String);

Map<String, dynamic> _$UploadProfileImageDataToJson(
  _UploadProfileImageData instance,
) => <String, dynamic>{'avatarUrl': instance.avatarUrl};

_UploadProfileImageResponse _$UploadProfileImageResponseFromJson(
  Map<String, dynamic> json,
) => _UploadProfileImageResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: UploadProfileImageData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UploadProfileImageResponseToJson(
  _UploadProfileImageResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
