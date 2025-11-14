import 'dart:async';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/utils/logger.dart';
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
    // Guard: prevent concurrent fetches
    if (_isFetching) {
      AppLogger.w('⚠️ Already fetching beat plans, skipping duplicate request');
      throw Exception('Fetch already in progress');
    }

    _isFetching = true;
    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i('Fetching beat plan summaries from API...');

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
    // Guard: prevent concurrent fetches
    if (_isFetching) {
      AppLogger.w('⚠️ Already fetching beat plan details, skipping duplicate request');
      throw Exception('Fetch already in progress');
    }

    _isFetching = true;
    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i('Fetching beat plan details for ID: $beatPlanId');

      final response = await dio.get(ApiEndpoints.beatPlanDetails(beatPlanId));

      if (response.statusCode == 200) {
        // Parse the API response
        final beatPlanResponse = BeatPlanDetailResponse.fromJson(response.data);

        AppLogger.i('✅ Beat plan details loaded: ${beatPlanResponse.data.name}');
        AppLogger.d('Parties: ${beatPlanResponse.data.parties.length}, Progress: ${beatPlanResponse.data.progress.percentage}%');

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

  /// Mark a party visit as complete
  ///
  /// Parameters:
  /// - beatPlanId: The ID of the beat plan
  /// - visitId: The ID of the visit to mark as complete
  ///
  /// Returns: true if successful, false otherwise
  Future<bool> markVisitComplete(String beatPlanId, String visitId) async {
    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i('Marking visit $visitId as complete for beat plan $beatPlanId');

      final response = await dio.put(
        ApiEndpoints.markVisitComplete(beatPlanId, visitId),
      );

      if (response.statusCode == 200) {
        AppLogger.i('✅ Visit marked as complete');

        // Refresh beat plan details to get updated data
        if (ref.mounted) {
          await refresh(beatPlanId);
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
