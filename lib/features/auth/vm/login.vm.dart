import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/network_layer/token_storage_service.dart';

import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/core/providers/user_controller.dart';
import '../models/login.models.dart';

part 'login.vm.g.dart';

@Riverpod(keepAlive: true) // 👈 ensures it's never disposed
class LoginViewModel extends _$LoginViewModel {
  @override
  Future<LoginResponse?> build() async {
    // No initial state, just return null
    // Token validation is handled by AppStartupProvider
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
      state = AsyncError({
        'email': emailError,
        'password': passwordError,
      }, StackTrace.empty);
      return;
    }

    // Begin async login
    state = const AsyncLoading();

    try {
      final dio = ref.read(dioClientProvider);
      final tokenStorage = ref.read(tokenStorageServiceProvider);

      AppLogger.i('🔐 Attempting login for: $email');

      final response = await dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final loginResponse = LoginResponse.fromJson(response.data);

        AppLogger.i('✅ Login successful for: ${loginResponse.data.user.name}');

        // Save token
        await tokenStorage.saveToken(loginResponse.token);

        // Save user data to SharedPreferences
        await tokenStorage.saveUserData(loginResponse.data.user.toJson());

        AppLogger.i('✅ Token and user data stored successfully');

        // Update global user state 👇
        ref
            .read(userControllerProvider.notifier)
            .setUser(loginResponse.data.user);

        // Save successful login in state
        state = AsyncData(loginResponse);
      } else {
        AppLogger.w('⚠️ Login failed with status: ${response.statusCode}');
        state = AsyncError({
          'general': 'Login failed. Please try again.',
        }, StackTrace.empty);
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Login failed', e);

      if (e.response?.statusCode == 401) {
        state = AsyncError({
          'general': 'Invalid email or password',
        }, StackTrace.empty);
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Invalid request.';
        state = AsyncError({'general': message}, StackTrace.empty);
      } else {
        state = AsyncError({
          'general': 'Network error. Please check your connection.',
        }, StackTrace.empty);
      }
    } catch (e, stack) {
      AppLogger.e('❌ Unexpected error during login', e, stack);
      state = AsyncError({
        'general': 'Something went wrong. Please try again.',
      }, StackTrace.current);
    }
  }
}
