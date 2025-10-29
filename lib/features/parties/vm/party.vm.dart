// lib/features/parties/vm/parties.vm.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';
import 'package:sales_sphere/features/parties/models/party_details.model.dart';

part 'party.vm.g.dart';

@riverpod
class PartyViewModel extends _$PartyViewModel {
  @override
  FutureOr<List<PartyDetails>> build() async {
    // Initial state - fetch all parties
    return _fetchParties();
  }

  // Fetch all parties from API/Database
  Future<List<PartyDetails>> _fetchParties() async {
    try {
      // Mock data for now
      await Future.delayed(const Duration(seconds: 1));
      return getMockParties();
    } catch (e) {
      throw Exception('Failed to fetch parties: $e');
    }
  }

  // Get parties by ID
  Future<PartyDetails?> getPartyById(String id) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Get directly from mock data
      final allParties = getMockParties();

      final party = allParties.firstWhere(
            (party) => party.id == id,
        orElse: () => throw Exception('Party not found with ID: $id'),
      );

      return party;
    } catch (e) {
      throw Exception('Failed to get parties: $e');
    }
  }

  // Add new parties
  Future<void> addParty(PartyDetails party) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentParties = state.value ?? [];
      return [...currentParties, party];
    });
  }

  // Update existing parties
  Future<void> updateParty(PartyDetails party) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentParties = state.value ?? [];
      return currentParties.map((p) => p.id == party.id ? party : p).toList();
    });
  }

  // Delete parties
  Future<void> deleteParty(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentParties = state.value ?? [];
      return currentParties.where((p) => p.id != id).toList();
    });
  }

  // Search parties by query
  List<PartyDetails> searchParties(String query) {
    final parties = state.value ?? [];
    if (query.isEmpty) return parties;

    final lowerQuery = query.toLowerCase();
    return parties.where((party) {
      return party.name.toLowerCase().contains(lowerQuery) ||
          party.phoneNumber.contains(query) ||
          party.ownerName.toLowerCase().contains(lowerQuery) ||
          party.fullAddress.toLowerCase().contains(lowerQuery) ||
          (party.email?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  // Filter by active status
  List<PartyDetails> filterByActiveStatus(bool isActive) {
    final parties = state.value ?? [];
    return parties.where((party) => party.isActive == isActive).toList();
  }

  // Refresh parties list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchParties);
  }

  // Local validation for fields (can be used in UI)
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[\d\s-()]+$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  // ✅ Changed to public method so it can be called from getPartyById
  List<PartyDetails> getMockParties() {
    return [
      PartyDetails(
        id: '1',
        name: 'Agarwal Traders',
        ownerName: 'Rajesh Agarwal',
        panVatNumber: 'GST12345678',
        phoneNumber: '9800000000',
        email: 'rajesh@agarwaltraders.com',
        fullAddress: '123 MG Road, Mumbai, Maharashtra, 400001, India',
        latitude: 19.0760,
        longitude: 72.8777,
        notes: 'Regular customer, good payment history',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      PartyDetails(
        id: '2',
        name: 'Kumar Enterprises',
        ownerName: 'Suresh Kumar',
        panVatNumber: 'GST87654321',
        phoneNumber: '9875632415',
        email: 'suresh@kumarenterprises.com',
        fullAddress: '456 Park Street, Delhi, 110001, India',
        latitude: 28.6139,
        longitude: 77.2090,
        notes: 'Reliable vendor',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now(),
      ),
      PartyDetails(
        id: '3',
        name: 'Shah & Sons',
        ownerName: 'Ashok Shah',
        panVatNumber: 'GST11223344',
        phoneNumber: '9856314789',
        email: 'ashok@shahandsons.com',
        fullAddress: '789 Link Road, Ahmedabad, Gujarat, 380001, India',
        latitude: 23.0225,
        longitude: 72.5714,
        notes: 'New supplier, on trial period',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}

// ✅ NEW: Standalone provider to fetch a single parties by ID
@riverpod
Future<PartyDetails?> partyById(Ref ref, String partyId) async {
  try {
    print('🔍 Fetching parties with ID: $partyId');

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Get mock parties
    final mockParties = [
      PartyDetails(
        id: '1',
        name: 'Agarwal Traders',
        ownerName: 'Rajesh Agarwal',
        panVatNumber: 'GST12345678',
        phoneNumber: '9824643789',
        email: 'rajesh@agarwaltraders.com',
        fullAddress: '123 MG Road, Mumbai, Maharashtra, 400001, India',
        latitude: 19.0760,
        longitude: 72.8777,
        notes: 'Regular customer, good payment history',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      PartyDetails(
        id: '2',
        name: 'Kumar Enterprises',
        ownerName: 'Suresh Kumar',
        panVatNumber: 'GST87654321',
        phoneNumber: '9845632145',
        email: 'suresh@kumarenterprises.com',
        fullAddress: '456 Park Street, Delhi, 110001, India',
        latitude: 28.6139,
        longitude: 77.2090,
        notes: 'Reliable vendor',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now(),
      ),
      PartyDetails(
        id: '3',
        name: 'Shah & Sons',
        ownerName: 'Ashok Shah',
        panVatNumber: 'GST11223344',
        phoneNumber: '9863254125',
        email: 'ashok@shahandsons.com',
        fullAddress: '789 Link Road, Ahmedabad, Gujarat, 380001, India',
        latitude: 23.0225,
        longitude: 72.5714,
        notes: 'New supplier, on trial period',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
    ];

    final party = mockParties.firstWhere(
          (p) => p.id == partyId,
      orElse: () => throw Exception('Party not found with ID: $partyId'),
    );

    print('✅ Found parties: ${party.name}');
    return party;
  } catch (e) {
    print('❌ Error: $e');
    rethrow;
  }
}