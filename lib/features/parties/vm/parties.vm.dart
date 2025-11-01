import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';
import 'package:sales_sphere/features/parties/models/parties.model.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/constants/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'parties.vm.g.dart';

// ============================================================================
// MAIN PARTIES LIST VIEW MODEL
// Handles: Fetch all parties, Delete, Search, Filter, Refresh
// ============================================================================

@riverpod
class PartiesViewModel extends _$PartiesViewModel {
  @override
  FutureOr<List<PartyDetails>> build() async {
    // Initial state - fetch all parties from API
    return _fetchParties();
  }

  // FETCH ALL PARTIES FROM API
  Future<List<PartyDetails>> _fetchParties() async {
    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i('Fetching parties from API: ${ApiEndpoints.parties}');

      final response = await dio.get(ApiEndpoints.parties);

      AppLogger.d('Parties API response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final apiResponse = PartiesApiResponse.fromJson(response.data);
        AppLogger.i('✅ Fetched ${apiResponse.count} parties successfully');

        final parties = apiResponse.data.map((apiData) {
          return PartyDetails(
            id: apiData.id,
            name: apiData.partyName,
            ownerName: apiData.ownerName,
            panVatNumber: '', // Not available in list API
            phoneNumber: '', // Not available in list API
            fullAddress: apiData.location.address,
            isActive: true,
          );
        }).toList();

        return parties;
      } else {
        throw Exception('Failed to fetch parties: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error fetching parties: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      AppLogger.e('❌ Error fetching parties: $e');
      throw Exception('Failed to fetch parties: $e');
    }
  }

  // DELETE PARTY VIA API
  Future<void> deleteParty(String id) async {
    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i('Deleting party with ID: $id');

      final response = await dio.delete(ApiEndpoints.deleteParty(id));

      if (response.statusCode == 200) {
        AppLogger.i('✅ Party deleted successfully');

        // Update local state by removing the deleted party
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() async {
          final currentParties = state.value ?? [];
          return currentParties.where((p) => p.id != id).toList();
        });
      } else {
        throw Exception('Failed to delete party: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error deleting party: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      AppLogger.e('❌ Error deleting party: $e');
      throw Exception('Failed to delete party: $e');
    }
  }

  // SEARCH PARTIES
  List<PartyDetails> searchParties(String query) {
    final parties = state.value ?? [];
    if (query.isEmpty) return parties;

    final lowerQuery = query.toLowerCase();
    return parties.where((party) {
      return party.name.toLowerCase().contains(lowerQuery) ||
          party.phoneNumber.contains(query) ||
          party.ownerName.toLowerCase().contains(lowerQuery) ||
          party.fullAddress.toLowerCase().contains(lowerQuery) ||
          (party.email?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  // FILTER BY ACTIVE STATUS
  List<PartyDetails> filterByActiveStatus(bool isActive) {
    final parties = state.value ?? [];
    return parties.where((party) => party.isActive == isActive).toList();
  }

  // REFRESH PARTIES LIST
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchParties);
  }
}

// ============================================================================
// SEARCH QUERY PROVIDER
// ============================================================================

@riverpod
class SearchQuery extends _$SearchQuery {
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

// Provider for searched/filtered parties
@riverpod
Future<List<PartyListItem>> searchedParties(Ref ref) async {
  final searchQuery = ref.watch(searchQueryProvider);
  final allParties = await ref.watch(partiesViewModelProvider.future);
  final listItems = allParties
      .map((party) => PartyListItem.fromPartyDetails(party))
      .toList();

  if (searchQuery.isEmpty) return listItems;

  final lowerQuery = searchQuery.toLowerCase();
  return listItems.where((party) {
    return party.name.toLowerCase().contains(lowerQuery) ||
        party.ownerName.toLowerCase().contains(lowerQuery) ||
        (party.phoneNumber ?? '').contains(searchQuery) ||
        party.fullAddress.toLowerCase().contains(lowerQuery);
  }).toList();
}

// Provider to get total party count
@riverpod
int partyCount(Ref ref) {
  final partiesAsync = ref.watch(partiesViewModelProvider);

  return partiesAsync.when(
    data: (parties) => parties.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}

// Provider to get active party count
@riverpod
int activePartyCount(Ref ref) {
  final partiesAsync = ref.watch(partiesViewModelProvider);

  return partiesAsync.when(
    data: (parties) => parties.where((p) => p.isActive).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}
