// lib/features/prospects/vm/add_prospect.vm.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/features/prospects/models/add_prospect.model.dart';
import 'package:sales_sphere/features/prospects/models/prospects.model.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'add_prospect.vm.g.dart';

// ============================================================================
// ADD PROSPECT VIEW MODEL
// Handles: Create new prospect (Local only - No API)
// ============================================================================

@riverpod
class AddProspectViewModel extends _$AddProspectViewModel {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  // CREATE NEW PROSPECT (LOCAL MOCK - NO API)
  Future<Prospects> createProspect(CreateProspectRequest newProspectRequest) async {
    try {
      AppLogger.i('Creating new prospect: ${newProspectRequest.name}');

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Generate a unique ID (in real app, this comes from API)
      final newId = 'p${DateTime.now().millisecondsSinceEpoch}';

      // Convert request to Prospects model
      final createdProspect = newProspectRequest.toProspects(newId);

      AppLogger.i('✅ Prospect created successfully (local): ${createdProspect.name}');

      // Return the created prospect - screen will add it to the list
      return createdProspect;
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error creating prospect: $e');
      AppLogger.e('Stack trace: $stackTrace');
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
    // ✅ OPTIONAL - Can be empty
    if (value == null || value.trim().isEmpty) {
      return null; // Valid if empty
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