import 'package:freezed_annotation/freezed_annotation.dart';

part 'forgot_password.models.freezed.dart';
part 'forgot_password.models.g.dart';

// ========================================
// FORGOT PASSWORD REQUEST MODEL
// ========================================
@freezed
abstract class ForgotPasswordRequest with _$ForgotPasswordRequest {
  const factory ForgotPasswordRequest({required String email}) =
      _ForgotPasswordRequest;

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordRequestFromJson(json);
}

// ========================================
// FORGOT PASSWORD RESPONSE MODEL
// ========================================
@freezed
abstract class ForgotPasswordResponse with _$ForgotPasswordResponse {
  const factory ForgotPasswordResponse({
    required String status,
    required String message,
  }) = _ForgotPasswordResponse;

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordResponseFromJson(json);
}
