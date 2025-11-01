import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sales_sphere/core/constants/storage_keys.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import '../models/profile.model.dart';

part 'profile.vm.g.dart';

@riverpod
class ProfileViewModel extends _$ProfileViewModel {
  @override
  Future<Profile?> build() async {
    return await fetchProfile();
  }

  /// Fetch user profile
  Future<Profile?> fetchProfile() async {
    state = const AsyncLoading();

    try {
      // TODO: Replace with actual API call when backend is ready
      // Simulating API delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Load saved profile image from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedImagePath = prefs.getString(StorageKeys.profileImagePath);

      // Mock profile data
      final mockProfile = Profile(
        id: '123456789',
        fullName: 'John Doe',
        email: 'john.doe@salessphere.com',
        phoneNumber: '9841234567',
        address: 'Kathmandu Metropolitan City, Ward No. 5',
        gender: 'Male',
        citizenship: '12345678901234',
        panNumber: '123456789',
        dateOfBirth: DateTime(1990, 5, 15),
        dateJoined: DateTime(2024, 1, 15),
        city: 'Kathmandu',
        country: 'Nepal',
        profileImageUrl: savedImagePath, // Load from SharedPreferences
        role: 'Sales Representative',
        employeeId: 'EMP-2024-001',
        totalVisits: 45,
        totalOrders: 32,
        attendancePercentage: 92.5,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        updatedAt: DateTime.now(),
      );

      AppLogger.i('✅ Mock profile loaded successfully');
      if (savedImagePath != null) {
        AppLogger.i('✅ Loaded saved profile image: $savedImagePath');
      }
      state = AsyncData(mockProfile);
      return mockProfile;

      // COMMENTED OUT - Real API call for later implementation
      /*
      final dio = ref.read(dioClientProvider);
      final response = await dio.get(ApiEndpoints.profile);

      if (response.statusCode == 200) {
        final profileResponse = ProfileResponse.fromJson(response.data);
        state = AsyncData(profileResponse.data);
        return profileResponse.data;
      } else {
        throw Exception('Failed to fetch profile');
      }
      */
    } on DioException catch (e) {
      AppLogger.e('Failed to fetch profile', e);
      state = AsyncError(
        e.response?.data['message'] ?? 'Failed to load profile',
        StackTrace.current,
      );
      return null;
    } catch (e, stack) {
      AppLogger.e('Unexpected error fetching profile', e, stack);
      state = AsyncError('Something went wrong', stack);
      return null;
    }
  }

  /// Update user profile
  Future<bool> updateProfile(UpdateProfileRequest request) async {
    final currentProfile = state.value;
    if (currentProfile == null) return false;

    // Set loading state (no optimistic update)
    state = const AsyncLoading<Profile?>();

    try {
      // TODO: Replace with actual API call when backend is ready
      // Simulating API delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock update - merge request data with current profile
      final updatedProfile = currentProfile.copyWith(
        fullName: request.fullName ?? currentProfile.fullName,
        email: request.email ?? currentProfile.email,
        phoneNumber: request.phoneNumber ?? currentProfile.phoneNumber,
        address: request.address ?? currentProfile.address,
        gender: request.gender ?? currentProfile.gender,
        citizenship: request.citizenship ?? currentProfile.citizenship,
        panNumber: request.panNumber ?? currentProfile.panNumber,
        dateOfBirth: request.dateOfBirth ?? currentProfile.dateOfBirth,
        dateJoined: request.dateJoined ?? currentProfile.dateJoined,
        city: request.city ?? currentProfile.city,
        country: request.country ?? currentProfile.country,
        profileImageUrl: request.profileImageUrl ?? currentProfile.profileImageUrl,
        updatedAt: DateTime.now(),
      );

      state = AsyncData(updatedProfile);
      AppLogger.i('✅ Mock profile updated successfully');
      return true;

      // COMMENTED OUT - Real API call for later implementation
      /*
      final dio = ref.read(dioClientProvider);
      final response = await dio.put(
        ApiEndpoints.updateProfile,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final profileResponse = ProfileResponse.fromJson(response.data);
        state = AsyncData(profileResponse.data);
        AppLogger.i('Profile updated successfully');
        return true;
      } else {
        // Revert to previous profile on failure
        state = AsyncData(currentProfile);
        throw Exception('Failed to update profile');
      }
      */
    } on DioException catch (e) {
      // Revert to previous profile
      state = AsyncData(currentProfile);
      AppLogger.e('Failed to update profile', e);
      return false;
    } catch (e, stack) {
      // Revert to previous profile
      state = AsyncData(currentProfile);
      AppLogger.e('Unexpected error updating profile', e, stack);
      return false;
    }
  }

  /// Refresh profile
  Future<void> refresh() async {
    await fetchProfile();
  }

  /// Update profile image
  Future<bool> updateProfileImage(String imageUrl) async {
    try {
      // Save image path to SharedPreferences for persistence
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.profileImagePath, imageUrl);
      AppLogger.i('✅ Profile image path saved: $imageUrl');

      // Update the profile with the new image
      return await updateProfile(
        UpdateProfileRequest(profileImageUrl: imageUrl),
      );
    } catch (e, stack) {
      AppLogger.e('Failed to save profile image path', e, stack);
      return false;
    }
  }
}
