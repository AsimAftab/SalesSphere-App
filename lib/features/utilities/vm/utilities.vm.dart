import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'utilities.vm.g.dart';

/// ViewModel for Utilities feature
/// Currently minimal as utilities are static UI configuration
/// Can be expanded for:
/// - Dynamic utility availability based on user permissions
/// - Feature flags/remote config
/// - Analytics tracking
@riverpod
class UtilitiesViewModel extends _$UtilitiesViewModel {
  @override
  void build() {
    // No state needed currently
    // Future: Could load user permissions, feature flags, etc.
  }

  // Future methods can be added here:
  // - checkUtilityPermission(String utilityId)
  // - trackUtilityAccess(String utilityId)
  // - getEnabledUtilities() based on user role
}