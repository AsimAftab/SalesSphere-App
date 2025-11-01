// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_item_details.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CatalogItemDetails _$CatalogItemDetailsFromJson(Map<String, dynamic> json) =>
    _CatalogItemDetails(
      id: json['id'] as String,
      name: json['name'] as String,
      categoryId: json['category_id'] as String,
      categoryName: json['category_name'] as String,
      imageAssetPath: json['image_asset_path'] as String,
      subCategory: json['sub_category'] as String?,
      sku: json['sku'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      material: json['material'] as String?,
      origin: json['origin'] as String?,
      finish: json['finish'] as String?,
      application: json['application'] as String?,
      durability: json['durability'] as String?,
      inStockSqFt: (json['in_stock_sq_ft'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CatalogItemDetailsToJson(_CatalogItemDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category_id': instance.categoryId,
      'category_name': instance.categoryName,
      'image_asset_path': instance.imageAssetPath,
      'sub_category': instance.subCategory,
      'sku': instance.sku,
      'price': instance.price,
      'material': instance.material,
      'origin': instance.origin,
      'finish': instance.finish,
      'application': instance.application,
      'durability': instance.durability,
      'in_stock_sq_ft': instance.inStockSqFt,
    };
