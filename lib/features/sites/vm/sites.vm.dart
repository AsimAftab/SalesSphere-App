// lib/features/sites/vm/sites.vm.dart

import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/features/sites/models/sites.model.dart';

part 'sites.vm.g.dart';

/// Main Sites ViewModel - Manages all sites
@riverpod
class SiteViewModel extends _$SiteViewModel {
  @override
  FutureOr<List<Sites>> build() async {
    return _fetchSites();
  }

  Future<List<Sites>> _fetchSites() async {
    try {
      // Simulate network delay for loading skeleton
      await Future.delayed(const Duration(milliseconds: 1200));
      return _getMockSites();
    } catch (e) {
      throw Exception('Failed to fetch sites: $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchSites);
  }

  // Add a site to the list
  void addSite(Sites newSite) {
    state.whenData((currentSites) {
      // Add the new site to the beginning of the list
      final updatedList = [newSite, ...currentSites];
      state = AsyncValue.data(updatedList);
    });
  }

  // Mock data with ALL fields
  List<Sites> _getMockSites() {
    return [
      Sites(
        id: 's1',
        name: 'Downtown Construction Site',
        location: 'Mumbai, Maharashtra',
        ownerName: 'Rajesh Kumar',
        phoneNumber: '9876543210',
        email: 'rajesh.kumar@site.com',
        panVatNumber: 'ABCDE1234F',
        latitude: 19.0760,
        longitude: 72.8777,
        notes: 'Large commercial project',
        dateJoined: '2024-01-15',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Sites(
        id: 's2',
        name: 'Residential Complex Site',
        location: 'Bangalore, Karnataka',
        ownerName: 'Priya Sharma',
        phoneNumber: '9876543211',
        email: 'priya@residentialsite.com',
        panVatNumber: 'FGHIJ5678K',
        latitude: 12.9716,
        longitude: 77.5946,
        notes: 'Luxury apartments',
        dateJoined: '2024-01-10',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Sites(
        id: 's3',
        name: 'Industrial Park Site',
        location: 'Pune, Maharashtra',
        ownerName: 'Amit Patel',
        phoneNumber: '9876543212',
        email: null,
        panVatNumber: null,
        latitude: 18.5204,
        longitude: 73.8567,
        notes: null,
        dateJoined: '2024-01-05',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Sites(
        id: 's4',
        name: 'Tech Park Site',
        location: 'Hyderabad, Telangana',
        ownerName: 'Sneha Reddy',
        phoneNumber: '9876543213',
        email: null,
        panVatNumber: null,
        latitude: 17.3850,
        longitude: 78.4867,
        notes: null,
        dateJoined: '2024-01-03',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      Sites(
        id: 's5',
        name: 'Highway Project Site',
        location: 'Delhi NCR',
        ownerName: 'Vikram Singh',
        phoneNumber: '9876543214',
        email: null,
        panVatNumber: null,
        latitude: 28.7041,
        longitude: 77.1025,
        notes: null,
        dateJoined: '2024-01-01',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Sites(
        id: 's6',
        name: 'Mall Construction Site',
        location: 'Chennai, Tamil Nadu',
        ownerName: 'Lakshmi Iyer',
        phoneNumber: '9876543215',
        email: 'lakshmi@mall.com',
        panVatNumber: 'MNOPQ9012R',
        latitude: 13.0827,
        longitude: 80.2707,
        notes: 'Shopping complex',
        dateJoined: '2023-12-28',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
      ),
      Sites(
        id: 's7',
        name: 'Airport Expansion Site',
        location: 'Kolkata, West Bengal',
        ownerName: 'Subhash Ghosh',
        phoneNumber: '9876543216',
        email: null,
        panVatNumber: null,
        latitude: 22.5726,
        longitude: 88.3639,
        notes: null,
        dateJoined: '2023-12-25',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
  }
}

/// Search Query Provider
@riverpod
class SiteSearchQuery extends _$SiteSearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }

  void clearQuery() {
    state = '';
  }
}

/// Provider for Searched/Filtered Sites
@riverpod
class SearchedSites extends _$SearchedSites {
  @override
  FutureOr<List<Sites>> build() async {
    final searchQuery = ref.watch(siteSearchQueryProvider);
    final allSites = await ref.watch(siteViewModelProvider.future);

    if (searchQuery.isEmpty) return allSites;

    final lowerQuery = searchQuery.toLowerCase();
    return allSites.where((site) {
      return site.name.toLowerCase().contains(lowerQuery) ||
          site.location.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

/// Site Count Provider
@riverpod
int siteCount(Ref ref) {
  final sitesAsync = ref.watch(siteViewModelProvider);

  return sitesAsync.when(
    data: (sites) => sites.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}