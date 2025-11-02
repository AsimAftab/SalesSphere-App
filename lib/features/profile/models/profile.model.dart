import 'package:freezed_annotation/freezed_annotation.dart';

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
    required String organizationId,
    @Default(true) bool isActive,
    required String phone,
    required String address,
    required String gender,
    required DateTime dateOfBirth,
    required int age,
    required String panNumber,
    required String citizenshipNumber,
    required DateTime dateJoined,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? avatarUrl,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
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
