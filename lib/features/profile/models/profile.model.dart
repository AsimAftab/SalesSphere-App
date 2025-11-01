import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.model.freezed.dart';
part 'profile.model.g.dart';

/// Profile Model - User profile information
@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    @JsonKey(name: '_id') required String id,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String address,
    String? gender,
    String? citizenship,
    String? panNumber,
    DateTime? dateOfBirth,
    DateTime? dateJoined,
    String? city,
    String? country,
    String? profileImageUrl,
    String? role,
    String? employeeId,
    @Default(0) int totalVisits,
    @Default(0) int totalOrders,
    @Default(0.0) double attendancePercentage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}

/// Update Profile Request
@freezed
abstract class UpdateProfileRequest with _$UpdateProfileRequest {
  const factory UpdateProfileRequest({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? address,
    String? gender,
    String? citizenship,
    String? panNumber,
    DateTime? dateOfBirth,
    DateTime? dateJoined,
    String? city,
    String? country,
    String? profileImageUrl,
  }) = _UpdateProfileRequest;

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);
}

/// Profile API Response
@freezed
abstract class ProfileResponse with _$ProfileResponse {
  const factory ProfileResponse({
    required String status,
    required Profile data,
  }) = _ProfileResponse;

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseFromJson(json);
}
