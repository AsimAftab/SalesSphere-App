import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sales_sphere/core/models/location_address.dart';
import 'package:sales_sphere/core/models/queued_location.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Background Tracking Service
/// Manages background location tracking using flutter_background_service
/// Keeps tracking alive even when app is minimized or screen is locked
@pragma('vm:entry-point')
class BackgroundTrackingService {
  BackgroundTrackingService._();

  static final BackgroundTrackingService instance =
      BackgroundTrackingService._();

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
  static const String _keyTotalDirectories = 'totalDirectories';
  static const String _keyVisitedDirectories = 'visitedDirectories';

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
          initialNotificationTitle: 'Beat Plan Tracking Active',
          initialNotificationContent:
              'Your location is being tracked. Do not close this app until all visits are complete.',
          foregroundServiceNotificationId: _notificationId,
          autoStartOnBoot: false, // Don't start on device boot
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
  Future<void> startTracking(
    String beatPlanId, {
    int totalDirectories = 0,
    int visitedDirectories = 0,
  }) async {
    try {
      AppLogger.i('🎯 Starting background tracking for beat plan: $beatPlanId');

      // Store beat plan ID, tracking flag, and progress in SharedPreferences for background isolate
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyBeatPlanId, beatPlanId);
      await prefs.setBool(_keyIsTracking, true); // Set tracking flag!
      await prefs.setInt(_keyTotalDirectories, totalDirectories);
      await prefs.setInt(_keyVisitedDirectories, visitedDirectories);

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

  /// Update visit progress (when user marks a directory as visited or skipped)
  Future<void> updateProgress(
    int visitedDirectories, {
    int skippedDirectories = 0,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyVisitedDirectories, visitedDirectories);

      // Store skipped directories count for notification display
      await prefs.setInt('skippedDirectories', skippedDirectories);

      // Notify background service to update notification
      _service.invoke('updateProgress', {
        'visitedDirectories': visitedDirectories,
        'skippedDirectories': skippedDirectories,
      });
    } catch (e) {
      AppLogger.e('❌ Error updating progress: $e');
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

  /// Perform reverse geocoding to get address from coordinates
  /// Returns null if geocoding fails (to avoid blocking location tracking)
  static Future<Map<String, dynamic>?> _reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              AppLogger.w('⚠️ Reverse geocoding timeout');
              return <Placemark>[];
            },
          );

      if (placemarks.isEmpty) {
        AppLogger.d('📍 No address found for location');
        return null;
      }

      final placemark = placemarks.first;
      final address = LocationAddress.fromPlacemark(placemark);

      AppLogger.d(
        '📍 Reverse geocoded: ${address.formattedAddress ?? "Unknown"}',
      );

      return address.toJson();
    } catch (e) {
      AppLogger.e('❌ Reverse geocoding error: $e');
      return null; // Don't block location tracking if geocoding fails
    }
  }

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
    String? currentAddress;
    int totalDirectories = 0;
    int visitedDirectories = 0;
    int skippedDirectories = 0;

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

    // Get beat plan ID and progress from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    beatPlanId = prefs.getString(_keyBeatPlanId);
    totalDirectories = prefs.getInt(_keyTotalDirectories) ?? 0;
    visitedDirectories = prefs.getInt(_keyVisitedDirectories) ?? 0;
    skippedDirectories = prefs.getInt('skippedDirectories') ?? 0;

    if (beatPlanId == null) {
      AppLogger.e('❌ No beat plan ID found, stopping service');
      await locationBox?.close();
      service.stopSelf();
      return;
    }

    AppLogger.i(
      '📊 Starting tracking with progress: $visitedDirectories/$totalDirectories',
    );

    // Ensure tracking flag is set
    await prefs.setBool(_keyIsTracking, true);

    // Start tracking
    startTime = DateTime.now();
    isTracking = true;

    // Start location tracking (no timeout - runs continuously)
    positionSubscription =
        Geolocator.getPositionStream(
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

            // STEP 1: Reverse geocode to get address (non-blocking)
            Map<String, dynamic>? address;
            try {
              address = await _reverseGeocode(
                latitude: position.latitude,
                longitude: position.longitude,
              );

              // Update current address for notification
              if (address != null && address['formattedAddress'] != null) {
                currentAddress = address['formattedAddress'] as String;
              }
            } catch (e) {
              AppLogger.w('⚠️ Skipping reverse geocoding: $e');
              address = null; // Continue without address if geocoding fails
            }

            // STEP 2: Save to Hive first (ALWAYS works, even offline)
            try {
              if (locationBox != null) {
                final queuedLocation = QueuedLocation.fromLocationUpdate(
                  beatPlanId: beatPlanId!,
                  latitude: position.latitude,
                  longitude: position.longitude,
                  accuracy: position.accuracy,
                  speed: position.speed,
                  heading: position.heading,
                  address: address, // Include address
                );
                await locationBox.add(queuedLocation);
                AppLogger.d(
                  '💾 Location saved to Hive queue (with address: ${address != null})',
                );
              }
            } catch (e) {
              AppLogger.e('❌ Error saving to Hive: $e');
            }

            // STEP 3: Update notification with rich information (like Uber)
            await _updateNotification(
              notificationPlugin,
              beatPlanId: beatPlanId!,
              distance: totalDistance,
              duration: duration,
              currentAddress: currentAddress,
              totalDirectories: totalDirectories,
              visitedDirectories: visitedDirectories,
            );

            // STEP 4: Send update to main app (will try to send to server)
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
              if (address != null) 'address': address, // Include address
            });

            AppLogger.d(
              '📍 Background location: ${position.latitude}, ${position.longitude} ${address != null ? "(with address)" : ""}',
            );
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

    service.on('updateProgress').listen((event) async {
      AppLogger.i('📊 Received progress update');

      if (event != null && event is Map) {
        final newVisitedCount = event['visitedDirectories'] as int?;
        final newSkippedCount = event['skippedDirectories'] as int? ?? 0;

        if (newVisitedCount != null) {
          visitedDirectories = newVisitedCount;

          // Also update skipped count if provided
          if (newSkippedCount > 0) {
            skippedDirectories = newSkippedCount;
            await prefs.setInt('skippedDirectories', skippedDirectories);
          }

          // Update notification immediately to show new progress
          if (startTime != null) {
            final duration = DateTime.now().difference(startTime!);

            await _updateNotification(
              notificationPlugin,
              beatPlanId: beatPlanId!,
              distance: totalDistance,
              duration: duration,
              currentAddress: currentAddress,
              totalDirectories: totalDirectories,
              visitedDirectories: visitedDirectories,
              skippedDirectories: skippedDirectories,
            );

            final totalProcessed = visitedDirectories + skippedDirectories;
            AppLogger.i(
              '✅ Notification updated: $visitedDirectories visited, $skippedDirectories skipped / $totalDirectories total ($totalProcessed processed)',
            );
          }
        }
      }
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
        InitializationSettings(android: initializationSettingsAndroid);

    await plugin.initialize(initializationSettings);

    // Create notification channel with MAX importance to prevent dismissal (Uber-like)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Ongoing beat plan tracking notification',
      importance: Importance.max, // MAX importance - truly non-dismissible
      playSound: false,
      enableVibration: false,
    );

    await plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Update tracking notification with Uber-like rich information
  static Future<void> _updateNotification(
    FlutterLocalNotificationsPlugin plugin, {
    required String beatPlanId,
    required double distance,
    required Duration duration,
    String? currentAddress,
    int totalDirectories = 0,
    int visitedDirectories = 0,
    int skippedDirectories = 0,
  }) async {
    final distanceKm = (distance / 1000).toStringAsFixed(2);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final durationStr = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

    // Calculate progress percentage (visited + skipped)
    final totalProcessed = visitedDirectories + skippedDirectories;
    final progressPercent = totalDirectories > 0
        ? ((totalProcessed / totalDirectories) * 100).toInt()
        : 0;

    // Build notification title with visited + skipped
    final title = totalDirectories > 0
        ? 'Beat Plan Tracking ($visitedDirectories visited, $skippedDirectories skipped / $totalDirectories total)'
        : 'Beat Plan Tracking Active';

    // Build notification content
    final content = currentAddress != null
        ? '📍 $currentAddress\n$distanceKm km • $durationStr'
        : '📍 Tracking your location\n$distanceKm km • $durationStr';

    // Build expanded content with utilities details
    final bigText =
        '''
📍 Current Location: ${currentAddress ?? 'Getting location...'}

📊 Progress: $visitedDirectories visited, $skippedDirectories skipped / $totalDirectories total ($progressPercent%)
🚗 Distance Traveled: $distanceKm km
⏱️ Duration: $durationStr

⚠️ Keep tracking active until all visits are complete.
Do not force close this app.
''';

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Real-time beat plan tracking - Keep this active',
          importance: Importance.max,
          // MAX importance for Uber-like non-dismissible notification
          priority: Priority.high,
          // High priority
          ongoing: true,
          // Cannot be dismissed by user
          autoCancel: false,
          playSound: false,
          enableVibration: false,
          showWhen: true,
          when: DateTime.now().millisecondsSinceEpoch,
          usesChronometer: true,
          // Shows elapsed time
          chronometerCountDown: false,
          icon: '@mipmap/ic_launcher',
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          styleInformation: BigTextStyleInformation(
            bigText,
            contentTitle: title,
            summaryText: 'SalesSphere Location Tracking',
            htmlFormatBigText: false,
            htmlFormatContentTitle: false,
          ),
          // Show progress if available
          showProgress: totalDirectories > 0,
          maxProgress: totalDirectories,
          progress: totalProcessed, // Show total processed (visited + skipped)
          indeterminate: false,
          // Make it sticky and high priority
          category: AndroidNotificationCategory.navigation,
          visibility: NotificationVisibility.public,
          ticker: 'Beat Plan Tracking Active',
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await plugin.show(_notificationId, title, content, notificationDetails);
  }
}
