import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/token_storage_service.dart';
import 'package:sales_sphere/core/providers/permission_controller.dart';
import 'package:sales_sphere/core/providers/user_controller.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'settings.vm.g.dart';

@Riverpod(keepAlive: true)
class SettingsViewModel extends _$SettingsViewModel {
  @override
  FutureOr<void> build() {
    // No initialization needed
  }

  // settings.vm.dart
  Future<void> signOut() async {
    final tokenStorage = ref.read(tokenStorageServiceProvider);

    try {
      await tokenStorage.clearAuthData();
      ref.read(userControllerProvider.notifier).clearUser();
      ref.read(permissionControllerProvider.notifier).clearData();
      AppLogger.i('👋 User signed out successfully');
    } catch (e, stack) {
      AppLogger.e('❌ Error during sign out', e, stack);
      rethrow;
    }
  }
}
