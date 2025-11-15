import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/services/location_tracking_service.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'location_tracking_provider.g.dart';

/// Location Tracking Service Provider
/// Provides access to the singleton location tracking service
@riverpod
LocationTrackingService locationTrackingService(Ref ref) {
  final service = LocationTrackingService.instance;

  // Cleanup when provider is disposed
  ref.onDispose(() {
    AppLogger.d('Disposing LocationTrackingService provider');
    service.dispose();
  });

  return service;
}

/// Location Stream Provider
/// Streams location updates from the tracking service
@riverpod
Stream<LocationUpdate> locationStream(Ref ref) {
  final service = ref.watch(locationTrackingServiceProvider);

  return service.locationStream;
}

/// Current Location Provider
/// Provides the last known location
@riverpod
LocationUpdate? currentLocation(Ref ref) {
  // This will be updated by listening to the location stream
  return null; // Initial value
}

/// Tracking Status Provider
/// Indicates if location tracking is currently active
@riverpod
class TrackingStatus extends _$TrackingStatus {
  @override
  bool build() {
    final service = ref.watch(locationTrackingServiceProvider);
    return service.isTracking;
  }

  /// Update tracking status
  void update(bool isTracking) {
    state = isTracking;
  }
}
