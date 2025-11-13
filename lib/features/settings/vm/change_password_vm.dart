import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import '../models/change_password.models.dart';

part 'change_password_vm.g.dart';

@Riverpod(keepAlive: true)
class ChangePasswordViewModel extends _$ChangePasswordViewModel {
  @override
  Future<ChangePasswordResponse?> build() async {
    // No initial data to fetch
    return null;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    state = const AsyncValue.loading();

    try {
      AppLogger.i('🔒 Attempting to change password...');

      final dio = ref.read(dioClientProvider);

      // Create request object
      final request = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );

      final response = await dio.put(
        ApiEndpoints.changePassword,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final changePasswordResponse = ChangePasswordResponse.fromJson(response.data);

        AppLogger.i('✅ Password changed successfully: ${changePasswordResponse.message}');

        state = AsyncData(changePasswordResponse);
        return true;
      } else {
        // Extract error message from response
        String errorMessage = 'Password change failed. Please try again.';
        if (response.data is Map && response.data['message'] != null) {
          errorMessage = response.data['message'];
        }

        AppLogger.w('⚠️ Password change failed with status: ${response.statusCode} - $errorMessage');
        state = AsyncError({
          'general': errorMessage,
        }, StackTrace.current);
        return false;
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Password change failed', e);

      if (e.response?.statusCode == 401 || e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Invalid current password';
        state = AsyncError({'general': message}, StackTrace.current);
      } else if (e.response?.statusCode == 422) {
        final message = e.response?.data['message'] ?? 'Validation failed';
        state = AsyncError({'general': message}, StackTrace.current);
      } else {
        state = AsyncError({
          'general': 'Network error. Please check your connection.',
        }, StackTrace.current);
      }
      return false;
    } catch (e, st) {
      AppLogger.e('❌ Unexpected error during password change', e, st);
      state = AsyncError({
        'general': 'Something went wrong. Please try again.',
      }, st);
      return false;
    }
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Must contain an uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Must contain a lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Must contain a number';
    }
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(value)) {
      return 'Must contain a special character';
    }
    return null;
  }
}
