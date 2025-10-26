import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/login_model.dart'; // Optional, if using a request model

part 'login.vm.g.dart';

/// Login state can include field errors for inline validation
class LoginError {
  final String? email;
  final String? password;
  final String? general;

  const LoginError({this.email, this.password, this.general});
}

@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  Future<void> build() async {
    // No initialization needed for now
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
      // TODO: Replace this with real API call using repository
      await Future.delayed(const Duration(seconds: 2));

      // Simulate backend validation failure example
      if (email != 'test@example.com' || password != 'password123') {
        state = AsyncError(
          {'general': 'Invalid email or password'},
          StackTrace.empty,
        );
        return;
      }

      // Success
      state = const AsyncData(null);
    } catch (e) {
      // Unexpected errors
      state = AsyncError({'general': 'Something went wrong. Please try again.'}, StackTrace.current);
    }
  }
}
