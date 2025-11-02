// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forgot_password.models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ForgotPasswordRequest _$ForgotPasswordRequestFromJson(
  Map<String, dynamic> json,
) => _ForgotPasswordRequest(email: json['email'] as String);

Map<String, dynamic> _$ForgotPasswordRequestToJson(
  _ForgotPasswordRequest instance,
) => <String, dynamic>{'email': instance.email};

_ForgotPasswordResponse _$ForgotPasswordResponseFromJson(
  Map<String, dynamic> json,
) => _ForgotPasswordResponse(
  status: json['status'] as String,
  message: json['message'] as String,
);

Map<String, dynamic> _$ForgotPasswordResponseToJson(
  _ForgotPasswordResponse instance,
) => <String, dynamic>{'status': instance.status, 'message': instance.message};
