import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/features/catalog/models/catalog_item.model.dart';

part 'catalog_list.vm.g.dart';

@riverpod
class CategoryItemListViewModel extends _$CategoryItemListViewModel {
  @override
  late String categoryId;

  @override
  FutureOr<List<CatalogItem>> build(String categoryId) async {
    this.categoryId = categoryId;
    return _fetchItemsForCategory(categoryId);
  }

  Future<List<CatalogItem>> _fetchItemsForCategory(String categoryId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      return _getMockItems()
          .where((item) => item.categoryId == categoryId)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch items for category $categoryId: $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchItemsForCategory(categoryId));
  }

  // --- Mock Data ---
  List<CatalogItem> _getMockItems() {
    return [
      const CatalogItem(
        id: '101',
        name: 'Marble',
        categoryId: '1',
        subCategory: 'Plain',
        sku: 'SKU-4001',
        imageAssetPath: 'assets/images/placeholder_marble.png',
      ),
      const CatalogItem(
        id: '102',
        name: 'Marble Red',
        categoryId: '1',
        subCategory: 'Plain',
        sku: 'SKU-4002',
        imageAssetPath: 'assets/images/placeholder_marble_red.png',
      ),
      const CatalogItem(
        id: '103',
        name: 'Marble-Blue',
        categoryId: '1',
        subCategory: 'Plain',
        sku: 'SKU-4003',
        imageAssetPath: 'assets/images/placeholder_marble_blue.png',
      ),
      const CatalogItem(
        id: '104',
        name: 'Marble-yellow',
        categoryId: '1',
        subCategory: 'Plain',
        sku: 'SKU-4004',
        imageAssetPath: 'assets/images/placeholder_marble_yellow.png',
      ),
      const CatalogItem(
        id: '105',
        name: 'Marble - Emerald',
        categoryId: '1',
        subCategory: 'Plain',
        sku: 'SKU-4005',
        imageAssetPath: 'assets/images/placeholder_marble_emerald.png',
      ),
      const CatalogItem(
        id: '201',
        name: 'Tractor Emulsion',
        categoryId: '2',
        subCategory: 'Interior',
        sku: 'PAINT-001',
        imageAssetPath: 'assets/images/placeholder_paints.png',
      ),
      const CatalogItem(
        id: '301',
        name: 'Basic Commode Set',
        categoryId: '3',
        subCategory: 'Western',
        sku: 'SAN-101',
        imageAssetPath: 'assets/images/placeholder_sanitary.png',
      ),
    ];
  }
}

/// --- Search Query Provider ---
@riverpod
class ItemListSearchQuery extends _$ItemListSearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }

  void clearQuery() {
    state = '';
  }
}

/// --- Filtered / Searched Items Provider ---
@riverpod
Future<List<CatalogItem>> searchedCategoryItems(
    Ref ref,
    String categoryId,
    ) async {
  final searchQuery = ref.watch(itemListSearchQueryProvider);
  final allItemsAsync = ref.watch(categoryItemListViewModelProvider(categoryId));

  return allItemsAsync.when(
    data: (allItems) {
      if (searchQuery.isEmpty) return allItems;

      final lowerQuery = searchQuery.toLowerCase();
      return allItems.where((item) {
        return item.name.toLowerCase().contains(lowerQuery) ||
            (item.sku?.toLowerCase().contains(lowerQuery) ?? false) ||
            (item.subCategory?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
}