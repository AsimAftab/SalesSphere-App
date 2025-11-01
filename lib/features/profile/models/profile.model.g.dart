// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: json['_id'] as String,
  fullName: json['fullName'] as String,
  email: json['email'] as String,
  phoneNumber: json['phoneNumber'] as String,
  address: json['address'] as String,
  gender: json['gender'] as String?,
  citizenship: json['citizenship'] as String?,
  panNumber: json['panNumber'] as String?,
  dateOfBirth: json['dateOfBirth'] == null
      ? null
      : DateTime.parse(json['dateOfBirth'] as String),
  dateJoined: json['dateJoined'] == null
      ? null
      : DateTime.parse(json['dateJoined'] as String),
  city: json['city'] as String?,
  country: json['country'] as String?,
  profileImageUrl: json['profileImageUrl'] as String?,
  role: json['role'] as String?,
  employeeId: json['employeeId'] as String?,
  totalVisits: (json['totalVisits'] as num?)?.toInt() ?? 0,
  totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
  attendancePercentage:
      (json['attendancePercentage'] as num?)?.toDouble() ?? 0.0,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  '_id': instance.id,
  'fullName': instance.fullName,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'address': instance.address,
  'gender': instance.gender,
  'citizenship': instance.citizenship,
  'panNumber': instance.panNumber,
  'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
  'dateJoined': instance.dateJoined?.toIso8601String(),
  'city': instance.city,
  'country': instance.country,
  'profileImageUrl': instance.profileImageUrl,
  'role': instance.role,
  'employeeId': instance.employeeId,
  'totalVisits': instance.totalVisits,
  'totalOrders': instance.totalOrders,
  'attendancePercentage': instance.attendancePercentage,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

_UpdateProfileRequest _$UpdateProfileRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateProfileRequest(
  fullName: json['fullName'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  address: json['address'] as String?,
  gender: json['gender'] as String?,
  citizenship: json['citizenship'] as String?,
  panNumber: json['panNumber'] as String?,
  dateOfBirth: json['dateOfBirth'] == null
      ? null
      : DateTime.parse(json['dateOfBirth'] as String),
  dateJoined: json['dateJoined'] == null
      ? null
      : DateTime.parse(json['dateJoined'] as String),
  city: json['city'] as String?,
  country: json['country'] as String?,
  profileImageUrl: json['profileImageUrl'] as String?,
);

Map<String, dynamic> _$UpdateProfileRequestToJson(
  _UpdateProfileRequest instance,
) => <String, dynamic>{
  'fullName': instance.fullName,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'address': instance.address,
  'gender': instance.gender,
  'citizenship': instance.citizenship,
  'panNumber': instance.panNumber,
  'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
  'dateJoined': instance.dateJoined?.toIso8601String(),
  'city': instance.city,
  'country': instance.country,
  'profileImageUrl': instance.profileImageUrl,
};

_ProfileResponse _$ProfileResponseFromJson(Map<String, dynamic> json) =>
    _ProfileResponse(
      status: json['status'] as String,
      data: Profile.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProfileResponseToJson(_ProfileResponse instance) =>
    <String, dynamic>{'status': instance.status, 'data': instance.data};
