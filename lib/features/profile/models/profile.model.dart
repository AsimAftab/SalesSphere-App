import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sales_sphere/features/auth/models/login.models.dart';

part 'profile.model.freezed.dart';
part 'profile.model.g.dart';

// ============================================================================
// PROFILE MODEL - User profile information from API
// ============================================================================

@freezed
abstract class Profile with _$Profile {
  const Profile._(); // Private constructor for Freezed

  const factory Profile({
    @JsonKey(name: '_id') required String id,
    required String name,
    required String email,
    required String role,
    @OrganizationConverter() required Organization organizationId,
    @Default(true) bool isActive,
    String? phone,
    String? address,
    String? gender,
    DateTime? dateOfBirth,
    int? age,
    String? panNumber,
    String? citizenshipNumber,
    DateTime? dateJoined,
    DateTime? createdAt,
    DateTime? updatedAt,
    @JsonKey(name: '__v') int? version,
    String? sessionExpiresAt,
    @Default([]) List<Document> documents,
    String? avatarUrl,
    CustomRole? customRoleId,
    List<String>? reportsTo,
    Map<String, dynamic>? permissions,
    Subscription? subscription,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  /// Returns the display role name.
  /// Uses customRoleId.name if available (e.g., "SalesPerson"),
  /// otherwise falls back to role field (e.g., "admin", "user").
  String get displayRole => customRoleId?.name ?? role;
}

// ============================================================================
// PROFILE API RESPONSE - Wraps the profile data from API
// ============================================================================

@freezed
abstract class ProfileApiResponse with _$ProfileApiResponse {
  const ProfileApiResponse._(); // Private constructor for Freezed

  const factory ProfileApiResponse({
    required bool success,
    required Profile data,
  }) = _ProfileApiResponse;

  factory ProfileApiResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileApiResponseFromJson(json);
}

// ============================================================================
// UPLOAD PROFILE IMAGE RESPONSE - Response from profile image upload API
// ============================================================================

@freezed
abstract class UploadProfileImageData with _$UploadProfileImageData {
  const UploadProfileImageData._(); // Private constructor for Freezed

  const factory UploadProfileImageData({
    required String avatarUrl,
  }) = _UploadProfileImageData;

  factory UploadProfileImageData.fromJson(Map<String, dynamic> json) =>
      _$UploadProfileImageDataFromJson(json);
}

@freezed
abstract class UploadProfileImageResponse with _$UploadProfileImageResponse {
  const UploadProfileImageResponse._(); // Private constructor for Freezed

  const factory UploadProfileImageResponse({
    required bool success,
    required String message,
    required UploadProfileImageData data,
  }) = _UploadProfileImageResponse;

  factory UploadProfileImageResponse.fromJson(Map<String, dynamic> json) =>
      _$UploadProfileImageResponseFromJson(json);
}
