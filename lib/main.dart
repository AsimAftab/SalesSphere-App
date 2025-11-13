import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'app.dart';
import 'core/utils/logger.dart';
import 'core/network_layer/token_storage_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'core/providers/shared_prefs_provider.dart';


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

  // Initialize SharedPreferences
  final SharedPreferences prefs;
  try {
    prefs = await SharedPreferences.getInstance();
    AppLogger.i('✅ SharedPreferences initialized');
  } catch (e) {
    AppLogger.e('❌ Failed to initialize SharedPreferences', e);
    rethrow; // Re-throw if prefs fail, app can't run
  }

  // Note: Sentry automatically handles FlutterError.onError
  // We only need to log locally in debug mode
  if (kDebugMode) {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
      AppLogger.e('🚨 Flutter Error', details.exception, details.stack);
    };
  }

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

  await SentryFlutter.init(
        (options) {
      // Load DSN from environment variables
      options.dsn = dotenv.env['SENTRY_DSN'] ?? '';

      // Environment-dependent configuration
      if (kDebugMode) {
        // Debug mode: capture all errors for testing
        options.tracesSampleRate = 1.0;
        options.profilesSampleRate = 1.0;
      } else {
        // Production mode: sample to reduce overhead and costs
        options.tracesSampleRate = 0.2; // 20% of transactions
        options.profilesSampleRate = 0.2; // 20% of profiled transactions
      }

      // Set environment
      options.environment = kDebugMode ? 'debug' : (kReleaseMode ? 'production' : 'profile');

      // Enable automatic breadcrumbs
      options.enableAutoSessionTracking = true;
      options.attachThreads = true;
      options.attachScreenshot = true;
      options.screenshotQuality = SentryScreenshotQuality.low;
      options.attachViewHierarchy = true;
    },
    appRunner: () => runApp(SentryWidget(child:
    // --- MODIFIED ProviderScope ---
    ProviderScope(
      observers: [
        if (kDebugMode) const LoggerProviderObserver(),
      ],
      // ADDED 'overrides'
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
    )),
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
