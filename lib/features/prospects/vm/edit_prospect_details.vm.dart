// lib/features/prospects/vm/edit_prospect_details.vm.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ ADD THIS
import 'package:sales_sphere/features/prospects/models/edit_prospect_details.model.dart';
import 'package:sales_sphere/features/prospects/models/prospects.model.dart';
import 'package:sales_sphere/features/prospects/vm/prospects.vm.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'edit_prospect_details.vm.g.dart';

// ============================================================================
// STANDALONE PROVIDER FOR PROSPECT DETAILS
// ============================================================================

@riverpod
Future<ProspectDetails?> prospectById(Ref ref, String prospectId) async {
  try {
    AppLogger.i('🔄 Fetching prospect details for ID: $prospectId');

    await Future.delayed(const Duration(milliseconds: 800));

    final allProspects = await ref.watch(prospectViewModelProvider.future);

    AppLogger.i('Total prospects available: ${allProspects.length}');
    AppLogger.i('Looking for prospect with ID: $prospectId');

    final prospect = allProspects.firstWhere(
          (p) {
        AppLogger.d('Checking prospect: ${p.id} (${p.name})');
        return p.id == prospectId;
      },
      orElse: () {
        AppLogger.e('❌ Prospect not found with ID: $prospectId');
        AppLogger.e('Available IDs: ${allProspects.map((p) => p.id).join(", ")}');
        throw Exception('Prospect not found with ID: $prospectId');
      },
    );

    final prospectDetails = ProspectDetails.fromProspects(prospect);

    AppLogger.i('✅ Fetched prospect details for: ${prospectDetails.name}');
    return prospectDetails;
  } catch (e, stackTrace) {
    AppLogger.e('❌ Error fetching prospect $prospectId: $e');
    AppLogger.e('Stack trace: $stackTrace');
    rethrow;
  }
}

// ============================================================================
// UPDATE PROSPECT HELPER FUNCTION
// ============================================================================

// ✅ CHANGED: Ref → WidgetRef
Future<void> updateProspect(WidgetRef ref, ProspectDetails updatedProspectDetails) async {
  try {
    AppLogger.i('Updating prospect: ${updatedProspectDetails.name} (ID: ${updatedProspectDetails.id})');

    await Future.delayed(const Duration(milliseconds: 800));

    final updatedProspect = Prospects(
      id: updatedProspectDetails.id,
      name: updatedProspectDetails.name,
      location: updatedProspectDetails.fullAddress,
      ownerName: updatedProspectDetails.ownerName,
      phoneNumber: updatedProspectDetails.phoneNumber,
      email: updatedProspectDetails.email,
      panVatNumber: updatedProspectDetails.panVatNumber,
      latitude: updatedProspectDetails.latitude,
      longitude: updatedProspectDetails.longitude,
      notes: updatedProspectDetails.notes,
      dateJoined: updatedProspectDetails.dateJoined,
      isActive: updatedProspectDetails.isActive,
      createdAt: updatedProspectDetails.createdAt,
    );

    final currentProspects = await ref.read(prospectViewModelProvider.future);

    final updatedList = currentProspects.map((prospect) {
      if (prospect.id == updatedProspect.id) {
        return updatedProspect;
      }
      return prospect;
    }).toList();

    ref.read(prospectViewModelProvider.notifier).state =
        AsyncValue.data(updatedList);

    AppLogger.i('✅ Prospect updated successfully (local)');
  } catch (e, stackTrace) {
    AppLogger.e('❌ Error updating prospect: $e');
    AppLogger.e('Stack trace: $stackTrace');
    throw Exception('Failed to update prospect: $e');
  }
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