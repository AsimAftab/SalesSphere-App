// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parties.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PartyListItem {

 String get id; String get name; String get ownerName;@JsonKey(name: 'full_address') String get fullAddress;@JsonKey(name: 'phone_number') String get phoneNumber;@JsonKey(name: 'is_active') bool get isActive;
/// Create a copy of PartyListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PartyListItemCopyWith<PartyListItem> get copyWith => _$PartyListItemCopyWithImpl<PartyListItem>(this as PartyListItem, _$identity);

  /// Serializes this PartyListItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PartyListItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.fullAddress, fullAddress) || other.fullAddress == fullAddress)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,ownerName,fullAddress,phoneNumber,isActive);

@override
String toString() {
  return 'PartyListItem(id: $id, name: $name, ownerName: $ownerName, fullAddress: $fullAddress, phoneNumber: $phoneNumber, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $PartyListItemCopyWith<$Res>  {
  factory $PartyListItemCopyWith(PartyListItem value, $Res Function(PartyListItem) _then) = _$PartyListItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, String ownerName,@JsonKey(name: 'full_address') String fullAddress,@JsonKey(name: 'phone_number') String phoneNumber,@JsonKey(name: 'is_active') bool isActive
});




}
/// @nodoc
class _$PartyListItemCopyWithImpl<$Res>
    implements $PartyListItemCopyWith<$Res> {
  _$PartyListItemCopyWithImpl(this._self, this._then);

  final PartyListItem _self;
  final $Res Function(PartyListItem) _then;

/// Create a copy of PartyListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? ownerName = null,Object? fullAddress = null,Object? phoneNumber = null,Object? isActive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,fullAddress: null == fullAddress ? _self.fullAddress : fullAddress // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PartyListItem].
extension PartyListItemPatterns on PartyListItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PartyListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PartyListItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PartyListItem value)  $default,){
final _that = this;
switch (_that) {
case _PartyListItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PartyListItem value)?  $default,){
final _that = this;
switch (_that) {
case _PartyListItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String ownerName, @JsonKey(name: 'full_address')  String fullAddress, @JsonKey(name: 'phone_number')  String phoneNumber, @JsonKey(name: 'is_active')  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PartyListItem() when $default != null:
return $default(_that.id,_that.name,_that.ownerName,_that.fullAddress,_that.phoneNumber,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String ownerName, @JsonKey(name: 'full_address')  String fullAddress, @JsonKey(name: 'phone_number')  String phoneNumber, @JsonKey(name: 'is_active')  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _PartyListItem():
return $default(_that.id,_that.name,_that.ownerName,_that.fullAddress,_that.phoneNumber,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String ownerName, @JsonKey(name: 'full_address')  String fullAddress, @JsonKey(name: 'phone_number')  String phoneNumber, @JsonKey(name: 'is_active')  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _PartyListItem() when $default != null:
return $default(_that.id,_that.name,_that.ownerName,_that.fullAddress,_that.phoneNumber,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PartyListItem implements PartyListItem {
  const _PartyListItem({required this.id, required this.name, required this.ownerName, @JsonKey(name: 'full_address') required this.fullAddress, @JsonKey(name: 'phone_number') required this.phoneNumber, @JsonKey(name: 'is_active') this.isActive = true});
  factory _PartyListItem.fromJson(Map<String, dynamic> json) => _$PartyListItemFromJson(json);

@override final  String id;
@override final  String name;
@override final  String ownerName;
@override@JsonKey(name: 'full_address') final  String fullAddress;
@override@JsonKey(name: 'phone_number') final  String phoneNumber;
@override@JsonKey(name: 'is_active') final  bool isActive;

/// Create a copy of PartyListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PartyListItemCopyWith<_PartyListItem> get copyWith => __$PartyListItemCopyWithImpl<_PartyListItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PartyListItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PartyListItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.fullAddress, fullAddress) || other.fullAddress == fullAddress)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,ownerName,fullAddress,phoneNumber,isActive);

@override
String toString() {
  return 'PartyListItem(id: $id, name: $name, ownerName: $ownerName, fullAddress: $fullAddress, phoneNumber: $phoneNumber, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$PartyListItemCopyWith<$Res> implements $PartyListItemCopyWith<$Res> {
  factory _$PartyListItemCopyWith(_PartyListItem value, $Res Function(_PartyListItem) _then) = __$PartyListItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String ownerName,@JsonKey(name: 'full_address') String fullAddress,@JsonKey(name: 'phone_number') String phoneNumber,@JsonKey(name: 'is_active') bool isActive
});




}
/// @nodoc
class __$PartyListItemCopyWithImpl<$Res>
    implements _$PartyListItemCopyWith<$Res> {
  __$PartyListItemCopyWithImpl(this._self, this._then);

  final _PartyListItem _self;
  final $Res Function(_PartyListItem) _then;

/// Create a copy of PartyListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? ownerName = null,Object? fullAddress = null,Object? phoneNumber = null,Object? isActive = null,}) {
  return _then(_PartyListItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,fullAddress: null == fullAddress ? _self.fullAddress : fullAddress // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
