
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/features/sites/models/sites.model.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'add_sites.vm.g.dart';

// ============================================================================
// ADD SITE VIEW MODEL
// Handles: Create new site with backend API integration
// ============================================================================

@riverpod
class AddSiteViewModel extends _$AddSiteViewModel {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  // CREATE NEW SITE (API INTEGRATION)
  Future<Sites> createSite(CreateSiteRequest newSiteRequest) async {
    try {
      AppLogger.i('Creating new site: ${newSiteRequest.siteName}');

      // Get Dio instance
      final dio = ref.read(dioClientProvider);

      // Make API call
      final response = await dio.post(
        ApiEndpoints.createSite,
        data: newSiteRequest.toJson(),
      );

      AppLogger.d('API Response: ${response.data}');

      // Parse response
      final createSiteResponse = CreateSiteResponse.fromJson(response.data);

      if (!createSiteResponse.success) {
        throw Exception(createSiteResponse.message);
      }

      // Convert to Sites model
      final createdSite = createSiteResponse.toSites();

      AppLogger.i('✅ Site created successfully: ${createdSite.name}');

      // Return the created site - screen will add it to the list
      return createdSite;
    } on DioException catch (e) {
      AppLogger.e('❌ DioException creating site: ${e.message}');
      AppLogger.e('Response data: ${e.response?.data}');

      // Extract error message from response if available
      String errorMessage = 'Failed to create site';
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic>) {
          errorMessage = data['message'] ?? errorMessage;
        }
      }

      throw Exception(errorMessage);
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error creating site: $e');
      AppLogger.e('Stack trace: $stackTrace');
      throw Exception('Failed to create site: $e');
    }
  }

  // ============================================================================
  // VALIDATION HELPERS
  // ============================================================================

  String? validateSiteName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Site name is required';
    }
    if (value.trim().length < 2) {
      return 'Site name must be at least 2 characters';
    }
    return null;
  }

  String? validateManagerName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Manager name is required';
    }
    if (value.trim().length < 2) {
      return 'Manager name must be at least 2 characters';
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