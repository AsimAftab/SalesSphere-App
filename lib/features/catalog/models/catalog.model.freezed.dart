// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CatalogCategory {

 String get id; String get name;// This will hold the path to your asset image, e.g., 'assets/images/marble.png'
@JsonKey(name: 'image_asset_path') String? get imageAssetPath;// We can add a simple item count to display
@JsonKey(name: 'item_count') int? get itemCount;
/// Create a copy of CatalogCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogCategoryCopyWith<CatalogCategory> get copyWith => _$CatalogCategoryCopyWithImpl<CatalogCategory>(this as CatalogCategory, _$identity);

  /// Serializes this CatalogCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.imageAssetPath, imageAssetPath) || other.imageAssetPath == imageAssetPath)&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,imageAssetPath,itemCount);

@override
String toString() {
  return 'CatalogCategory(id: $id, name: $name, imageAssetPath: $imageAssetPath, itemCount: $itemCount)';
}


}

/// @nodoc
abstract mixin class $CatalogCategoryCopyWith<$Res>  {
  factory $CatalogCategoryCopyWith(CatalogCategory value, $Res Function(CatalogCategory) _then) = _$CatalogCategoryCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'image_asset_path') String? imageAssetPath,@JsonKey(name: 'item_count') int? itemCount
});




}
/// @nodoc
class _$CatalogCategoryCopyWithImpl<$Res>
    implements $CatalogCategoryCopyWith<$Res> {
  _$CatalogCategoryCopyWithImpl(this._self, this._then);

  final CatalogCategory _self;
  final $Res Function(CatalogCategory) _then;

/// Create a copy of CatalogCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? imageAssetPath = freezed,Object? itemCount = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,imageAssetPath: freezed == imageAssetPath ? _self.imageAssetPath : imageAssetPath // ignore: cast_nullable_to_non_nullable
as String?,itemCount: freezed == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CatalogCategory].
extension CatalogCategoryPatterns on CatalogCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CatalogCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CatalogCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CatalogCategory value)  $default,){
final _that = this;
switch (_that) {
case _CatalogCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CatalogCategory value)?  $default,){
final _that = this;
switch (_that) {
case _CatalogCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'image_asset_path')  String? imageAssetPath, @JsonKey(name: 'item_count')  int? itemCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CatalogCategory() when $default != null:
return $default(_that.id,_that.name,_that.imageAssetPath,_that.itemCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'image_asset_path')  String? imageAssetPath, @JsonKey(name: 'item_count')  int? itemCount)  $default,) {final _that = this;
switch (_that) {
case _CatalogCategory():
return $default(_that.id,_that.name,_that.imageAssetPath,_that.itemCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'image_asset_path')  String? imageAssetPath, @JsonKey(name: 'item_count')  int? itemCount)?  $default,) {final _that = this;
switch (_that) {
case _CatalogCategory() when $default != null:
return $default(_that.id,_that.name,_that.imageAssetPath,_that.itemCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CatalogCategory implements CatalogCategory {
  const _CatalogCategory({required this.id, required this.name, @JsonKey(name: 'image_asset_path') this.imageAssetPath, @JsonKey(name: 'item_count') this.itemCount});
  factory _CatalogCategory.fromJson(Map<String, dynamic> json) => _$CatalogCategoryFromJson(json);

@override final  String id;
@override final  String name;
// This will hold the path to your asset image, e.g., 'assets/images/marble.png'
@override@JsonKey(name: 'image_asset_path') final  String? imageAssetPath;
// We can add a simple item count to display
@override@JsonKey(name: 'item_count') final  int? itemCount;

/// Create a copy of CatalogCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CatalogCategoryCopyWith<_CatalogCategory> get copyWith => __$CatalogCategoryCopyWithImpl<_CatalogCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CatalogCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CatalogCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.imageAssetPath, imageAssetPath) || other.imageAssetPath == imageAssetPath)&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,imageAssetPath,itemCount);

@override
String toString() {
  return 'CatalogCategory(id: $id, name: $name, imageAssetPath: $imageAssetPath, itemCount: $itemCount)';
}


}

/// @nodoc
abstract mixin class _$CatalogCategoryCopyWith<$Res> implements $CatalogCategoryCopyWith<$Res> {
  factory _$CatalogCategoryCopyWith(_CatalogCategory value, $Res Function(_CatalogCategory) _then) = __$CatalogCategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'image_asset_path') String? imageAssetPath,@JsonKey(name: 'item_count') int? itemCount
});




}
/// @nodoc
class __$CatalogCategoryCopyWithImpl<$Res>
    implements _$CatalogCategoryCopyWith<$Res> {
  __$CatalogCategoryCopyWithImpl(this._self, this._then);

  final _CatalogCategory _self;
  final $Res Function(_CatalogCategory) _then;

/// Create a copy of CatalogCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? imageAssetPath = freezed,Object? itemCount = freezed,}) {
  return _then(_CatalogCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,imageAssetPath: freezed == imageAssetPath ? _self.imageAssetPath : imageAssetPath // ignore: cast_nullable_to_non_nullable
as String?,itemCount: freezed == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
