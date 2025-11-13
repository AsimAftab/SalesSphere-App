import 'package:freezed_annotation/freezed_annotation.dart';

part 'change_password.models.freezed.dart';
part 'change_password.models.g.dart';

// ========================================
// CHANGE PASSWORD REQUEST MODEL
// ========================================
@freezed
abstract class ChangePasswordRequest with _$ChangePasswordRequest {
  const factory ChangePasswordRequest({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) = _ChangePasswordRequest;

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordRequestFromJson(json);
}

// ========================================
// CHANGE PASSWORD RESPONSE MODEL
// ========================================
@freezed
abstract class ChangePasswordResponse with _$ChangePasswordResponse {
  const factory ChangePasswordResponse({
    required bool success,
    required String message,
  }) = _ChangePasswordResponse;

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordResponseFromJson(json);
}
