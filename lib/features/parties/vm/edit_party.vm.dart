import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/features/parties/models/parties.model.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/constants/api_endpoints.dart';
import 'package:sales_sphere/features/parties/vm/parties.vm.dart';
import 'package:dio/dio.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'edit_party.vm.g.dart';

// ============================================================================
// EDIT PARTY VIEW MODEL
// Handles: Get specific party by ID, Update specific party
// ============================================================================

@riverpod
class EditPartyViewModel extends _$EditPartyViewModel {
  @override
  FutureOr<void> build() {
    // No initial state needed
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

        // Invalidate the parties list to refresh it (only if ref is still mounted)
        if (ref.mounted) {
          ref.invalidate(partiesViewModelProvider);
        }
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

  // VALIDATION HELPERS FOR EDIT SCREEN
  String? validatePartyName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Party name is required';
    }
    if (value.trim().length < 2) {
      return 'Party name must be at least 2 characters';
    }
    return null;
  }

  String? validateOwnerName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Owner name is required';
    }
    if (value.trim().length < 2) {
      return 'Owner name must be at least 2 characters';
    }
    return null;
  }

  String? validatePanVatNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PAN/VAT number is required';
    }
    if (value.trim().length > 14) {
      return 'PAN/VAT number cannot exceed 14 characters';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    // Remove any spaces or special characters for validation
    final cleanedValue = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanedValue.length != 10) {
      return 'Phone number must be exactly 10 digits';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email is optional
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    return null;
  }
}

// ============================================================================
// STANDALONE PROVIDER FOR PARTY DETAILS
// ============================================================================

// Standalone provider for getting single party details
// Always fetches full details from API to ensure all fields are populated
@riverpod
Future<PartyDetails?> partyById(Ref ref, String partyId) async {
  // Always fetch full details from API since list endpoint doesn't return all fields
  // (phone, email, panVatNumber, latitude, longitude, notes are missing from list)
  AppLogger.i('🔄 Fetching full party details for ID: $partyId');
  final vm = ref.read(editPartyViewModelProvider.notifier);
  return vm.getPartyById(partyId);
}
