import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'core/utils/logger.dart';
import 'core/network_layer/token_storage_service.dart';

/// Riverpod 3.0 ProviderObserver for logging provider lifecycle
final class LoggerProviderObserver extends ProviderObserver {
  const LoggerProviderObserver();

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    final providerName = context.provider.name ?? context.provider.runtimeType.toString();
    AppLogger.d('➕ Provider added: $providerName');
  }

  @override
  void didUpdateProvider(ProviderObserverContext context, Object? previousValue, Object? newValue) {
    final providerName = context.provider.name ?? context.provider.runtimeType.toString();
    AppLogger.i('🔄 Provider updated: $providerName');
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    final providerName = context.provider.name ?? context.provider.runtimeType.toString();
    AppLogger.d('🗑️ Provider disposed: $providerName');
  }

  @override
  void providerDidFail(ProviderObserverContext context, Object error, StackTrace stackTrace) {
    final providerName = context.provider.name ?? context.provider.runtimeType.toString();
    AppLogger.e('❌ Provider failed: $providerName', error, stackTrace);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    AppLogger.i('✅ Environment variables loaded');
  } catch (e) {
    AppLogger.w('⚠️ Failed to load .env file: $e');
  }

  // Initialize token storage service
  try {
    final tokenStorage = TokenStorageService();
    await tokenStorage.init();
    AppLogger.i('✅ Token storage initialized');
  } catch (e) {
    AppLogger.e('❌ Failed to initialize token storage', e);
  }

  // Global Flutter error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    AppLogger.e('🚨 Flutter Error', details.exception, details.stack);
  };

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Lock portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Log build mode
  if (kDebugMode) {
    AppLogger.i('🐛 Running in DEBUG mode');
  } else if (kReleaseMode) {
    AppLogger.i('🚀 Running in RELEASE mode');
  }

  runApp(
    const ProviderScope(
      observers: [
        if (kDebugMode) LoggerProviderObserver(),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800), // Base design size from your Figma/XD
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => child!,
      child: const App(), // Your main App widget with GoRouter or MaterialApp
    );
  }
}
