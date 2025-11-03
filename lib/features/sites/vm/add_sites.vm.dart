// lib/features/sites/vm/add_sites.vm.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/features/sites/models/sites.model.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'add_sites.vm.g.dart';

// ============================================================================
// ADD SITE VIEW MODEL
// Handles: Create new site (Local only - No API)
// ============================================================================

@riverpod
class AddSiteViewModel extends _$AddSiteViewModel {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  // CREATE NEW SITE (LOCAL MOCK - NO API)
  Future<Sites> createSite(CreateSiteRequest newSiteRequest) async {
    try {
      AppLogger.i('Creating new site: ${newSiteRequest.name}');

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Generate a unique ID (in real app, this comes from API)
      final newId = 's${DateTime.now().millisecondsSinceEpoch}';

      // Convert request to Sites model
      final createdSite = newSiteRequest.toSites(newId);

      AppLogger.i('✅ Site created successfully (local): ${createdSite.name}');

      // Return the created site - screen will add it to the list
      return createdSite;
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