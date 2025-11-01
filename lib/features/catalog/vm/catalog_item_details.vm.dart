import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/features/catalog/models/catalog_item_details.model.dart';

part 'catalog_item_details.vm.g.dart';

// --- Provider to fetch a SINGLE item's details ---
@riverpod
Future<CatalogItemDetails> catalogItemDetails(
    Ref ref, // This type will be generated
    String itemId,
    ) async {

  // This provider will fetch and return a single item.
  try {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 700));

    // Get the mock data
    final mockItems = _getMockItemDetails();

    // Find the item or throw an error
    final item = mockItems.firstWhere(
          (i) => i.id == itemId,
      orElse: () => throw Exception('Item with ID $itemId not found'),
    );
    return item;
  } catch (e) {
    print('Error fetching item details: $e');
    rethrow;
  }
}

// --- Mock Data ---
// This is a private helper function to hold the detailed mock data
List<CatalogItemDetails> _getMockItemDetails() {
  return [
    const CatalogItemDetails(
      id: '101',
      name: 'Marble- Red',
      categoryId: '1',
      categoryName: 'Marble',
      subCategory: 'Plain',
      sku: 'SKU-4001',
      imageAssetPath: 'assets/images/marble_red.svg',
      price: 400.0,
      material: 'Natural Stone',
      origin: 'Italy/Spain',
      finish: 'Polished',
      application: 'Floor/Wall',
      durability: 'High',
      inStockSqFt: 5000,
    ),
    const CatalogItemDetails(
      id: '102',
      name: 'Marble- White',
      categoryId: '1',
      categoryName: 'Marble',
      subCategory: 'Plain',
      sku: 'SKU-4002',
      imageAssetPath: 'assets/images/placeholder_marble.png', // Use a real asset path
      price: 550.0,
      material: 'Natural Stone',
      origin: 'India',
      finish: 'Matte',
      application: 'Wall',
      durability: 'Medium',
      inStockSqFt: 3200,
    ),
    const CatalogItemDetails(
      id: '201',
      name: 'Tractor Emulsion (White)',
      categoryId: '2',
      categoryName: 'Paints',
      subCategory: 'Interior',
      sku: 'PAINT-001',
      imageAssetPath: 'assets/images/placeholder_paints.png', // Use a real asset path
      price: 1200.0,
      material: 'Acrylic Emulsion',
      origin: 'India',
      finish: 'Smooth',
      application: 'Interior Walls',
      durability: 'Good Washability',
      inStockSqFt: 10000, // Or in liters
    ),
    const CatalogItemDetails(
      id: '301',
      name: 'Basic Commode Set',
      categoryId: '3',
      categoryName: 'Sanitary',
      subCategory: 'Western',
      sku: 'SAN-101',
      imageAssetPath: 'assets/images/placeholder_sanitary.png', // Use a real asset path
      price: 3500.0,
      material: 'Ceramic',
      origin: 'China',
      finish: 'Glossy',
      application: 'Bathroom',
      durability: 'Standard',
      inStockSqFt: 50, // This might be a count of units
    ),
    // ... Add mock data for your other items (SKU-4003, 4004, 4005, etc.)
  ];
}
