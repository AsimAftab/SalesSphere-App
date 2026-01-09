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
// CHECK STATUS RESPONSE MODEL
// ========================================
@freezed
abstract class CheckStatusResponse with _$CheckStatusResponse {
  const factory CheckStatusResponse({
    required String status,
    required String message,
    required CheckStatusData data,
  }) = _CheckStatusResponse;

  factory CheckStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$CheckStatusResponseFromJson(json);
}

// ========================================
// CHECK STATUS DATA MODEL (Contains User)
// ========================================
@freezed
abstract class CheckStatusData with _$CheckStatusData {
  const factory CheckStatusData({
    required User user,
  }) = _CheckStatusData;

  factory CheckStatusData.fromJson(Map<String, dynamic> json) =>
      _$CheckStatusDataFromJson(json);
}

// ========================================
// LOGIN RESPONSE MODEL
// ========================================
@freezed
abstract class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required String status,
    required String accessToken,
    required String refreshToken,
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
    Map<String, dynamic>? permissions,
    bool? mobileAppAccess,
    bool? webPortalAccess,
    Subscription? subscription,
  }) = _LoginData;

  factory LoginData.fromJson(Map<String, dynamic> json) =>
      _$LoginDataFromJson(json);
}

// ========================================
// REFRESH TOKEN RESPONSE MODEL
// ========================================
@freezed
abstract class RefreshTokenResponse with _$RefreshTokenResponse {
  const factory RefreshTokenResponse({
    required String status,
    required String message,
    required RefreshTokenData data,
  }) = _RefreshTokenResponse;

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenResponseFromJson(json);
}

// ========================================
// REFRESH TOKEN DATA MODEL
// ========================================
@freezed
abstract class RefreshTokenData with _$RefreshTokenData {
  const factory RefreshTokenData({
    required String accessToken,
    required String refreshToken,
    required User user,
  }) = _RefreshTokenData;

  factory RefreshTokenData.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenDataFromJson(json);
}

// ========================================
// ORGANIZATION MODEL
// ========================================
@freezed
abstract class Organization with _$Organization {
  const factory Organization({
    @JsonKey(name: '_id') required String id,
    String? name,
    String? panVatNumber,
    String? phone,
    String? address,
    String? country,
    double? latitude,
    double? longitude,
    String? googleMapLink,
    String? checkInTime,
    String? checkOutTime,
    String? halfDayCheckOutTime,
    String? weeklyOffDay,
    String? timezone,
    String? subscriptionType,
    bool? isActive,
    String? subscriptionStartDate,
    String? subscriptionEndDate,
    bool? isSubscriptionActive,
    String? owner,
    @JsonKey(name: '__v') int? version,
    List<dynamic>? subscriptionHistory,
    String? createdAt,
    String? updatedAt,
  }) = _Organization;

  factory Organization.fromJson(Map<String, dynamic> json) =>
      _$OrganizationFromJson(json);
}

// Organization converter for handling String or Object in JSON
class OrganizationConverter implements JsonConverter<Organization, dynamic> {
  const OrganizationConverter();

  @override
  Organization fromJson(dynamic json) {
    if (json is String) {
      return Organization(id: json, name: 'Organization');
    } else if (json is Map<String, dynamic>) {
      return Organization.fromJson(json);
    }
    return Organization(id: '', name: 'Organization');
  }

  @override
  dynamic toJson(Organization object) => object.toJson();
}

// ========================================
// SUBSCRIPTION MODEL
// ========================================
@freezed
abstract class Subscription with _$Subscription {
  const factory Subscription({
    required String planName,
    @JsonKey(name: 'planTier') required String tier,
    required int maxEmployees,
    required List<String> enabledModules,
    String? subscriptionEndDate,
    required bool isActive,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);
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
    @OrganizationConverter() required Organization organizationId,
    required bool isActive,
    String? phone,
    String? address,
    String? gender,
    String? dateOfBirth,
    int? age,
    String? panNumber,
    String? citizenshipNumber,
    required String dateJoined,
    @Default([]) List<Document> documents,
    String? createdAt,
    String? updatedAt,
    @JsonKey(name: '__v') int? version,
    String? avatarUrl,
    String? sessionExpiresAt,
    String? customRoleId,
    List<String>? reportsTo,
    Map<String, dynamic>? permissions,
    Subscription? subscription,
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