// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'add_prospect.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateProspectRequest {

 String get name; String get ownerName; String get dateJoined; String? get panVatNumber; CreateProspectContact get contact; CreateProspectLocation get location; String? get notes;
/// Create a copy of CreateProspectRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateProspectRequestCopyWith<CreateProspectRequest> get copyWith => _$CreateProspectRequestCopyWithImpl<CreateProspectRequest>(this as CreateProspectRequest, _$identity);

  /// Serializes this CreateProspectRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateProspectRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.dateJoined, dateJoined) || other.dateJoined == dateJoined)&&(identical(other.panVatNumber, panVatNumber) || other.panVatNumber == panVatNumber)&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.location, location) || other.location == location)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,ownerName,dateJoined,panVatNumber,contact,location,notes);

@override
String toString() {
  return 'CreateProspectRequest(name: $name, ownerName: $ownerName, dateJoined: $dateJoined, panVatNumber: $panVatNumber, contact: $contact, location: $location, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $CreateProspectRequestCopyWith<$Res>  {
  factory $CreateProspectRequestCopyWith(CreateProspectRequest value, $Res Function(CreateProspectRequest) _then) = _$CreateProspectRequestCopyWithImpl;
@useResult
$Res call({
 String name, String ownerName, String dateJoined, String? panVatNumber, CreateProspectContact contact, CreateProspectLocation location, String? notes
});


$CreateProspectContactCopyWith<$Res> get contact;$CreateProspectLocationCopyWith<$Res> get location;

}
/// @nodoc
class _$CreateProspectRequestCopyWithImpl<$Res>
    implements $CreateProspectRequestCopyWith<$Res> {
  _$CreateProspectRequestCopyWithImpl(this._self, this._then);

  final CreateProspectRequest _self;
  final $Res Function(CreateProspectRequest) _then;

/// Create a copy of CreateProspectRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? ownerName = null,Object? dateJoined = null,Object? panVatNumber = freezed,Object? contact = null,Object? location = null,Object? notes = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,dateJoined: null == dateJoined ? _self.dateJoined : dateJoined // ignore: cast_nullable_to_non_nullable
as String,panVatNumber: freezed == panVatNumber ? _self.panVatNumber : panVatNumber // ignore: cast_nullable_to_non_nullable
as String?,contact: null == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as CreateProspectContact,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as CreateProspectLocation,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CreateProspectRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreateProspectContactCopyWith<$Res> get contact {
  
  return $CreateProspectContactCopyWith<$Res>(_self.contact, (value) {
    return _then(_self.copyWith(contact: value));
  });
}/// Create a copy of CreateProspectRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreateProspectLocationCopyWith<$Res> get location {
  
  return $CreateProspectLocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// Adds pattern-matching-related methods to [CreateProspectRequest].
extension CreateProspectRequestPatterns on CreateProspectRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateProspectRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateProspectRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateProspectRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateProspectRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateProspectRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateProspectRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String ownerName,  String dateJoined,  String? panVatNumber,  CreateProspectContact contact,  CreateProspectLocation location,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateProspectRequest() when $default != null:
return $default(_that.name,_that.ownerName,_that.dateJoined,_that.panVatNumber,_that.contact,_that.location,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String ownerName,  String dateJoined,  String? panVatNumber,  CreateProspectContact contact,  CreateProspectLocation location,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _CreateProspectRequest():
return $default(_that.name,_that.ownerName,_that.dateJoined,_that.panVatNumber,_that.contact,_that.location,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String ownerName,  String dateJoined,  String? panVatNumber,  CreateProspectContact contact,  CreateProspectLocation location,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _CreateProspectRequest() when $default != null:
return $default(_that.name,_that.ownerName,_that.dateJoined,_that.panVatNumber,_that.contact,_that.location,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateProspectRequest implements CreateProspectRequest {
  const _CreateProspectRequest({required this.name, required this.ownerName, required this.dateJoined, this.panVatNumber, required this.contact, required this.location, this.notes});
  factory _CreateProspectRequest.fromJson(Map<String, dynamic> json) => _$CreateProspectRequestFromJson(json);

@override final  String name;
@override final  String ownerName;
@override final  String dateJoined;
@override final  String? panVatNumber;
@override final  CreateProspectContact contact;
@override final  CreateProspectLocation location;
@override final  String? notes;

/// Create a copy of CreateProspectRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateProspectRequestCopyWith<_CreateProspectRequest> get copyWith => __$CreateProspectRequestCopyWithImpl<_CreateProspectRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateProspectRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateProspectRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.dateJoined, dateJoined) || other.dateJoined == dateJoined)&&(identical(other.panVatNumber, panVatNumber) || other.panVatNumber == panVatNumber)&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.location, location) || other.location == location)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,ownerName,dateJoined,panVatNumber,contact,location,notes);

@override
String toString() {
  return 'CreateProspectRequest(name: $name, ownerName: $ownerName, dateJoined: $dateJoined, panVatNumber: $panVatNumber, contact: $contact, location: $location, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$CreateProspectRequestCopyWith<$Res> implements $CreateProspectRequestCopyWith<$Res> {
  factory _$CreateProspectRequestCopyWith(_CreateProspectRequest value, $Res Function(_CreateProspectRequest) _then) = __$CreateProspectRequestCopyWithImpl;
@override @useResult
$Res call({
 String name, String ownerName, String dateJoined, String? panVatNumber, CreateProspectContact contact, CreateProspectLocation location, String? notes
});


@override $CreateProspectContactCopyWith<$Res> get contact;@override $CreateProspectLocationCopyWith<$Res> get location;

}
/// @nodoc
class __$CreateProspectRequestCopyWithImpl<$Res>
    implements _$CreateProspectRequestCopyWith<$Res> {
  __$CreateProspectRequestCopyWithImpl(this._self, this._then);

  final _CreateProspectRequest _self;
  final $Res Function(_CreateProspectRequest) _then;

/// Create a copy of CreateProspectRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? ownerName = null,Object? dateJoined = null,Object? panVatNumber = freezed,Object? contact = null,Object? location = null,Object? notes = freezed,}) {
  return _then(_CreateProspectRequest(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,dateJoined: null == dateJoined ? _self.dateJoined : dateJoined // ignore: cast_nullable_to_non_nullable
as String,panVatNumber: freezed == panVatNumber ? _self.panVatNumber : panVatNumber // ignore: cast_nullable_to_non_nullable
as String?,contact: null == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as CreateProspectContact,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as CreateProspectLocation,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CreateProspectRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreateProspectContactCopyWith<$Res> get contact {
  
  return $CreateProspectContactCopyWith<$Res>(_self.contact, (value) {
    return _then(_self.copyWith(contact: value));
  });
}/// Create a copy of CreateProspectRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreateProspectLocationCopyWith<$Res> get location {
  
  return $CreateProspectLocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// @nodoc
mixin _$CreateProspectContact {

 String get phone; String? get email;
/// Create a copy of CreateProspectContact
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateProspectContactCopyWith<CreateProspectContact> get copyWith => _$CreateProspectContactCopyWithImpl<CreateProspectContact>(this as CreateProspectContact, _$identity);

  /// Serializes this CreateProspectContact to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateProspectContact&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phone,email);

@override
String toString() {
  return 'CreateProspectContact(phone: $phone, email: $email)';
}


}

/// @nodoc
abstract mixin class $CreateProspectContactCopyWith<$Res>  {
  factory $CreateProspectContactCopyWith(CreateProspectContact value, $Res Function(CreateProspectContact) _then) = _$CreateProspectContactCopyWithImpl;
@useResult
$Res call({
 String phone, String? email
});




}
/// @nodoc
class _$CreateProspectContactCopyWithImpl<$Res>
    implements $CreateProspectContactCopyWith<$Res> {
  _$CreateProspectContactCopyWithImpl(this._self, this._then);

  final CreateProspectContact _self;
  final $Res Function(CreateProspectContact) _then;

/// Create a copy of CreateProspectContact
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phone = null,Object? email = freezed,}) {
  return _then(_self.copyWith(
phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateProspectContact].
extension CreateProspectContactPatterns on CreateProspectContact {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateProspectContact value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateProspectContact() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateProspectContact value)  $default,){
final _that = this;
switch (_that) {
case _CreateProspectContact():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateProspectContact value)?  $default,){
final _that = this;
switch (_that) {
case _CreateProspectContact() when $default != null:
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
case _CreateProspectContact() when $default != null:
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
case _CreateProspectContact():
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
case _CreateProspectContact() when $default != null:
return $default(_that.phone,_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateProspectContact implements CreateProspectContact {
  const _CreateProspectContact({required this.phone, this.email});
  factory _CreateProspectContact.fromJson(Map<String, dynamic> json) => _$CreateProspectContactFromJson(json);

@override final  String phone;
@override final  String? email;

/// Create a copy of CreateProspectContact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateProspectContactCopyWith<_CreateProspectContact> get copyWith => __$CreateProspectContactCopyWithImpl<_CreateProspectContact>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateProspectContactToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateProspectContact&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phone,email);

@override
String toString() {
  return 'CreateProspectContact(phone: $phone, email: $email)';
}


}

/// @nodoc
abstract mixin class _$CreateProspectContactCopyWith<$Res> implements $CreateProspectContactCopyWith<$Res> {
  factory _$CreateProspectContactCopyWith(_CreateProspectContact value, $Res Function(_CreateProspectContact) _then) = __$CreateProspectContactCopyWithImpl;
@override @useResult
$Res call({
 String phone, String? email
});




}
/// @nodoc
class __$CreateProspectContactCopyWithImpl<$Res>
    implements _$CreateProspectContactCopyWith<$Res> {
  __$CreateProspectContactCopyWithImpl(this._self, this._then);

  final _CreateProspectContact _self;
  final $Res Function(_CreateProspectContact) _then;

/// Create a copy of CreateProspectContact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phone = null,Object? email = freezed,}) {
  return _then(_CreateProspectContact(
phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CreateProspectLocation {

 String get address; double get latitude; double get longitude;
/// Create a copy of CreateProspectLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateProspectLocationCopyWith<CreateProspectLocation> get copyWith => _$CreateProspectLocationCopyWithImpl<CreateProspectLocation>(this as CreateProspectLocation, _$identity);

  /// Serializes this CreateProspectLocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateProspectLocation&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,latitude,longitude);

@override
String toString() {
  return 'CreateProspectLocation(address: $address, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class $CreateProspectLocationCopyWith<$Res>  {
  factory $CreateProspectLocationCopyWith(CreateProspectLocation value, $Res Function(CreateProspectLocation) _then) = _$CreateProspectLocationCopyWithImpl;
@useResult
$Res call({
 String address, double latitude, double longitude
});




}
/// @nodoc
class _$CreateProspectLocationCopyWithImpl<$Res>
    implements $CreateProspectLocationCopyWith<$Res> {
  _$CreateProspectLocationCopyWithImpl(this._self, this._then);

  final CreateProspectLocation _self;
  final $Res Function(CreateProspectLocation) _then;

/// Create a copy of CreateProspectLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? address = null,Object? latitude = null,Object? longitude = null,}) {
  return _then(_self.copyWith(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateProspectLocation].
extension CreateProspectLocationPatterns on CreateProspectLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateProspectLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateProspectLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateProspectLocation value)  $default,){
final _that = this;
switch (_that) {
case _CreateProspectLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateProspectLocation value)?  $default,){
final _that = this;
switch (_that) {
case _CreateProspectLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String address,  double latitude,  double longitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateProspectLocation() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String address,  double latitude,  double longitude)  $default,) {final _that = this;
switch (_that) {
case _CreateProspectLocation():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String address,  double latitude,  double longitude)?  $default,) {final _that = this;
switch (_that) {
case _CreateProspectLocation() when $default != null:
return $default(_that.address,_that.latitude,_that.longitude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateProspectLocation implements CreateProspectLocation {
  const _CreateProspectLocation({required this.address, required this.latitude, required this.longitude});
  factory _CreateProspectLocation.fromJson(Map<String, dynamic> json) => _$CreateProspectLocationFromJson(json);

@override final  String address;
@override final  double latitude;
@override final  double longitude;

/// Create a copy of CreateProspectLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateProspectLocationCopyWith<_CreateProspectLocation> get copyWith => __$CreateProspectLocationCopyWithImpl<_CreateProspectLocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateProspectLocationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateProspectLocation&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,latitude,longitude);

@override
String toString() {
  return 'CreateProspectLocation(address: $address, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class _$CreateProspectLocationCopyWith<$Res> implements $CreateProspectLocationCopyWith<$Res> {
  factory _$CreateProspectLocationCopyWith(_CreateProspectLocation value, $Res Function(_CreateProspectLocation) _then) = __$CreateProspectLocationCopyWithImpl;
@override @useResult
$Res call({
 String address, double latitude, double longitude
});




}
/// @nodoc
class __$CreateProspectLocationCopyWithImpl<$Res>
    implements _$CreateProspectLocationCopyWith<$Res> {
  __$CreateProspectLocationCopyWithImpl(this._self, this._then);

  final _CreateProspectLocation _self;
  final $Res Function(_CreateProspectLocation) _then;

/// Create a copy of CreateProspectLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? address = null,Object? latitude = null,Object? longitude = null,}) {
  return _then(_CreateProspectLocation(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
