import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers/shared_prefs_provider.dart';
import 'core/services/notification_permission_service.dart';
import 'core/services/offline_queue_service.dart';
import 'core/utils/logger.dart';

/// Riverpod 3.0 ProviderObserver for logging provider lifecycle
final class LoggerProviderObserver extends ProviderObserver {
  const LoggerProviderObserver();

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    final providerName =
        context.provider.name ?? context.provider.runtimeType.toString();
    AppLogger.d('➕ Provider added: $providerName');
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    final providerName =
        context.provider.name ?? context.provider.runtimeType.toString();
    AppLogger.i('🔄 Provider updated: $providerName');
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    final providerName =
        context.provider.name ?? context.provider.runtimeType.toString();
    AppLogger.d('🗑️ Provider disposed: $providerName');
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    final providerName =
        context.provider.name ?? context.provider.runtimeType.toString();
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

  // Initialize SharedPreferences early
  final sharedPreferences = await SharedPreferences.getInstance();
  AppLogger.i('✅ SharedPreferences initialized');

  // Initialize Hive for offline storage
  try {
    await Hive.initFlutter();

    // Save Hive path to SharedPreferences for background isolate
    final hivePath = await getApplicationDocumentsDirectory();
    await sharedPreferences.setString('hivePath', hivePath.path);

    AppLogger.i('✅ Hive initialized at: ${hivePath.path}');
  } catch (e) {
    AppLogger.e('❌ Failed to initialize Hive', e);
  }

  // Initialize notification channel for tracking
  try {
    final notificationPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await notificationPlugin.initialize(initializationSettings);

    // Create notification channel for tracking (MAX importance like Uber - non-dismissible)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'tracking_channel',
      'Beat Plan Tracking',
      description:
          'Real-time beat plan tracking - Keep this notification active',
      importance: Importance.max,
      // MAX importance - truly non-dismissible
      playSound: false,
      enableVibration: false,
      showBadge: true,
    );

    await notificationPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    AppLogger.i('✅ Notification channel initialized');
  } catch (e) {
    AppLogger.e('❌ Failed to initialize notification channel', e);
  }

  // Request notification permission (Android 13+)
  try {
    final notificationPermission = NotificationPermissionService.instance;
    final hasPermission = await notificationPermission.requestPermission();

    if (hasPermission) {
      AppLogger.i('✅ Notification permission granted');
    } else {
      AppLogger.w(
        '⚠️ Notification permission denied - notifications will not work',
      );
    }
  } catch (e) {
    AppLogger.e('❌ Failed to request notification permission', e);
  }

  // Initialize offline queue service
  try {
    await OfflineQueueService.instance.initialize();
    AppLogger.i('✅ Offline queue service initialized');
  } catch (e) {
    AppLogger.e('❌ Failed to initialize offline queue service', e);
  }

  // Note: TokenStorageService is now automatically initialized via provider
  // It uses the sharedPrefsProvider which is overridden below

  // Note: TrackingCoordinator will be initialized after ProviderScope is created
  // so it can access the Dio client from the provider

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
      options.environment = kDebugMode
          ? 'debug'
          : (kReleaseMode ? 'production' : 'profile');

      // Enable automatic breadcrumbs
      options.enableAutoSessionTracking = true;
      options.attachThreads = true;
      options.attachScreenshot = true;
      options.screenshotQuality = SentryScreenshotQuality.low;
      options.attachViewHierarchy = true;
    },
    appRunner: () => runApp(
      SentryWidget(
        child: ProviderScope(
          overrides: [
            // Override the sharedPrefsProvider with the initialized instance
            sharedPrefsProvider.overrideWithValue(sharedPreferences),
          ],
          observers: [if (kDebugMode) const LoggerProviderObserver()],
          child: const MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      // Base design size from your Figma/XD
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => child!,
      child: const App(), // Your main App widget with GoRouter or MaterialApp
    );
  }
}
