// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'party_details.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PartyDetails {

 String get id; String get name;@JsonKey(name: 'owner_name') String get ownerName;@JsonKey(name: 'pan_vat_number') String get panVatNumber;@JsonKey(name: 'phone_number') String get phoneNumber; String? get email;@JsonKey(name: 'full_address') String get fullAddress; double? get latitude; double? get longitude; String? get notes;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of PartyDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PartyDetailsCopyWith<PartyDetails> get copyWith => _$PartyDetailsCopyWithImpl<PartyDetails>(this as PartyDetails, _$identity);

  /// Serializes this PartyDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PartyDetails&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.panVatNumber, panVatNumber) || other.panVatNumber == panVatNumber)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.email, email) || other.email == email)&&(identical(other.fullAddress, fullAddress) || other.fullAddress == fullAddress)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,ownerName,panVatNumber,phoneNumber,email,fullAddress,latitude,longitude,notes,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'PartyDetails(id: $id, name: $name, ownerName: $ownerName, panVatNumber: $panVatNumber, phoneNumber: $phoneNumber, email: $email, fullAddress: $fullAddress, latitude: $latitude, longitude: $longitude, notes: $notes, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PartyDetailsCopyWith<$Res>  {
  factory $PartyDetailsCopyWith(PartyDetails value, $Res Function(PartyDetails) _then) = _$PartyDetailsCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'owner_name') String ownerName,@JsonKey(name: 'pan_vat_number') String panVatNumber,@JsonKey(name: 'phone_number') String phoneNumber, String? email,@JsonKey(name: 'full_address') String fullAddress, double? latitude, double? longitude, String? notes,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$PartyDetailsCopyWithImpl<$Res>
    implements $PartyDetailsCopyWith<$Res> {
  _$PartyDetailsCopyWithImpl(this._self, this._then);

  final PartyDetails _self;
  final $Res Function(PartyDetails) _then;

/// Create a copy of PartyDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? ownerName = null,Object? panVatNumber = null,Object? phoneNumber = null,Object? email = freezed,Object? fullAddress = null,Object? latitude = freezed,Object? longitude = freezed,Object? notes = freezed,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,panVatNumber: null == panVatNumber ? _self.panVatNumber : panVatNumber // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,fullAddress: null == fullAddress ? _self.fullAddress : fullAddress // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PartyDetails].
extension PartyDetailsPatterns on PartyDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PartyDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PartyDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PartyDetails value)  $default,){
final _that = this;
switch (_that) {
case _PartyDetails():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PartyDetails value)?  $default,){
final _that = this;
switch (_that) {
case _PartyDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'owner_name')  String ownerName, @JsonKey(name: 'pan_vat_number')  String panVatNumber, @JsonKey(name: 'phone_number')  String phoneNumber,  String? email, @JsonKey(name: 'full_address')  String fullAddress,  double? latitude,  double? longitude,  String? notes, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PartyDetails() when $default != null:
return $default(_that.id,_that.name,_that.ownerName,_that.panVatNumber,_that.phoneNumber,_that.email,_that.fullAddress,_that.latitude,_that.longitude,_that.notes,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'owner_name')  String ownerName, @JsonKey(name: 'pan_vat_number')  String panVatNumber, @JsonKey(name: 'phone_number')  String phoneNumber,  String? email, @JsonKey(name: 'full_address')  String fullAddress,  double? latitude,  double? longitude,  String? notes, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PartyDetails():
return $default(_that.id,_that.name,_that.ownerName,_that.panVatNumber,_that.phoneNumber,_that.email,_that.fullAddress,_that.latitude,_that.longitude,_that.notes,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'owner_name')  String ownerName, @JsonKey(name: 'pan_vat_number')  String panVatNumber, @JsonKey(name: 'phone_number')  String phoneNumber,  String? email, @JsonKey(name: 'full_address')  String fullAddress,  double? latitude,  double? longitude,  String? notes, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PartyDetails() when $default != null:
return $default(_that.id,_that.name,_that.ownerName,_that.panVatNumber,_that.phoneNumber,_that.email,_that.fullAddress,_that.latitude,_that.longitude,_that.notes,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PartyDetails implements PartyDetails {
  const _PartyDetails({required this.id, required this.name, @JsonKey(name: 'owner_name') required this.ownerName, @JsonKey(name: 'pan_vat_number') required this.panVatNumber, @JsonKey(name: 'phone_number') required this.phoneNumber, this.email, @JsonKey(name: 'full_address') required this.fullAddress, this.latitude, this.longitude, this.notes, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _PartyDetails.fromJson(Map<String, dynamic> json) => _$PartyDetailsFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(name: 'owner_name') final  String ownerName;
@override@JsonKey(name: 'pan_vat_number') final  String panVatNumber;
@override@JsonKey(name: 'phone_number') final  String phoneNumber;
@override final  String? email;
@override@JsonKey(name: 'full_address') final  String fullAddress;
@override final  double? latitude;
@override final  double? longitude;
@override final  String? notes;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of PartyDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PartyDetailsCopyWith<_PartyDetails> get copyWith => __$PartyDetailsCopyWithImpl<_PartyDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PartyDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PartyDetails&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.panVatNumber, panVatNumber) || other.panVatNumber == panVatNumber)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.email, email) || other.email == email)&&(identical(other.fullAddress, fullAddress) || other.fullAddress == fullAddress)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,ownerName,panVatNumber,phoneNumber,email,fullAddress,latitude,longitude,notes,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'PartyDetails(id: $id, name: $name, ownerName: $ownerName, panVatNumber: $panVatNumber, phoneNumber: $phoneNumber, email: $email, fullAddress: $fullAddress, latitude: $latitude, longitude: $longitude, notes: $notes, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PartyDetailsCopyWith<$Res> implements $PartyDetailsCopyWith<$Res> {
  factory _$PartyDetailsCopyWith(_PartyDetails value, $Res Function(_PartyDetails) _then) = __$PartyDetailsCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'owner_name') String ownerName,@JsonKey(name: 'pan_vat_number') String panVatNumber,@JsonKey(name: 'phone_number') String phoneNumber, String? email,@JsonKey(name: 'full_address') String fullAddress, double? latitude, double? longitude, String? notes,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$PartyDetailsCopyWithImpl<$Res>
    implements _$PartyDetailsCopyWith<$Res> {
  __$PartyDetailsCopyWithImpl(this._self, this._then);

  final _PartyDetails _self;
  final $Res Function(_PartyDetails) _then;

/// Create a copy of PartyDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? ownerName = null,Object? panVatNumber = null,Object? phoneNumber = null,Object? email = freezed,Object? fullAddress = null,Object? latitude = freezed,Object? longitude = freezed,Object? notes = freezed,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_PartyDetails(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,panVatNumber: null == panVatNumber ? _self.panVatNumber : panVatNumber // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,fullAddress: null == fullAddress ? _self.fullAddress : fullAddress // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
