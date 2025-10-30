import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_item.model.freezed.dart';
part 'catalog_item.model.g.dart';


@freezed
abstract class CatalogItem with _$CatalogItem {
  const factory CatalogItem({
    required String id,
    required String name,
    @JsonKey(name: 'category_id') required String categoryId,
    @JsonKey(name: 'sub_category') String? subCategory,
    String? sku,
    @JsonKey(name: 'image_asset_path') String? imageAssetPath,
    // double? price, // Add other fields if needed
  }) = _CatalogItem;

  factory CatalogItem.fromJson(Map<String, dynamic> json) =>
      _$CatalogItemFromJson(json);
}