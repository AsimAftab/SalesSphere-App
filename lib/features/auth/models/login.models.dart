import 'package:freezed_annotation/freezed_annotation.dart';

part 'login.models.freezed.dart';
part 'login.models.g.dart';

// ========================================
// LOGIN REQUEST MODEL
// ========================================
@freezed
abstract class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

// ========================================
// LOGIN RESPONSE MODEL
// ========================================
@freezed
abstract class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required String status,
    required String token,
    required LoginData data,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}

// ========================================
// LOGIN DATA MODEL (Contains User)
// ========================================
@freezed
abstract class LoginData with _$LoginData {
  const factory LoginData({
    required User user,
  }) = _LoginData;

  factory LoginData.fromJson(Map<String, dynamic> json) =>
      _$LoginDataFromJson(json);
}

// ========================================
// USER MODEL
// ========================================
@freezed
abstract class User with _$User {
  const factory User({
    @JsonKey(name: '_id') required String id,
    required String name,
    required String email,
    required String role,
    required String organizationId,
    required bool isActive,
    required String phone,
    required String address,
    required String gender,
    required String dateOfBirth,
    required int age,
    required String panNumber,
    required String citizenshipNumber,
    required String dateJoined,
    required List<Document> documents,
    required String createdAt,
    required String updatedAt,
    @JsonKey(name: '__v') required int version,
    String? avatarUrl,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

// ========================================
// DOCUMENT MODEL
// ========================================
@freezed
abstract class Document with _$Document {
  const factory Document({
    @JsonKey(name: '_id') required String id,
    required String fileName,
    required String fileUrl,
    required String uploadedAt,
  }) = _Document;

  factory Document.fromJson(Map<String, dynamic> json) =>
      _$DocumentFromJson(json);
}