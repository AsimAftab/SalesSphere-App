import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/route_handler.dart';
import 'core/theme/theme.dart';
import 'core/providers/app_startup.dart';
import 'core/utils/connectivity_utils.dart';
import 'widget/no_internet_screen.dart';
import 'widget/loading_screen.dart';
import 'features/catalog/vm/catalog.vm.dart';
import 'features/catalog/vm/catalog_item.vm.dart';
import 'features/home/vm/home.vm.dart';
import 'features/invoice/vm/invoice.vm.dart';
import 'features/parties/vm/parties.vm.dart';
import 'features/profile/vm/profile.vm.dart';
import 'features/prospects/vm/prospects.vm.dart';
import 'features/sites/vm/sites.vm.dart';
import 'features/attendance/vm/attendance.vm.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch app startup to ensure initialization completes before showing app
    final appStartupState = ref.watch(appStartupProvider);

    // Wait for initialization to complete
    return appStartupState.when(
      // Loading: Show loading screen during startup
      loading: () => MaterialApp(
        title: 'Sales Sphere',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoadingScreen(),
      ),

      // Data: Check internet connectivity
      data: (startupState) {
        // No internet connection
        if (!startupState.hasInternet) {
          return MaterialApp(
            title: 'Sales Sphere',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const NoInternetScreen(),
          );
        }

        // Has internet, show normal app
        return _buildApp(ref);
      },

      // Error: Show app anyway (fail gracefully)
      error: (_, __) => _buildApp(ref),
    );
  }

  Widget _buildApp(WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Sales Sphere',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,

      // Text scaling limiter + Global connectivity overlay
      builder: (_, child) => MediaQuery.withClampedTextScaling(
        minScaleFactor: 0.8,
        maxScaleFactor: 1.3,
        child: GlobalConnectivityWrapper(
          onConnectivityRestored: _invalidateAllProviders,
          child: child!,
        ),
      ),
    );
  }

  /// Invalidate all data providers when connectivity returns
  /// This ensures fresh data after reconnection
  void _invalidateAllProviders(WidgetRef ref) {
    // Catalog
    ref.invalidate(catalogViewModelProvider);
    ref.invalidate(allCatalogItemsProvider);

    // Home
    ref.invalidate(homeViewModelProvider);

    // Parties
    ref.invalidate(partiesViewModelProvider);

    // Invoice
    ref.invalidate(invoiceHistoryProvider);

    // Prospects
    ref.invalidate(prospectViewModelProvider);

    // Sites
    ref.invalidate(siteViewModelProvider);

    // Attendance
    ref.invalidate(todayAttendanceViewModelProvider);
    ref.invalidate(monthlyAttendanceReportViewModelProvider);

    // Profile (if needed)
    ref.invalidate(profileViewModelProvider);
  }
}