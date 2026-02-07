import 'dart:async';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/prospects/models/prospects.model.dart';

part 'prospects.vm.g.dart';

/// Main Prospects ViewModel - Manages all prospects
@riverpod
class ProspectViewModel extends _$ProspectViewModel {
  bool _isFetching = false;

  @override
  FutureOr<List<Prospects>> build() async {
    // Keep alive for 60 seconds (prevents disposal on tab switch)
    final link = ref.keepAlive();
    Timer(const Duration(seconds: 60), () {
      link.close();
    });

    // Fetch prospects - Global wrapper handles connectivity
    return _fetchProspects();
  }

  Future<List<Prospects>> _fetchProspects() async {
    // Guard: prevent concurrent fetches
    if (_isFetching) {
      AppLogger.w('⚠️ Already fetching prospects, skipping duplicate request');
      throw Exception('Fetch already in progress');
    }

    _isFetching = true;
    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.d('Fetching prospects from API');

      final response = await dio.get(ApiEndpoints.prospects);

      AppLogger.d('Prospects API response: ${response.statusCode}');

      final prospectsResponse = ProspectsResponse.fromJson(response.data);

      if (prospectsResponse.success) {
        AppLogger.i(
          'Successfully fetched ${prospectsResponse.count} prospects',
        );
        return prospectsResponse.data;
      } else {
        throw Exception(
          'Failed to fetch prospects: API returned success=false',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('DioException while fetching prospects: $e');
      throw Exception('Failed to fetch prospects: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.e('DioException while fetching prospects: $e');
      AppLogger.e('Error fetching prospects: $e\n$stackTrace');

      throw Exception('Failed to fetch prospects: $e');
    } finally {
      _isFetching = false;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchProspects);
  }

  // Add a prospect to the list
  void addProspect(Prospects newProspect) {
    state.whenData((currentProspects) {
      // Add the new prospect to the beginning of the list
      final updatedList = [newProspect, ...currentProspects];
      state = AsyncValue.data(updatedList);
    });
  }
}

/// Search Query Provider
@riverpod
class ProspectSearchQuery extends _$ProspectSearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }

  void clearQuery() {
    state = '';
  }
}

/// Provider for Searched/Filtered Prospects
@riverpod
class SearchedProspects extends _$SearchedProspects {
  @override
  FutureOr<List<Prospects>> build() async {
    final searchQuery = ref.watch(prospectSearchQueryProvider);
    final allProspects = await ref.watch(prospectViewModelProvider.future);

    if (searchQuery.isEmpty) return allProspects;

    final lowerQuery = searchQuery.toLowerCase();
    return allProspects.where((prospect) {
      return prospect.name.toLowerCase().contains(lowerQuery) ||
          prospect.location.address.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

/// Prospect Count Provider
@riverpod
int prospectCount(Ref ref) {
  final prospectsAsync = ref.watch(prospectViewModelProvider);

  return prospectsAsync.when(
    data: (prospects) => prospects.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}
