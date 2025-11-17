import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/route_handler.dart';
import 'core/theme/theme.dart';
import 'core/providers/app_startup.dart';
import 'core/providers/provider_registry.dart';
import 'core/utils/connectivity_utils.dart';
import 'core/network_layer/dio_client.dart';
import 'core/services/tracking_coordinator.dart';
import 'core/utils/logger.dart';

/// Provider to initialize TrackingCoordinator with Dio client
final trackingCoordinatorInitProvider = FutureProvider<void>((ref) async {
  try {
    final dio = ref.watch(dioClientProvider);
    await TrackingCoordinator.instance.initialize(dioClient: dio);
    AppLogger.i('✅ Tracking coordinator initialized via provider');
  } catch (e) {
    AppLogger.e('❌ Failed to initialize tracking coordinator', e);
  }
});

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize app startup in background (don't block UI)
    ref.watch(appStartupProvider);

    // Initialize tracking coordinator with Dio client
    ref.watch(trackingCoordinatorInitProvider);

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