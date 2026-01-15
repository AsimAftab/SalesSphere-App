import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/services/tracking_socket_service.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'tracking_socket_provider.g.dart';

/// Tracking Socket Service Provider
/// Provides access to the singleton tracking socket service
/// NOTE: keepAlive is required to prevent service from being disposed during navigation
@Riverpod(keepAlive: true)
TrackingSocketService trackingSocketService(Ref ref) {
  final service = TrackingSocketService.instance;

  // Cleanup when provider is disposed (only on logout/app shutdown)
  ref.onDispose(() {
    AppLogger.d('Disposing TrackingSocketService provider');
    // Don't dispose singleton - only dispose on logout/app shutdown
    // service.dispose() is now called only when explicitly stopping tracking
  });

  return service;
}

/// Socket Connection Status Provider
/// Indicates if socket is currently connected
@riverpod
class SocketConnectionStatus extends _$SocketConnectionStatus {
  @override
  bool build() {
    final service = ref.watch(trackingSocketServiceProvider);
    return service.isConnected;
  }

  /// Update connection status
  void update(bool isConnected) {
    state = isConnected;
  }
}

/// Tracking Started Event Stream Provider
@riverpod
Stream<TrackingStartedEvent> trackingStartedStream(Ref ref) {
  final service = ref.watch(trackingSocketServiceProvider);
  return service.onTrackingStarted;
}

/// Location Update Event Stream Provider
@riverpod
Stream<LocationUpdateEvent> locationUpdateStream(Ref ref) {
  final service = ref.watch(trackingSocketServiceProvider);
  return service.onLocationUpdate;
}

/// Tracking Status Update Event Stream Provider
@riverpod
Stream<TrackingStatusUpdateEvent> trackingStatusUpdateStream(Ref ref) {
  final service = ref.watch(trackingSocketServiceProvider);
  return service.onStatusUpdate;
}

/// Tracking Stopped Event Stream Provider
@riverpod
Stream<TrackingStoppedEvent> trackingStoppedStream(Ref ref) {
  final service = ref.watch(trackingSocketServiceProvider);
  return service.onTrackingStopped;
}

/// Tracking Error Stream Provider
@riverpod
Stream<String> trackingErrorStream(Ref ref) {
  final service = ref.watch(trackingSocketServiceProvider);
  return service.onError;
}
