import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/token_storage_service.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/auth/models/login.models.dart';

part 'permission_controller.g.dart';

/// Permission and Subscription State
class PermissionState {
  final Map<String, dynamic>? permissions;
  final Subscription? subscription;
  final bool mobileAppAccess;
  final bool webPortalAccess;

  const PermissionState({
    this.permissions,
    this.subscription,
    this.mobileAppAccess = false,
    this.webPortalAccess = false,
  });

  /// Check if user has a specific permission
  bool hasPermission(String module, String permission) {
    if (permissions == null) return false;
    final modulePermissions = permissions![module];
    if (modulePermissions is Map<String, dynamic>) {
      return modulePermissions[permission] == true;
    }
    return false;
  }

  /// Check if module is enabled in subscription
  bool isModuleEnabled(String module) {
    return subscription?.enabledModules.contains(module) ?? false;
  }

  PermissionState copyWith({
    Map<String, dynamic>? permissions,
    Subscription? subscription,
    bool? mobileAppAccess,
    bool? webPortalAccess,
  }) {
    return PermissionState(
      permissions: permissions ?? this.permissions,
      subscription: subscription ?? this.subscription,
      mobileAppAccess: mobileAppAccess ?? this.mobileAppAccess,
      webPortalAccess: webPortalAccess ?? this.webPortalAccess,
    );
  }
}

/// Permission Controller Provider
@Riverpod(keepAlive: true)
class PermissionController extends _$PermissionController {
  @override
  PermissionState build() {
    // Load cached data synchronously before returning initial state
    try {
      final tokenStorage = ref.read(tokenStorageServiceProvider);

      final permissions = tokenStorage.getPermissions();
      final subscriptionJson = tokenStorage.getSubscription();

      Subscription? subscription;
      if (subscriptionJson != null) {
        subscription = Subscription.fromJson(subscriptionJson);
      }

      if (permissions != null || subscription != null) {
        AppLogger.i('✅ Cached permissions and subscription loaded on build');
        return PermissionState(
          permissions: permissions,
          subscription: subscription,
        );
      }
    } catch (e, stack) {
      AppLogger.e('❌ Error loading cached permission data', e, stack);
    }

    // Return empty state if no cached data
    return const PermissionState();
  }

  /// Update permissions and subscription state
  void updateData({
    Map<String, dynamic>? permissions,
    Subscription? subscription,
    bool? mobileAppAccess,
    bool? webPortalAccess,
  }) {
    state = state.copyWith(
      permissions: permissions,
      subscription: subscription,
      mobileAppAccess: mobileAppAccess,
      webPortalAccess: webPortalAccess,
    );
  }

  /// Clear all permission data
  void clearData() {
    state = const PermissionState();
    AppLogger.i('✅ Permission data cleared');
  }

  /// Check if user has a specific permission
  bool hasPermission(String module, String permission) {
    return state.hasPermission(module, permission);
  }

  /// Check if module is enabled in subscription
  bool isModuleEnabled(String module) {
    return state.isModuleEnabled(module);
  }

  /// Get current subscription tier
  String get subscriptionTier => state.subscription?.tier ?? 'free';

  /// Get current plan name
  String get planName => state.subscription?.planName ?? 'Unknown';

  /// Check if user has mobile app access
  bool get hasMobileAppAccess => state.mobileAppAccess;

  /// Check if user has web portal access
  bool get hasWebPortalAccess => state.webPortalAccess;
}
