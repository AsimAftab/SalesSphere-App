import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/network_layer/network_exceptions.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/collection/models/collection.model.dart';

part 'bank_names.vm.g.dart';

@riverpod
class BankNamesViewModel extends _$BankNamesViewModel {
  @override
  FutureOr<List<BankName>> build() async {
    // Keep alive for caching
    final link = ref.keepAlive();
    ref.onDispose(() {
      link.close();
    });

    return _fetchBankNames();
  }

  Future<List<BankName>> _fetchBankNames() async {
    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i('Fetching bank names from API');

      final response = await dio.get(ApiEndpoints.bankNames);

      if (response.statusCode == 200) {
        final apiResponse = BankNamesApiResponse.fromJson(response.data);
        AppLogger.i('✅ Fetched ${apiResponse.count} bank names');
        return apiResponse.data;
      } else {
        throw Exception(
          'Failed to fetch bank names: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error fetching bank names', e);
      if (e.error is NetworkException) {
        throw Exception((e.error as NetworkException).userFriendlyMessage);
      }
      throw Exception('Failed to fetch bank names: ${e.message}');
    } catch (e) {
      AppLogger.e('❌ Error fetching bank names: $e');
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchBankNames);
  }
}
