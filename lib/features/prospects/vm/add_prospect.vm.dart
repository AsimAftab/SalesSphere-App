// lib/features/prospects/vm/add_prospect.vm.dart

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/features/prospects/models/prospects.model.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'add_prospect.vm.g.dart';

// ============================================================================
// ADD PROSPECT VIEW MODEL
// Handles: Create new prospect via API
// ============================================================================

@riverpod
class AddProspectViewModel extends _$AddProspectViewModel {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  // CREATE NEW PROSPECT (API CALL)
  Future<Prospects> createProspect(CreateProspectRequest newProspectRequest) async {
    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i('Creating new prospect via API: ${newProspectRequest.name}');

      // Make POST request to create prospect
      final response = await dio.post(
        '/prospects',
        data: newProspectRequest.toJson(),
      );

      AppLogger.d('Create prospect API status: ${response.statusCode}');
      AppLogger.d('Create prospect API raw data: ${response.data.runtimeType} -> ${response.data}');

      // ✅ Ensure we have a proper JSON map
      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw Exception(
          'Invalid API response format — expected a JSON object but got ${response.data.runtimeType}',
        );
      }

      // ✅ Parse safely
      final createResponse =
      CreateProspectApiResponse.fromJson(response.data as Map<String, dynamic>);

      // ✅ Check success
      if (createResponse.success) {
        final data = createResponse.data;

        AppLogger.i('✅ Prospect created successfully: ${data.name} (${data.id})');

        // Convert API response to Prospects model
        final createdProspect = Prospects(
          id: data.id,
          name: data.name,
          ownerName: data.ownerName,
          location: ProspectLocation(
            address:
            data.location?.address ?? newProspectRequest.location.address,
          ),
        );

        return createdProspect;
      } else {
        throw Exception(
          'Failed to create prospect: API returned success=false',
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.e('DioException while creating prospect: $e\n$stackTrace');
      throw Exception('Failed to create prospect: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.e('Error creating prospect: $e\n$stackTrace');
      throw Exception('Failed to create prospect: $e');
    }
  }

  // ============================================================================
  // VALIDATION HELPERS
  // ============================================================================

  String? validateProspectName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Prospect name is required';
    }
    if (value.trim().length < 2) {
      return 'Prospect name must be at least 2 characters';
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
    if (value == null || value.trim().isEmpty) return null; // optional
    if (value.trim().length > 14) {
      return 'PAN/VAT number cannot exceed 14 characters';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleanedValue = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanedValue.length != 10) {
      return 'Phone number must be exactly 10 digits';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final emailRegex =
    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
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
