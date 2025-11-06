
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales_sphere/features/sites/models/sites.model.dart';
import 'package:sales_sphere/features/sites/vm/sites.vm.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'edit_site_details.vm.g.dart';

// ============================================================================
// STANDALONE PROVIDER FOR SITE DETAILS
// ============================================================================

@riverpod
Future<SiteDetails?> siteById(Ref ref, String siteId) async {
  try {
    AppLogger.i('🔄 Fetching site details for ID: $siteId');

    await Future.delayed(const Duration(milliseconds: 800));

    final allSites = await ref.watch(siteViewModelProvider.future);

    AppLogger.i('Total sites available: ${allSites.length}');
    AppLogger.i('Looking for site with ID: $siteId');

    final site = allSites.firstWhere(
          (s) {
        AppLogger.d('Checking site: ${s.id} (${s.name})');
        return s.id == siteId;
      },
      orElse: () {
        AppLogger.e('❌ Site not found with ID: $siteId');
        AppLogger.e('Available IDs: ${allSites.map((s) => s.id).join(", ")}');
        throw Exception('Site not found with ID: $siteId');
      },
    );

    final siteDetails = SiteDetails.fromSites(site);

    AppLogger.i('✅ Fetched site details for: ${siteDetails.name}');
    return siteDetails;
  } catch (e, stackTrace) {
    AppLogger.e('❌ Error fetching site $siteId: $e');
    AppLogger.e('Stack trace: $stackTrace');
    rethrow;
  }
}

// ============================================================================
// UPDATE SITE HELPER FUNCTION
// ============================================================================

Future<void> updateSite(WidgetRef ref, SiteDetails updatedSiteDetails) async {
  try {
    AppLogger.i('Updating site: ${updatedSiteDetails.name} (ID: ${updatedSiteDetails.id})');

    await Future.delayed(const Duration(milliseconds: 800));

    final updatedSite = Sites(
      id: updatedSiteDetails.id,
      name: updatedSiteDetails.name,
      location: updatedSiteDetails.fullAddress,
      ownerName: updatedSiteDetails.managerName,
      phoneNumber: updatedSiteDetails.phoneNumber,
      email: updatedSiteDetails.email,
      panVatNumber: null,
      latitude: updatedSiteDetails.latitude,
      longitude: updatedSiteDetails.longitude,
      notes: updatedSiteDetails.notes,
      dateJoined: updatedSiteDetails.dateJoined,
      isActive: updatedSiteDetails.isActive,
      createdAt: updatedSiteDetails.createdAt,
    );

    // Use the updateSite method from the ViewModel
    ref.read(siteViewModelProvider.notifier).updateSite(updatedSite);

    AppLogger.i('✅ Site updated successfully (local)');
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

  static String? validateManagerName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Manager name is required';
    }
    if (value.trim().length < 2) {
      return 'Manager name must be at least 2 characters';
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