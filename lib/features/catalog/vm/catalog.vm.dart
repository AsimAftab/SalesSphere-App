import 'dart:async';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/features/catalog/models/catalog.models.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/catalog/vm/catalog_item.vm.dart';
import 'package:sales_sphere/core/providers/connectivity_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

part 'catalog.vm.g.dart';

@riverpod
class CatalogViewModel extends _$CatalogViewModel {
  bool _isFetching = false;

  @override
  FutureOr<List<CatalogCategory>> build() async {
    // Keep alive for 60 seconds after last use (prevents disposal on tab switch)
    final link = ref.keepAlive();
    Timer(const Duration(seconds: 60), () {
      link.close();
    });

    // Initial state - fetch all categories
    // Global connectivity wrapper handles offline/online transitions
    return _fetchCategories();
  }

  // Fetch all categories from API/Database
  Future<List<CatalogCategory>> _fetchCategories() async {
    // Guard: prevent concurrent fetches
    if (_isFetching) {
      AppLogger.w('⚠️ Already fetching categories, skipping duplicate request');
      throw Exception('Fetch already in progress');
    }

    _isFetching = true;
    try {
      final dio = ref.read(dioClientProvider);

      AppLogger.i('Fetching categories from API...');
      final response = await dio.get(ApiEndpoints.categories);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> categoriesJson = response.data['data'] ?? [];
        final categories = categoriesJson
            .map(
              (json) => CatalogCategory.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        AppLogger.i('✅ Fetched ${categories.length} categories');
        return categories;
      } else {
        throw Exception('API returned unsuccessful response');
      }
    } on DioException catch (e) {
      AppLogger.e('Failed to fetch categories: ${e.message}');
      throw Exception('Failed to fetch categories: ${e.message}');
    } catch (e) {
      AppLogger.e('Unexpected error fetching categories: $e');
      throw Exception('Failed to fetch categories: $e');
    } finally {
      _isFetching = false;
    }
  }

  // Refresh categories list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchCategories);
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

// --- Selected Category Provider ---
@riverpod
class SelectedCategory extends _$SelectedCategory {
  @override
  String? build() => null;

  void selectCategory(String? categoryId) {
    state = categoryId;
  }

  void clearSelection() {
    state = null;
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

// --- Provider for Categories with Products Only ---
/// Filters out categories that have no products
@riverpod
Future<List<CatalogCategory>> categoriesWithProducts(Ref ref) async {
  try {
    // Get all categories and products
    final allCategories = await ref.watch(catalogViewModelProvider.future);
    final allProducts = await ref.watch(allCatalogItemsProvider.future);

    // If there are no products, return empty list
    if (allProducts.isEmpty) {
      AppLogger.i('No products found, returning empty categories list');
      return [];
    }

    // Get unique category IDs from products
    final productCategoryIds = allProducts
        .map((product) => product.category.id)
        .toSet();

    // Filter categories that have at least one product
    final categoriesWithItems = allCategories.where((category) {
      return productCategoryIds.contains(category.id);
    }).toList();

    AppLogger.i(
      '✅ Filtered ${categoriesWithItems.length} categories with products out of ${allCategories.length} total categories',
    );

    return categoriesWithItems;
  } catch (e) {
    AppLogger.e('Error filtering categories with products: $e');
    rethrow;
  }
}
