import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/network_layer/network_exceptions.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import '../models/tour_plan.model.dart';

part 'add_tour.vm.g.dart';

@riverpod
class AddTourViewModel extends _$AddTourViewModel {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<bool> createTourPlan(CreateTourRequest request) async {
    state = const AsyncLoading();

    try {
      final dio = ref.read(dioClientProvider);

      final response = await dio.post(
        ApiEndpoints.createTourPlan,
        data: request.toJson(),
      );

      final createResponse = CreateTourResponse.fromJson(response.data);

      if (createResponse.success) {
        AppLogger.i('Tour plan created successfully: ${createResponse.data.id}');
        state = const AsyncData(null);
        return true;
      } else {
        state = AsyncError('Failed to create tour plan', StackTrace.current);
        return false;
      }
    } on DioException catch (e, stack) {
      AppLogger.e('Failed to create tour plan', e, stack);

      String errorMessage = 'Failed to create tour plan';
      if (e.error is NetworkException) {
        final error = e.error as NetworkException;
        errorMessage = error.userFriendlyMessage;
      }

      state = AsyncError(errorMessage, stack);
      return false;
    } catch (e, stack) {
      AppLogger.e('Unexpected error creating tour plan', e, stack);
      state = AsyncError(e.toString(), stack);
      return false;
    }
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
