// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'edit_prospect_details.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProspectDetails {

 String get id; String get name; String get ownerName; String? get panVatNumber;// ✅ Optional
 String get phoneNumber; String? get email; String get fullAddress; double? get latitude; double? get longitude; String? get notes; bool get isActive; String? get dateJoined; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of ProspectDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProspectDetailsCopyWith<ProspectDetails> get copyWith => _$ProspectDetailsCopyWithImpl<ProspectDetails>(this as ProspectDetails, _$identity);

  /// Serializes this ProspectDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProspectDetails&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.panVatNumber, panVatNumber) || other.panVatNumber == panVatNumber)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.email, email) || other.email == email)&&(identical(other.fullAddress, fullAddress) || other.fullAddress == fullAddress)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.dateJoined, dateJoined) || other.dateJoined == dateJoined)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,ownerName,panVatNumber,phoneNumber,email,fullAddress,latitude,longitude,notes,isActive,dateJoined,createdAt,updatedAt);

@override
String toString() {
  return 'ProspectDetails(id: $id, name: $name, ownerName: $ownerName, panVatNumber: $panVatNumber, phoneNumber: $phoneNumber, email: $email, fullAddress: $fullAddress, latitude: $latitude, longitude: $longitude, notes: $notes, isActive: $isActive, dateJoined: $dateJoined, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ProspectDetailsCopyWith<$Res>  {
  factory $ProspectDetailsCopyWith(ProspectDetails value, $Res Function(ProspectDetails) _then) = _$ProspectDetailsCopyWithImpl;
@useResult
$Res call({
 String id, String name, String ownerName, String? panVatNumber, String phoneNumber, String? email, String fullAddress, double? latitude, double? longitude, String? notes, bool isActive, String? dateJoined, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$ProspectDetailsCopyWithImpl<$Res>
    implements $ProspectDetailsCopyWith<$Res> {
  _$ProspectDetailsCopyWithImpl(this._self, this._then);

  final ProspectDetails _self;
  final $Res Function(ProspectDetails) _then;

/// Create a copy of ProspectDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? ownerName = null,Object? panVatNumber = freezed,Object? phoneNumber = null,Object? email = freezed,Object? fullAddress = null,Object? latitude = freezed,Object? longitude = freezed,Object? notes = freezed,Object? isActive = null,Object? dateJoined = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,panVatNumber: freezed == panVatNumber ? _self.panVatNumber : panVatNumber // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,fullAddress: null == fullAddress ? _self.fullAddress : fullAddress // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,dateJoined: freezed == dateJoined ? _self.dateJoined : dateJoined // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProspectDetails].
extension ProspectDetailsPatterns on ProspectDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProspectDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProspectDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProspectDetails value)  $default,){
final _that = this;
switch (_that) {
case _ProspectDetails():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProspectDetails value)?  $default,){
final _that = this;
switch (_that) {
case _ProspectDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String ownerName,  String? panVatNumber,  String phoneNumber,  String? email,  String fullAddress,  double? latitude,  double? longitude,  String? notes,  bool isActive,  String? dateJoined,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProspectDetails() when $default != null:
return $default(_that.id,_that.name,_that.ownerName,_that.panVatNumber,_that.phoneNumber,_that.email,_that.fullAddress,_that.latitude,_that.longitude,_that.notes,_that.isActive,_that.dateJoined,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String ownerName,  String? panVatNumber,  String phoneNumber,  String? email,  String fullAddress,  double? latitude,  double? longitude,  String? notes,  bool isActive,  String? dateJoined,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ProspectDetails():
return $default(_that.id,_that.name,_that.ownerName,_that.panVatNumber,_that.phoneNumber,_that.email,_that.fullAddress,_that.latitude,_that.longitude,_that.notes,_that.isActive,_that.dateJoined,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String ownerName,  String? panVatNumber,  String phoneNumber,  String? email,  String fullAddress,  double? latitude,  double? longitude,  String? notes,  bool isActive,  String? dateJoined,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProspectDetails() when $default != null:
return $default(_that.id,_that.name,_that.ownerName,_that.panVatNumber,_that.phoneNumber,_that.email,_that.fullAddress,_that.latitude,_that.longitude,_that.notes,_that.isActive,_that.dateJoined,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProspectDetails extends ProspectDetails {
  const _ProspectDetails({required this.id, required this.name, required this.ownerName, this.panVatNumber, required this.phoneNumber, this.email, required this.fullAddress, this.latitude, this.longitude, this.notes, this.isActive = true, this.dateJoined, this.createdAt, this.updatedAt}): super._();
  factory _ProspectDetails.fromJson(Map<String, dynamic> json) => _$ProspectDetailsFromJson(json);

@override final  String id;
@override final  String name;
@override final  String ownerName;
@override final  String? panVatNumber;
// ✅ Optional
@override final  String phoneNumber;
@override final  String? email;
@override final  String fullAddress;
@override final  double? latitude;
@override final  double? longitude;
@override final  String? notes;
@override@JsonKey() final  bool isActive;
@override final  String? dateJoined;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of ProspectDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProspectDetailsCopyWith<_ProspectDetails> get copyWith => __$ProspectDetailsCopyWithImpl<_ProspectDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProspectDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProspectDetails&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.panVatNumber, panVatNumber) || other.panVatNumber == panVatNumber)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.email, email) || other.email == email)&&(identical(other.fullAddress, fullAddress) || other.fullAddress == fullAddress)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.dateJoined, dateJoined) || other.dateJoined == dateJoined)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,ownerName,panVatNumber,phoneNumber,email,fullAddress,latitude,longitude,notes,isActive,dateJoined,createdAt,updatedAt);

@override
String toString() {
  return 'ProspectDetails(id: $id, name: $name, ownerName: $ownerName, panVatNumber: $panVatNumber, phoneNumber: $phoneNumber, email: $email, fullAddress: $fullAddress, latitude: $latitude, longitude: $longitude, notes: $notes, isActive: $isActive, dateJoined: $dateJoined, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProspectDetailsCopyWith<$Res> implements $ProspectDetailsCopyWith<$Res> {
  factory _$ProspectDetailsCopyWith(_ProspectDetails value, $Res Function(_ProspectDetails) _then) = __$ProspectDetailsCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String ownerName, String? panVatNumber, String phoneNumber, String? email, String fullAddress, double? latitude, double? longitude, String? notes, bool isActive, String? dateJoined, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$ProspectDetailsCopyWithImpl<$Res>
    implements _$ProspectDetailsCopyWith<$Res> {
  __$ProspectDetailsCopyWithImpl(this._self, this._then);

  final _ProspectDetails _self;
  final $Res Function(_ProspectDetails) _then;

/// Create a copy of ProspectDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? ownerName = null,Object? panVatNumber = freezed,Object? phoneNumber = null,Object? email = freezed,Object? fullAddress = null,Object? latitude = freezed,Object? longitude = freezed,Object? notes = freezed,Object? isActive = null,Object? dateJoined = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ProspectDetails(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,panVatNumber: freezed == panVatNumber ? _self.panVatNumber : panVatNumber // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,fullAddress: null == fullAddress ? _self.fullAddress : fullAddress // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,dateJoined: freezed == dateJoined ? _self.dateJoined : dateJoined // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$UpdateProspectDetailsRequest {

 String get name; String get ownerName; String? get panVatNumber;// ✅ Optional
 UpdateProspectDetailsContact get contact; UpdateProspectDetailsLocation get location; String? get notes;
/// Create a copy of UpdateProspectDetailsRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateProspectDetailsRequestCopyWith<UpdateProspectDetailsRequest> get copyWith => _$UpdateProspectDetailsRequestCopyWithImpl<UpdateProspectDetailsRequest>(this as UpdateProspectDetailsRequest, _$identity);

  /// Serializes this UpdateProspectDetailsRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateProspectDetailsRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.panVatNumber, panVatNumber) || other.panVatNumber == panVatNumber)&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.location, location) || other.location == location)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,ownerName,panVatNumber,contact,location,notes);

@override
String toString() {
  return 'UpdateProspectDetailsRequest(name: $name, ownerName: $ownerName, panVatNumber: $panVatNumber, contact: $contact, location: $location, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $UpdateProspectDetailsRequestCopyWith<$Res>  {
  factory $UpdateProspectDetailsRequestCopyWith(UpdateProspectDetailsRequest value, $Res Function(UpdateProspectDetailsRequest) _then) = _$UpdateProspectDetailsRequestCopyWithImpl;
@useResult
$Res call({
 String name, String ownerName, String? panVatNumber, UpdateProspectDetailsContact contact, UpdateProspectDetailsLocation location, String? notes
});


$UpdateProspectDetailsContactCopyWith<$Res> get contact;$UpdateProspectDetailsLocationCopyWith<$Res> get location;

}
/// @nodoc
class _$UpdateProspectDetailsRequestCopyWithImpl<$Res>
    implements $UpdateProspectDetailsRequestCopyWith<$Res> {
  _$UpdateProspectDetailsRequestCopyWithImpl(this._self, this._then);

  final UpdateProspectDetailsRequest _self;
  final $Res Function(UpdateProspectDetailsRequest) _then;

/// Create a copy of UpdateProspectDetailsRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? ownerName = null,Object? panVatNumber = freezed,Object? contact = null,Object? location = null,Object? notes = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,panVatNumber: freezed == panVatNumber ? _self.panVatNumber : panVatNumber // ignore: cast_nullable_to_non_nullable
as String?,contact: null == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as UpdateProspectDetailsContact,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as UpdateProspectDetailsLocation,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of UpdateProspectDetailsRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpdateProspectDetailsContactCopyWith<$Res> get contact {
  
  return $UpdateProspectDetailsContactCopyWith<$Res>(_self.contact, (value) {
    return _then(_self.copyWith(contact: value));
  });
}/// Create a copy of UpdateProspectDetailsRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpdateProspectDetailsLocationCopyWith<$Res> get location {
  
  return $UpdateProspectDetailsLocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// Adds pattern-matching-related methods to [UpdateProspectDetailsRequest].
extension UpdateProspectDetailsRequestPatterns on UpdateProspectDetailsRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateProspectDetailsRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateProspectDetailsRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateProspectDetailsRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateProspectDetailsRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateProspectDetailsRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateProspectDetailsRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String ownerName,  String? panVatNumber,  UpdateProspectDetailsContact contact,  UpdateProspectDetailsLocation location,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateProspectDetailsRequest() when $default != null:
return $default(_that.name,_that.ownerName,_that.panVatNumber,_that.contact,_that.location,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String ownerName,  String? panVatNumber,  UpdateProspectDetailsContact contact,  UpdateProspectDetailsLocation location,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _UpdateProspectDetailsRequest():
return $default(_that.name,_that.ownerName,_that.panVatNumber,_that.contact,_that.location,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String ownerName,  String? panVatNumber,  UpdateProspectDetailsContact contact,  UpdateProspectDetailsLocation location,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _UpdateProspectDetailsRequest() when $default != null:
return $default(_that.name,_that.ownerName,_that.panVatNumber,_that.contact,_that.location,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateProspectDetailsRequest implements UpdateProspectDetailsRequest {
  const _UpdateProspectDetailsRequest({required this.name, required this.ownerName, this.panVatNumber, required this.contact, required this.location, this.notes});
  factory _UpdateProspectDetailsRequest.fromJson(Map<String, dynamic> json) => _$UpdateProspectDetailsRequestFromJson(json);

@override final  String name;
@override final  String ownerName;
@override final  String? panVatNumber;
// ✅ Optional
@override final  UpdateProspectDetailsContact contact;
@override final  UpdateProspectDetailsLocation location;
@override final  String? notes;

/// Create a copy of UpdateProspectDetailsRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateProspectDetailsRequestCopyWith<_UpdateProspectDetailsRequest> get copyWith => __$UpdateProspectDetailsRequestCopyWithImpl<_UpdateProspectDetailsRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateProspectDetailsRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateProspectDetailsRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.panVatNumber, panVatNumber) || other.panVatNumber == panVatNumber)&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.location, location) || other.location == location)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,ownerName,panVatNumber,contact,location,notes);

@override
String toString() {
  return 'UpdateProspectDetailsRequest(name: $name, ownerName: $ownerName, panVatNumber: $panVatNumber, contact: $contact, location: $location, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$UpdateProspectDetailsRequestCopyWith<$Res> implements $UpdateProspectDetailsRequestCopyWith<$Res> {
  factory _$UpdateProspectDetailsRequestCopyWith(_UpdateProspectDetailsRequest value, $Res Function(_UpdateProspectDetailsRequest) _then) = __$UpdateProspectDetailsRequestCopyWithImpl;
@override @useResult
$Res call({
 String name, String ownerName, String? panVatNumber, UpdateProspectDetailsContact contact, UpdateProspectDetailsLocation location, String? notes
});


@override $UpdateProspectDetailsContactCopyWith<$Res> get contact;@override $UpdateProspectDetailsLocationCopyWith<$Res> get location;

}
/// @nodoc
class __$UpdateProspectDetailsRequestCopyWithImpl<$Res>
    implements _$UpdateProspectDetailsRequestCopyWith<$Res> {
  __$UpdateProspectDetailsRequestCopyWithImpl(this._self, this._then);

  final _UpdateProspectDetailsRequest _self;
  final $Res Function(_UpdateProspectDetailsRequest) _then;

/// Create a copy of UpdateProspectDetailsRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? ownerName = null,Object? panVatNumber = freezed,Object? contact = null,Object? location = null,Object? notes = freezed,}) {
  return _then(_UpdateProspectDetailsRequest(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,panVatNumber: freezed == panVatNumber ? _self.panVatNumber : panVatNumber // ignore: cast_nullable_to_non_nullable
as String?,contact: null == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as UpdateProspectDetailsContact,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as UpdateProspectDetailsLocation,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of UpdateProspectDetailsRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpdateProspectDetailsContactCopyWith<$Res> get contact {
  
  return $UpdateProspectDetailsContactCopyWith<$Res>(_self.contact, (value) {
    return _then(_self.copyWith(contact: value));
  });
}/// Create a copy of UpdateProspectDetailsRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpdateProspectDetailsLocationCopyWith<$Res> get location {
  
  return $UpdateProspectDetailsLocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// @nodoc
mixin _$UpdateProspectDetailsContact {

 String get phone; String? get email;
/// Create a copy of UpdateProspectDetailsContact
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateProspectDetailsContactCopyWith<UpdateProspectDetailsContact> get copyWith => _$UpdateProspectDetailsContactCopyWithImpl<UpdateProspectDetailsContact>(this as UpdateProspectDetailsContact, _$identity);

  /// Serializes this UpdateProspectDetailsContact to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateProspectDetailsContact&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phone,email);

@override
String toString() {
  return 'UpdateProspectDetailsContact(phone: $phone, email: $email)';
}


}

/// @nodoc
abstract mixin class $UpdateProspectDetailsContactCopyWith<$Res>  {
  factory $UpdateProspectDetailsContactCopyWith(UpdateProspectDetailsContact value, $Res Function(UpdateProspectDetailsContact) _then) = _$UpdateProspectDetailsContactCopyWithImpl;
@useResult
$Res call({
 String phone, String? email
});




}
/// @nodoc
class _$UpdateProspectDetailsContactCopyWithImpl<$Res>
    implements $UpdateProspectDetailsContactCopyWith<$Res> {
  _$UpdateProspectDetailsContactCopyWithImpl(this._self, this._then);

  final UpdateProspectDetailsContact _self;
  final $Res Function(UpdateProspectDetailsContact) _then;

/// Create a copy of UpdateProspectDetailsContact
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phone = null,Object? email = freezed,}) {
  return _then(_self.copyWith(
phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateProspectDetailsContact].
extension UpdateProspectDetailsContactPatterns on UpdateProspectDetailsContact {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateProspectDetailsContact value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateProspectDetailsContact() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateProspectDetailsContact value)  $default,){
final _that = this;
switch (_that) {
case _UpdateProspectDetailsContact():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateProspectDetailsContact value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateProspectDetailsContact() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String phone,  String? email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateProspectDetailsContact() when $default != null:
return $default(_that.phone,_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String phone,  String? email)  $default,) {final _that = this;
switch (_that) {
case _UpdateProspectDetailsContact():
return $default(_that.phone,_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String phone,  String? email)?  $default,) {final _that = this;
switch (_that) {
case _UpdateProspectDetailsContact() when $default != null:
return $default(_that.phone,_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateProspectDetailsContact implements UpdateProspectDetailsContact {
  const _UpdateProspectDetailsContact({required this.phone, this.email});
  factory _UpdateProspectDetailsContact.fromJson(Map<String, dynamic> json) => _$UpdateProspectDetailsContactFromJson(json);

@override final  String phone;
@override final  String? email;

/// Create a copy of UpdateProspectDetailsContact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateProspectDetailsContactCopyWith<_UpdateProspectDetailsContact> get copyWith => __$UpdateProspectDetailsContactCopyWithImpl<_UpdateProspectDetailsContact>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateProspectDetailsContactToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateProspectDetailsContact&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phone,email);

@override
String toString() {
  return 'UpdateProspectDetailsContact(phone: $phone, email: $email)';
}


}

/// @nodoc
abstract mixin class _$UpdateProspectDetailsContactCopyWith<$Res> implements $UpdateProspectDetailsContactCopyWith<$Res> {
  factory _$UpdateProspectDetailsContactCopyWith(_UpdateProspectDetailsContact value, $Res Function(_UpdateProspectDetailsContact) _then) = __$UpdateProspectDetailsContactCopyWithImpl;
@override @useResult
$Res call({
 String phone, String? email
});




}
/// @nodoc
class __$UpdateProspectDetailsContactCopyWithImpl<$Res>
    implements _$UpdateProspectDetailsContactCopyWith<$Res> {
  __$UpdateProspectDetailsContactCopyWithImpl(this._self, this._then);

  final _UpdateProspectDetailsContact _self;
  final $Res Function(_UpdateProspectDetailsContact) _then;

/// Create a copy of UpdateProspectDetailsContact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phone = null,Object? email = freezed,}) {
  return _then(_UpdateProspectDetailsContact(
phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UpdateProspectDetailsLocation {

 String get address; double? get latitude; double? get longitude;
/// Create a copy of UpdateProspectDetailsLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateProspectDetailsLocationCopyWith<UpdateProspectDetailsLocation> get copyWith => _$UpdateProspectDetailsLocationCopyWithImpl<UpdateProspectDetailsLocation>(this as UpdateProspectDetailsLocation, _$identity);

  /// Serializes this UpdateProspectDetailsLocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateProspectDetailsLocation&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,latitude,longitude);

@override
String toString() {
  return 'UpdateProspectDetailsLocation(address: $address, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class $UpdateProspectDetailsLocationCopyWith<$Res>  {
  factory $UpdateProspectDetailsLocationCopyWith(UpdateProspectDetailsLocation value, $Res Function(UpdateProspectDetailsLocation) _then) = _$UpdateProspectDetailsLocationCopyWithImpl;
@useResult
$Res call({
 String address, double? latitude, double? longitude
});




}
/// @nodoc
class _$UpdateProspectDetailsLocationCopyWithImpl<$Res>
    implements $UpdateProspectDetailsLocationCopyWith<$Res> {
  _$UpdateProspectDetailsLocationCopyWithImpl(this._self, this._then);

  final UpdateProspectDetailsLocation _self;
  final $Res Function(UpdateProspectDetailsLocation) _then;

/// Create a copy of UpdateProspectDetailsLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? address = null,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(_self.copyWith(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateProspectDetailsLocation].
extension UpdateProspectDetailsLocationPatterns on UpdateProspectDetailsLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateProspectDetailsLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateProspectDetailsLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateProspectDetailsLocation value)  $default,){
final _that = this;
switch (_that) {
case _UpdateProspectDetailsLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateProspectDetailsLocation value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateProspectDetailsLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String address,  double? latitude,  double? longitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateProspectDetailsLocation() when $default != null:
return $default(_that.address,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String address,  double? latitude,  double? longitude)  $default,) {final _that = this;
switch (_that) {
case _UpdateProspectDetailsLocation():
return $default(_that.address,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String address,  double? latitude,  double? longitude)?  $default,) {final _that = this;
switch (_that) {
case _UpdateProspectDetailsLocation() when $default != null:
return $default(_that.address,_that.latitude,_that.longitude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateProspectDetailsLocation implements UpdateProspectDetailsLocation {
  const _UpdateProspectDetailsLocation({required this.address, this.latitude, this.longitude});
  factory _UpdateProspectDetailsLocation.fromJson(Map<String, dynamic> json) => _$UpdateProspectDetailsLocationFromJson(json);

@override final  String address;
@override final  double? latitude;
@override final  double? longitude;

/// Create a copy of UpdateProspectDetailsLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateProspectDetailsLocationCopyWith<_UpdateProspectDetailsLocation> get copyWith => __$UpdateProspectDetailsLocationCopyWithImpl<_UpdateProspectDetailsLocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateProspectDetailsLocationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateProspectDetailsLocation&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,latitude,longitude);

@override
String toString() {
  return 'UpdateProspectDetailsLocation(address: $address, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class _$UpdateProspectDetailsLocationCopyWith<$Res> implements $UpdateProspectDetailsLocationCopyWith<$Res> {
  factory _$UpdateProspectDetailsLocationCopyWith(_UpdateProspectDetailsLocation value, $Res Function(_UpdateProspectDetailsLocation) _then) = __$UpdateProspectDetailsLocationCopyWithImpl;
@override @useResult
$Res call({
 String address, double? latitude, double? longitude
});




}
/// @nodoc
class __$UpdateProspectDetailsLocationCopyWithImpl<$Res>
    implements _$UpdateProspectDetailsLocationCopyWith<$Res> {
  __$UpdateProspectDetailsLocationCopyWithImpl(this._self, this._then);

  final _UpdateProspectDetailsLocation _self;
  final $Res Function(_UpdateProspectDetailsLocation) _then;

/// Create a copy of UpdateProspectDetailsLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? address = null,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(_UpdateProspectDetailsLocation(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
