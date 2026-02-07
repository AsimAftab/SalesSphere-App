import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/leave/models/leave.model.dart';

part 'leave.vm.g.dart';

@riverpod
class LeaveViewModel extends _$LeaveViewModel {
  @override
  FutureOr<List<LeaveListItem>> build() async {
    AppLogger.d('🏗️ LeaveViewModel build()');
    return _fetchLeaves();
  }

  Future<List<LeaveListItem>> _fetchLeaves() async {
    try {
      AppLogger.i(
        '📡 Fetching leave requests: ${ApiEndpoints.myLeaveRequests}',
      );

      final dio = ref.read(dioClientProvider);
      final response = await dio.get(ApiEndpoints.myLeaveRequests);

      AppLogger.d('📡 Response Code: ${response.statusCode}');

      if (response.data == null) {
        AppLogger.w('⚠️ Null response data from leave API');
        return [];
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        AppLogger.e('❌ Invalid data type: ${data.runtimeType}. Expected Map.');
        throw Exception('Invalid response format');
      }

      final apiResponse = LeaveApiResponse.fromJson(data);

      if (!apiResponse.success) {
        AppLogger.w('⚠️ API success=false');
        throw Exception('API error occurred');
      }

      final list = apiResponse.data
          .map((e) => LeaveListItem.fromApiData(e))
          .toList();
      AppLogger.i('✅ Fetched ${list.length} items');
      return list;
    } catch (e, stack) {
      AppLogger.e('❌ Leave fetch failed: $e', e, stack);
      rethrow;
    }
  }

  Future<void> refresh() async {
    AppLogger.i('🔄 Manual refresh requested');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchLeaves);
  }
}

@riverpod
class LeaveSearchQuery extends _$LeaveSearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) => state = query;
}

@riverpod
class LeaveFilterNotifier extends _$LeaveFilterNotifier {
  @override
  LeaveFilter build() => LeaveFilter.all;

  void setFilter(LeaveFilter filter) => state = filter;
}

@riverpod
AsyncValue<List<LeaveListItem>> filteredLeaves(Ref ref) {
  final leavesAsync = ref.watch(leaveViewModelProvider);
  final query = ref.watch(leaveSearchQueryProvider).toLowerCase();
  final filter = ref.watch(leaveFilterProvider);

  return leavesAsync.whenData((leaves) {
    // Apply search filter
    var result = leaves;
    if (query.isNotEmpty) {
      result = result
          .where(
            (l) =>
                l.displayLeaveType.toLowerCase().contains(query) ||
                l.leaveType.toLowerCase().contains(query) ||
                (l.reason?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    // Apply status filter
    if (filter != LeaveFilter.all) {
      result = result
          .where((l) => l.status.toLowerCase() == filter.name.toLowerCase())
          .toList();
    }

    return result;
  });
}
