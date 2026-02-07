import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/utils/logger.dart';

import '../models/forgot_password.models.dart';

part 'forgot_password.vm.g.dart';

@riverpod
class ForgotPasswordViewModel extends _$ForgotPasswordViewModel {
  @override
  Future<ForgotPasswordResponse?> build() async {
    return null;
  }

  /// Local email validation
  String? validateEmailLocally(String? value) {
    if (value == null || value.isEmpty) return 'Email cannot be empty';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  /// Send forgot password request
  Future<bool> sendResetEmail(String email) async {
    // Reset previous errors
    state = const AsyncData(null);

    // Pre-validate locally
    final emailError = validateEmailLocally(email);

    if (emailError != null) {
      state = AsyncError({'email': emailError}, StackTrace.empty);
      return false;
    }

    // Begin async request
    state = const AsyncLoading();

    try {
      final dio = ref.read(dioClientProvider);

      AppLogger.i('📧 Sending password reset email to: $email');

      final response = await dio.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final forgotPasswordResponse = ForgotPasswordResponse.fromJson(
          response.data,
        );

        AppLogger.i('✅ Password reset email sent successfully');

        // Save successful response in state
        state = AsyncData(forgotPasswordResponse);
        return true;
      } else {
        AppLogger.w('⚠️ Request failed with status: ${response.statusCode}');
        state = AsyncError({
          'general': 'Failed to send reset email. Please try again.',
        }, StackTrace.empty);
        return false;
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Forgot password request failed', e);

      // Handle different error scenarios
      if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Invalid email format.';
        state = AsyncError({'general': message}, StackTrace.empty);
      } else if (e.response != null) {
        // Server responded with an error
        final message =
            e.response?.data['message'] ?? 'Failed to send reset email.';
        state = AsyncError({'general': message}, StackTrace.empty);
      } else {
        // Network error (no response from server)
        state = AsyncError({
          'general': 'Network error. Please check your connection.',
        }, StackTrace.empty);
      }
      return false;
    } catch (e, stack) {
      AppLogger.e('❌ Unexpected error during forgot password', e, stack);
      state = AsyncError({
        'general': 'Something went wrong. Please try again.',
      }, StackTrace.current);
      return false;
    }
  }
}
