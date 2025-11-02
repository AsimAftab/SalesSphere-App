// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Profile {

@JsonKey(name: '_id') String get id; String get name; String get email; String get role; String get organizationId; bool get isActive; String get phone; String get address; String get gender; DateTime get dateOfBirth; int get age; String get panNumber; String get citizenshipNumber; DateTime get dateJoined; DateTime get createdAt; DateTime get updatedAt; String? get avatarUrl;
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCopyWith<Profile> get copyWith => _$ProfileCopyWithImpl<Profile>(this as Profile, _$identity);

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.age, age) || other.age == age)&&(identical(other.panNumber, panNumber) || other.panNumber == panNumber)&&(identical(other.citizenshipNumber, citizenshipNumber) || other.citizenshipNumber == citizenshipNumber)&&(identical(other.dateJoined, dateJoined) || other.dateJoined == dateJoined)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,role,organizationId,isActive,phone,address,gender,dateOfBirth,age,panNumber,citizenshipNumber,dateJoined,createdAt,updatedAt,avatarUrl);

@override
String toString() {
  return 'Profile(id: $id, name: $name, email: $email, role: $role, organizationId: $organizationId, isActive: $isActive, phone: $phone, address: $address, gender: $gender, dateOfBirth: $dateOfBirth, age: $age, panNumber: $panNumber, citizenshipNumber: $citizenshipNumber, dateJoined: $dateJoined, createdAt: $createdAt, updatedAt: $updatedAt, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $ProfileCopyWith<$Res>  {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) _then) = _$ProfileCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String id, String name, String email, String role, String organizationId, bool isActive, String phone, String address, String gender, DateTime dateOfBirth, int age, String panNumber, String citizenshipNumber, DateTime dateJoined, DateTime createdAt, DateTime updatedAt, String? avatarUrl
});




}
/// @nodoc
class _$ProfileCopyWithImpl<$Res>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._self, this._then);

  final Profile _self;
  final $Res Function(Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = null,Object? role = null,Object? organizationId = null,Object? isActive = null,Object? phone = null,Object? address = null,Object? gender = null,Object? dateOfBirth = null,Object? age = null,Object? panNumber = null,Object? citizenshipNumber = null,Object? dateJoined = null,Object? createdAt = null,Object? updatedAt = null,Object? avatarUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: null == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,panNumber: null == panNumber ? _self.panNumber : panNumber // ignore: cast_nullable_to_non_nullable
as String,citizenshipNumber: null == citizenshipNumber ? _self.citizenshipNumber : citizenshipNumber // ignore: cast_nullable_to_non_nullable
as String,dateJoined: null == dateJoined ? _self.dateJoined : dateJoined // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Profile].
extension ProfilePatterns on Profile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Profile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Profile value)  $default,){
final _that = this;
switch (_that) {
case _Profile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Profile value)?  $default,){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String name,  String email,  String role,  String organizationId,  bool isActive,  String phone,  String address,  String gender,  DateTime dateOfBirth,  int age,  String panNumber,  String citizenshipNumber,  DateTime dateJoined,  DateTime createdAt,  DateTime updatedAt,  String? avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.role,_that.organizationId,_that.isActive,_that.phone,_that.address,_that.gender,_that.dateOfBirth,_that.age,_that.panNumber,_that.citizenshipNumber,_that.dateJoined,_that.createdAt,_that.updatedAt,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String name,  String email,  String role,  String organizationId,  bool isActive,  String phone,  String address,  String gender,  DateTime dateOfBirth,  int age,  String panNumber,  String citizenshipNumber,  DateTime dateJoined,  DateTime createdAt,  DateTime updatedAt,  String? avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _Profile():
return $default(_that.id,_that.name,_that.email,_that.role,_that.organizationId,_that.isActive,_that.phone,_that.address,_that.gender,_that.dateOfBirth,_that.age,_that.panNumber,_that.citizenshipNumber,_that.dateJoined,_that.createdAt,_that.updatedAt,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String id,  String name,  String email,  String role,  String organizationId,  bool isActive,  String phone,  String address,  String gender,  DateTime dateOfBirth,  int age,  String panNumber,  String citizenshipNumber,  DateTime dateJoined,  DateTime createdAt,  DateTime updatedAt,  String? avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.role,_that.organizationId,_that.isActive,_that.phone,_that.address,_that.gender,_that.dateOfBirth,_that.age,_that.panNumber,_that.citizenshipNumber,_that.dateJoined,_that.createdAt,_that.updatedAt,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Profile extends Profile {
  const _Profile({@JsonKey(name: '_id') required this.id, required this.name, required this.email, required this.role, required this.organizationId, this.isActive = true, required this.phone, required this.address, required this.gender, required this.dateOfBirth, required this.age, required this.panNumber, required this.citizenshipNumber, required this.dateJoined, required this.createdAt, required this.updatedAt, this.avatarUrl}): super._();
  factory _Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

@override@JsonKey(name: '_id') final  String id;
@override final  String name;
@override final  String email;
@override final  String role;
@override final  String organizationId;
@override@JsonKey() final  bool isActive;
@override final  String phone;
@override final  String address;
@override final  String gender;
@override final  DateTime dateOfBirth;
@override final  int age;
@override final  String panNumber;
@override final  String citizenshipNumber;
@override final  DateTime dateJoined;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? avatarUrl;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileCopyWith<_Profile> get copyWith => __$ProfileCopyWithImpl<_Profile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.age, age) || other.age == age)&&(identical(other.panNumber, panNumber) || other.panNumber == panNumber)&&(identical(other.citizenshipNumber, citizenshipNumber) || other.citizenshipNumber == citizenshipNumber)&&(identical(other.dateJoined, dateJoined) || other.dateJoined == dateJoined)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,role,organizationId,isActive,phone,address,gender,dateOfBirth,age,panNumber,citizenshipNumber,dateJoined,createdAt,updatedAt,avatarUrl);

@override
String toString() {
  return 'Profile(id: $id, name: $name, email: $email, role: $role, organizationId: $organizationId, isActive: $isActive, phone: $phone, address: $address, gender: $gender, dateOfBirth: $dateOfBirth, age: $age, panNumber: $panNumber, citizenshipNumber: $citizenshipNumber, dateJoined: $dateJoined, createdAt: $createdAt, updatedAt: $updatedAt, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$ProfileCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$ProfileCopyWith(_Profile value, $Res Function(_Profile) _then) = __$ProfileCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String id, String name, String email, String role, String organizationId, bool isActive, String phone, String address, String gender, DateTime dateOfBirth, int age, String panNumber, String citizenshipNumber, DateTime dateJoined, DateTime createdAt, DateTime updatedAt, String? avatarUrl
});




}
/// @nodoc
class __$ProfileCopyWithImpl<$Res>
    implements _$ProfileCopyWith<$Res> {
  __$ProfileCopyWithImpl(this._self, this._then);

  final _Profile _self;
  final $Res Function(_Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,Object? role = null,Object? organizationId = null,Object? isActive = null,Object? phone = null,Object? address = null,Object? gender = null,Object? dateOfBirth = null,Object? age = null,Object? panNumber = null,Object? citizenshipNumber = null,Object? dateJoined = null,Object? createdAt = null,Object? updatedAt = null,Object? avatarUrl = freezed,}) {
  return _then(_Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: null == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,panNumber: null == panNumber ? _self.panNumber : panNumber // ignore: cast_nullable_to_non_nullable
as String,citizenshipNumber: null == citizenshipNumber ? _self.citizenshipNumber : citizenshipNumber // ignore: cast_nullable_to_non_nullable
as String,dateJoined: null == dateJoined ? _self.dateJoined : dateJoined // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ProfileApiResponse {

 bool get success; Profile get data;
/// Create a copy of ProfileApiResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileApiResponseCopyWith<ProfileApiResponse> get copyWith => _$ProfileApiResponseCopyWithImpl<ProfileApiResponse>(this as ProfileApiResponse, _$identity);

  /// Serializes this ProfileApiResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileApiResponse&&(identical(other.success, success) || other.success == success)&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,data);

@override
String toString() {
  return 'ProfileApiResponse(success: $success, data: $data)';
}


}

/// @nodoc
abstract mixin class $ProfileApiResponseCopyWith<$Res>  {
  factory $ProfileApiResponseCopyWith(ProfileApiResponse value, $Res Function(ProfileApiResponse) _then) = _$ProfileApiResponseCopyWithImpl;
@useResult
$Res call({
 bool success, Profile data
});


$ProfileCopyWith<$Res> get data;

}
/// @nodoc
class _$ProfileApiResponseCopyWithImpl<$Res>
    implements $ProfileApiResponseCopyWith<$Res> {
  _$ProfileApiResponseCopyWithImpl(this._self, this._then);

  final ProfileApiResponse _self;
  final $Res Function(ProfileApiResponse) _then;

/// Create a copy of ProfileApiResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = null,Object? data = null,}) {
  return _then(_self.copyWith(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Profile,
  ));
}
/// Create a copy of ProfileApiResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res> get data {
  
  return $ProfileCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProfileApiResponse].
extension ProfileApiResponsePatterns on ProfileApiResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileApiResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileApiResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileApiResponse value)  $default,){
final _that = this;
switch (_that) {
case _ProfileApiResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileApiResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileApiResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool success,  Profile data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileApiResponse() when $default != null:
return $default(_that.success,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool success,  Profile data)  $default,) {final _that = this;
switch (_that) {
case _ProfileApiResponse():
return $default(_that.success,_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool success,  Profile data)?  $default,) {final _that = this;
switch (_that) {
case _ProfileApiResponse() when $default != null:
return $default(_that.success,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileApiResponse extends ProfileApiResponse {
  const _ProfileApiResponse({required this.success, required this.data}): super._();
  factory _ProfileApiResponse.fromJson(Map<String, dynamic> json) => _$ProfileApiResponseFromJson(json);

@override final  bool success;
@override final  Profile data;

/// Create a copy of ProfileApiResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileApiResponseCopyWith<_ProfileApiResponse> get copyWith => __$ProfileApiResponseCopyWithImpl<_ProfileApiResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileApiResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileApiResponse&&(identical(other.success, success) || other.success == success)&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,data);

@override
String toString() {
  return 'ProfileApiResponse(success: $success, data: $data)';
}


}

/// @nodoc
abstract mixin class _$ProfileApiResponseCopyWith<$Res> implements $ProfileApiResponseCopyWith<$Res> {
  factory _$ProfileApiResponseCopyWith(_ProfileApiResponse value, $Res Function(_ProfileApiResponse) _then) = __$ProfileApiResponseCopyWithImpl;
@override @useResult
$Res call({
 bool success, Profile data
});


@override $ProfileCopyWith<$Res> get data;

}
/// @nodoc
class __$ProfileApiResponseCopyWithImpl<$Res>
    implements _$ProfileApiResponseCopyWith<$Res> {
  __$ProfileApiResponseCopyWithImpl(this._self, this._then);

  final _ProfileApiResponse _self;
  final $Res Function(_ProfileApiResponse) _then;

/// Create a copy of ProfileApiResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = null,Object? data = null,}) {
  return _then(_ProfileApiResponse(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Profile,
  ));
}

/// Create a copy of ProfileApiResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res> get data {
  
  return $ProfileCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// @nodoc
mixin _$UploadProfileImageData {

 String get avatarUrl;
/// Create a copy of UploadProfileImageData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadProfileImageDataCopyWith<UploadProfileImageData> get copyWith => _$UploadProfileImageDataCopyWithImpl<UploadProfileImageData>(this as UploadProfileImageData, _$identity);

  /// Serializes this UploadProfileImageData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadProfileImageData&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,avatarUrl);

@override
String toString() {
  return 'UploadProfileImageData(avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $UploadProfileImageDataCopyWith<$Res>  {
  factory $UploadProfileImageDataCopyWith(UploadProfileImageData value, $Res Function(UploadProfileImageData) _then) = _$UploadProfileImageDataCopyWithImpl;
@useResult
$Res call({
 String avatarUrl
});




}
/// @nodoc
class _$UploadProfileImageDataCopyWithImpl<$Res>
    implements $UploadProfileImageDataCopyWith<$Res> {
  _$UploadProfileImageDataCopyWithImpl(this._self, this._then);

  final UploadProfileImageData _self;
  final $Res Function(UploadProfileImageData) _then;

/// Create a copy of UploadProfileImageData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? avatarUrl = null,}) {
  return _then(_self.copyWith(
avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UploadProfileImageData].
extension UploadProfileImageDataPatterns on UploadProfileImageData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadProfileImageData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadProfileImageData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadProfileImageData value)  $default,){
final _that = this;
switch (_that) {
case _UploadProfileImageData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadProfileImageData value)?  $default,){
final _that = this;
switch (_that) {
case _UploadProfileImageData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadProfileImageData() when $default != null:
return $default(_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _UploadProfileImageData():
return $default(_that.avatarUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _UploadProfileImageData() when $default != null:
return $default(_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UploadProfileImageData extends UploadProfileImageData {
  const _UploadProfileImageData({required this.avatarUrl}): super._();
  factory _UploadProfileImageData.fromJson(Map<String, dynamic> json) => _$UploadProfileImageDataFromJson(json);

@override final  String avatarUrl;

/// Create a copy of UploadProfileImageData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadProfileImageDataCopyWith<_UploadProfileImageData> get copyWith => __$UploadProfileImageDataCopyWithImpl<_UploadProfileImageData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UploadProfileImageDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadProfileImageData&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,avatarUrl);

@override
String toString() {
  return 'UploadProfileImageData(avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$UploadProfileImageDataCopyWith<$Res> implements $UploadProfileImageDataCopyWith<$Res> {
  factory _$UploadProfileImageDataCopyWith(_UploadProfileImageData value, $Res Function(_UploadProfileImageData) _then) = __$UploadProfileImageDataCopyWithImpl;
@override @useResult
$Res call({
 String avatarUrl
});




}
/// @nodoc
class __$UploadProfileImageDataCopyWithImpl<$Res>
    implements _$UploadProfileImageDataCopyWith<$Res> {
  __$UploadProfileImageDataCopyWithImpl(this._self, this._then);

  final _UploadProfileImageData _self;
  final $Res Function(_UploadProfileImageData) _then;

/// Create a copy of UploadProfileImageData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? avatarUrl = null,}) {
  return _then(_UploadProfileImageData(
avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UploadProfileImageResponse {

 bool get success; String get message; UploadProfileImageData get data;
/// Create a copy of UploadProfileImageResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadProfileImageResponseCopyWith<UploadProfileImageResponse> get copyWith => _$UploadProfileImageResponseCopyWithImpl<UploadProfileImageResponse>(this as UploadProfileImageResponse, _$identity);

  /// Serializes this UploadProfileImageResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadProfileImageResponse&&(identical(other.success, success) || other.success == success)&&(identical(other.message, message) || other.message == message)&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,message,data);

@override
String toString() {
  return 'UploadProfileImageResponse(success: $success, message: $message, data: $data)';
}


}

/// @nodoc
abstract mixin class $UploadProfileImageResponseCopyWith<$Res>  {
  factory $UploadProfileImageResponseCopyWith(UploadProfileImageResponse value, $Res Function(UploadProfileImageResponse) _then) = _$UploadProfileImageResponseCopyWithImpl;
@useResult
$Res call({
 bool success, String message, UploadProfileImageData data
});


$UploadProfileImageDataCopyWith<$Res> get data;

}
/// @nodoc
class _$UploadProfileImageResponseCopyWithImpl<$Res>
    implements $UploadProfileImageResponseCopyWith<$Res> {
  _$UploadProfileImageResponseCopyWithImpl(this._self, this._then);

  final UploadProfileImageResponse _self;
  final $Res Function(UploadProfileImageResponse) _then;

/// Create a copy of UploadProfileImageResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = null,Object? message = null,Object? data = null,}) {
  return _then(_self.copyWith(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as UploadProfileImageData,
  ));
}
/// Create a copy of UploadProfileImageResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UploadProfileImageDataCopyWith<$Res> get data {
  
  return $UploadProfileImageDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [UploadProfileImageResponse].
extension UploadProfileImageResponsePatterns on UploadProfileImageResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadProfileImageResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadProfileImageResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadProfileImageResponse value)  $default,){
final _that = this;
switch (_that) {
case _UploadProfileImageResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadProfileImageResponse value)?  $default,){
final _that = this;
switch (_that) {
case _UploadProfileImageResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool success,  String message,  UploadProfileImageData data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadProfileImageResponse() when $default != null:
return $default(_that.success,_that.message,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool success,  String message,  UploadProfileImageData data)  $default,) {final _that = this;
switch (_that) {
case _UploadProfileImageResponse():
return $default(_that.success,_that.message,_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool success,  String message,  UploadProfileImageData data)?  $default,) {final _that = this;
switch (_that) {
case _UploadProfileImageResponse() when $default != null:
return $default(_that.success,_that.message,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UploadProfileImageResponse extends UploadProfileImageResponse {
  const _UploadProfileImageResponse({required this.success, required this.message, required this.data}): super._();
  factory _UploadProfileImageResponse.fromJson(Map<String, dynamic> json) => _$UploadProfileImageResponseFromJson(json);

@override final  bool success;
@override final  String message;
@override final  UploadProfileImageData data;

/// Create a copy of UploadProfileImageResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadProfileImageResponseCopyWith<_UploadProfileImageResponse> get copyWith => __$UploadProfileImageResponseCopyWithImpl<_UploadProfileImageResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UploadProfileImageResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadProfileImageResponse&&(identical(other.success, success) || other.success == success)&&(identical(other.message, message) || other.message == message)&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,message,data);

@override
String toString() {
  return 'UploadProfileImageResponse(success: $success, message: $message, data: $data)';
}


}

/// @nodoc
abstract mixin class _$UploadProfileImageResponseCopyWith<$Res> implements $UploadProfileImageResponseCopyWith<$Res> {
  factory _$UploadProfileImageResponseCopyWith(_UploadProfileImageResponse value, $Res Function(_UploadProfileImageResponse) _then) = __$UploadProfileImageResponseCopyWithImpl;
@override @useResult
$Res call({
 bool success, String message, UploadProfileImageData data
});


@override $UploadProfileImageDataCopyWith<$Res> get data;

}
/// @nodoc
class __$UploadProfileImageResponseCopyWithImpl<$Res>
    implements _$UploadProfileImageResponseCopyWith<$Res> {
  __$UploadProfileImageResponseCopyWithImpl(this._self, this._then);

  final _UploadProfileImageResponse _self;
  final $Res Function(_UploadProfileImageResponse) _then;

/// Create a copy of UploadProfileImageResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = null,Object? message = null,Object? data = null,}) {
  return _then(_UploadProfileImageResponse(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as UploadProfileImageData,
  ));
}

/// Create a copy of UploadProfileImageResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UploadProfileImageDataCopyWith<$Res> get data {
  
  return $UploadProfileImageDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

// dart format on
