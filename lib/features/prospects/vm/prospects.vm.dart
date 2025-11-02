import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/features/prospects/models/prospects.model.dart';

part 'prospects.vm.g.dart';

/// Main Prospects ViewModel - Manages all prospects
@riverpod
class ProspectViewModel extends _$ProspectViewModel {
  @override
  FutureOr<List<Prospects>> build() async {
    return _fetchProspects();
  }

  Future<List<Prospects>> _fetchProspects() async {
    try {
      // Simulate network delay for loading skeleton
      await Future.delayed(const Duration(milliseconds: 1200));
      return _getMockProspects();
    } catch (e) {
      throw Exception('Failed to fetch prospects: $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchProspects);
  }

  // Add a prospect to the list
  void addProspect(Prospects newProspect) {
    state.whenData((currentProspects) {
      // Add the new prospect to the beginning of the list
      final updatedList = [newProspect, ...currentProspects];
      state = AsyncValue.data(updatedList);
    });
  }

  // Mock data with ALL fields
  List<Prospects> _getMockProspects() {
    return [
      Prospects(
        id: 'p1',
        name: 'Agarwal Traders',
        location: 'Binamod, Nepal',
        ownerName: 'Rajesh Agarwal',
        phoneNumber: '9876543210',
        email: 'rajesh@agarwaltraders.com',
        panVatNumber: '1234567890',
        latitude: 27.7172,
        longitude: 85.3240,
        notes: 'Premium customer',
        dateJoined: '2024-01-15',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Prospects(
        id: 'p2',
        name: 'Traders I',
        location: 'Kathmandu, Nepal',
        ownerName: 'Owner I',
        phoneNumber: '9876543211',
        email: 'owner1@traders.com',
        panVatNumber: null,
        latitude: 27.7172,
        longitude: 85.3240,
        notes: null,
        dateJoined: '2024-01-10',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Prospects(
        id: 'p3',
        name: 'Traders II',
        location: 'Pokhara, Nepal',
        ownerName: 'Owner II',
        phoneNumber: '9876543212',
        email: null,
        panVatNumber: null,
        latitude: 28.2096,
        longitude: 83.9856,
        notes: null,
        dateJoined: '2024-01-05',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Prospects(
        id: 'p4',
        name: 'Traders III',
        location: 'Lalitpur, Nepal',
        ownerName: 'Owner III',
        phoneNumber: '9876543213',
        email: null,
        panVatNumber: null,
        latitude: 27.6710,
        longitude: 85.3238,
        notes: null,
        dateJoined: '2024-01-03',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      Prospects(
        id: 'p5',
        name: 'Trader IV',
        location: 'Bhaktapur, Nepal',
        ownerName: 'Owner IV',
        phoneNumber: '9876543214',
        email: null,
        panVatNumber: null,
        latitude: 27.6710,
        longitude: 85.4298,
        notes: null,
        dateJoined: '2024-01-01',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
  }
}

/// Search Query Provider
@riverpod
class ProspectSearchQuery extends _$ProspectSearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }

  void clearQuery() {
    state = '';
  }
}

/// Provider for Searched/Filtered Prospects
@riverpod
class SearchedProspects extends _$SearchedProspects {
  @override
  FutureOr<List<Prospects>> build() async {
    final searchQuery = ref.watch(prospectSearchQueryProvider);
    final allProspects = await ref.watch(prospectViewModelProvider.future);

    if (searchQuery.isEmpty) return allProspects;

    final lowerQuery = searchQuery.toLowerCase();
    return allProspects.where((prospect) {
      return prospect.name.toLowerCase().contains(lowerQuery) ||
          prospect.location.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

/// Prospect Count Provider
@riverpod
int prospectCount(Ref ref) {
  final prospectsAsync = ref.watch(prospectViewModelProvider);

  return prospectsAsync.when(
    data: (prospects) => prospects.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}