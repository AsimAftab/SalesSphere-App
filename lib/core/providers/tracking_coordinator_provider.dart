import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/services/tracking_coordinator.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'tracking_coordinator_provider.g.dart';

/// Tracking Coordinator Service Provider
/// Provides access to the singleton tracking coordinator
/// NOTE: keepAlive is required to prevent stream controllers from being closed
@Riverpod(keepAlive: true)
TrackingCoordinator trackingCoordinator(Ref ref) {
  final coordinator = TrackingCoordinator.instance;

  // Cleanup when provider is disposed
  ref.onDispose(() {
    AppLogger.d('Disposing TrackingCoordinator provider');
    coordinator.dispose();
  });

  return coordinator;
}

/// Tracking State Stream Provider
/// Streams the current tracking state (idle, active, paused, etc.)
@riverpod
Stream<TrackingState> trackingStateStream(Ref ref) {
  final coordinator = ref.watch(trackingCoordinatorProvider);
  return coordinator.onStateChanged;
}

/// Tracking Stats Stream Provider
/// Streams tracking statistics (duration, queue, connectivity, etc.)
@riverpod
Stream<TrackingStats> trackingStatsStream(Ref ref) {
  final coordinator = ref.watch(trackingCoordinatorProvider);
  return coordinator.onStatsChanged;
}

/// Current Tracking State Provider
/// Provides the current tracking state
@riverpod
class CurrentTrackingState extends _$CurrentTrackingState {
  @override
  TrackingState build() {
    return TrackingState.idle;
  }

  /// Update tracking state
  void update(TrackingState state) {
    this.state = state;
  }
}

/// Is Tracking Provider
/// Simple boolean provider indicating if tracking is active
@riverpod
class IsTracking extends _$IsTracking {
  @override
  bool build() {
    final coordinator = ref.watch(trackingCoordinatorProvider);
    return coordinator.isTracking;
  }

  /// Update tracking status
  void update(bool isTracking) {
    state = isTracking;
  }
}

/// Current Beat Plan ID Provider
/// Provides the ID of the currently tracked beat plan
@riverpod
class CurrentBeatPlanId extends _$CurrentBeatPlanId {
  @override
  String? build() {
    final coordinator = ref.watch(trackingCoordinatorProvider);
    return coordinator.currentBeatPlanId;
  }

  /// Update beat plan ID
  void update(String? beatPlanId) {
    state = beatPlanId;
  }
}
