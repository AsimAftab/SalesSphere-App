import 'dart:async';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/network_layer/permission_denied_exception.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/miscellaneous/models/miscellaneous.model.dart';

part 'miscellaneous_list.vm.g.dart';

// ============================================================================
// MISCELLANEOUS WORK LIST VIEW MODEL
// Handles: Fetch all work, Search, Filter, Refresh
// ============================================================================

@riverpod
class MiscellaneousListViewModel extends _$MiscellaneousListViewModel {
  bool _isFetching = false;

  @override
  FutureOr<List<MiscWorkData>> build() async {
    // Keep alive for 60 seconds (prevents disposal on tab switch)
    final link = ref.keepAlive();
    Timer(const Duration(seconds: 60), () {
      link.close();
    });

    // Fetch miscellaneous works
    return _fetchMiscWorks();
  }

  // FETCH ALL MISCELLANEOUS WORKS FROM API
  Future<List<MiscWorkData>> _fetchMiscWorks() async {
    // Guard: prevent concurrent fetches
    if (_isFetching) {
      AppLogger.w('⚠️ Already fetching misc works, skipping duplicate request');
      throw Exception('Fetch already in progress');
    }

    _isFetching = true;
    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i(
        'Fetching miscellaneous works from API: ${ApiEndpoints.myMiscellaneousWorks}',
      );

      final response = await dio.get(ApiEndpoints.myMiscellaneousWorks);

      AppLogger.d('Misc Works API response: ${response.statusCode}');

      // Check for permission denied before parsing
      if (response.statusCode == 403) {
        throw PermissionDeniedException(
          message: response.data['message'] ?? 'Permission denied',
        );
      }

      final apiResponse = MiscWorkListApiResponse.fromJson(response.data);
      AppLogger.i(
        '✅ Fetched ${apiResponse.count} miscellaneous works successfully',
      );

      return apiResponse.data;
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error fetching misc works: ${e.message}');
      // Rethrow DioException directly so UI can check for NetworkException (403, etc.)
      rethrow;
    } catch (e) {
      AppLogger.e('❌ Error fetching misc works: $e');
      rethrow;
    } finally {
      _isFetching = false;
    }
  }

  // SEARCH MISCELLANEOUS WORKS
  List<MiscWorkData> searchWorks(String query) {
    final works = state.value ?? [];
    if (query.isEmpty) return works;

    final lowerQuery = query.toLowerCase();
    return works.where((work) {
      return work.natureOfWork.toLowerCase().contains(lowerQuery) ||
          work.assignedBy.toLowerCase().contains(lowerQuery) ||
          work.address.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // REFRESH WORKS LIST
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchMiscWorks);
  }
}

// ============================================================================
// SEARCH QUERY PROVIDER
// ============================================================================

@riverpod
class MiscListSearchQuery extends _$MiscListSearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }

  void clearQuery() {
    state = '';
  }
}

// ============================================================================
// COMPUTED PROVIDERS
// ============================================================================

// Provider for searched/filtered miscellaneous works
@riverpod
Future<List<MiscWorkListItem>> searchedMiscWorks(Ref ref) async {
  final searchQuery = ref.watch(miscListSearchQueryProvider);
  final allWorks = await ref.watch(miscellaneousListViewModelProvider.future);
  final listItems = allWorks
      .map((work) => MiscWorkListItem.fromApiData(work))
      .toList();

  if (searchQuery.isEmpty) return listItems;

  final lowerQuery = searchQuery.toLowerCase();
  return listItems.where((work) {
    return work.natureOfWork.toLowerCase().contains(lowerQuery) ||
        work.assignedBy.toLowerCase().contains(lowerQuery) ||
        work.address.toLowerCase().contains(lowerQuery);
  }).toList();
}

// Provider to get total work count
@riverpod
int miscWorkCount(Ref ref) {
  final worksAsync = ref.watch(miscellaneousListViewModelProvider);

  return worksAsync.when(
    data: (works) => works.length,
    loading: () => 0,
    error: (error, stackTrace) => 0,
  );
}
