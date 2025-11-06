import 'dart:async';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/features/catalog/models/catalog.models.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'catalog_item.vm.g.dart';

// --- Mock Data Removed - Now Using Real API ---

@riverpod
class CategoryItemListViewModel extends _$CategoryItemListViewModel {
  late String categoryId;

  @override
  FutureOr<List<CatalogItem>> build(String categoryId) async {
    this.categoryId = categoryId;
    return _fetchItemsForCategory(categoryId);
  }

  // Fetch items for a specific category from API
  Future<List<CatalogItem>> _fetchItemsForCategory(String categoryId) async {
    try {
      final dio = ref.read(dioClientProvider);

      AppLogger.i('Fetching products for category: $categoryId');
      final response = await dio.get(ApiEndpoints.products);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> productsJson = response.data['data'] ?? [];
        final allProducts = productsJson
            .map((json) => CatalogItem.fromJson(json as Map<String, dynamic>))
            .toList();

        // Filter by category ID
        final categoryProducts = allProducts
            .where((item) => item.category.id == categoryId)
            .toList();

        AppLogger.i('✅ Fetched ${categoryProducts.length} products for category $categoryId');
        return categoryProducts;
      } else {
        throw Exception('API returned unsuccessful response');
      }
    } on DioException catch (e) {
      AppLogger.e('Failed to fetch products for category $categoryId: ${e.message}');
      throw Exception('Failed to fetch products: ${e.message}');
    } catch (e) {
      AppLogger.e('Unexpected error fetching products for category $categoryId: $e');
      throw Exception('Failed to fetch products: $e');
    }
  }

  // Refresh the list for the current category
  Future<void> refresh() async {
    state = const AsyncValue.loading(); // Set state to loading
    // Re-fetch data using the stored categoryId
    state = await AsyncValue.guard(() => _fetchItemsForCategory(categoryId));
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

/// --- Provider for ALL catalog items (no category filtering) ---
/// This loads all items once and caches them for better performance
@riverpod
class AllCatalogItems extends _$AllCatalogItems {
  @override
  FutureOr<List<CatalogItem>> build() async {
    return _fetchAllProducts();
  }

  // Fetch all products from API
  Future<List<CatalogItem>> _fetchAllProducts() async {
    try {
      final dio = ref.read(dioClientProvider);

      AppLogger.i('Fetching all products from API...');
      final response = await dio.get(ApiEndpoints.products);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> productsJson = response.data['data'] ?? [];
        final products = productsJson
            .map((json) => CatalogItem.fromJson(json as Map<String, dynamic>))
            .toList();

        AppLogger.i('✅ Fetched ${products.length} products');
        return products;
      } else {
        throw Exception('API returned unsuccessful response');
      }
    } on DioException catch (e) {
      AppLogger.e('Failed to fetch products: ${e.message}');
      throw Exception('Failed to fetch products: ${e.message}');
    } catch (e) {
      AppLogger.e('Unexpected error fetching products: $e');
      throw Exception('Failed to fetch products: $e');
    }
  }

  // Refresh all items
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchAllProducts);
  }
}
