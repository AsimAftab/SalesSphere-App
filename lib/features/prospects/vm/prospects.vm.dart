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

  // Mock data based on your UI image
  List<Prospects> _getMockProspects() {
    return [
      Prospects(
        id: 'p1',
        name: 'Agarwal Traders',
        location: 'Binamod, Nepal',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Prospects(
        id: 'p2',
        name: 'Traders I',
        location: 'Location',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Prospects(
        id: 'p3',
        name: 'Traders II',
        location: 'Location',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Prospects(
        id: 'p4',
        name: 'Traders III',
        location: 'Location',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      Prospects(
        id: 'p5',
        name: 'Trader IV',
        location: 'Location',
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