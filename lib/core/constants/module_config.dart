/// Central configuration for module-based access control.
///
/// Maps UI components (routes, tabs, utilities) to their corresponding module names
/// from the subscription's enabledModules array.
class ModuleConfig {
  ModuleConfig._();

  // ========================================
  // MODULE DEFINITIONS
  // ========================================

  /// All modules that can be enabled/disabled via subscription.
  /// The key is the module name from API's enabledModules array.
  static const Map<String, AppModule> modules = {
    // Core Navigation Tabs
    'dashboard': AppModule(
      id: 'dashboard',
      displayName: 'Home',
      routePaths: ['/home'],
      navTabIndex: 0,
    ),
    'products': AppModule(
      id: 'products',
      displayName: 'Catalog',
      routePaths: ['/catalog', '/catalog/select-category'],
      navTabIndex: 1,
    ),
    'invoices': AppModule(
      id: 'invoices',
      displayName: 'Invoice',
      routePaths: ['/invoice', '/invoice/history', '/invoice/details'],
      navTabIndex: 2,
    ),
    'estimates': AppModule(
      id: 'estimates',
      displayName: 'Estimates',
      routePaths: ['/estimate', '/estimate/details'],
      navTabIndex: null, // Part of Invoice tab
    ),

    // Directory Modules (shown in DirectoryOptionsSheet)
    'parties': AppModule(
      id: 'parties',
      displayName: 'Parties',
      routePaths: [
        '/parties',
        '/directory/party-list',
        '/add-party',
        '/edit_party_details_screen',
      ],
      directoryIndex: 0,
    ),
    'prospects': AppModule(
      id: 'prospects',
      displayName: 'Prospects',
      routePaths: [
        '/prospects',
        '/directory/prospects-list',
        '/add-prospect',
        '/edit-prospect',
        '/edit_prospect_details_screen',
      ],
      directoryIndex: 1,
    ),
    'sites': AppModule(
      id: 'sites',
      displayName: 'Sites',
      routePaths: [
        '/sites',
        '/directory/sites-list',
        '/add-site',
        '/edit-site',
        '/edit_site_details_screen',
        '/sites/images',
      ],
      directoryIndex: 2,
    ),

    // Utility Modules (shown in UtilitiesScreen)
    'attendance': AppModule(
      id: 'attendance',
      displayName: 'Attendance',
      routePaths: ['/attendance', '/attendance/monthly-details'],
      utilityIndex: 0,
    ),
    'leaves': AppModule(
      id: 'leaves',
      displayName: 'Leave Request',
      routePaths: ['/leave-requests', '/apply-leave', '/edit-leave'],
      utilityIndex: 1,
    ),
    'odometer': AppModule(
      id: 'odometer',
      displayName: 'Odometer',
      routePaths: ['/odometer', '/odometer-list', '/odometer-details'],
      utilityIndex: 2,
    ),
    'expenses': AppModule(
      id: 'expenses',
      displayName: 'Expense Claims',
      routePaths: ['/expense-claims', '/add-expense-claim', '/expense-claim'],
      utilityIndex: 3,
    ),
    'notes': AppModule(
      id: 'notes',
      displayName: 'Notes',
      routePaths: ['/notes', '/add-notes', '/edit-notes'],
      utilityIndex: 4,
    ),
    'collections': AppModule(
      id: 'collections',
      displayName: 'Collection',
      routePaths: ['/collections', '/add-collection', '/edit-collection'],
      utilityIndex: 5,
    ),
    'tourPlan': AppModule(
      id: 'tourPlan',
      displayName: 'Tour Plan',
      routePaths: ['/tour-plans', '/add-tour', '/edit-tour'],
      utilityIndex: 6,
    ),
    'miscellaneousWork': AppModule(
      id: 'miscellaneousWork',
      displayName: 'Miscellaneous Work',
      routePaths: [
        '/miscellaneous-work',
        '/add-miscellaneous-work',
        '/edit-miscellaneous-work',
      ],
      utilityIndex: 7,
    ),

    // Other modules (not in main navigation)
    'beatPlan': AppModule(
      id: 'beatPlan',
      displayName: 'Beat Plan',
      routePaths: ['/beat-plan'],
      navTabIndex: null,
    ),
  };

  // ========================================
  // MODULE GROUPINGS
  // ========================================

  /// Modules that appear in bottom navigation tabs
  static const List<String> navTabModules = [
    'dashboard', // Home tab
    'products', // Catalog tab
    'invoices', // Invoice tab (includes estimates)
  ];

  /// Modules that appear in Directory options sheet
  static const List<String> directoryModules = [
    'parties',
    'prospects',
    'sites',
  ];

  /// Modules that appear in Utilities screen
  static const List<String> utilityModules = [
    'attendance',
    'leaves',
    'odometer',
    'expenses',
    'notes',
    'collections',
    'tourPlan',
    'miscellaneousWork',
  ];

  /// Routes that are always accessible (not module-gated)
  static const Set<String> alwaysAccessibleRoutes = {
    '/splash',
    '/onboarding',
    '/',
    '/forgot-password',
    '/profile',
    '/settings',
    '/about',
    '/terms-and-conditions',
    '/settings/change-password',
  };

  /// Modules that are always available in the UI (not subscription-gated)
  /// These include core features that should be accessible to all users
  static const Set<String> alwaysAvailableModules = {
    'dashboard', // Home tab - always visible
  };

  /// Check if a module should always be available in the UI
  static bool isAlwaysAvailableModule(String moduleId) {
    return alwaysAvailableModules.contains(moduleId);
  }

  /// Check if a route is always accessible (not module-gated)
  static bool isAlwaysAccessibleRoute(String path) {
    return _matchesAlwaysAccessibleRoute(path);
  }

  // ========================================
  // HELPER METHODS
  // ========================================

  /// Check if a path matches a route pattern exactly or as a prefix
  /// Prevents false matches like /catalog2 matching /catalog
  static bool _pathMatches(String routePattern, String actualPath) {
    if (actualPath == routePattern) return true;
    // Check if it's a direct child path (e.g., /settings/change-password matches /settings)
    if (actualPath.startsWith('$routePattern/')) return true;
    return false;
  }

  /// Check if path matches any always accessible route
  static bool _matchesAlwaysAccessibleRoute(String path) {
    if (alwaysAccessibleRoutes.contains(path)) return true;
    for (final route in alwaysAccessibleRoutes) {
      if (_pathMatches(route, path)) return true;
    }
    return false;
  }

  /// Get module config by ID
  static AppModule? getModule(String moduleId) {
    return modules[moduleId];
  }

  /// Get module ID for a given route path
  static String? getModuleForRoute(String path) {
    for (final module in modules.values) {
      for (final routePath in module.routePaths) {
        if (_pathMatches(routePath, path)) {
          // Handle estimates as part of invoices
          if (module.id == 'invoices' && path.contains('/estimate')) {
            return 'estimates';
          }
          return module.id;
        }
      }
    }
    return null;
  }

  /// Check if route requires module access check
  static bool requiresModuleCheck(String path) {
    return !_matchesAlwaysAccessibleRoute(path) &&
        getModuleForRoute(path) != null;
  }

  /// Get display name for a module
  static String getDisplayName(String moduleId) {
    return modules[moduleId]?.displayName ?? 'This feature';
  }

  // ========================================
  // BATCH MODULE CHECK HELPERS
  // ========================================

  /// Check multiple modules and return their enabled states
  static Map<String, bool> checkModules(
    List<String> moduleIds,
    bool Function(String) isEnabledFn,
  ) {
    return Map.fromEntries(
      moduleIds.map((id) => MapEntry(id, isEnabledFn(id))),
    );
  }

  /// Get list of enabled module IDs from a list
  static List<String> getEnabledModules(
    List<String> moduleIds,
    bool Function(String) isEnabledFn,
  ) {
    return moduleIds.where((id) => isEnabledFn(id)).toList();
  }

  /// Check if ANY of the given modules are enabled
  static bool isAnyModuleEnabled(
    List<String> moduleIds,
    bool Function(String) isEnabledFn,
  ) {
    return moduleIds.any((id) => isEnabledFn(id));
  }

  // ========================================
  // NAVIGATION TAB HELPERS
  // ========================================

  /// Get the actual visual tab index for a module, considering which tabs are visible.
  ///
  /// Visual layout: [Home:0] [Catalog:1] [Invoice:2-floating] [Directory:3] [Utilities:4]
  static int? getVisualTabIndex(
    String moduleId,
    bool Function(String) isEnabledFn,
  ) {
    final module = modules[moduleId];
    if (module == null) return null;

    // Handle direct nav tab modules
    if (module.navTabIndex != null) {
      // Special case: invoices uses the spacer position (index 2)
      if (moduleId == 'invoices') {
        return 2;
      }
      return module.navTabIndex;
    }

    // Handle directory modules (parties, prospects, sites)
    if (directoryModules.contains(moduleId)) {
      return isAnyModuleEnabled(directoryModules, isEnabledFn) ? 3 : null;
    }

    // Handle utility modules
    if (utilityModules.contains(moduleId)) {
      return isAnyModuleEnabled(utilityModules, isEnabledFn) ? 4 : null;
    }

    return null;
  }

  /// Get the module ID for a given visual tab index
  static String? getModuleIdForVisualIndex(
    int visualIndex,
    bool Function(String) isEnabledFn,
  ) {
    int currentIndex = 0;
    final invoiceOrEstimatesEnabled =
        isEnabledFn('invoices') || isEnabledFn('estimates');

    for (final navModuleId in navTabModules) {
      if (!isEnabledFn(navModuleId)) continue;

      if (currentIndex == visualIndex) {
        return navModuleId;
      }

      currentIndex++;
      // Account for spacer after catalog
      if (navModuleId == 'products' && invoiceOrEstimatesEnabled) {
        currentIndex++; // Skip spacer position
      }
    }
    return null;
  }

  /// Get list of visible tab indices (considering spacers)
  static List<int> getVisibleTabIndices(bool Function(String) isEnabledFn) {
    final indices = <int>[];
    int logicalIndex = 0;

    for (final navModuleId in navTabModules) {
      if (isEnabledFn(navModuleId)) {
        indices.add(logicalIndex);
        logicalIndex++;
      }
      // Add spacer position after catalog if invoice/estimates enabled
      if (navModuleId == 'products' &&
          (isEnabledFn('invoices') || isEnabledFn('estimates'))) {
        logicalIndex++;
      }
    }
    return indices;
  }
}

/// Represents a configurable app module.
class AppModule {
  /// Module ID (matches API's enabledModules array)
  final String id;

  /// Human-readable display name
  final String displayName;

  /// Route paths that belong to this module
  final List<String> routePaths;

  /// Index in bottom navigation (if applicable)
  final int? navTabIndex;

  /// Index in Directory options sheet (if applicable)
  final int? directoryIndex;

  /// Index in Utilities screen grid (if applicable)
  final int? utilityIndex;

  const AppModule({
    required this.id,
    required this.displayName,
    required this.routePaths,
    this.navTabIndex,
    this.directoryIndex,
    this.utilityIndex,
  });
}
