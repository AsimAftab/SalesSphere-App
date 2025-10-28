// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login.models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) =>
    _LoginRequest(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestToJson(_LoginRequest instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

_LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    _LoginResponse(
      status: json['status'] as String,
      token: json['token'] as String,
      data: LoginData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResponseToJson(_LoginResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'token': instance.token,
      'data': instance.data,
    };

_LoginData _$LoginDataFromJson(Map<String, dynamic> json) =>
    _LoginData(user: User.fromJson(json['user'] as Map<String, dynamic>));

Map<String, dynamic> _$LoginDataToJson(_LoginData instance) =>
    <String, dynamic>{'user': instance.user};

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['_id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  role: json['role'] as String,
  organizationId: json['organizationId'] as String,
  isActive: json['isActive'] as bool,
  phone: json['phone'] as String,
  address: json['address'] as String,
  gender: json['gender'] as String,
  dateOfBirth: json['dateOfBirth'] as String,
  age: (json['age'] as num).toInt(),
  panNumber: json['panNumber'] as String,
  citizenshipNumber: json['citizenshipNumber'] as String,
  dateJoined: json['dateJoined'] as String,
  documents: (json['documents'] as List<dynamic>)
      .map((e) => Document.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
  version: (json['__v'] as num).toInt(),
  avatarUrl: json['avatarUrl'] as String?,
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'role': instance.role,
  'organizationId': instance.organizationId,
  'isActive': instance.isActive,
  'phone': instance.phone,
  'address': instance.address,
  'gender': instance.gender,
  'dateOfBirth': instance.dateOfBirth,
  'age': instance.age,
  'panNumber': instance.panNumber,
  'citizenshipNumber': instance.citizenshipNumber,
  'dateJoined': instance.dateJoined,
  'documents': instance.documents,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  '__v': instance.version,
  'avatarUrl': instance.avatarUrl,
};

_Document _$DocumentFromJson(Map<String, dynamic> json) => _Document(
  id: json['_id'] as String,
  fileName: json['fileName'] as String,
  fileUrl: json['fileUrl'] as String,
  uploadedAt: json['uploadedAt'] as String,
);

Map<String, dynamic> _$DocumentToJson(_Document instance) => <String, dynamic>{
  '_id': instance.id,
  'fileName': instance.fileName,
  'fileUrl': instance.fileUrl,
  'uploadedAt': instance.uploadedAt,
};
