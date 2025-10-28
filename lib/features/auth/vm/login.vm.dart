import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/network_layer/token_storage_service.dart';
import 'package:sales_sphere/core/network_layer/network_exceptions.dart';
import 'package:sales_sphere/core/constants/api_endpoints.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import '../models/login.models.dart';

part 'login.vm.g.dart';

@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  Future<LoginResponse?> build() async {
    // No initialization needed for now
    return null;
  }

  /// Local email validation
  String? validateEmailLocally(String? value) {
    if (value == null || value.isEmpty) return 'Email cannot be empty';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  /// Local password validation
  String? validatePasswordLocally(String? value) {
    if (value == null || value.isEmpty) return 'Password cannot be empty';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  /// Login method
  Future<void> login(String email, String password) async {
    // Reset previous errors
    state = const AsyncData(null);

    // Pre-validate locally
    final emailError = validateEmailLocally(email);
    final passwordError = validatePasswordLocally(password);

    if (emailError != null || passwordError != null) {
      // Return field-specific errors
      state = AsyncError(
        {
          'email': emailError,
          'password': passwordError,
        },
        StackTrace.empty,
      );
      return;
    }

    // Begin async login
    state = const AsyncLoading();

    try {
      final dio = ref.read(dioClientProvider);
      final tokenStorage = ref.read(tokenStorageServiceProvider);

      AppLogger.i('🔐 Attempting login for: $email');

      // Make API call
      final response = await dio.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse response
        final loginResponse = LoginResponse.fromJson(response.data);

        AppLogger.i('✅ Login successful for: ${loginResponse.data.user.name}');

        // Store token in SharedPreferences
        await tokenStorage.saveToken(loginResponse.token);

        AppLogger.i('✅ Token stored successfully');

        // Success - store the user data in state
        state = AsyncData(loginResponse);
      } else {
        AppLogger.w('⚠️ Login failed with status: ${response.statusCode}');
        state = AsyncError(
          {'general': 'Login failed. Please try again.'},
          StackTrace.empty,
        );
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Login failed', e);

      // Handle network exceptions
      if (e.error is NetworkException) {
        final networkError = e.error as NetworkException;
        state = AsyncError(
          {'general': networkError.userFriendlyMessage},
          StackTrace.empty,
        );
      } else if (e.response?.statusCode == 401) {
        // Unauthorized - invalid credentials
        state = AsyncError(
          {'general': 'Invalid email or password'},
          StackTrace.empty,
        );
      } else if (e.response?.statusCode == 400) {
        // Bad request - might have field-specific errors
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic> && errorData['message'] != null) {
          state = AsyncError(
            {'general': errorData['message']},
            StackTrace.empty,
          );
        } else {
          state = AsyncError(
            {'general': 'Invalid request. Please check your input.'},
            StackTrace.empty,
          );
        }
      } else {
        state = AsyncError(
          {'general': 'Network error. Please check your connection.'},
          StackTrace.empty,
        );
      }
    } catch (e, stack) {
      // Unexpected errors
      AppLogger.e('❌ Unexpected error during login', e, stack);
      state = AsyncError(
        {'general': 'Something went wrong. Please try again.'},
        StackTrace.current,
      );
    }
  }

  /// Get stored user data
  User? get currentUser {
    return state.value?.data.user;
  }
}
