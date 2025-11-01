import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_item_details.model.freezed.dart';
part 'catalog_item_details.model.g.dart';

@freezed
abstract class CatalogItemDetails with _$CatalogItemDetails {
  const factory CatalogItemDetails({
    // Core Info
    required String id,
    required String name,

    // Links & Asset
    @JsonKey(name: 'category_id') required String categoryId,
    @JsonKey(name: 'category_name') required String categoryName,
    @JsonKey(name: 'image_asset_path') required String imageAssetPath,

    // Main Card Info (from screenshot 1)
    @JsonKey(name: 'sub_category') String? subCategory, // e.g., "Plain"
    String? sku, // e.g., "SKU-4001"
    @Default(0.0) double price, // e.g., 400.0

    // Info Cards (from screenshot 1)
    String? material, // e.g., "Natural Stone"
    String? origin,   // e.g., "Italy/Spain"

    // Key Features (from screenshot 2)
    String? finish,
    String? application,
    String? durability,

    // Stock Info (from screenshot 3)
    @JsonKey(name: 'in_stock_sq_ft') @Default(0) int inStockSqFt,

  }) = _CatalogItemDetails;

  factory CatalogItemDetails.fromJson(Map<String, dynamic> json) =>
      _$CatalogItemDetailsFromJson(json);
}
