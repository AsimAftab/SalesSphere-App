import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog.models.freezed.dart';
part 'catalog.models.g.dart';

// ========================================
// CATALOG CATEGORY MODEL
// ========================================
@freezed
abstract class CatalogCategory with _$CatalogCategory {
  const factory CatalogCategory({
    @JsonKey(name: '_id') required String id,
    required String name,
    required String organizationId,
    required DateTime createdAt,
    required DateTime updatedAt,
    @JsonKey(name: '__v') int? v,
    // Optional UI fields (not from API)
    @JsonKey(name: 'image_asset_path') String? imageAssetPath,
    @JsonKey(name: 'item_count') int? itemCount,
  }) = _CatalogCategory;

  factory CatalogCategory.fromJson(Map<String, dynamic> json) =>
      _$CatalogCategoryFromJson(json);
}

// ========================================
// PRODUCT IMAGE MODEL (Nested in CatalogItem)
// ========================================
@freezed
abstract class ProductImage with _$ProductImage {
  const factory ProductImage({
    @JsonKey(name: 'public_id') String? publicId,
    String? url,
  }) = _ProductImage;

  factory ProductImage.fromJson(Map<String, dynamic> json) =>
      _$ProductImageFromJson(json);
}

// ========================================
// PRODUCT CATEGORY MODEL (Nested in CatalogItem)
// ========================================
@freezed
abstract class ProductCategory with _$ProductCategory {
  const factory ProductCategory({
    @JsonKey(name: '_id') required String id,
    required String name,
  }) = _ProductCategory;

  factory ProductCategory.fromJson(Map<String, dynamic> json) =>
      _$ProductCategoryFromJson(json);
}

// ========================================
// CATALOG ITEM MODEL (Product)
// ========================================
@freezed
abstract class CatalogItem with _$CatalogItem {
  const factory CatalogItem({
    @JsonKey(name: '_id') required String id,
    @JsonKey(name: 'productName') required String name,
    @JsonKey(name: 'serialNo') String? sku,
    required ProductCategory category,
    @Default(0.0) double price,
    @JsonKey(name: 'qty') int? quantity,
    @JsonKey(name: 'isActive') @Default(true) bool isActive,
    required String organizationId,
    required CreatedByInfo createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    @JsonKey(name: '__v') int? v,
    ProductImage? image,
    // Optional UI/legacy fields (for backward compatibility)
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'category_name') String? categoryName,
    @JsonKey(name: 'sub_category') String? subCategory,
    @JsonKey(name: 'image_asset_path') String? imageAssetPath,
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

// ========================================
// CREATED BY INFO MODEL
// ========================================
@freezed
abstract class CreatedByInfo with _$CreatedByInfo {
  const factory CreatedByInfo({
    @JsonKey(name: '_id') required String id,
    required String name,
  }) = _CreatedByInfo;

  factory CreatedByInfo.fromJson(Map<String, dynamic> json) =>
      _$CreatedByInfoFromJson(json);
}
