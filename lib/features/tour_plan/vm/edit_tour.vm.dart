import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/network_layer/network_exceptions.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/tour_plan/models/tour_plan.model.dart';

part 'edit_tour.vm.g.dart';

@riverpod
class EditTourViewModel extends _$EditTourViewModel {
  @override
  FutureOr<void> build() => null;

  Future<bool> updateTourPlan({
    required String tourId,
    required UpdateTourRequest request,
  }) async {
    state = const AsyncLoading();

    try {
      final dio = ref.read(dioClientProvider);

      final response = await dio.patch(
        ApiEndpoints.updateTourPlan(tourId),
        data: request.toJson(),
      );

      final statusCode = response.statusCode ?? 0;
      final responseData = response.data;

      if (statusCode >= 400) {
        final message =
            _extractMessage(responseData) ?? 'Failed to update tour plan';
        state = AsyncError(message, StackTrace.current);
        return false;
      }

      if (responseData is! Map<String, dynamic>) {
        state = AsyncError('Invalid response from server', StackTrace.current);
        return false;
      }

      final success = responseData['success'] == true;
      if (!success) {
        final message =
            _extractMessage(responseData) ?? 'Failed to update tour plan';
        state = AsyncError(message, StackTrace.current);
        return false;
      }

      final updateResponse = UpdateTourResponse.fromJson(responseData);
      AppLogger.i('Tour plan updated successfully: ${updateResponse.data.id}');
      state = const AsyncData(null);
      return true;
    } on DioException catch (e, stack) {
      AppLogger.e('Failed to update tour plan', e, stack);

      String errorMessage = 'Failed to update tour plan';
      if (e.error is NetworkException) {
        final error = e.error as NetworkException;
        errorMessage = error.userFriendlyMessage;
      }

      state = AsyncError(errorMessage, stack);
      return false;
    } catch (e, stack) {
      AppLogger.e('Unexpected error updating tour plan', e, stack);
      state = AsyncError(e.toString(), stack);
      return false;
    }
  }

  String? _extractMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
      final error = responseData['error'];
      if (error is String && error.trim().isNotEmpty) {
        return error.trim();
      }
      final detail = responseData['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail.trim();
      }
    }
    return null;
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}

@riverpod
Future<TourDetails?> tourById(Ref ref, String tourId) async {
  try {
    final dio = ref.read(dioClientProvider);
    final response = await dio.get(ApiEndpoints.updateTourPlan(tourId));

    final apiResponse = UpdateTourResponse.fromJson(response.data);
    if (apiResponse.success) {
      return TourDetails.fromUpdateData(apiResponse.data);
    }
    return null;
  } on DioException catch (e) {
    AppLogger.e('Failed to fetch tour details', e);
    if (e.error is NetworkException) {
      throw (e.error as NetworkException).userFriendlyMessage;
    }
    throw 'Failed to fetch tour details';
  }
}
