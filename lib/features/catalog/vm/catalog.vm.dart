import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/features/catalog/models/catalog.model.dart';

part 'catalog.vm.g.dart';

@riverpod
class CatalogViewModel extends _$CatalogViewModel {
  @override
  FutureOr<List<CatalogCategory>> build() async {
    // Initial state - fetch all categories
    return _fetchCategories();
  }

  // Fetch all categories from API/Database
  Future<List<CatalogCategory>> _fetchCategories() async {
    try {
      // Mock data for now, simulating a network delay
      await Future.delayed(const Duration(milliseconds: 800));
      return _getMockCategories();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  // Refresh categories list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchCategories);
  }

  // --- Mock Data (based on your image) ---
  List<CatalogCategory> _getMockCategories() {
    return [
      CatalogCategory(
        id: '1',
        name: 'Marble',
        imageAssetPath: 'assets/images/placeholder_marble.png',
        itemCount: 125,
      ),
      CatalogCategory(
        id: '2',
        name: 'Paints',
        imageAssetPath: 'assets/images/placeholder_paints.png',
        itemCount: 88,
      ),
      CatalogCategory(
        id: '3',
        name: 'Sanitary',
        imageAssetPath: 'assets/images/placeholder_sanitary.png',
        itemCount: 210,
      ),
      CatalogCategory(
        id: '4',
        name: 'Cpvc',
        imageAssetPath: 'assets/images/placeholder_cpvc.png',
        itemCount: 74,
      ),
      CatalogCategory(
        id: '5',
        name: 'Ply',
        imageAssetPath: 'assets/images/placeholder_ply.png',
        itemCount: 45,
      ),
      CatalogCategory(
        id: '6',
        name: 'Pla',
        imageAssetPath: 'assets/images/placeholder_pla.png',
        itemCount: 50,
      ),
    ];
  }
}

// --- Search Query Provider ---
@riverpod
class CatalogSearchQuery extends _$CatalogSearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }

  void clearQuery() {
    state = '';
  }
}

// --- Provider for Searched/Filtered Categories ---
@riverpod
Future<List<CatalogCategory>> searchedCategories(Ref ref) async {
  final searchQuery = ref.watch(catalogSearchQueryProvider);

  // This propagates the loading state.
  final allCategories = await ref.watch(catalogViewModelProvider.future);

  if (searchQuery.isEmpty) return allCategories;

  final lowerQuery = searchQuery.toLowerCase();
  return allCategories.where((category) {
    return category.name.toLowerCase().contains(lowerQuery);
  }).toList();
}