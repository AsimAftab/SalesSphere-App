// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog_item_details.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CatalogItemDetails {

// Core Info
 String get id; String get name;// Links & Asset
@JsonKey(name: 'category_id') String get categoryId;@JsonKey(name: 'category_name') String get categoryName;@JsonKey(name: 'image_asset_path') String get imageAssetPath;// Main Card Info (from screenshot 1)
@JsonKey(name: 'sub_category') String? get subCategory;// e.g., "Plain"
 String? get sku;// e.g., "SKU-4001"
 double get price;// e.g., 400.0
// Info Cards (from screenshot 1)
 String? get material;// e.g., "Natural Stone"
 String? get origin;// e.g., "Italy/Spain"
// Key Features (from screenshot 2)
 String? get finish; String? get application; String? get durability;// Stock Info (from screenshot 3)
@JsonKey(name: 'in_stock_sq_ft') int get inStockSqFt;
/// Create a copy of CatalogItemDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogItemDetailsCopyWith<CatalogItemDetails> get copyWith => _$CatalogItemDetailsCopyWithImpl<CatalogItemDetails>(this as CatalogItemDetails, _$identity);

  /// Serializes this CatalogItemDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogItemDetails&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.imageAssetPath, imageAssetPath) || other.imageAssetPath == imageAssetPath)&&(identical(other.subCategory, subCategory) || other.subCategory == subCategory)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.price, price) || other.price == price)&&(identical(other.material, material) || other.material == material)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.finish, finish) || other.finish == finish)&&(identical(other.application, application) || other.application == application)&&(identical(other.durability, durability) || other.durability == durability)&&(identical(other.inStockSqFt, inStockSqFt) || other.inStockSqFt == inStockSqFt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,categoryId,categoryName,imageAssetPath,subCategory,sku,price,material,origin,finish,application,durability,inStockSqFt);

@override
String toString() {
  return 'CatalogItemDetails(id: $id, name: $name, categoryId: $categoryId, categoryName: $categoryName, imageAssetPath: $imageAssetPath, subCategory: $subCategory, sku: $sku, price: $price, material: $material, origin: $origin, finish: $finish, application: $application, durability: $durability, inStockSqFt: $inStockSqFt)';
}


}

/// @nodoc
abstract mixin class $CatalogItemDetailsCopyWith<$Res>  {
  factory $CatalogItemDetailsCopyWith(CatalogItemDetails value, $Res Function(CatalogItemDetails) _then) = _$CatalogItemDetailsCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'category_id') String categoryId,@JsonKey(name: 'category_name') String categoryName,@JsonKey(name: 'image_asset_path') String imageAssetPath,@JsonKey(name: 'sub_category') String? subCategory, String? sku, double price, String? material, String? origin, String? finish, String? application, String? durability,@JsonKey(name: 'in_stock_sq_ft') int inStockSqFt
});




}
/// @nodoc
class _$CatalogItemDetailsCopyWithImpl<$Res>
    implements $CatalogItemDetailsCopyWith<$Res> {
  _$CatalogItemDetailsCopyWithImpl(this._self, this._then);

  final CatalogItemDetails _self;
  final $Res Function(CatalogItemDetails) _then;

/// Create a copy of CatalogItemDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? categoryId = null,Object? categoryName = null,Object? imageAssetPath = null,Object? subCategory = freezed,Object? sku = freezed,Object? price = null,Object? material = freezed,Object? origin = freezed,Object? finish = freezed,Object? application = freezed,Object? durability = freezed,Object? inStockSqFt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,imageAssetPath: null == imageAssetPath ? _self.imageAssetPath : imageAssetPath // ignore: cast_nullable_to_non_nullable
as String,subCategory: freezed == subCategory ? _self.subCategory : subCategory // ignore: cast_nullable_to_non_nullable
as String?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,origin: freezed == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String?,finish: freezed == finish ? _self.finish : finish // ignore: cast_nullable_to_non_nullable
as String?,application: freezed == application ? _self.application : application // ignore: cast_nullable_to_non_nullable
as String?,durability: freezed == durability ? _self.durability : durability // ignore: cast_nullable_to_non_nullable
as String?,inStockSqFt: null == inStockSqFt ? _self.inStockSqFt : inStockSqFt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CatalogItemDetails].
extension CatalogItemDetailsPatterns on CatalogItemDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CatalogItemDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CatalogItemDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CatalogItemDetails value)  $default,){
final _that = this;
switch (_that) {
case _CatalogItemDetails():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CatalogItemDetails value)?  $default,){
final _that = this;
switch (_that) {
case _CatalogItemDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'category_id')  String categoryId, @JsonKey(name: 'category_name')  String categoryName, @JsonKey(name: 'image_asset_path')  String imageAssetPath, @JsonKey(name: 'sub_category')  String? subCategory,  String? sku,  double price,  String? material,  String? origin,  String? finish,  String? application,  String? durability, @JsonKey(name: 'in_stock_sq_ft')  int inStockSqFt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CatalogItemDetails() when $default != null:
return $default(_that.id,_that.name,_that.categoryId,_that.categoryName,_that.imageAssetPath,_that.subCategory,_that.sku,_that.price,_that.material,_that.origin,_that.finish,_that.application,_that.durability,_that.inStockSqFt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'category_id')  String categoryId, @JsonKey(name: 'category_name')  String categoryName, @JsonKey(name: 'image_asset_path')  String imageAssetPath, @JsonKey(name: 'sub_category')  String? subCategory,  String? sku,  double price,  String? material,  String? origin,  String? finish,  String? application,  String? durability, @JsonKey(name: 'in_stock_sq_ft')  int inStockSqFt)  $default,) {final _that = this;
switch (_that) {
case _CatalogItemDetails():
return $default(_that.id,_that.name,_that.categoryId,_that.categoryName,_that.imageAssetPath,_that.subCategory,_that.sku,_that.price,_that.material,_that.origin,_that.finish,_that.application,_that.durability,_that.inStockSqFt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'category_id')  String categoryId, @JsonKey(name: 'category_name')  String categoryName, @JsonKey(name: 'image_asset_path')  String imageAssetPath, @JsonKey(name: 'sub_category')  String? subCategory,  String? sku,  double price,  String? material,  String? origin,  String? finish,  String? application,  String? durability, @JsonKey(name: 'in_stock_sq_ft')  int inStockSqFt)?  $default,) {final _that = this;
switch (_that) {
case _CatalogItemDetails() when $default != null:
return $default(_that.id,_that.name,_that.categoryId,_that.categoryName,_that.imageAssetPath,_that.subCategory,_that.sku,_that.price,_that.material,_that.origin,_that.finish,_that.application,_that.durability,_that.inStockSqFt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CatalogItemDetails implements CatalogItemDetails {
  const _CatalogItemDetails({required this.id, required this.name, @JsonKey(name: 'category_id') required this.categoryId, @JsonKey(name: 'category_name') required this.categoryName, @JsonKey(name: 'image_asset_path') required this.imageAssetPath, @JsonKey(name: 'sub_category') this.subCategory, this.sku, this.price = 0.0, this.material, this.origin, this.finish, this.application, this.durability, @JsonKey(name: 'in_stock_sq_ft') this.inStockSqFt = 0});
  factory _CatalogItemDetails.fromJson(Map<String, dynamic> json) => _$CatalogItemDetailsFromJson(json);

// Core Info
@override final  String id;
@override final  String name;
// Links & Asset
@override@JsonKey(name: 'category_id') final  String categoryId;
@override@JsonKey(name: 'category_name') final  String categoryName;
@override@JsonKey(name: 'image_asset_path') final  String imageAssetPath;
// Main Card Info (from screenshot 1)
@override@JsonKey(name: 'sub_category') final  String? subCategory;
// e.g., "Plain"
@override final  String? sku;
// e.g., "SKU-4001"
@override@JsonKey() final  double price;
// e.g., 400.0
// Info Cards (from screenshot 1)
@override final  String? material;
// e.g., "Natural Stone"
@override final  String? origin;
// e.g., "Italy/Spain"
// Key Features (from screenshot 2)
@override final  String? finish;
@override final  String? application;
@override final  String? durability;
// Stock Info (from screenshot 3)
@override@JsonKey(name: 'in_stock_sq_ft') final  int inStockSqFt;

/// Create a copy of CatalogItemDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CatalogItemDetailsCopyWith<_CatalogItemDetails> get copyWith => __$CatalogItemDetailsCopyWithImpl<_CatalogItemDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CatalogItemDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CatalogItemDetails&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.imageAssetPath, imageAssetPath) || other.imageAssetPath == imageAssetPath)&&(identical(other.subCategory, subCategory) || other.subCategory == subCategory)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.price, price) || other.price == price)&&(identical(other.material, material) || other.material == material)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.finish, finish) || other.finish == finish)&&(identical(other.application, application) || other.application == application)&&(identical(other.durability, durability) || other.durability == durability)&&(identical(other.inStockSqFt, inStockSqFt) || other.inStockSqFt == inStockSqFt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,categoryId,categoryName,imageAssetPath,subCategory,sku,price,material,origin,finish,application,durability,inStockSqFt);

@override
String toString() {
  return 'CatalogItemDetails(id: $id, name: $name, categoryId: $categoryId, categoryName: $categoryName, imageAssetPath: $imageAssetPath, subCategory: $subCategory, sku: $sku, price: $price, material: $material, origin: $origin, finish: $finish, application: $application, durability: $durability, inStockSqFt: $inStockSqFt)';
}


}

/// @nodoc
abstract mixin class _$CatalogItemDetailsCopyWith<$Res> implements $CatalogItemDetailsCopyWith<$Res> {
  factory _$CatalogItemDetailsCopyWith(_CatalogItemDetails value, $Res Function(_CatalogItemDetails) _then) = __$CatalogItemDetailsCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'category_id') String categoryId,@JsonKey(name: 'category_name') String categoryName,@JsonKey(name: 'image_asset_path') String imageAssetPath,@JsonKey(name: 'sub_category') String? subCategory, String? sku, double price, String? material, String? origin, String? finish, String? application, String? durability,@JsonKey(name: 'in_stock_sq_ft') int inStockSqFt
});




}
/// @nodoc
class __$CatalogItemDetailsCopyWithImpl<$Res>
    implements _$CatalogItemDetailsCopyWith<$Res> {
  __$CatalogItemDetailsCopyWithImpl(this._self, this._then);

  final _CatalogItemDetails _self;
  final $Res Function(_CatalogItemDetails) _then;

/// Create a copy of CatalogItemDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? categoryId = null,Object? categoryName = null,Object? imageAssetPath = null,Object? subCategory = freezed,Object? sku = freezed,Object? price = null,Object? material = freezed,Object? origin = freezed,Object? finish = freezed,Object? application = freezed,Object? durability = freezed,Object? inStockSqFt = null,}) {
  return _then(_CatalogItemDetails(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,imageAssetPath: null == imageAssetPath ? _self.imageAssetPath : imageAssetPath // ignore: cast_nullable_to_non_nullable
as String,subCategory: freezed == subCategory ? _self.subCategory : subCategory // ignore: cast_nullable_to_non_nullable
as String?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,origin: freezed == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String?,finish: freezed == finish ? _self.finish : finish // ignore: cast_nullable_to_non_nullable
as String?,application: freezed == application ? _self.application : application // ignore: cast_nullable_to_non_nullable
as String?,durability: freezed == durability ? _self.durability : durability // ignore: cast_nullable_to_non_nullable
as String?,inStockSqFt: null == inStockSqFt ? _self.inStockSqFt : inStockSqFt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
