import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/leave/models/leave.model.dart';
import 'package:sales_sphere/features/leave/vm/leave.vm.dart';

part 'edit_leave.vm.g.dart';

@riverpod
class EditLeaveViewModel extends _$EditLeaveViewModel {
  @override
  FutureOr<LeaveListItem?> build(String leaveId) async {
    if (leaveId.isEmpty) return null;
    return _fetchLeaveDetails(leaveId);
  }

  Future<LeaveListItem> _fetchLeaveDetails(String leaveId) async {
    try {
      AppLogger.i('📡 Fetching leave details: $leaveId');

      final dio = ref.read(dioClientProvider);
      final response = await dio.get('${ApiEndpoints.createLeave}/$leaveId');

      if (response.statusCode == 200) {
        final apiResponse = LeaveDetailApiResponse.fromJson(response.data);

        if (apiResponse.success) {
          final item = LeaveListItem.fromApiData(apiResponse.data);
          AppLogger.i('✅ Leave details fetched successfully');
          return item;
        } else {
          throw Exception('Failed to fetch leave details');
        }
      } else {
        throw Exception('Failed to fetch leave: ${response.statusCode}');
      }
    } catch (e, stack) {
      AppLogger.e('❌ Failed to fetch leave details: $e', e, stack);
      rethrow;
    }
  }

  Future<void> updateLeave({
    required String leaveId,
    required String category,
    required String startDate,
    String? endDate,
    required String reason,
  }) async {
    state = const AsyncValue.loading();
    try {
      AppLogger.i('🚀 Updating Leave Request: $leaveId');
      AppLogger.d('Category: $category, Start: $startDate, End: $endDate');

      final dio = ref.read(dioClientProvider);

      final request = AddLeaveRequest(
        leaveType: category,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
      );

      final response = await dio.put(
        '${ApiEndpoints.createLeave}/$leaveId',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final apiResponse = AddLeaveApiResponse.fromJson(response.data);

        if (apiResponse.success) {
          AppLogger.i(
            '✅ Leave update successful - ${apiResponse.leaveDays} day(s)',
          );

          if (ref.mounted) {
            ref.invalidate(leaveViewModelProvider);
          }

          // Refresh the current leave details
          final updatedItem = await _fetchLeaveDetails(leaveId);
          state = AsyncValue.data(updatedItem);
        } else {
          throw Exception('Leave update failed');
        }
      } else {
        final errorMessage =
            response.data?['message'] ?? 'Failed to update leave';
        throw Exception(errorMessage);
      }
    } catch (e, stack) {
      AppLogger.e('❌ Leave update failed: $e', e, stack);
      if (ref.mounted) {
        state = AsyncValue.error(e, stack);
      }
      rethrow;
    }
  }
}
