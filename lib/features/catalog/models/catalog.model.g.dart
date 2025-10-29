// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CatalogCategory _$CatalogCategoryFromJson(Map<String, dynamic> json) =>
    _CatalogCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      imageAssetPath: json['image_asset_path'] as String?,
      itemCount: (json['item_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CatalogCategoryToJson(_CatalogCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image_asset_path': instance.imageAssetPath,
      'item_count': instance.itemCount,
    };
