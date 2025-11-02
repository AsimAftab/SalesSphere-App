// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prospects.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Prospects {

 String get id; String get name; String get location; String? get ownerName; String? get phoneNumber; String? get email; String? get panVatNumber; double? get latitude; double? get longitude; String? get notes; String? get dateJoined; bool get isActive; DateTime? get createdAt;
/// Create a copy of Prospects
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProspectsCopyWith<Prospects> get copyWith => _$ProspectsCopyWithImpl<Prospects>(this as Prospects, _$identity);

  /// Serializes this Prospects to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Prospects&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.location, location) || other.location == location)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.email, email) || other.email == email)&&(identical(other.panVatNumber, panVatNumber) || other.panVatNumber == panVatNumber)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.dateJoined, dateJoined) || other.dateJoined == dateJoined)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,location,ownerName,phoneNumber,email,panVatNumber,latitude,longitude,notes,dateJoined,isActive,createdAt);

@override
String toString() {
  return 'Prospects(id: $id, name: $name, location: $location, ownerName: $ownerName, phoneNumber: $phoneNumber, email: $email, panVatNumber: $panVatNumber, latitude: $latitude, longitude: $longitude, notes: $notes, dateJoined: $dateJoined, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ProspectsCopyWith<$Res>  {
  factory $ProspectsCopyWith(Prospects value, $Res Function(Prospects) _then) = _$ProspectsCopyWithImpl;
@useResult
$Res call({
 String id, String name, String location, String? ownerName, String? phoneNumber, String? email, String? panVatNumber, double? latitude, double? longitude, String? notes, String? dateJoined, bool isActive, DateTime? createdAt
});




}
/// @nodoc
class _$ProspectsCopyWithImpl<$Res>
    implements $ProspectsCopyWith<$Res> {
  _$ProspectsCopyWithImpl(this._self, this._then);

  final Prospects _self;
  final $Res Function(Prospects) _then;

/// Create a copy of Prospects
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? location = null,Object? ownerName = freezed,Object? phoneNumber = freezed,Object? email = freezed,Object? panVatNumber = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? notes = freezed,Object? dateJoined = freezed,Object? isActive = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,ownerName: freezed == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,panVatNumber: freezed == panVatNumber ? _self.panVatNumber : panVatNumber // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,dateJoined: freezed == dateJoined ? _self.dateJoined : dateJoined // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Prospects].
extension ProspectsPatterns on Prospects {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Prospects value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Prospects() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Prospects value)  $default,){
final _that = this;
switch (_that) {
case _Prospects():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Prospects value)?  $default,){
final _that = this;
switch (_that) {
case _Prospects() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String location,  String? ownerName,  String? phoneNumber,  String? email,  String? panVatNumber,  double? latitude,  double? longitude,  String? notes,  String? dateJoined,  bool isActive,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Prospects() when $default != null:
return $default(_that.id,_that.name,_that.location,_that.ownerName,_that.phoneNumber,_that.email,_that.panVatNumber,_that.latitude,_that.longitude,_that.notes,_that.dateJoined,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String location,  String? ownerName,  String? phoneNumber,  String? email,  String? panVatNumber,  double? latitude,  double? longitude,  String? notes,  String? dateJoined,  bool isActive,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Prospects():
return $default(_that.id,_that.name,_that.location,_that.ownerName,_that.phoneNumber,_that.email,_that.panVatNumber,_that.latitude,_that.longitude,_that.notes,_that.dateJoined,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String location,  String? ownerName,  String? phoneNumber,  String? email,  String? panVatNumber,  double? latitude,  double? longitude,  String? notes,  String? dateJoined,  bool isActive,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Prospects() when $default != null:
return $default(_that.id,_that.name,_that.location,_that.ownerName,_that.phoneNumber,_that.email,_that.panVatNumber,_that.latitude,_that.longitude,_that.notes,_that.dateJoined,_that.isActive,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Prospects implements Prospects {
  const _Prospects({required this.id, required this.name, required this.location, this.ownerName, this.phoneNumber, this.email, this.panVatNumber, this.latitude, this.longitude, this.notes, this.dateJoined, this.isActive = true, this.createdAt});
  factory _Prospects.fromJson(Map<String, dynamic> json) => _$ProspectsFromJson(json);

@override final  String id;
@override final  String name;
@override final  String location;
@override final  String? ownerName;
@override final  String? phoneNumber;
@override final  String? email;
@override final  String? panVatNumber;
@override final  double? latitude;
@override final  double? longitude;
@override final  String? notes;
@override final  String? dateJoined;
@override@JsonKey() final  bool isActive;
@override final  DateTime? createdAt;

/// Create a copy of Prospects
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProspectsCopyWith<_Prospects> get copyWith => __$ProspectsCopyWithImpl<_Prospects>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProspectsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Prospects&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.location, location) || other.location == location)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.email, email) || other.email == email)&&(identical(other.panVatNumber, panVatNumber) || other.panVatNumber == panVatNumber)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.dateJoined, dateJoined) || other.dateJoined == dateJoined)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,location,ownerName,phoneNumber,email,panVatNumber,latitude,longitude,notes,dateJoined,isActive,createdAt);

@override
String toString() {
  return 'Prospects(id: $id, name: $name, location: $location, ownerName: $ownerName, phoneNumber: $phoneNumber, email: $email, panVatNumber: $panVatNumber, latitude: $latitude, longitude: $longitude, notes: $notes, dateJoined: $dateJoined, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ProspectsCopyWith<$Res> implements $ProspectsCopyWith<$Res> {
  factory _$ProspectsCopyWith(_Prospects value, $Res Function(_Prospects) _then) = __$ProspectsCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String location, String? ownerName, String? phoneNumber, String? email, String? panVatNumber, double? latitude, double? longitude, String? notes, String? dateJoined, bool isActive, DateTime? createdAt
});




}
/// @nodoc
class __$ProspectsCopyWithImpl<$Res>
    implements _$ProspectsCopyWith<$Res> {
  __$ProspectsCopyWithImpl(this._self, this._then);

  final _Prospects _self;
  final $Res Function(_Prospects) _then;

/// Create a copy of Prospects
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? location = null,Object? ownerName = freezed,Object? phoneNumber = freezed,Object? email = freezed,Object? panVatNumber = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? notes = freezed,Object? dateJoined = freezed,Object? isActive = null,Object? createdAt = freezed,}) {
  return _then(_Prospects(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,ownerName: freezed == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,panVatNumber: freezed == panVatNumber ? _self.panVatNumber : panVatNumber // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,dateJoined: freezed == dateJoined ? _self.dateJoined : dateJoined // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
