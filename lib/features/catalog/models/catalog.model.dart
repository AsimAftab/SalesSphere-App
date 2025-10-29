import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog.model.freezed.dart';
part 'catalog.model.g.dart';

@freezed
abstract class CatalogCategory with _$CatalogCategory {
  const factory CatalogCategory({
    required String id,
    required String name,

    // This will hold the path to your asset image, e.g., 'assets/images/marble.png'
    @JsonKey(name: 'image_asset_path') String? imageAssetPath,

    // We can add a simple item count to display
    @JsonKey(name: 'item_count') int? itemCount,

  }) = _CatalogCategory;

  factory CatalogCategory.fromJson(Map<String, dynamic> json) =>
      _$CatalogCategoryFromJson(json);
}