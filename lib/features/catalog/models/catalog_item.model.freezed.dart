// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog_item.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CatalogItem {

 String get id; String get name;@JsonKey(name: 'category_id') String get categoryId;@JsonKey(name: 'sub_category') String? get subCategory; String? get sku;@JsonKey(name: 'image_asset_path') String? get imageAssetPath;
/// Create a copy of CatalogItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogItemCopyWith<CatalogItem> get copyWith => _$CatalogItemCopyWithImpl<CatalogItem>(this as CatalogItem, _$identity);

  /// Serializes this CatalogItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.subCategory, subCategory) || other.subCategory == subCategory)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.imageAssetPath, imageAssetPath) || other.imageAssetPath == imageAssetPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,categoryId,subCategory,sku,imageAssetPath);

@override
String toString() {
  return 'CatalogItem(id: $id, name: $name, categoryId: $categoryId, subCategory: $subCategory, sku: $sku, imageAssetPath: $imageAssetPath)';
}


}

/// @nodoc
abstract mixin class $CatalogItemCopyWith<$Res>  {
  factory $CatalogItemCopyWith(CatalogItem value, $Res Function(CatalogItem) _then) = _$CatalogItemCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'category_id') String categoryId,@JsonKey(name: 'sub_category') String? subCategory, String? sku,@JsonKey(name: 'image_asset_path') String? imageAssetPath
});




}
/// @nodoc
class _$CatalogItemCopyWithImpl<$Res>
    implements $CatalogItemCopyWith<$Res> {
  _$CatalogItemCopyWithImpl(this._self, this._then);

  final CatalogItem _self;
  final $Res Function(CatalogItem) _then;

/// Create a copy of CatalogItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? categoryId = null,Object? subCategory = freezed,Object? sku = freezed,Object? imageAssetPath = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,subCategory: freezed == subCategory ? _self.subCategory : subCategory // ignore: cast_nullable_to_non_nullable
as String?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,imageAssetPath: freezed == imageAssetPath ? _self.imageAssetPath : imageAssetPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CatalogItem].
extension CatalogItemPatterns on CatalogItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CatalogItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CatalogItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CatalogItem value)  $default,){
final _that = this;
switch (_that) {
case _CatalogItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CatalogItem value)?  $default,){
final _that = this;
switch (_that) {
case _CatalogItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'category_id')  String categoryId, @JsonKey(name: 'sub_category')  String? subCategory,  String? sku, @JsonKey(name: 'image_asset_path')  String? imageAssetPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CatalogItem() when $default != null:
return $default(_that.id,_that.name,_that.categoryId,_that.subCategory,_that.sku,_that.imageAssetPath);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'category_id')  String categoryId, @JsonKey(name: 'sub_category')  String? subCategory,  String? sku, @JsonKey(name: 'image_asset_path')  String? imageAssetPath)  $default,) {final _that = this;
switch (_that) {
case _CatalogItem():
return $default(_that.id,_that.name,_that.categoryId,_that.subCategory,_that.sku,_that.imageAssetPath);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'category_id')  String categoryId, @JsonKey(name: 'sub_category')  String? subCategory,  String? sku, @JsonKey(name: 'image_asset_path')  String? imageAssetPath)?  $default,) {final _that = this;
switch (_that) {
case _CatalogItem() when $default != null:
return $default(_that.id,_that.name,_that.categoryId,_that.subCategory,_that.sku,_that.imageAssetPath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CatalogItem implements CatalogItem {
  const _CatalogItem({required this.id, required this.name, @JsonKey(name: 'category_id') required this.categoryId, @JsonKey(name: 'sub_category') this.subCategory, this.sku, @JsonKey(name: 'image_asset_path') this.imageAssetPath});
  factory _CatalogItem.fromJson(Map<String, dynamic> json) => _$CatalogItemFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(name: 'category_id') final  String categoryId;
@override@JsonKey(name: 'sub_category') final  String? subCategory;
@override final  String? sku;
@override@JsonKey(name: 'image_asset_path') final  String? imageAssetPath;

/// Create a copy of CatalogItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CatalogItemCopyWith<_CatalogItem> get copyWith => __$CatalogItemCopyWithImpl<_CatalogItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CatalogItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CatalogItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.subCategory, subCategory) || other.subCategory == subCategory)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.imageAssetPath, imageAssetPath) || other.imageAssetPath == imageAssetPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,categoryId,subCategory,sku,imageAssetPath);

@override
String toString() {
  return 'CatalogItem(id: $id, name: $name, categoryId: $categoryId, subCategory: $subCategory, sku: $sku, imageAssetPath: $imageAssetPath)';
}


}

/// @nodoc
abstract mixin class _$CatalogItemCopyWith<$Res> implements $CatalogItemCopyWith<$Res> {
  factory _$CatalogItemCopyWith(_CatalogItem value, $Res Function(_CatalogItem) _then) = __$CatalogItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'category_id') String categoryId,@JsonKey(name: 'sub_category') String? subCategory, String? sku,@JsonKey(name: 'image_asset_path') String? imageAssetPath
});




}
/// @nodoc
class __$CatalogItemCopyWithImpl<$Res>
    implements _$CatalogItemCopyWith<$Res> {
  __$CatalogItemCopyWithImpl(this._self, this._then);

  final _CatalogItem _self;
  final $Res Function(_CatalogItem) _then;

/// Create a copy of CatalogItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? categoryId = null,Object? subCategory = freezed,Object? sku = freezed,Object? imageAssetPath = freezed,}) {
  return _then(_CatalogItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,subCategory: freezed == subCategory ? _self.subCategory : subCategory // ignore: cast_nullable_to_non_nullable
as String?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,imageAssetPath: freezed == imageAssetPath ? _self.imageAssetPath : imageAssetPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
