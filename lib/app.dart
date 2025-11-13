import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/route_handler.dart';
import 'core/theme/theme.dart';
import 'core/providers/app_startup.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch app startup to ensure token validation completes before showing app
    final appStartupState = ref.watch(appStartupProvider);

    // Wait for token validation to complete ONCE on startup
    return appStartupState.when(
      // Loading: Keep showing native Flutter splash (or your custom splash)
      loading: () => const SizedBox.shrink(),

      // Data/Error: Token check complete, show the app with router
      data: (_) => _buildApp(ref),
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

      // Text scaling limiter
      builder: (_, child) => MediaQuery.withClampedTextScaling(
        minScaleFactor: 0.8,
        maxScaleFactor: 1.3,
        child: child!,
      ),
    );
  }
}