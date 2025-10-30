// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_item.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CatalogItem _$CatalogItemFromJson(Map<String, dynamic> json) => _CatalogItem(
  id: json['id'] as String,
  name: json['name'] as String,
  categoryId: json['category_id'] as String,
  subCategory: json['sub_category'] as String?,
  sku: json['sku'] as String?,
  imageAssetPath: json['image_asset_path'] as String?,
);

Map<String, dynamic> _$CatalogItemToJson(_CatalogItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category_id': instance.categoryId,
      'sub_category': instance.subCategory,
      'sku': instance.sku,
      'image_asset_path': instance.imageAssetPath,
    };
