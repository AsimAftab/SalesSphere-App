import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/route_handler.dart';
import 'core/theme/theme.dart';
import 'core/providers/app_startup.dart';
import 'core/providers/provider_registry.dart';
import 'core/utils/connectivity_utils.dart';
import 'widget/no_internet_screen.dart';
import 'widget/loading_screen.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize app startup in background (don't block UI)
    ref.watch(appStartupProvider);

    // Show app immediately with splash screen
    // App startup checks will happen in background during splash
    return _buildApp(ref);
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
          onConnectivityRestored: ProviderRegistry.invalidateAll,
          child: child!,
        ),
      ),
    );
  }
}