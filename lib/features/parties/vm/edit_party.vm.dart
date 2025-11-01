import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';
import 'package:sales_sphere/features/parties/models/parties.model.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/constants/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'edit_party.vm.g.dart';

@riverpod
class PartyViewModel extends _$PartyViewModel {
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

  // GET SINGLE PARTY BY ID FROM API
  Future<PartyDetails?> getPartyById(String id) async {
    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i('Fetching party details for ID: $id');

      final response = await dio.get(ApiEndpoints.partyById(id));

      if (response.statusCode == 200) {
        // Parse the full API response
        final apiResponse = PartyDetailApiResponse.fromJson(response.data);

        // Convert API data to PartyDetails using helper method
        final party = PartyDetails.fromApiDetail(apiResponse.data);

        AppLogger.i('✅ Fetched party details for: ${party.name}');
        AppLogger.d('Party details: Phone: ${party.phoneNumber}, Email: ${party.email}, Address: ${party.fullAddress}');

        return party;
      } else {
        throw Exception('Party not found with ID: $id');
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error fetching party $id: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error fetching party $id: $e');
      AppLogger.e('Stack trace: $stackTrace');
      throw Exception('Failed to get party: $e');
    }
  }

  // CRUD OPERATIONS

  // CREATE NEW PARTY VIA API
  Future<PartyDetails> addParty(UpdatePartyRequest newPartyRequest) async {
    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i('Creating new party: ${newPartyRequest.partyName}');

      // Convert to JSON
      final requestData = newPartyRequest.toJson();
      AppLogger.d('Create party request data: $requestData');

      // Send POST request
      final response = await dio.post(
        ApiEndpoints.createParty,
        data: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.i('✅ Party created successfully');

        // Parse the response to get the created party
        final responseData = response.data['data'] ?? response.data;

        // If response contains party details, parse it
        if (responseData is Map<String, dynamic>) {
          final apiResponse = PartyDetailApiResponse.fromJson(response.data);
          final createdParty = PartyDetails.fromApiDetail(apiResponse.data);

          // Refresh the parties list
          await refresh();

          return createdParty;
        } else {
          // If no data returned, refresh list
          await refresh();
          throw Exception('Party created but no data returned');
        }
      } else {
        throw Exception('Failed to create party: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error creating party: ${e.message}');
      if (e.response != null) {
        AppLogger.e('Response data: ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error creating party: $e');
      AppLogger.e('Stack trace: $stackTrace');
      throw Exception('Failed to create party: $e');
    }
  }

  // UPDATE PARTY VIA API
  Future<void> updateParty(PartyDetails updatedParty) async {
    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i('Updating party: ${updatedParty.name} (ID: ${updatedParty.id})');

      // Create update request with all editable fields
      final updateRequest = UpdatePartyRequest.fromPartyDetails(updatedParty);

      // Convert to JSON
      final requestData = updateRequest.toJson();

      AppLogger.d('Update request data: $requestData');

      // Send PUT request
      final response = await dio.put(
        ApiEndpoints.updateParty(updatedParty.id),
        data: requestData,
      );

      if (response.statusCode == 200) {
        AppLogger.i('✅ Party updated successfully');

        // Update local state
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() async {
          final currentParties = state.value ?? [];
          return currentParties.map((p) => p.id == updatedParty.id ? updatedParty : p).toList();
        });
      } else {
        throw Exception('Failed to update party: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error updating party: ${e.message}');
      if (e.response != null) {
        AppLogger.e('Response data: ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error updating party: $e');
      AppLogger.e('Stack trace: $stackTrace');
      throw Exception('Failed to update party: $e');
    }
  }

  Future<void> deleteParty(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentParties = state.value ?? [];
      return currentParties.where((p) => p.id != id).toList();
    });
  }

  // SEARCH & FILTER
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

  List<PartyDetails> filterByActiveStatus(bool isActive) {
    final parties = state.value ?? [];
    return parties.where((party) => party.isActive == isActive).toList();
  }

  // REFRESH
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchParties);
  }


  // VALIDATION HELPERS
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[\d\s-()]+$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

}


// Standalone provider for getting single party details
// Always fetches full details from API to ensure all fields are populated
@riverpod
Future<PartyDetails?> partyById(Ref ref, String partyId) async {
  // Always fetch full details from API since list endpoint doesn't return all fields
  // (phone, email, panVatNumber, latitude, longitude, notes are missing from list)
  AppLogger.i('🔄 Fetching full party details for ID: $partyId');
  final vm = ref.read(partyViewModelProvider.notifier);
  return vm.getPartyById(partyId);
}
