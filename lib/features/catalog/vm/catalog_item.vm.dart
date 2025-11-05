import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/features/catalog/models/catalog.models.dart';

part 'catalog_item.vm.g.dart';

// --- Mock Data Helper (extracted for reuse) ---
List<CatalogItem> _getAllMockItems() {
  return [
    // Marble Category (id: '1') - 7 items
    const CatalogItem(
      id: '101',
      name: 'Italian White Marble',
      categoryId: '1',
      subCategory: 'Premium',
      sku: 'MAR-001',
      imageAssetPath: 'assets/images/products/marble_white.jpg',
      price: 450.0,
      quantity: 120,
    ),
    const CatalogItem(
      id: '102',
      name: 'Carrara Marble',
      categoryId: '1',
      subCategory: 'Classic',
      sku: 'MAR-002',
      imageAssetPath: 'assets/images/products/marble_carrara.jpg',
      price: 380.0,
      quantity: 85,
    ),
    const CatalogItem(
      id: '103',
      name: 'Black Galaxy Marble',
      categoryId: '1',
      subCategory: 'Exotic',
      sku: 'MAR-003',
      imageAssetPath: 'assets/images/products/marble_black.jpg',
      price: 520.0,
      quantity: 65,
    ),
    const CatalogItem(
      id: '104',
      name: 'Statuario Marble',
      categoryId: '1',
      subCategory: 'Luxury',
      sku: 'MAR-004',
      imageAssetPath: 'assets/images/products/marble_statuario.jpg',
      price: 680.0,
      quantity: 45,
    ),
    const CatalogItem(
      id: '105',
      name: 'Emperador Marble',
      categoryId: '1',
      subCategory: 'Brown',
      sku: 'MAR-005',
      imageAssetPath: 'assets/images/products/marble_emperador.jpg',
      price: 420.0,
      quantity: 95,
    ),
    const CatalogItem(
      id: '106',
      name: 'Crema Marfil Marble',
      categoryId: '1',
      subCategory: 'Beige',
      sku: 'MAR-006',
      imageAssetPath: 'assets/images/products/marble_crema.jpg',
      price: 390.0,
      quantity: 110,
    ),
    const CatalogItem(
      id: '107',
      name: 'Green Marble',
      categoryId: '1',
      subCategory: 'Exotic',
      sku: 'MAR-007',
      imageAssetPath: 'assets/images/products/marble_green.jpg',
      price: 550.0,
      quantity: 75,
    ),

    // Paints Category (id: '2') - 7 items
    const CatalogItem(
      id: '201',
      name: 'Asian Paints Royale',
      categoryId: '2',
      subCategory: 'Premium',
      sku: 'PAI-001',
      imageAssetPath: 'assets/images/products/paint_royale.jpg',
      price: 850.0,
      quantity: 200,
    ),
    const CatalogItem(
      id: '202',
      name: 'Berger Easy Clean',
      categoryId: '2',
      subCategory: 'Interior',
      sku: 'PAI-002',
      imageAssetPath: 'assets/images/products/paint_berger.jpg',
      price: 720.0,
      quantity: 150,
    ),
    const CatalogItem(
      id: '203',
      name: 'Nerolac Excel',
      categoryId: '2',
      subCategory: 'Interior',
      sku: 'PAI-003',
      imageAssetPath: 'assets/images/products/paint_nerolac.jpg',
      price: 680.0,
      quantity: 180,
    ),
    const CatalogItem(
      id: '204',
      name: 'Dulux Weathershield',
      categoryId: '2',
      subCategory: 'Exterior',
      sku: 'PAI-004',
      imageAssetPath: 'assets/images/products/paint_dulux.jpg',
      price: 920.0,
      quantity: 130,
    ),
    const CatalogItem(
      id: '205',
      name: 'Asian Paints Apcolite',
      categoryId: '2',
      subCategory: 'Emulsion',
      sku: 'PAI-005',
      imageAssetPath: 'assets/images/products/paint_apcolite.jpg',
      price: 780.0,
      quantity: 165,
    ),
    const CatalogItem(
      id: '206',
      name: 'Berger Weather Coat',
      categoryId: '2',
      subCategory: 'Exterior',
      sku: 'PAI-006',
      imageAssetPath: 'assets/images/products/paint_weathercoat.jpg',
      price: 890.0,
      quantity: 140,
    ),
    const CatalogItem(
      id: '207',
      name: 'Nerolac Impressions',
      categoryId: '2',
      subCategory: 'Designer',
      sku: 'PAI-007',
      imageAssetPath: 'assets/images/products/paint_impressions.jpg',
      price: 950.0,
      quantity: 120,
    ),

    // Sanitary Category (id: '3') - 7 items
    const CatalogItem(
      id: '301',
      name: 'Hindware Wash Basin',
      categoryId: '3',
      subCategory: 'Basin',
      sku: 'SAN-001',
      imageAssetPath: 'assets/images/products/sanitary_basin.jpg',
      price: 3200.0,
      quantity: 45,
    ),
    const CatalogItem(
      id: '302',
      name: 'Parryware Toilet Seat',
      categoryId: '3',
      subCategory: 'Toilet',
      sku: 'SAN-002',
      imageAssetPath: 'assets/images/products/sanitary_toilet.jpg',
      price: 4500.0,
      quantity: 35,
    ),
    const CatalogItem(
      id: '303',
      name: 'Jaquar Shower',
      categoryId: '3',
      subCategory: 'Shower',
      sku: 'SAN-003',
      imageAssetPath: 'assets/images/products/sanitary_shower.jpg',
      price: 2800.0,
      quantity: 60,
    ),
    const CatalogItem(
      id: '304',
      name: 'Cera Faucet',
      categoryId: '3',
      subCategory: 'Faucet',
      sku: 'SAN-004',
      imageAssetPath: 'assets/images/products/sanitary_faucet.jpg',
      price: 1500.0,
      quantity: 80,
    ),
    const CatalogItem(
      id: '305',
      name: 'Kohler Bathtub',
      categoryId: '3',
      subCategory: 'Bathtub',
      sku: 'SAN-005',
      imageAssetPath: 'assets/images/products/sanitary_bathtub.jpg',
      price: 25000.0,
      quantity: 15,
    ),
    const CatalogItem(
      id: '306',
      name: 'Grohe Kitchen Sink',
      categoryId: '3',
      subCategory: 'Sink',
      sku: 'SAN-006',
      imageAssetPath: 'assets/images/products/sanitary_sink.jpg',
      price: 5500.0,
      quantity: 30,
    ),
    const CatalogItem(
      id: '307',
      name: 'Roca Mirror Cabinet',
      categoryId: '3',
      subCategory: 'Cabinet',
      sku: 'SAN-007',
      imageAssetPath: 'assets/images/products/sanitary_cabinet.jpg',
      price: 8500.0,
      quantity: 25,
    ),

    // CPVC Category (id: '4') - 7 items
    const CatalogItem(
      id: '401',
      name: 'CPVC Pipe 1/2 inch',
      categoryId: '4',
      subCategory: 'Pipe',
      sku: 'CPV-001',
      imageAssetPath: 'assets/images/products/cpvc_pipe_half.jpg',
      price: 180.0,
      quantity: 250,
    ),
    const CatalogItem(
      id: '402',
      name: 'CPVC Pipe 3/4 inch',
      categoryId: '4',
      subCategory: 'Pipe',
      sku: 'CPV-002',
      imageAssetPath: 'assets/images/products/cpvc_pipe_three_quarter.jpg',
      price: 220.0,
      quantity: 220,
    ),
    const CatalogItem(
      id: '403',
      name: 'CPVC Elbow 90°',
      categoryId: '4',
      subCategory: 'Fitting',
      sku: 'CPV-003',
      imageAssetPath: 'assets/images/products/cpvc_elbow.jpg',
      price: 25.0,
      quantity: 500,
    ),
    const CatalogItem(
      id: '404',
      name: 'CPVC Tee Joint',
      categoryId: '4',
      subCategory: 'Fitting',
      sku: 'CPV-004',
      imageAssetPath: 'assets/images/products/cpvc_tee.jpg',
      price: 30.0,
      quantity: 450,
    ),
    const CatalogItem(
      id: '405',
      name: 'CPVC Coupler',
      categoryId: '4',
      subCategory: 'Fitting',
      sku: 'CPV-005',
      imageAssetPath: 'assets/images/products/cpvc_coupler.jpg',
      price: 20.0,
      quantity: 600,
    ),
    const CatalogItem(
      id: '406',
      name: 'CPVC Ball Valve',
      categoryId: '4',
      subCategory: 'Valve',
      sku: 'CPV-006',
      imageAssetPath: 'assets/images/products/cpvc_valve.jpg',
      price: 120.0,
      quantity: 180,
    ),
    const CatalogItem(
      id: '407',
      name: 'CPVC End Cap',
      categoryId: '4',
      subCategory: 'Fitting',
      sku: 'CPV-007',
      imageAssetPath: 'assets/images/products/cpvc_cap.jpg',
      price: 15.0,
      quantity: 700,
    ),

    // Ply Category (id: '5') - 7 items
    const CatalogItem(
      id: '501',
      name: 'Marine Plywood 18mm',
      categoryId: '5',
      subCategory: 'Marine Grade',
      sku: 'PLY-001',
      imageAssetPath: 'assets/images/products/ply_marine.jpg',
      price: 2800.0,
      quantity: 90,
    ),
    const CatalogItem(
      id: '502',
      name: 'BWR Plywood 12mm',
      categoryId: '5',
      subCategory: 'Water Resistant',
      sku: 'PLY-002',
      imageAssetPath: 'assets/images/products/ply_bwr.jpg',
      price: 1800.0,
      quantity: 120,
    ),
    const CatalogItem(
      id: '503',
      name: 'Commercial Ply 6mm',
      categoryId: '5',
      subCategory: 'Commercial',
      sku: 'PLY-003',
      imageAssetPath: 'assets/images/products/ply_commercial.jpg',
      price: 950.0,
      quantity: 150,
    ),
    const CatalogItem(
      id: '504',
      name: 'Flexible Plywood 4mm',
      categoryId: '5',
      subCategory: 'Flexible',
      sku: 'PLY-004',
      imageAssetPath: 'assets/images/products/ply_flexible.jpg',
      price: 1200.0,
      quantity: 100,
    ),
    const CatalogItem(
      id: '505',
      name: 'Fireproof Ply 18mm',
      categoryId: '5',
      subCategory: 'Fire Resistant',
      sku: 'PLY-005',
      imageAssetPath: 'assets/images/products/ply_fireproof.jpg',
      price: 3200.0,
      quantity: 75,
    ),
    const CatalogItem(
      id: '506',
      name: 'Waterproof Ply 12mm',
      categoryId: '5',
      subCategory: 'Waterproof',
      sku: 'PLY-006',
      imageAssetPath: 'assets/images/products/ply_waterproof.jpg',
      price: 2200.0,
      quantity: 110,
    ),
    const CatalogItem(
      id: '507',
      name: 'Shuttering Ply 12mm',
      categoryId: '5',
      subCategory: 'Shuttering',
      sku: 'PLY-007',
      imageAssetPath: 'assets/images/products/ply_shuttering.jpg',
      price: 1600.0,
      quantity: 130,
    ),
  ];
}

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
      // Marble Category (id: '1') - 7 items
      const CatalogItem(
        id: '101',
        name: 'Italian White Marble',
        categoryId: '1',
        subCategory: 'Premium',
        sku: 'MAR-001',
        imageAssetPath: 'assets/images/products/marble_white.jpg',
        price: 450.0,
        quantity: 120,
      ),
      const CatalogItem(
        id: '102',
        name: 'Carrara Marble',
        categoryId: '1',
        subCategory: 'Classic',
        sku: 'MAR-002',
        imageAssetPath: 'assets/images/products/marble_carrara.jpg',
        price: 380.0,
        quantity: 85,
      ),
      const CatalogItem(
        id: '103',
        name: 'Black Galaxy Marble',
        categoryId: '1',
        subCategory: 'Exotic',
        sku: 'MAR-003',
        imageAssetPath: 'assets/images/products/marble_black.jpg',
        price: 520.0,
        quantity: 65,
      ),
      const CatalogItem(
        id: '104',
        name: 'Statuario Marble',
        categoryId: '1',
        subCategory: 'Luxury',
        sku: 'MAR-004',
        imageAssetPath: 'assets/images/products/marble_statuario.jpg',
        price: 680.0,
        quantity: 45,
      ),
      const CatalogItem(
        id: '105',
        name: 'Emperador Marble',
        categoryId: '1',
        subCategory: 'Brown',
        sku: 'MAR-005',
        imageAssetPath: 'assets/images/products/marble_emperador.jpg',
        price: 420.0,
        quantity: 95,
      ),
      const CatalogItem(
        id: '106',
        name: 'Crema Marfil Marble',
        categoryId: '1',
        subCategory: 'Beige',
        sku: 'MAR-006',
        imageAssetPath: 'assets/images/products/marble_crema.jpg',
        price: 390.0,
        quantity: 110,
      ),
      const CatalogItem(
        id: '107',
        name: 'Green Marble',
        categoryId: '1',
        subCategory: 'Exotic',
        sku: 'MAR-007',
        imageAssetPath: 'assets/images/products/marble_green.jpg',
        price: 550.0,
        quantity: 75,
      ),

      // Paints Category (id: '2') - 7 items
      const CatalogItem(
        id: '201',
        name: 'Asian Paints Royale',
        categoryId: '2',
        subCategory: 'Premium',
        sku: 'PAI-001',
        imageAssetPath: 'assets/images/products/paint_royale.jpg',
        price: 850.0,
        quantity: 200,
      ),
      const CatalogItem(
        id: '202',
        name: 'Berger Easy Clean',
        categoryId: '2',
        subCategory: 'Interior',
        sku: 'PAI-002',
        imageAssetPath: 'assets/images/products/paint_berger.jpg',
        price: 720.0,
        quantity: 150,
      ),
      const CatalogItem(
        id: '203',
        name: 'Nerolac Excel',
        categoryId: '2',
        subCategory: 'Interior',
        sku: 'PAI-003',
        imageAssetPath: 'assets/images/products/paint_nerolac.jpg',
        price: 680.0,
        quantity: 180,
      ),
      const CatalogItem(
        id: '204',
        name: 'Dulux Weathershield',
        categoryId: '2',
        subCategory: 'Exterior',
        sku: 'PAI-004',
        imageAssetPath: 'assets/images/products/paint_dulux.jpg',
        price: 920.0,
        quantity: 130,
      ),
      const CatalogItem(
        id: '205',
        name: 'Asian Paints Apcolite',
        categoryId: '2',
        subCategory: 'Emulsion',
        sku: 'PAI-005',
        imageAssetPath: 'assets/images/products/paint_apcolite.jpg',
        price: 780.0,
        quantity: 165,
      ),
      const CatalogItem(
        id: '206',
        name: 'Berger Weather Coat',
        categoryId: '2',
        subCategory: 'Exterior',
        sku: 'PAI-006',
        imageAssetPath: 'assets/images/products/paint_weathercoat.jpg',
        price: 890.0,
        quantity: 140,
      ),
      const CatalogItem(
        id: '207',
        name: 'Nerolac Impressions',
        categoryId: '2',
        subCategory: 'Designer',
        sku: 'PAI-007',
        imageAssetPath: 'assets/images/products/paint_impressions.jpg',
        price: 950.0,
        quantity: 120,
      ),

      // Sanitary Category (id: '3') - 7 items
      const CatalogItem(
        id: '301',
        name: 'Hindware Wash Basin',
        categoryId: '3',
        subCategory: 'Basin',
        sku: 'SAN-001',
        imageAssetPath: 'assets/images/products/sanitary_basin.jpg',
        price: 3200.0,
        quantity: 45,
      ),
      const CatalogItem(
        id: '302',
        name: 'Parryware Toilet Seat',
        categoryId: '3',
        subCategory: 'Toilet',
        sku: 'SAN-002',
        imageAssetPath: 'assets/images/products/sanitary_toilet.jpg',
        price: 4500.0,
        quantity: 35,
      ),
      const CatalogItem(
        id: '303',
        name: 'Jaquar Shower',
        categoryId: '3',
        subCategory: 'Shower',
        sku: 'SAN-003',
        imageAssetPath: 'assets/images/products/sanitary_shower.jpg',
        price: 2800.0,
        quantity: 60,
      ),
      const CatalogItem(
        id: '304',
        name: 'Cera Faucet',
        categoryId: '3',
        subCategory: 'Faucet',
        sku: 'SAN-004',
        imageAssetPath: 'assets/images/products/sanitary_faucet.jpg',
        price: 1500.0,
        quantity: 80,
      ),
      const CatalogItem(
        id: '305',
        name: 'Kohler Bathtub',
        categoryId: '3',
        subCategory: 'Bathtub',
        sku: 'SAN-005',
        imageAssetPath: 'assets/images/products/sanitary_bathtub.jpg',
        price: 25000.0,
        quantity: 15,
      ),
      const CatalogItem(
        id: '306',
        name: 'Grohe Kitchen Sink',
        categoryId: '3',
        subCategory: 'Sink',
        sku: 'SAN-006',
        imageAssetPath: 'assets/images/products/sanitary_sink.jpg',
        price: 5500.0,
        quantity: 30,
      ),
      const CatalogItem(
        id: '307',
        name: 'Roca Mirror Cabinet',
        categoryId: '3',
        subCategory: 'Cabinet',
        sku: 'SAN-007',
        imageAssetPath: 'assets/images/products/sanitary_cabinet.jpg',
        price: 8500.0,
        quantity: 25,
      ),

      // CPVC Category (id: '4') - 7 items
      const CatalogItem(
        id: '401',
        name: 'CPVC Pipe 1/2 inch',
        categoryId: '4',
        subCategory: 'Pipe',
        sku: 'CPV-001',
        imageAssetPath: 'assets/images/products/cpvc_pipe_half.jpg',
        price: 180.0,
        quantity: 250,
      ),
      const CatalogItem(
        id: '402',
        name: 'CPVC Pipe 3/4 inch',
        categoryId: '4',
        subCategory: 'Pipe',
        sku: 'CPV-002',
        imageAssetPath: 'assets/images/products/cpvc_pipe_three_quarter.jpg',
        price: 220.0,
        quantity: 220,
      ),
      const CatalogItem(
        id: '403',
        name: 'CPVC Elbow 90°',
        categoryId: '4',
        subCategory: 'Fitting',
        sku: 'CPV-003',
        imageAssetPath: 'assets/images/products/cpvc_elbow.jpg',
        price: 25.0,
        quantity: 500,
      ),
      const CatalogItem(
        id: '404',
        name: 'CPVC Tee Joint',
        categoryId: '4',
        subCategory: 'Fitting',
        sku: 'CPV-004',
        imageAssetPath: 'assets/images/products/cpvc_tee.jpg',
        price: 30.0,
        quantity: 450,
      ),
      const CatalogItem(
        id: '405',
        name: 'CPVC Coupler',
        categoryId: '4',
        subCategory: 'Fitting',
        sku: 'CPV-005',
        imageAssetPath: 'assets/images/products/cpvc_coupler.jpg',
        price: 20.0,
        quantity: 600,
      ),
      const CatalogItem(
        id: '406',
        name: 'CPVC Ball Valve',
        categoryId: '4',
        subCategory: 'Valve',
        sku: 'CPV-006',
        imageAssetPath: 'assets/images/products/cpvc_valve.jpg',
        price: 120.0,
        quantity: 180,
      ),
      const CatalogItem(
        id: '407',
        name: 'CPVC End Cap',
        categoryId: '4',
        subCategory: 'Fitting',
        sku: 'CPV-007',
        imageAssetPath: 'assets/images/products/cpvc_cap.jpg',
        price: 15.0,
        quantity: 700,
      ),

      // Ply Category (id: '5') - 7 items
      const CatalogItem(
        id: '501',
        name: 'Marine Plywood 18mm',
        categoryId: '5',
        subCategory: 'Marine Grade',
        sku: 'PLY-001',
        imageAssetPath: 'assets/images/products/ply_marine.jpg',
        price: 2800.0,
        quantity: 90,
      ),
      const CatalogItem(
        id: '502',
        name: 'BWR Plywood 12mm',
        categoryId: '5',
        subCategory: 'Water Resistant',
        sku: 'PLY-002',
        imageAssetPath: 'assets/images/products/ply_bwr.jpg',
        price: 1800.0,
        quantity: 120,
      ),
      const CatalogItem(
        id: '503',
        name: 'Commercial Ply 6mm',
        categoryId: '5',
        subCategory: 'Commercial',
        sku: 'PLY-003',
        imageAssetPath: 'assets/images/products/ply_commercial.jpg',
        price: 950.0,
        quantity: 150,
      ),
      const CatalogItem(
        id: '504',
        name: 'Flexible Plywood 4mm',
        categoryId: '5',
        subCategory: 'Flexible',
        sku: 'PLY-004',
        imageAssetPath: 'assets/images/products/ply_flexible.jpg',
        price: 1200.0,
        quantity: 100,
      ),
      const CatalogItem(
        id: '505',
        name: 'Fireproof Ply 18mm',
        categoryId: '5',
        subCategory: 'Fire Resistant',
        sku: 'PLY-005',
        imageAssetPath: 'assets/images/products/ply_fireproof.jpg',
        price: 3200.0,
        quantity: 75,
      ),
      const CatalogItem(
        id: '506',
        name: 'Waterproof Ply 12mm',
        categoryId: '5',
        subCategory: 'Waterproof',
        sku: 'PLY-006',
        imageAssetPath: 'assets/images/products/ply_waterproof.jpg',
        price: 2200.0,
        quantity: 110,
      ),
      const CatalogItem(
        id: '507',
        name: 'Shuttering Ply 12mm',
        categoryId: '5',
        subCategory: 'Shuttering',
        sku: 'PLY-007',
        imageAssetPath: 'assets/images/products/ply_shuttering.jpg',
        price: 1600.0,
        quantity: 130,
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

/// --- Provider for ALL catalog items (no category filtering) ---
/// This loads all items once and caches them for better performance
@riverpod
class AllCatalogItems extends _$AllCatalogItems {
  @override
  FutureOr<List<CatalogItem>> build() async {
    // Load all items once - instant with mock data
    return _getAllMockItems();
  }

  // Refresh all items
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => _getAllMockItems());
  }
}
