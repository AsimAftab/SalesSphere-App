import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:sales_sphere/core/models/queued_location.dart';
import 'package:sales_sphere/core/services/tracking_socket_service.dart';
import 'package:sales_sphere/core/utils/logger.dart';

/// Offline Queue Service
/// Manages offline location queue using Hive for persistence
/// Automatically syncs queued locations when connection is available
class OfflineQueueService {
  OfflineQueueService._();

  static final OfflineQueueService instance = OfflineQueueService._();

  // Hive box for queued locations
  Box<QueuedLocation>? _locationBox;

  // Queue state
  bool _isSyncing = false;
  bool _isInitialized = false;

  // Configuration
  static const String _boxName = 'queued_locations';
  static const int _maxRetryCount = 3;
  static const int _batchSize = 10; // Sync 10 locations at a time

  // Stream controller for queue updates
  final StreamController<int> _queueCountController =
      StreamController<int>.broadcast();

  /// Get queue count stream
  Stream<int> get onQueueCountChanged => _queueCountController.stream;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Get current queue count
  int get queueCount =>
      _locationBox?.values.where((loc) => !loc.isSynced).length ?? 0;

  /// Get total count (including synced)
  int get totalCount => _locationBox?.length ?? 0;

  /// Check if sync is in progress
  bool get isSyncing => _isSyncing;

  /// Initialize Hive and open location box
  Future<void> initialize() async {
    if (_isInitialized) {
      AppLogger.w('⚠️ OfflineQueueService already initialized');
      return;
    }

    try {
      AppLogger.i('🔧 Initializing OfflineQueueService...');

      // Initialize Hive (if not already done)
      if (!Hive.isAdapterRegistered(0)) {
        final adapter = QueuedLocationAdapter();
        Hive.registerAdapter(adapter);
        AppLogger.d('Registered QueuedLocationAdapter');
      }

      // Open location box
      _locationBox = await Hive.openBox<QueuedLocation>(_boxName);
      _isInitialized = true;

      AppLogger.i('✅ OfflineQueueService initialized ($queueCount pending)');

      // Emit initial count
      _queueCountController.add(queueCount);
    } catch (e, stack) {
      AppLogger.e('❌ Error initializing OfflineQueueService: $e');
      AppLogger.e('Stack trace: $stack');
      rethrow;
    }
  }

  /// Add location to queue
  ///
  /// Stores location locally for later synchronization
  Future<void> queueLocation({
    required String beatPlanId,
    required double latitude,
    required double longitude,
    required double accuracy,
    required double speed,
    required double heading,
  }) async {
    if (!_isInitialized) {
      throw Exception('OfflineQueueService not initialized');
    }

    try {
      final location = QueuedLocation.fromLocationUpdate(
        beatPlanId: beatPlanId,
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
        speed: speed,
        heading: heading,
      );

      await _locationBox!.add(location);

      AppLogger.i('📥 Location queued: ${location.toString()}');

      // Emit updated count
      _queueCountController.add(queueCount);
    } catch (e, stack) {
      AppLogger.e('❌ Error queuing location: $e');
      AppLogger.e('Stack trace: $stack');
      rethrow;
    }
  }

  /// Sync all queued locations to server
  ///
  /// Uploads pending locations in batches via socket connection
  /// Returns number of successfully synced locations
  Future<int> syncQueue({required TrackingSocketService socketService}) async {
    if (!_isInitialized) {
      throw Exception('OfflineQueueService not initialized');
    }

    if (_isSyncing) {
      AppLogger.w('⚠️ Sync already in progress');
      return 0;
    }

    if (!socketService.isConnected) {
      AppLogger.w('⚠️ Cannot sync: Socket not connected');
      return 0;
    }

    try {
      _isSyncing = true;
      AppLogger.i('🔄 Starting queue sync ($queueCount pending)...');

      // Get all unsynced locations
      final unsyncedLocations = _locationBox!.values
          .where((loc) => !loc.isSynced && loc.retryCount < _maxRetryCount)
          .toList();

      if (unsyncedLocations.isEmpty) {
        AppLogger.i('✅ Queue is empty, nothing to sync');
        return 0;
      }

      int syncedCount = 0;

      // Process in batches
      for (int i = 0; i < unsyncedLocations.length; i += _batchSize) {
        final batch = unsyncedLocations.skip(i).take(_batchSize).toList();

        AppLogger.d(
          'Processing batch ${i ~/ _batchSize + 1} (${batch.length} locations)',
        );

        for (final location in batch) {
          try {
            // Send location update via socket (including address)
            socketService.updateLocation(
              beatPlanId: location.beatPlanId,
              latitude: location.latitude,
              longitude: location.longitude,
              accuracy: location.accuracy,
              speed: location.speed,
              heading: location.heading,
              address: location.address, // Include address
            );

            // Mark as synced
            await location.save();
            final updated = location.copyWith(isSynced: true);
            await _locationBox!.put(location.key, updated);

            syncedCount++;
            AppLogger.d(
              '✅ Synced: ${location.toString()} ${location.address != null ? "(with address)" : ""}',
            );
          } catch (e) {
            AppLogger.e('❌ Error syncing location: $e');

            // Increment retry count
            final updated = location.copyWith(
              retryCount: location.retryCount + 1,
            );
            await _locationBox!.put(location.key, updated);

            // Skip to next location
            continue;
          }
        }

        // Small delay between batches to avoid overwhelming the server
        if (i + _batchSize < unsyncedLocations.length) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      AppLogger.i(
        '✅ Queue sync completed: $syncedCount/${unsyncedLocations.length} synced',
      );

      // Emit updated count
      _queueCountController.add(queueCount);

      return syncedCount;
    } catch (e, stack) {
      AppLogger.e('❌ Error during queue sync: $e');
      AppLogger.e('Stack trace: $stack');
      return 0;
    } finally {
      _isSyncing = false;
    }
  }

  /// Clear all synced locations from queue
  ///
  /// Removes successfully synced locations to free up storage
  Future<int> clearSynced() async {
    if (!_isInitialized) {
      throw Exception('OfflineQueueService not initialized');
    }

    try {
      AppLogger.i('🗑️ Clearing synced locations...');

      final syncedKeys = _locationBox!.values
          .where((loc) => loc.isSynced)
          .map((loc) => loc.key)
          .toList();

      await _locationBox!.deleteAll(syncedKeys);

      AppLogger.i('✅ Cleared ${syncedKeys.length} synced locations');

      // Emit updated count
      _queueCountController.add(queueCount);

      return syncedKeys.length;
    } catch (e, stack) {
      AppLogger.e('❌ Error clearing synced locations: $e');
      AppLogger.e('Stack trace: $stack');
      return 0;
    }
  }

  /// Clear all locations (including unsynced)
  ///
  /// WARNING: This will delete all queued locations, including those not yet synced
  Future<void> clearAll() async {
    if (!_isInitialized) {
      throw Exception('OfflineQueueService not initialized');
    }

    try {
      AppLogger.w('⚠️ Clearing all queued locations...');

      final count = _locationBox!.length;
      await _locationBox!.clear();

      AppLogger.i('✅ Cleared all $count locations');

      // Emit updated count
      _queueCountController.add(0);
    } catch (e, stack) {
      AppLogger.e('❌ Error clearing all locations: $e');
      AppLogger.e('Stack trace: $stack');
      rethrow;
    }
  }

  /// Get all queued locations (for debugging)
  List<QueuedLocation> getAllLocations() {
    if (!_isInitialized) {
      return [];
    }

    return _locationBox!.values.toList();
  }

  /// Get pending (unsynced) locations
  List<QueuedLocation> getPendingLocations() {
    if (!_isInitialized) {
      return [];
    }

    return _locationBox!.values.where((loc) => !loc.isSynced).toList();
  }

  /// Get failed locations (reached max retry count)
  List<QueuedLocation> getFailedLocations() {
    if (!_isInitialized) {
      return [];
    }

    return _locationBox!.values
        .where((loc) => !loc.isSynced && loc.retryCount >= _maxRetryCount)
        .toList();
  }

  /// Reset retry count for failed locations
  ///
  /// Allows failed locations to be retried again
  Future<int> resetFailedLocations() async {
    if (!_isInitialized) {
      throw Exception('OfflineQueueService not initialized');
    }

    try {
      AppLogger.i('🔄 Resetting failed locations...');

      final failedLocations = getFailedLocations();

      for (final location in failedLocations) {
        final updated = location.copyWith(retryCount: 0);
        await _locationBox!.put(location.key, updated);
      }

      AppLogger.i('✅ Reset ${failedLocations.length} failed locations');

      return failedLocations.length;
    } catch (e, stack) {
      AppLogger.e('❌ Error resetting failed locations: $e');
      AppLogger.e('Stack trace: $stack');
      return 0;
    }
  }

  /// Get queue statistics
  Map<String, dynamic> getStats() {
    if (!_isInitialized) {
      return {
        'initialized': false,
        'total': 0,
        'pending': 0,
        'synced': 0,
        'failed': 0,
      };
    }

    final all = _locationBox!.values.toList();
    final pending = all.where((loc) => !loc.isSynced).length;
    final synced = all.where((loc) => loc.isSynced).length;
    final failed = all
        .where((loc) => !loc.isSynced && loc.retryCount >= _maxRetryCount)
        .length;

    return {
      'initialized': true,
      'total': all.length,
      'pending': pending,
      'synced': synced,
      'failed': failed,
      'isSyncing': _isSyncing,
    };
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _queueCountController.close();
    await _locationBox?.close();
    _isInitialized = false;
    AppLogger.d('OfflineQueueService disposed');
  }
}
