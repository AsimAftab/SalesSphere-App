import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/services/offline_queue_service.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'offline_queue_provider.g.dart';

/// Offline Queue Service Provider
/// Provides access to the singleton offline queue service
@riverpod
OfflineQueueService offlineQueueService(Ref ref) {
  final service = OfflineQueueService.instance;

  // Cleanup when provider is disposed
  ref.onDispose(() {
    AppLogger.d('Disposing OfflineQueueService provider');
    service.dispose();
  });

  return service;
}

/// Queue Count Stream Provider
/// Streams the current count of pending locations in the queue
@riverpod
Stream<int> queueCountStream(Ref ref) {
  final service = ref.watch(offlineQueueServiceProvider);
  return service.onQueueCountChanged;
}

/// Queue Statistics Provider
/// Provides current queue statistics (total, pending, synced, failed)
@riverpod
class QueueStats extends _$QueueStats {
  @override
  Map<String, dynamic> build() {
    final service = ref.watch(offlineQueueServiceProvider);
    return service.getStats();
  }

  /// Refresh statistics
  void refresh() {
    final service = ref.read(offlineQueueServiceProvider);
    state = service.getStats();
  }
}

/// Sync Status Provider
/// Indicates if queue sync is currently in progress
@riverpod
class SyncStatus extends _$SyncStatus {
  @override
  bool build() {
    final service = ref.watch(offlineQueueServiceProvider);
    return service.isSyncing;
  }

  /// Update sync status
  void update(bool isSyncing) {
    state = isSyncing;
  }
}
