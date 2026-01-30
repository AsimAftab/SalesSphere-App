import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/parties/models/parties.model.dart';

part 'party_types.vm.g.dart';

// ============================================================================
// PARTY TYPES VIEW MODEL
// Fetches party types from API
// ============================================================================

@riverpod
class PartyTypesViewModel extends _$PartyTypesViewModel {
  @override
  Future<List<PartyType>> build() async {
    return fetchPartyTypes();
  }

  /// Fetch party types from API
  Future<List<PartyType>> fetchPartyTypes() async {
    try {
      AppLogger.i('📋 Fetching party types');

      final dio = ref.read(dioClientProvider);

      final response = await dio.get(ApiEndpoints.partyTypes);

      if (response.statusCode == 200) {
        final apiResponse = PartyTypesApiResponse.fromJson(response.data);
        AppLogger.i('✅ Fetched ${apiResponse.count} party types');
        return apiResponse.data;
      } else {
        throw Exception('Failed to fetch party types: ${response.statusMessage}');
      }
    } catch (e) {
      AppLogger.e('❌ Error fetching party types: $e');
      rethrow;
    }
  }

  /// Refresh party types
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => fetchPartyTypes());
  }
}
