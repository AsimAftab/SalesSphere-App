import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network_layer/api_endpoints.dart';
import '../../../core/network_layer/dio_client.dart';
import '../../../core/utils/logger.dart';
import '../models/invoice.models.dart';

part 'tax_config.vm.g.dart';

@riverpod
class TaxConfigViewModel extends _$TaxConfigViewModel {
  @override
  FutureOr<List<TaxConfig>> build() async {
    return fetchTaxConfigs();
  }

  Future<List<TaxConfig>> fetchTaxConfigs() async {
    try {
      final dio = ref.read(dioClientProvider);

      AppLogger.d('Fetching tax configs...');

      final response = await dio.get(ApiEndpoints.taxConfigs);

      final Map<String, dynamic> responseData;
      if (response.data is String) {
        responseData =
            jsonDecode(response.data as String) as Map<String, dynamic>;
      } else if (response.data is Map<String, dynamic>) {
        responseData = response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          'Unexpected response type: ${response.data.runtimeType}',
        );
      }

      final taxConfigResponse = TaxConfigResponse.fromJson(responseData);

      AppLogger.d('Fetched ${taxConfigResponse.count} tax configs');

      return taxConfigResponse.data;
    } catch (e, stackTrace) {
      AppLogger.e('Error fetching tax configs: $e\n$stackTrace');
      // Tax is optional - return empty list on error so it doesn't block invoice creation
      return [];
    }
  }
}
