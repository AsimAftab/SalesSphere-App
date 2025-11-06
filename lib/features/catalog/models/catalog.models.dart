import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog.models.freezed.dart';
part 'catalog.models.g.dart';

// ========================================
// CATALOG CATEGORY MODEL
// ========================================
@freezed
abstract class CatalogCategory with _$CatalogCategory {
  const factory CatalogCategory({
    required String id,
    required String name,
    @JsonKey(name: 'image_asset_path') String? imageAssetPath,
    @JsonKey(name: 'item_count') int? itemCount,
  }) = _CatalogCategory;

  factory CatalogCategory.fromJson(Map<String, dynamic> json) =>
      _$CatalogCategoryFromJson(json);
}

// ========================================
// CATALOG ITEM MODEL
// ========================================
@freezed
abstract class CatalogItem with _$CatalogItem {
  const factory CatalogItem({
    required String id,
    required String name,
    @JsonKey(name: 'category_id') required String categoryId,
    @JsonKey(name: 'category_name') String? categoryName,
    @JsonKey(name: 'sub_category') String? subCategory,
    String? sku,
    @JsonKey(name: 'image_asset_path') String? imageAssetPath,
    @Default(0.0) double price,
    int? quantity,
    // Detailed fields (optional - used in details view)
    String? material,
    String? origin,
    String? finish,
    String? application,
    String? durability,
    @JsonKey(name: 'in_stock_sq_ft') @Default(0) int inStockSqFt,
  }) = _CatalogItem;

  factory CatalogItem.fromJson(Map<String, dynamic> json) =>
      _$CatalogItemFromJson(json);
}
