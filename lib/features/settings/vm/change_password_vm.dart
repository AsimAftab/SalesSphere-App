import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/features/auth/models/login.models.dart';

part 'change_password_vm.g.dart';

@Riverpod(keepAlive: true)
class ChangePasswordViewModel extends _$ChangePasswordViewModel {
  @override
  Future<void> build() async {
    // No initial data to fetch
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = const AsyncValue.loading();
    try {
      final dio = ref.read(dioClientProvider);
      // TODO: Replace with actual endpoint
      await dio.post(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
      state = const AsyncValue.data(null);
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        state = AsyncValue.error({
          'general': 'Invalid current password',
        }, StackTrace.current);
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Invalid request.';
        state = AsyncValue.error({'general': message}, StackTrace.current);
      } else {
        state = AsyncValue.error({
          'general': 'Network error. Please check your connection.',
        }, StackTrace.current);
      }
      return false;
    } catch (e, st) {
      state = AsyncValue.error({
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
      return 'Must be at least 8 characters.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Must contain an uppercase letter.';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Must contain a lowercase letter.';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Must contain a number.';
    }
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(value)) {
      return 'Must contain a special character.';
    }
    return null;
  }
}
