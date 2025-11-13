import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/core/providers/user_controller.dart';
import '../models/profile.model.dart';

part 'profile.vm.g.dart';

// ============================================================================
// PROFILE VIEW MODEL
// Handles: Fetch user profile, Upload profile image
// Note: Profile details cannot be updated (read-only), only image can be updated
// ============================================================================

@riverpod
class ProfileViewModel extends _$ProfileViewModel {
  @override
  Future<Profile?> build() async {
    return await fetchProfile();
  }

  /// Fetch user profile from API
  Future<Profile?> fetchProfile() async {
    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i('Fetching user profile from API...');

      final response = await dio.get(ApiEndpoints.profile);

      if (response.statusCode == 200) {
        // Parse the API response
        final profileResponse = ProfileApiResponse.fromJson(response.data);

        AppLogger.i('✅ Profile loaded successfully: ${profileResponse.data.name}');
        AppLogger.d('Email: ${profileResponse.data.email}, Role: ${profileResponse.data.role}');

        return profileResponse.data;
      } else {
        throw Exception('Failed to fetch profile: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error fetching profile: ${e.message}');
      if (e.response != null) {
        AppLogger.e('Response data: ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e, stack) {
      AppLogger.e('❌ Unexpected error fetching profile: $e');
      AppLogger.e('Stack trace: $stack');
      throw Exception('Failed to load profile: $e');
    }
  }

  /// Refresh profile
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final profile = await fetchProfile();
      state = AsyncData(profile);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  /// Upload profile image
  /// Uploads image file to server and updates the avatar URL
  ///
  /// Parameters:
  /// - imagePath: Local file path of the image to upload
  ///
  /// Returns: true if successful, false otherwise
  Future<bool> uploadProfileImage(String imagePath) async {
    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i('Uploading profile image: $imagePath');

      // Create form data with the image file
      final formData = FormData.fromMap({
        'profileImage': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
      });

      // Upload the image using PUT method
      final response = await dio.put(
        ApiEndpoints.uploadProfileImage,
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.i('✅ Profile image uploaded successfully');

        // Parse the response to get the new avatar URL
        final uploadResponse = UploadProfileImageResponse.fromJson(response.data);
        AppLogger.d('New avatar URL: ${uploadResponse.data.avatarUrl}');

        // Refresh profile to get updated data from server
        if (ref.mounted) {
          try {
            final updatedProfile = await fetchProfile();
            state = AsyncData(updatedProfile);

            // Also update the user controller so avatar updates in home and settings
            final currentUser = ref.read(userControllerProvider);
            if (currentUser != null) {
              ref.read(userControllerProvider.notifier).setUser(
                currentUser.copyWith(avatarUrl: uploadResponse.data.avatarUrl),
              );
              AppLogger.i('✅ Updated user avatar in userController');
            }
          } catch (e) {
            AppLogger.e('Failed to refresh profile after image upload: $e');
            // Still return true since upload was successful
          }
        }
        return true;
      } else {
        throw Exception('Failed to upload profile image: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error uploading profile image: ${e.message}');
      if (e.response != null) {
        AppLogger.e('Response data: ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e, stack) {
      AppLogger.e('❌ Error uploading profile image: $e');
      AppLogger.e('Stack trace: $stack');
      throw Exception('Failed to upload profile image: $e');
    }
  }
}
