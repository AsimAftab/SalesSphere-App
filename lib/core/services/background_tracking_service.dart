import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sales_sphere/core/models/queued_location.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Background Tracking Service
/// Manages background location tracking using flutter_background_service
/// Keeps tracking alive even when app is minimized or screen is locked
@pragma('vm:entry-point')
class BackgroundTrackingService {
  BackgroundTrackingService._();
  static final BackgroundTrackingService instance = BackgroundTrackingService._();

  // Service instance
  final FlutterBackgroundService _service = FlutterBackgroundService();

  // Notification channel
  static const String _channelId = 'tracking_channel';
  static const String _channelName = 'Beat Plan Tracking';
  static const int _notificationId = 888;

  // Service data keys
  static const String _keyBeatPlanId = 'beatPlanId';
  static const String _keyIsTracking = 'isTracking';
  static const String _keyTotalDistance = 'totalDistance';
  static const String _keyTotalDuration = 'totalDuration';
  static const String _keyLastUpdate = 'lastUpdate';

  /// Initialize background service
  Future<void> initialize() async {
    try {
      AppLogger.i('🔧 Initializing BackgroundTrackingService...');

      // Configure the service
      await _service.configure(
        androidConfiguration: AndroidConfiguration(
          onStart: onStart,
          autoStart: false,
          isForegroundMode: true,
          notificationChannelId: _channelId,
          initialNotificationTitle: 'Beat Plan Tracking',
          initialNotificationContent: 'Initializing tracking...',
          foregroundServiceNotificationId: _notificationId,
        ),
        iosConfiguration: IosConfiguration(
          autoStart: false,
          onForeground: onStart,
          onBackground: onIosBackground,
        ),
      );

      AppLogger.i('✅ BackgroundTrackingService initialized');
    } catch (e, stack) {
      AppLogger.e('❌ Error initializing BackgroundTrackingService: $e');
      AppLogger.e('Stack trace: $stack');
      rethrow;
    }
  }

  /// Start background tracking
  Future<void> startTracking(String beatPlanId) async {
    try {
      AppLogger.i('🎯 Starting background tracking for beat plan: $beatPlanId');

      // Store beat plan ID and tracking flag in SharedPreferences for background isolate
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyBeatPlanId, beatPlanId);
      await prefs.setBool(_keyIsTracking, true);  // Set tracking flag!

      // Start the service
      final isRunning = await _service.isRunning();
      if (!isRunning) {
        await _service.startService();
        AppLogger.i('✅ Background service started');
      } else {
        // Service already running, just resume tracking
        _service.invoke('resumeTracking');
        AppLogger.i('✅ Background tracking resumed');
      }
    } catch (e, stack) {
      AppLogger.e('❌ Error starting background tracking: $e');
      AppLogger.e('Stack trace: $stack');
      rethrow;
    }
  }

  /// Stop background tracking
  Future<void> stopTracking() async {
    try {
      AppLogger.i('🛑 Stopping background tracking...');

      // Clear tracking flag in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsTracking, false);

      final isRunning = await _service.isRunning();
      if (isRunning) {
        _service.invoke('stopTracking');
        await Future.delayed(const Duration(milliseconds: 500));
        // Service will stop itself after cleanup
      }

      AppLogger.i('✅ Background tracking stopped');
    } catch (e, stack) {
      AppLogger.e('❌ Error stopping background tracking: $e');
      AppLogger.e('Stack trace: $stack');
    }
  }

  /// Pause background tracking
  Future<void> pauseTracking() async {
    try {
      AppLogger.i('⏸️ Pausing background tracking...');

      _service.invoke('pauseTracking');

      AppLogger.i('✅ Background tracking paused');
    } catch (e) {
      AppLogger.e('❌ Error pausing background tracking: $e');
    }
  }

  /// Resume background tracking
  Future<void> resumeTracking() async {
    try {
      AppLogger.i('▶️ Resuming background tracking...');

      _service.invoke('resumeTracking');

      AppLogger.i('✅ Background tracking resumed');
    } catch (e) {
      AppLogger.e('❌ Error resuming background tracking: $e');
    }
  }

  /// Check if service is running
  Future<bool> isRunning() async {
    return await _service.isRunning();
  }

  /// Listen to service updates
  Stream<Map<String, dynamic>?> get onServiceUpdate {
    return _service.on('update');
  }

  // =========================================================================
  // BACKGROUND ISOLATE ENTRY POINTS
  // =========================================================================

  /// Main entry point for Android background service
  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    AppLogger.i('🚀 Background service started');

    // Tracking state
    bool isTracking = false;
    String? beatPlanId;
    StreamSubscription<Position>? positionSubscription;
    double totalDistance = 0.0;
    DateTime? startTime;
    Position? lastPosition;
    Box<QueuedLocation>? locationBox;

    // Initialize notification plugin
    final notificationPlugin = FlutterLocalNotificationsPlugin();
    await _initializeNotifications(notificationPlugin);

    // Initialize Hive for offline storage
    try {
      // Get application documents directory for Hive storage
      final prefs = await SharedPreferences.getInstance();
      final hivePath = prefs.getString('hivePath');

      if (hivePath != null) {
        // Initialize Hive with path
        await Hive.initFlutter(hivePath);
        AppLogger.d('Hive initialized with path: $hivePath');
      } else {
        AppLogger.e('❌ No Hive path found in SharedPreferences');
      }

      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(QueuedLocationAdapter());
        AppLogger.d('Registered QueuedLocationAdapter in background isolate');
      }
      locationBox = await Hive.openBox<QueuedLocation>('queued_locations');
      AppLogger.i('✅ Hive initialized in background isolate');
    } catch (e) {
      AppLogger.e('❌ Error initializing Hive in background: $e');
    }

    // Get beat plan ID from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    beatPlanId = prefs.getString(_keyBeatPlanId);

    if (beatPlanId == null) {
      AppLogger.e('❌ No beat plan ID found, stopping service');
      await locationBox?.close();
      service.stopSelf();
      return;
    }

    // Ensure tracking flag is set
    await prefs.setBool(_keyIsTracking, true);

    // Start tracking
    startTime = DateTime.now();
    isTracking = true;

    // Start location tracking (no timeout - runs continuously)
    positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        // No timeLimit - tracking continues indefinitely until stopped
      ),
    ).listen(
      (Position position) async {
        if (!isTracking) return;

        // Calculate distance
        if (lastPosition != null) {
          final distance = Geolocator.distanceBetween(
            lastPosition!.latitude,
            lastPosition!.longitude,
            position.latitude,
            position.longitude,
          );
          totalDistance += distance;
        }
        lastPosition = position;

        // Calculate duration
        final duration = DateTime.now().difference(startTime!);

        // STEP 1: Save to Hive first (ALWAYS works, even offline)
        try {
          if (locationBox != null) {
            final queuedLocation = QueuedLocation.fromLocationUpdate(
              beatPlanId: beatPlanId!,
              latitude: position.latitude,
              longitude: position.longitude,
              accuracy: position.accuracy,
              speed: position.speed,
              heading: position.heading,
            );
            await locationBox.add(queuedLocation);
            AppLogger.d('💾 Location saved to Hive queue');
          }
        } catch (e) {
          AppLogger.e('❌ Error saving to Hive: $e');
        }

        // STEP 2: Update notification
        await _updateNotification(
          notificationPlugin,
          beatPlanId: beatPlanId!,
          distance: totalDistance,
          duration: duration,
        );

        // STEP 3: Send update to main app (will try to send to server)
        service.invoke('update', {
          'beatPlanId': beatPlanId,
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'speed': position.speed,
          'heading': position.heading,
          'totalDistance': totalDistance,
          'totalDuration': duration.inSeconds,
          'timestamp': DateTime.now().toIso8601String(),
        });

        AppLogger.d('📍 Background location: ${position.latitude}, ${position.longitude}');
      },
      onError: (error) {
        AppLogger.e('❌ Location stream error: $error');
      },
    );

    // Listen for commands from main app
    service.on('stopTracking').listen((event) async {
      AppLogger.i('🛑 Received stop command');
      isTracking = false;
      await positionSubscription?.cancel();
      await locationBox?.close();
      AppLogger.d('Hive box closed');
      service.stopSelf();
    });

    service.on('pauseTracking').listen((event) {
      AppLogger.i('⏸️ Received pause command');
      isTracking = false;
    });

    service.on('resumeTracking').listen((event) {
      AppLogger.i('▶️ Received resume command');
      isTracking = true;
      startTime ??= DateTime.now();
    });

    // Periodic service check (every 30 seconds)
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (!isTracking) {
        timer.cancel();
        return;
      }

      AppLogger.d('⏰ Background service heartbeat');

      // Check if service should still be running
      final prefs = await SharedPreferences.getInstance();
      final shouldRun = prefs.getBool(_keyIsTracking) ?? false;

      if (!shouldRun) {
        AppLogger.i('🛑 Service should stop, shutting down');
        isTracking = false;
        await positionSubscription?.cancel();
        await locationBox?.close();
        AppLogger.d('Hive box closed');
        timer.cancel();
        service.stopSelf();
      }
    });
  }

  /// iOS background handler
  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    AppLogger.i('📱 iOS background handler called');

    return true;
  }

  /// Initialize notification channel
  static Future<void> _initializeNotifications(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await plugin.initialize(initializationSettings);

    // Create notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Ongoing beat plan tracking notification',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );

    await plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Update tracking notification
  static Future<void> _updateNotification(
    FlutterLocalNotificationsPlugin plugin, {
    required String beatPlanId,
    required double distance,
    required Duration duration,
  }) async {
    final distanceKm = (distance / 1000).toStringAsFixed(2);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final durationStr = hours > 0
        ? '${hours}h ${minutes}m'
        : '${minutes}m';

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Ongoing beat plan tracking notification',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      playSound: false,
      enableVibration: false,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await plugin.show(
      _notificationId,
      'Tracking Beat Plan',
      'Distance: $distanceKm km • Duration: $durationStr',
      notificationDetails,
    );
  }
}
