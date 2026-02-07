import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/utils/logger.dart';

import '../model/odometer.model.dart';

part 'odometer_details.vm.g.dart';

@riverpod
class OdometerDetailsViewModel extends _$OdometerDetailsViewModel {
  @override
  Future<OdometerDetails> build(String id) async {
    return _fetchOdometerDetails(id);
  }

  /// Fetch odometer details by ID from API
  Future<OdometerDetails> _fetchOdometerDetails(String id) async {
    try {
      AppLogger.i('📋 Fetching odometer details for ID: $id');

      final dio = ref.read(dioClientProvider);
      final response = await dio.get('/api/v1/odometer/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        AppLogger.i('✅ Odometer details fetched successfully');

        // The API might return 'distance' at root level (outside data)
        // Merge it into the data object for parsing
        final data = Map<String, dynamic>.from(response.data['data']);
        if (response.data['distance'] != null) {
          data['distance'] = response.data['distance'];
        }

        return OdometerDetails.fromJson(data);
      }

      throw Exception('Failed to fetch odometer details');
    } on DioException catch (e) {
      AppLogger.e('❌ Failed to fetch odometer details: $e');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      AppLogger.e('❌ Unexpected error: $e');
      throw Exception('Failed to load details: $e');
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
