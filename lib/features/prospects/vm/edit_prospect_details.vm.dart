// lib/features/prospects/vm/edit_prospect_details.vm.dart

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/features/prospects/models/prospects.model.dart';
import 'package:sales_sphere/features/prospects/vm/prospects.vm.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'edit_prospect_details.vm.g.dart';

// ============================================================================
// EDIT PROSPECT VIEW MODEL
// Handles: Get specific prospect by ID, Update specific prospect
// ============================================================================

@riverpod
class EditProspectViewModel extends _$EditProspectViewModel {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  // GET SINGLE PROSPECT BY ID FROM API
  Future<ProspectDetails?> getProspectById(String id) async {
    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i('Fetching prospect details for ID: $id');

      final response = await dio.get('/prospects/$id');

      if (response.statusCode == 200) {
        // Parse the full API response
        final apiResponse = UpdateProspectApiResponse.fromJson(response.data);

        // Convert API data to ProspectDetails using helper method
        final prospect = ProspectDetails.fromApiDetail(apiResponse.data);

        AppLogger.i('✅ Fetched prospect details for: ${prospect.name}');
        AppLogger.d('Prospect details: Phone: ${prospect.phoneNumber}, Email: ${prospect.email}, Address: ${prospect.fullAddress}');

        return prospect;
      } else {
        throw Exception('Prospect not found with ID: $id');
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error fetching prospect $id: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error fetching prospect $id: $e');
      AppLogger.e('Stack trace: $stackTrace');
      throw Exception('Failed to get prospect: $e');
    }
  }

  // UPDATE PROSPECT VIA API
  Future<void> updateProspect(ProspectDetails updatedProspect) async {
    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i('Updating prospect: ${updatedProspect.name} (ID: ${updatedProspect.id})');

      // Create update request with editable fields
      final updateRequest = UpdateProspectRequest(
        ownerName: updatedProspect.ownerName,
        location: UpdateProspectLocation(
          address: updatedProspect.fullAddress,
          latitude: updatedProspect.latitude ?? 0.0,
          longitude: updatedProspect.longitude ?? 0.0,
        ),
      );

      // Convert to JSON
      final requestData = updateRequest.toJson();

      AppLogger.d('Update request data: $requestData');

      // Send PUT request
      final response = await dio.put(
        '/prospects/${updatedProspect.id}',
        data: requestData,
      );

      if (response.statusCode == 200) {
        AppLogger.i('✅ Prospect updated successfully');

        // Invalidate the prospects list to refresh it (only if ref is still mounted)
        if (ref.mounted) {
          ref.invalidate(prospectViewModelProvider);
        }
      } else {
        throw Exception('Failed to update prospect: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error updating prospect: ${e.message}');
      if (e.response != null) {
        AppLogger.e('Response data: ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error updating prospect: $e');
      AppLogger.e('Stack trace: $stackTrace');
      throw Exception('Failed to update prospect: $e');
    }
  }

  // TRANSFER PROSPECT TO PARTY VIA API
  Future<TransferProspectToPartyResponse> transferProspectToParty(String prospectId) async {
    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i('Transferring prospect to party: $prospectId');

      // Send POST request with no body
      final response = await dio.post(
        '/prospects/$prospectId/transfer',
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300)  {
        AppLogger.i('✅ Prospect transferred to party successfully');

        // Parse the API response
        final transferResponse = TransferProspectToPartyResponse.fromJson(response.data);

        AppLogger.d('Transferred party name: ${transferResponse.data.partyName}');
        AppLogger.d('Transfer message: ${transferResponse.message}');

        // Invalidate the prospects list to refresh it (only if ref is still mounted)
        if (ref.mounted) {
          ref.invalidate(prospectViewModelProvider);
        }

        return transferResponse;
      } else {
        throw Exception('Failed to transfer prospect: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error transferring prospect: ${e.message}');
      if (e.response != null) {
        AppLogger.e('Response data: ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error transferring prospect: $e');
      AppLogger.e('Stack trace: $stackTrace');
      throw Exception('Failed to transfer prospect: $e');
    }
  }
}

// ============================================================================
// STANDALONE PROVIDER FOR PROSPECT DETAILS
// ============================================================================

// Standalone provider for getting single prospect details
// Always fetches full details from API to ensure all fields are populated
@riverpod
Future<ProspectDetails?> prospectById(Ref ref, String prospectId) async {
  // Always fetch full details from API since list endpoint doesn't return all fields
  AppLogger.i('🔄 Fetching full prospect details for ID: $prospectId');
  final vm = ref.read(editProspectViewModelProvider.notifier);
  return vm.getProspectById(prospectId);
}

// ============================================================================
// VALIDATION HELPERS
// ============================================================================

class ProspectValidators {
  static String? validateProspectName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Prospect name is required';
    }
    if (value.trim().length < 2) {
      return 'Prospect name must be at least 2 characters';
    }
    return null;
  }

  static String? validateOwnerName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Owner name is required';
    }
    if (value.trim().length < 2) {
      return 'Owner name must be at least 2 characters';
    }
    return null;
  }

  static String? validatePanVatNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (value.trim().length > 14) {
      return 'PAN/VAT number cannot exceed 14 characters';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleanedValue = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanedValue.length != 10) {
      return 'Phone number must be exactly 10 digits';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    return null;
  }
}