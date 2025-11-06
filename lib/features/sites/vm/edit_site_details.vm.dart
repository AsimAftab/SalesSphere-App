
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales_sphere/core/constants/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/features/sites/models/sites.model.dart';
import 'package:sales_sphere/features/sites/vm/sites.vm.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'edit_site_details.vm.g.dart';

// ============================================================================
// STANDALONE PROVIDER FOR SITE DETAILS (GET BY ID)
// ============================================================================

@riverpod
Future<SiteDetails?> siteById(Ref ref, String siteId) async {
  try {
    AppLogger.i('🔄 Fetching site details for ID: $siteId');

    // Get Dio instance
    final dio = ref.read(dioClientProvider);

    // Make API call
    final response = await dio.get(ApiEndpoints.siteById(siteId));

    AppLogger.d('API Response: ${response.data}');

    // Parse response
    final getSiteResponse = GetSiteResponse.fromJson(response.data);

    if (!getSiteResponse.success) {
      throw Exception('Failed to fetch site details');
    }

    // Convert to SiteDetails model
    final siteDetails = getSiteResponse.toSiteDetails();

    AppLogger.i('✅ Fetched site details for: ${siteDetails.name}');
    return siteDetails;
  } on DioException catch (e) {
    AppLogger.e('❌ DioException fetching site details: ${e.message}');
    AppLogger.e('Response data: ${e.response?.data}');

    // Extract error message from response if available
    String errorMessage = 'Failed to fetch site details';
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        errorMessage = data['message'] ?? errorMessage;
      }
    }

    throw Exception(errorMessage);
  } catch (e, stackTrace) {
    AppLogger.e('❌ Error fetching site $siteId: $e');
    AppLogger.e('Stack trace: $stackTrace');
    rethrow;
  }
}

// ============================================================================
// UPDATE SITE HELPER FUNCTION (PUT)
// ============================================================================

Future<void> updateSite(WidgetRef ref, SiteDetails updatedSiteDetails) async {
  try {
    AppLogger.i('Updating site: ${updatedSiteDetails.name} (ID: ${updatedSiteDetails.id})');

    // Get Dio instance
    final dio = ref.read(dioClientProvider);

    // Create update request
    final updateRequest = UpdateSiteRequest.fromSiteDetails(updatedSiteDetails);

    // Make API call
    final response = await dio.put(
      ApiEndpoints.updateSite(updatedSiteDetails.id),
      data: updateRequest.toJson(),
    );

    AppLogger.d('API Response: ${response.data}');

    // Parse response
    final updateSiteResponse = UpdateSiteResponse.fromJson(response.data);

    if (!updateSiteResponse.success) {
      throw Exception(updateSiteResponse.message);
    }

    // Convert response to Sites model and update local state
    final updatedSite = Sites(
      id: updateSiteResponse.data.id,
      name: updateSiteResponse.data.siteName,
      location: updateSiteResponse.data.location.address,
      ownerName: updateSiteResponse.data.ownerName,
      phoneNumber: updateSiteResponse.data.contact.phone,
      email: updateSiteResponse.data.contact.email,
      panVatNumber: null,
      latitude: updateSiteResponse.data.location.latitude,
      longitude: updateSiteResponse.data.location.longitude,
      notes: updateSiteResponse.data.description,
      dateJoined: updateSiteResponse.data.dateJoined,
      isActive: true,
      createdAt: updateSiteResponse.data.createdAt,
      updatedAt: updateSiteResponse.data.updatedAt,
    );

    // Use the updateSite method from the ViewModel to update local list
    ref.read(siteViewModelProvider.notifier).updateSite(updatedSite);

    AppLogger.i('✅ Site updated successfully: ${updatedSite.name}');
  } on DioException catch (e) {
    AppLogger.e('❌ DioException updating site: ${e.message}');
    AppLogger.e('Response data: ${e.response?.data}');

    // Extract error message from response if available
    String errorMessage = 'Failed to update site';
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        errorMessage = data['message'] ?? errorMessage;
      }
    }

    throw Exception(errorMessage);
  } catch (e, stackTrace) {
    AppLogger.e('❌ Error updating site: $e');
    AppLogger.e('Stack trace: $stackTrace');
    throw Exception('Failed to update site: $e');
  }
}

// ============================================================================
// VALIDATION HELPERS
// ============================================================================

class SiteValidators {
  static String? validateSiteName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Site name is required';
    }
    if (value.trim().length < 2) {
      return 'Site name must be at least 2 characters';
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