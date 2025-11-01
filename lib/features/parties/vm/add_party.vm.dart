import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/features/parties/models/parties.model.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/constants/api_endpoints.dart';
import 'package:sales_sphere/features/parties/vm/parties.vm.dart';
import 'package:dio/dio.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'add_party.vm.g.dart';

// ============================================================================
// ADD PARTY VIEW MODEL
// Handles: Create new party
// ============================================================================

@riverpod
class AddPartyViewModel extends _$AddPartyViewModel {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  // CREATE NEW PARTY VIA API
  Future<PartyDetails> createParty(CreatePartyRequest newPartyRequest) async {
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
        AppLogger.i(' Party created successfully');

        // Parse the response to get the created party
        final apiResponse = CreatePartyApiResponse.fromJson(response.data);
        final createdParty = PartyDetails.fromApiDetail(apiResponse.data);

        // Invalidate the parties list to refresh it (only if ref is still mounted)
        if (ref.mounted) {
          ref.invalidate(partiesViewModelProvider);
        }

        return createdParty;
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

  // VALIDATION HELPERS
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
