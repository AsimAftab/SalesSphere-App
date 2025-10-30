// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'add_new_party.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AddPartyRequest {

 String get companyName; String get ownerName; String get phone; String get address; String get email; String get panVatNumber; String? get googleMapLink; double? get latitude; double? get longitude;
/// Create a copy of AddPartyRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddPartyRequestCopyWith<AddPartyRequest> get copyWith => _$AddPartyRequestCopyWithImpl<AddPartyRequest>(this as AddPartyRequest, _$identity);

  /// Serializes this AddPartyRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddPartyRequest&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&(identical(other.email, email) || other.email == email)&&(identical(other.panVatNumber, panVatNumber) || other.panVatNumber == panVatNumber)&&(identical(other.googleMapLink, googleMapLink) || other.googleMapLink == googleMapLink)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,companyName,ownerName,phone,address,email,panVatNumber,googleMapLink,latitude,longitude);

@override
String toString() {
  return 'AddPartyRequest(companyName: $companyName, ownerName: $ownerName, phone: $phone, address: $address, email: $email, panVatNumber: $panVatNumber, googleMapLink: $googleMapLink, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class $AddPartyRequestCopyWith<$Res>  {
  factory $AddPartyRequestCopyWith(AddPartyRequest value, $Res Function(AddPartyRequest) _then) = _$AddPartyRequestCopyWithImpl;
@useResult
$Res call({
 String companyName, String ownerName, String phone, String address, String email, String panVatNumber, String? googleMapLink, double? latitude, double? longitude
});




}
/// @nodoc
class _$AddPartyRequestCopyWithImpl<$Res>
    implements $AddPartyRequestCopyWith<$Res> {
  _$AddPartyRequestCopyWithImpl(this._self, this._then);

  final AddPartyRequest _self;
  final $Res Function(AddPartyRequest) _then;

/// Create a copy of AddPartyRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? companyName = null,Object? ownerName = null,Object? phone = null,Object? address = null,Object? email = null,Object? panVatNumber = null,Object? googleMapLink = freezed,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(_self.copyWith(
companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,panVatNumber: null == panVatNumber ? _self.panVatNumber : panVatNumber // ignore: cast_nullable_to_non_nullable
as String,googleMapLink: freezed == googleMapLink ? _self.googleMapLink : googleMapLink // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [AddPartyRequest].
extension AddPartyRequestPatterns on AddPartyRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddPartyRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddPartyRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddPartyRequest value)  $default,){
final _that = this;
switch (_that) {
case _AddPartyRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddPartyRequest value)?  $default,){
final _that = this;
switch (_that) {
case _AddPartyRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String companyName,  String ownerName,  String phone,  String address,  String email,  String panVatNumber,  String? googleMapLink,  double? latitude,  double? longitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddPartyRequest() when $default != null:
return $default(_that.companyName,_that.ownerName,_that.phone,_that.address,_that.email,_that.panVatNumber,_that.googleMapLink,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String companyName,  String ownerName,  String phone,  String address,  String email,  String panVatNumber,  String? googleMapLink,  double? latitude,  double? longitude)  $default,) {final _that = this;
switch (_that) {
case _AddPartyRequest():
return $default(_that.companyName,_that.ownerName,_that.phone,_that.address,_that.email,_that.panVatNumber,_that.googleMapLink,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String companyName,  String ownerName,  String phone,  String address,  String email,  String panVatNumber,  String? googleMapLink,  double? latitude,  double? longitude)?  $default,) {final _that = this;
switch (_that) {
case _AddPartyRequest() when $default != null:
return $default(_that.companyName,_that.ownerName,_that.phone,_that.address,_that.email,_that.panVatNumber,_that.googleMapLink,_that.latitude,_that.longitude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AddPartyRequest implements AddPartyRequest {
  const _AddPartyRequest({required this.companyName, required this.ownerName, required this.phone, required this.address, required this.email, required this.panVatNumber, this.googleMapLink, this.latitude, this.longitude});
  factory _AddPartyRequest.fromJson(Map<String, dynamic> json) => _$AddPartyRequestFromJson(json);

@override final  String companyName;
@override final  String ownerName;
@override final  String phone;
@override final  String address;
@override final  String email;
@override final  String panVatNumber;
@override final  String? googleMapLink;
@override final  double? latitude;
@override final  double? longitude;

/// Create a copy of AddPartyRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddPartyRequestCopyWith<_AddPartyRequest> get copyWith => __$AddPartyRequestCopyWithImpl<_AddPartyRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddPartyRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddPartyRequest&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&(identical(other.email, email) || other.email == email)&&(identical(other.panVatNumber, panVatNumber) || other.panVatNumber == panVatNumber)&&(identical(other.googleMapLink, googleMapLink) || other.googleMapLink == googleMapLink)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,companyName,ownerName,phone,address,email,panVatNumber,googleMapLink,latitude,longitude);

@override
String toString() {
  return 'AddPartyRequest(companyName: $companyName, ownerName: $ownerName, phone: $phone, address: $address, email: $email, panVatNumber: $panVatNumber, googleMapLink: $googleMapLink, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class _$AddPartyRequestCopyWith<$Res> implements $AddPartyRequestCopyWith<$Res> {
  factory _$AddPartyRequestCopyWith(_AddPartyRequest value, $Res Function(_AddPartyRequest) _then) = __$AddPartyRequestCopyWithImpl;
@override @useResult
$Res call({
 String companyName, String ownerName, String phone, String address, String email, String panVatNumber, String? googleMapLink, double? latitude, double? longitude
});




}
/// @nodoc
class __$AddPartyRequestCopyWithImpl<$Res>
    implements _$AddPartyRequestCopyWith<$Res> {
  __$AddPartyRequestCopyWithImpl(this._self, this._then);

  final _AddPartyRequest _self;
  final $Res Function(_AddPartyRequest) _then;

/// Create a copy of AddPartyRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? companyName = null,Object? ownerName = null,Object? phone = null,Object? address = null,Object? email = null,Object? panVatNumber = null,Object? googleMapLink = freezed,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(_AddPartyRequest(
companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,panVatNumber: null == panVatNumber ? _self.panVatNumber : panVatNumber // ignore: cast_nullable_to_non_nullable
as String,googleMapLink: freezed == googleMapLink ? _self.googleMapLink : googleMapLink // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$AddPartyResponse {

 String get status; String get message; Party get data;
/// Create a copy of AddPartyResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddPartyResponseCopyWith<AddPartyResponse> get copyWith => _$AddPartyResponseCopyWithImpl<AddPartyResponse>(this as AddPartyResponse, _$identity);

  /// Serializes this AddPartyResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddPartyResponse&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message)&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,message,data);

@override
String toString() {
  return 'AddPartyResponse(status: $status, message: $message, data: $data)';
}


}

/// @nodoc
abstract mixin class $AddPartyResponseCopyWith<$Res>  {
  factory $AddPartyResponseCopyWith(AddPartyResponse value, $Res Function(AddPartyResponse) _then) = _$AddPartyResponseCopyWithImpl;
@useResult
$Res call({
 String status, String message, Party data
});


$PartyCopyWith<$Res> get data;

}
/// @nodoc
class _$AddPartyResponseCopyWithImpl<$Res>
    implements $AddPartyResponseCopyWith<$Res> {
  _$AddPartyResponseCopyWithImpl(this._self, this._then);

  final AddPartyResponse _self;
  final $Res Function(AddPartyResponse) _then;

/// Create a copy of AddPartyResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? message = null,Object? data = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Party,
  ));
}
/// Create a copy of AddPartyResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PartyCopyWith<$Res> get data {
  
  return $PartyCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [AddPartyResponse].
extension AddPartyResponsePatterns on AddPartyResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddPartyResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddPartyResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddPartyResponse value)  $default,){
final _that = this;
switch (_that) {
case _AddPartyResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddPartyResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AddPartyResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String status,  String message,  Party data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddPartyResponse() when $default != null:
return $default(_that.status,_that.message,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String status,  String message,  Party data)  $default,) {final _that = this;
switch (_that) {
case _AddPartyResponse():
return $default(_that.status,_that.message,_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String status,  String message,  Party data)?  $default,) {final _that = this;
switch (_that) {
case _AddPartyResponse() when $default != null:
return $default(_that.status,_that.message,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AddPartyResponse implements AddPartyResponse {
  const _AddPartyResponse({required this.status, required this.message, required this.data});
  factory _AddPartyResponse.fromJson(Map<String, dynamic> json) => _$AddPartyResponseFromJson(json);

@override final  String status;
@override final  String message;
@override final  Party data;

/// Create a copy of AddPartyResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddPartyResponseCopyWith<_AddPartyResponse> get copyWith => __$AddPartyResponseCopyWithImpl<_AddPartyResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddPartyResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddPartyResponse&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message)&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,message,data);

@override
String toString() {
  return 'AddPartyResponse(status: $status, message: $message, data: $data)';
}


}

/// @nodoc
abstract mixin class _$AddPartyResponseCopyWith<$Res> implements $AddPartyResponseCopyWith<$Res> {
  factory _$AddPartyResponseCopyWith(_AddPartyResponse value, $Res Function(_AddPartyResponse) _then) = __$AddPartyResponseCopyWithImpl;
@override @useResult
$Res call({
 String status, String message, Party data
});


@override $PartyCopyWith<$Res> get data;

}
/// @nodoc
class __$AddPartyResponseCopyWithImpl<$Res>
    implements _$AddPartyResponseCopyWith<$Res> {
  __$AddPartyResponseCopyWithImpl(this._self, this._then);

  final _AddPartyResponse _self;
  final $Res Function(_AddPartyResponse) _then;

/// Create a copy of AddPartyResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? message = null,Object? data = null,}) {
  return _then(_AddPartyResponse(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Party,
  ));
}

/// Create a copy of AddPartyResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PartyCopyWith<$Res> get data {
  
  return $PartyCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// @nodoc
mixin _$Party {

@JsonKey(name: '_id') String get id; String get companyName; String get ownerName; String get phone; String get address; String get email; String get panVatNumber; String? get googleMapLink; double? get latitude; double? get longitude; String get organizationId;// Assumed, based on User model
 bool get isActive; String get createdAt; String get updatedAt;@JsonKey(name: '__v') int get version;
/// Create a copy of Party
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PartyCopyWith<Party> get copyWith => _$PartyCopyWithImpl<Party>(this as Party, _$identity);

  /// Serializes this Party to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Party&&(identical(other.id, id) || other.id == id)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&(identical(other.email, email) || other.email == email)&&(identical(other.panVatNumber, panVatNumber) || other.panVatNumber == panVatNumber)&&(identical(other.googleMapLink, googleMapLink) || other.googleMapLink == googleMapLink)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyName,ownerName,phone,address,email,panVatNumber,googleMapLink,latitude,longitude,organizationId,isActive,createdAt,updatedAt,version);

@override
String toString() {
  return 'Party(id: $id, companyName: $companyName, ownerName: $ownerName, phone: $phone, address: $address, email: $email, panVatNumber: $panVatNumber, googleMapLink: $googleMapLink, latitude: $latitude, longitude: $longitude, organizationId: $organizationId, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, version: $version)';
}


}

/// @nodoc
abstract mixin class $PartyCopyWith<$Res>  {
  factory $PartyCopyWith(Party value, $Res Function(Party) _then) = _$PartyCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String id, String companyName, String ownerName, String phone, String address, String email, String panVatNumber, String? googleMapLink, double? latitude, double? longitude, String organizationId, bool isActive, String createdAt, String updatedAt,@JsonKey(name: '__v') int version
});




}
/// @nodoc
class _$PartyCopyWithImpl<$Res>
    implements $PartyCopyWith<$Res> {
  _$PartyCopyWithImpl(this._self, this._then);

  final Party _self;
  final $Res Function(Party) _then;

/// Create a copy of Party
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyName = null,Object? ownerName = null,Object? phone = null,Object? address = null,Object? email = null,Object? panVatNumber = null,Object? googleMapLink = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? organizationId = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? version = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,panVatNumber: null == panVatNumber ? _self.panVatNumber : panVatNumber // ignore: cast_nullable_to_non_nullable
as String,googleMapLink: freezed == googleMapLink ? _self.googleMapLink : googleMapLink // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Party].
extension PartyPatterns on Party {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Party value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Party() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Party value)  $default,){
final _that = this;
switch (_that) {
case _Party():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Party value)?  $default,){
final _that = this;
switch (_that) {
case _Party() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String companyName,  String ownerName,  String phone,  String address,  String email,  String panVatNumber,  String? googleMapLink,  double? latitude,  double? longitude,  String organizationId,  bool isActive,  String createdAt,  String updatedAt, @JsonKey(name: '__v')  int version)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Party() when $default != null:
return $default(_that.id,_that.companyName,_that.ownerName,_that.phone,_that.address,_that.email,_that.panVatNumber,_that.googleMapLink,_that.latitude,_that.longitude,_that.organizationId,_that.isActive,_that.createdAt,_that.updatedAt,_that.version);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String companyName,  String ownerName,  String phone,  String address,  String email,  String panVatNumber,  String? googleMapLink,  double? latitude,  double? longitude,  String organizationId,  bool isActive,  String createdAt,  String updatedAt, @JsonKey(name: '__v')  int version)  $default,) {final _that = this;
switch (_that) {
case _Party():
return $default(_that.id,_that.companyName,_that.ownerName,_that.phone,_that.address,_that.email,_that.panVatNumber,_that.googleMapLink,_that.latitude,_that.longitude,_that.organizationId,_that.isActive,_that.createdAt,_that.updatedAt,_that.version);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String id,  String companyName,  String ownerName,  String phone,  String address,  String email,  String panVatNumber,  String? googleMapLink,  double? latitude,  double? longitude,  String organizationId,  bool isActive,  String createdAt,  String updatedAt, @JsonKey(name: '__v')  int version)?  $default,) {final _that = this;
switch (_that) {
case _Party() when $default != null:
return $default(_that.id,_that.companyName,_that.ownerName,_that.phone,_that.address,_that.email,_that.panVatNumber,_that.googleMapLink,_that.latitude,_that.longitude,_that.organizationId,_that.isActive,_that.createdAt,_that.updatedAt,_that.version);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Party implements Party {
  const _Party({@JsonKey(name: '_id') required this.id, required this.companyName, required this.ownerName, required this.phone, required this.address, required this.email, required this.panVatNumber, this.googleMapLink, this.latitude, this.longitude, required this.organizationId, required this.isActive, required this.createdAt, required this.updatedAt, @JsonKey(name: '__v') required this.version});
  factory _Party.fromJson(Map<String, dynamic> json) => _$PartyFromJson(json);

@override@JsonKey(name: '_id') final  String id;
@override final  String companyName;
@override final  String ownerName;
@override final  String phone;
@override final  String address;
@override final  String email;
@override final  String panVatNumber;
@override final  String? googleMapLink;
@override final  double? latitude;
@override final  double? longitude;
@override final  String organizationId;
// Assumed, based on User model
@override final  bool isActive;
@override final  String createdAt;
@override final  String updatedAt;
@override@JsonKey(name: '__v') final  int version;

/// Create a copy of Party
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PartyCopyWith<_Party> get copyWith => __$PartyCopyWithImpl<_Party>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PartyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Party&&(identical(other.id, id) || other.id == id)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&(identical(other.email, email) || other.email == email)&&(identical(other.panVatNumber, panVatNumber) || other.panVatNumber == panVatNumber)&&(identical(other.googleMapLink, googleMapLink) || other.googleMapLink == googleMapLink)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyName,ownerName,phone,address,email,panVatNumber,googleMapLink,latitude,longitude,organizationId,isActive,createdAt,updatedAt,version);

@override
String toString() {
  return 'Party(id: $id, companyName: $companyName, ownerName: $ownerName, phone: $phone, address: $address, email: $email, panVatNumber: $panVatNumber, googleMapLink: $googleMapLink, latitude: $latitude, longitude: $longitude, organizationId: $organizationId, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, version: $version)';
}


}

/// @nodoc
abstract mixin class _$PartyCopyWith<$Res> implements $PartyCopyWith<$Res> {
  factory _$PartyCopyWith(_Party value, $Res Function(_Party) _then) = __$PartyCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String id, String companyName, String ownerName, String phone, String address, String email, String panVatNumber, String? googleMapLink, double? latitude, double? longitude, String organizationId, bool isActive, String createdAt, String updatedAt,@JsonKey(name: '__v') int version
});




}
/// @nodoc
class __$PartyCopyWithImpl<$Res>
    implements _$PartyCopyWith<$Res> {
  __$PartyCopyWithImpl(this._self, this._then);

  final _Party _self;
  final $Res Function(_Party) _then;

/// Create a copy of Party
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyName = null,Object? ownerName = null,Object? phone = null,Object? address = null,Object? email = null,Object? panVatNumber = null,Object? googleMapLink = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? organizationId = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? version = null,}) {
  return _then(_Party(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,panVatNumber: null == panVatNumber ? _self.panVatNumber : panVatNumber // ignore: cast_nullable_to_non_nullable
as String,googleMapLink: freezed == googleMapLink ? _self.googleMapLink : googleMapLink // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
