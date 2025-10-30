import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/utils/field_validators.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/add-new-party/models/add_new_party.model.dart';

part 'add_new_party.vm.g.dart';

@riverpod
class AddPartyViewModel extends _$AddPartyViewModel {
  @override
  Future<AddPartyResponse?> build() async {
    // No initial data to load, just return null
    return null;
  }

  // --- Local Validation Methods ---

  String? validateCompanyName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Company name cannot be empty';
    }
    return null;
  }

  String? validateOwnerName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Owner name cannot be empty';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number cannot be empty';
    }
    // Exactly 10-digit phone validation
    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Phone number must be exactly 10 digits';
    }
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address cannot be empty';
    }
    return null;
  }

  String? validatePanVat(String? value) {
    if (value == null || value.isEmpty) {
      return 'PAN/VAT number cannot be empty';
    }
    // Alphanumeric validation with exactly 14 characters
    final panVatRegex = RegExp(r'^[A-Za-z0-9]{14}$');
    if (!panVatRegex.hasMatch(value.trim())) {
      return 'PAN/VAT must be exactly 14 alphanumeric characters';
    }
    return null;
  }

  String? validateGoogleMapLink(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    // Basic URL validation
    final urlRegex = RegExp(
        r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$');
    if (!urlRegex.hasMatch(value)) {
      return 'Enter a valid URL';
    }
    return null;
  }

  /// Add Party method - MOCKED for UI testing
  Future<void> addParty(AddPartyRequest request) async {
    // Reset previous errors
    state = const AsyncData(null);

    // --- 1. Run all local validations ---
    final fieldErrors = {
      'companyName': validateCompanyName(request.companyName),
      'ownerName': validateOwnerName(request.ownerName),
      'phone': validatePhone(request.phone),
      'address': validateAddress(request.address),
      'email': FieldValidators.validateEmail(request.email), // Reuse from login
      'panVatNumber': validatePanVat(request.panVatNumber),
      'googleMapLink': validateGoogleMapLink(request.googleMapLink),
    }..removeWhere((key, value) => value == null); // Remove valid fields

    if (fieldErrors.isNotEmpty) {
      AppLogger.w('Local validation failed: $fieldErrors');
      state = AsyncError(fieldErrors, StackTrace.empty);
      return;
    }

    // --- 2. Begin async API call ---
    state = const AsyncLoading();

    try {
      AppLogger.i('🎭 MOCK: Attempting to add new party: ${request.companyName}');

      // Simulate network delay (1-2 seconds)
      await Future.delayed(const Duration(milliseconds: 1500));

      // --- MOCK SUCCESSFUL RESPONSE ---
      final mockPartyResponse = AddPartyResponse(
        status: 'success',
        message: '🎉 Party "${request.companyName}" added successfully!',
        data: Party(
          id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
          companyName: request.companyName,
          ownerName: request.ownerName,
          phone: request.phone,
          address: request.address,
          email: request.email,
          panVatNumber: request.panVatNumber,
          googleMapLink: request.googleMapLink,
          latitude: request.latitude,
          longitude: request.longitude,
          organizationId: 'mock_org_123456',
          isActive: true,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          version: 0,
        ),
      );

      AppLogger.i('✅ MOCK: Party added successfully: ${mockPartyResponse.data.id}');

      // Save successful response in state
      state = AsyncData(mockPartyResponse);

      // TODO: When API is ready, replace mock with:
      // final dio = ref.read(dioClientProvider);
      // final response = await dio.post(
      //   ApiEndpoints.addParty,
      //   data: request.toJson(),
      // );
      // final addPartyResponse = AddPartyResponse.fromJson(response.data);
      // state = AsyncData(addPartyResponse);

    } catch (e, stack) {
      AppLogger.e('❌ Unexpected error during add party', e, stack);
      state = AsyncError(const {
        'general': 'Something went wrong. Please try again.',
      }, stack);
    }
  }
}