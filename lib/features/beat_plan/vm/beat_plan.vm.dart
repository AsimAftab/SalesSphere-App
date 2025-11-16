import 'dart:async';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/core/services/tracking_coordinator.dart';
import '../models/beat_plan.models.dart';

part 'beat_plan.vm.g.dart';

// ============================================================================
// BEAT PLAN LIST VIEW MODEL
// Handles: Fetch beat plan summaries (minimal data for cards)
// ============================================================================

@riverpod
class BeatPlanListViewModel extends _$BeatPlanListViewModel {
  bool _isFetching = false;

  @override
  Future<List<BeatPlanSummary>> build() async {
    // Keep alive for 60 seconds (prevents disposal on tab switch)
    final link = ref.keepAlive();
    Timer(const Duration(seconds: 60), () {
      link.close();
    });

    // Fetch beat plan summaries - Global wrapper handles connectivity
    return _fetchBeatPlans();
  }

  /// Fetch beat plan summaries from API
  Future<List<BeatPlanSummary>> _fetchBeatPlans() async {
    // Guard: prevent concurrent fetches - wait for current request to complete
    if (_isFetching) {
      AppLogger.w('⚠️ Already fetching beat plans, waiting for current request');
      // Wait for current fetch to complete
      while (_isFetching) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      // Return current state after wait
      return state.hasValue ? state.requireValue : [];
    }

    _isFetching = true;
    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i('🔄 Fetching beat plan summaries from API...');

      final response = await dio.get(ApiEndpoints.myBeatPlans);

      if (response.statusCode == 200) {
        // Parse the API response
        final beatPlanResponse = BeatPlanSummaryResponse.fromJson(response.data);

        AppLogger.i('✅ Beat plan summaries loaded: ${beatPlanResponse.data.length} plans');

        return beatPlanResponse.data;
      } else {
        throw Exception('Failed to fetch beat plans: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error fetching beat plans: ${e.message}');
      if (e.response != null) {
        AppLogger.e('Response data: ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e, stack) {
      AppLogger.e('❌ Unexpected error fetching beat plans: $e');
      AppLogger.e('Stack trace: $stack');
      throw Exception('Failed to load beat plans: $e');
    } finally {
      _isFetching = false;
    }
  }

  /// Refresh beat plans
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final beatPlans = await _fetchBeatPlans();
      state = AsyncData(beatPlans);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  /// Start a beat plan
  ///
  /// Parameters:
  /// - beatPlanId: The ID of the beat plan to start
  ///
  /// Returns: true if successful, false otherwise
  Future<bool> startBeatPlan(String beatPlanId) async {
    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i('Starting beat plan $beatPlanId');

      final response = await dio.post(
        ApiEndpoints.startBeatPlan(beatPlanId),
      );

      if (response.statusCode == 200) {
        AppLogger.i('✅ Beat plan started successfully on server');

        // Get beat plan details to extract progress info
        int totalDirectories = 0;
        int visitedDirectories = 0;

        try {
          // Fetch details to get directory counts
          final detailsResponse = await dio.get(ApiEndpoints.beatPlanDetails(beatPlanId));
          if (detailsResponse.statusCode == 200) {
            final details = BeatPlanDetailResponse.fromJson(detailsResponse.data);
            totalDirectories = details.data.progress.totalDirectories;
            visitedDirectories = details.data.progress.visitedDirectories;
            AppLogger.d('📊 Progress: $visitedDirectories/$totalDirectories directories');
          }
        } catch (e) {
          AppLogger.w('⚠️ Could not fetch progress details: $e');
        }

        // Start real-time tracking with progress info
        try {
          AppLogger.i('🎯 Starting real-time tracking...');
          await TrackingCoordinator.instance.startTracking(
            beatPlanId,
            totalDirectories: totalDirectories,
            visitedDirectories: visitedDirectories,
          );
          AppLogger.i('✅ Real-time tracking started');
        } catch (trackingError) {
          AppLogger.e('❌ Failed to start tracking: $trackingError');
          // Continue even if tracking fails - beat plan is still started on server
        }

        // Refresh the beat plan list to get updated status
        await refresh();
        return true;
      } else {
        throw Exception('Failed to start beat plan: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error starting beat plan: ${e.message}');
      if (e.response != null) {
        AppLogger.e('Response data: ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e, stack) {
      AppLogger.e('❌ Error starting beat plan: $e');
      AppLogger.e('Stack trace: $stack');
      throw Exception('Failed to start beat plan: $e');
    }
  }
}

// ============================================================================
// BEAT PLAN DETAIL VIEW MODEL
// Handles: Fetch full beat plan details when opening a card
// ============================================================================

@riverpod
class BeatPlanDetailViewModel extends _$BeatPlanDetailViewModel {
  bool _isFetching = false;

  @override
  Future<BeatPlanDetail?> build(String beatPlanId) async {
    // Keep alive for 60 seconds
    final link = ref.keepAlive();
    Timer(const Duration(seconds: 60), () {
      link.close();
    });

    // Fetch beat plan details
    return _fetchBeatPlanDetails(beatPlanId);
  }

  /// Fetch beat plan details from API
  Future<BeatPlanDetail?> _fetchBeatPlanDetails(String beatPlanId) async {
    // Guard: prevent concurrent fetches - return null instead of throwing
    if (_isFetching) {
      AppLogger.w('⚠️ Already fetching beat plan details, waiting for current request');
      // Wait for current fetch to complete
      while (_isFetching) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      // Return current state after wait
      return state.hasValue ? state.requireValue : null;
    }

    _isFetching = true;
    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i('🔄 Fetching beat plan details for ID: $beatPlanId');

      final response = await dio.get(ApiEndpoints.beatPlanDetails(beatPlanId));

      if (response.statusCode == 200) {
        // Parse the API response
        final beatPlanResponse = BeatPlanDetailResponse.fromJson(response.data);

        AppLogger.i('✅ Beat plan details loaded: ${beatPlanResponse.data.name}');
        AppLogger.d('📊 Directories: ${beatPlanResponse.data.directories.length} (${beatPlanResponse.data.progress.totalParties} parties, ${beatPlanResponse.data.progress.totalSites} sites, ${beatPlanResponse.data.progress.totalProspects} prospects), Progress: ${beatPlanResponse.data.progress.percentage}%');

        return beatPlanResponse.data;
      } else {
        throw Exception('Failed to fetch beat plan details: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error fetching beat plan details: ${e.message}');
      if (e.response != null) {
        AppLogger.e('Response data: ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e, stack) {
      AppLogger.e('❌ Unexpected error fetching beat plan details: $e');
      AppLogger.e('Stack trace: $stack');
      throw Exception('Failed to load beat plan details: $e');
    } finally {
      _isFetching = false;
    }
  }

  /// Refresh beat plan details
  Future<void> refresh(String beatPlanId) async {
    state = const AsyncLoading();
    try {
      final beatPlan = await _fetchBeatPlanDetails(beatPlanId);
      state = AsyncData(beatPlan);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  /// Mark a party visit as complete with geofencing
  ///
  /// Parameters:
  /// - beatPlanId: The ID of the beat plan
  /// - directoryId: The ID of the directory (party/site/prospect) to mark as visited
  /// - directoryType: The type of directory ('party', 'site', 'prospect')
  /// - userLatitude: User's current latitude (for geofencing validation)
  /// - userLongitude: User's current longitude (for geofencing validation)
  ///
  /// Returns: true if successful, false otherwise
  Future<bool> markVisitComplete(
    String beatPlanId,
    String directoryId, {
    String directoryType = 'party',
    required double userLatitude,
    required double userLongitude,
  }) async {
    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i('Marking $directoryType $directoryId as visited for beat plan $beatPlanId');
      AppLogger.i('📍 User location: $userLatitude, $userLongitude');

      final requestBody = {
        'directoryId': directoryId,
        'directoryType': directoryType,
        'latitude': userLatitude,
        'longitude': userLongitude,
      };

      final response = await dio.post(
        ApiEndpoints.markVisit(beatPlanId),
        data: requestBody,
      );

      if (response.statusCode == 200) {
        AppLogger.i('✅ Visit marked as complete');

        // Refresh beat plan details to get updated data
        if (ref.mounted) {
          await refresh(beatPlanId);

          // Update tracking notification with new progress
          try {
            // Get updated progress from refreshed state
            if (state.hasValue && state.value != null) {
              final visitedCount = state.value!.progress.visitedDirectories;
              await TrackingCoordinator.instance.updateVisitProgress(visitedCount);
              AppLogger.i('📊 Tracking notification updated with progress');
            }
          } catch (e) {
            AppLogger.w('⚠️ Could not update tracking progress: $e');
          }
        }
        return true;
      } else {
        throw Exception('Failed to mark visit as complete: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error marking visit as complete: ${e.message}');
      if (e.response != null) {
        AppLogger.e('Response data: ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e, stack) {
      AppLogger.e('❌ Error marking visit as complete: $e');
      AppLogger.e('Stack trace: $stack');
      throw Exception('Failed to mark visit as complete: $e');
    }
  }

  /// Mark a party visit as pending
  ///
  /// Parameters:
  /// - beatPlanId: The ID of the beat plan
  /// - visitId: The ID of the visit to mark as pending
  ///
  /// Returns: true if successful, false otherwise
  Future<bool> markVisitPending(String beatPlanId, String visitId) async {
    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i('Marking visit $visitId as pending for beat plan $beatPlanId');

      final response = await dio.put(
        ApiEndpoints.markVisitPending(beatPlanId, visitId),
      );

      if (response.statusCode == 200) {
        AppLogger.i('✅ Visit marked as pending');

        // Refresh beat plan details to get updated data
        if (ref.mounted) {
          await refresh(beatPlanId);

          // Update tracking notification with new progress
          try {
            // Get updated progress from refreshed state
            if (state.hasValue && state.value != null) {
              final visitedCount = state.value!.progress.visitedDirectories;
              await TrackingCoordinator.instance.updateVisitProgress(visitedCount);
              AppLogger.i('📊 Tracking notification updated with progress');
            }
          } catch (e) {
            AppLogger.w('⚠️ Could not update tracking progress: $e');
          }
        }
        return true;
      } else {
        throw Exception('Failed to mark visit as pending: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error marking visit as pending: ${e.message}');
      if (e.response != null) {
        AppLogger.e('Response data: ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e, stack) {
      AppLogger.e('❌ Error marking visit as pending: $e');
      AppLogger.e('Stack trace: $stack');
      throw Exception('Failed to mark visit as pending: $e');
    }
  }

  // TODO: Future WebSocket integration for real-time tracking
  // Stream<BeatPlan> watchBeatPlan(String beatPlanId) { ... }
}
