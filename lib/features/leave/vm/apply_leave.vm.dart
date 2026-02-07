// lib/features/leave/vm/apply_leave.vm.dart

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/leave/models/leave.model.dart';
import 'package:sales_sphere/features/leave/vm/leave.vm.dart';

part 'apply_leave.vm.g.dart';

@riverpod
class ApplyLeaveViewModel extends _$ApplyLeaveViewModel {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> submitLeave({
    required String category,
    required String startDate,
    String? endDate,
    required String reason,
  }) async {
    state = const AsyncValue.loading();
    try {
      AppLogger.i('🚀 Submitting Leave Request');
      AppLogger.d('Category: $category, Start: $startDate, End: $endDate');

      final dio = ref.read(dioClientProvider);

      final request = AddLeaveRequest(
        leaveType: category,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
      );

      final response = await dio.post(
        ApiEndpoints.createLeave,
        data: request.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final apiResponse = AddLeaveApiResponse.fromJson(response.data);

        if (apiResponse.success) {
          AppLogger.i(
            '✅ Leave submission successful - ${apiResponse.leaveDays} day(s)',
          );

          if (ref.mounted) {
            ref.invalidate(leaveViewModelProvider);
            state = const AsyncValue.data(null);
          }
        } else {
          throw Exception('Leave submission failed');
        }
      } else {
        final errorMessage =
            response.data?['message'] ?? 'Failed to submit leave';
        AppLogger.e('❌ Leave submission failed: $errorMessage');
        if (ref.mounted) {
          state = AsyncValue.error(Exception(errorMessage), StackTrace.current);
        }
        throw Exception(errorMessage);
      }
    } on DioException catch (e, stack) {
      String errorMessage = 'Failed to submit leave';

      if (e.response?.statusCode == 400) {
        errorMessage = e.response?.data?['message'] ?? errorMessage;
      }

      AppLogger.e('❌ Leave submission failed: $errorMessage', e, stack);
      if (ref.mounted) {
        state = AsyncValue.error(Exception(errorMessage), stack);
      }
      throw Exception(errorMessage);
    } catch (e, stack) {
      AppLogger.e('❌ Leave submission failed: $e', e, stack);
      if (ref.mounted) {
        state = AsyncValue.error(e, stack);
      }
      rethrow;
    }
  }
}
