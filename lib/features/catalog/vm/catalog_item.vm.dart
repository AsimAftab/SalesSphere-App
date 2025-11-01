import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/features/catalog/models/catalog_item.model.dart';

part 'catalog_item.vm.g.dart';

@riverpod
class CategoryItemListViewModel extends _$CategoryItemListViewModel {
  late String categoryId;

  @override
  FutureOr<List<CatalogItem>> build(String categoryId) async {
    this.categoryId = categoryId;
    return _fetchItemsForCategory(categoryId);
  }

  // Fetch items for a specific category (replace with your actual API/DB call)
  Future<List<CatalogItem>> _fetchItemsForCategory(String categoryId) async {
    try {
      // You can add an artificial delay here for testing skeletons
      // await Future.delayed(const Duration(seconds: 3));
      await Future.delayed(const Duration(milliseconds: 600));
      return _getMockItems()
          .where((item) => item.categoryId == categoryId)
          .toList();
    } catch (e) {
      print('Error fetching items for category $categoryId: $e');
      throw Exception('Failed to fetch items: $e');
    }
  }

  // Refresh the list for the current category
  Future<void> refresh() async {
    state = const AsyncValue.loading(); // Set state to loading
    // Re-fetch data using the stored categoryId
    state = await AsyncValue.guard(() => _fetchItemsForCategory(categoryId));
  }

  // --- Mock Data (Replace with your actual data source) ---
  List<CatalogItem> _getMockItems() {
    // Example mock data - ensure categoryIds match your actual categories
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

  final allItems = await ref.watch(categoryItemListViewModelProvider(categoryId).future);

  if (searchQuery.isEmpty) return allItems;

  final lowerQuery = searchQuery.toLowerCase();
  return allItems.where((item) {
    return item.name.toLowerCase().contains(lowerQuery) ||
        (item.sku?.toLowerCase().contains(lowerQuery) ?? false) ||
        (item.subCategory?.toLowerCase().contains(lowerQuery) ?? false);
  }).toList();
}
