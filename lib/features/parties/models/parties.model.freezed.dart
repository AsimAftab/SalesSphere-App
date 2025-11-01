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
mixin _$PartiesApiResponse {

 bool get success; int get count; List<PartyApiData> get data;
/// Create a copy of PartiesApiResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PartiesApiResponseCopyWith<PartiesApiResponse> get copyWith => _$PartiesApiResponseCopyWithImpl<PartiesApiResponse>(this as PartiesApiResponse, _$identity);

  /// Serializes this PartiesApiResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PartiesApiResponse&&(identical(other.success, success) || other.success == success)&&(identical(other.count, count) || other.count == count)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,count,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'PartiesApiResponse(success: $success, count: $count, data: $data)';
}


}

/// @nodoc
abstract mixin class $PartiesApiResponseCopyWith<$Res>  {
  factory $PartiesApiResponseCopyWith(PartiesApiResponse value, $Res Function(PartiesApiResponse) _then) = _$PartiesApiResponseCopyWithImpl;
@useResult
$Res call({
 bool success, int count, List<PartyApiData> data
});




}
/// @nodoc
class _$PartiesApiResponseCopyWithImpl<$Res>
    implements $PartiesApiResponseCopyWith<$Res> {
  _$PartiesApiResponseCopyWithImpl(this._self, this._then);

  final PartiesApiResponse _self;
  final $Res Function(PartiesApiResponse) _then;

/// Create a copy of PartiesApiResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = null,Object? count = null,Object? data = null,}) {
  return _then(_self.copyWith(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as List<PartyApiData>,
  ));
}

}


/// Adds pattern-matching-related methods to [PartiesApiResponse].
extension PartiesApiResponsePatterns on PartiesApiResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PartiesApiResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PartiesApiResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PartiesApiResponse value)  $default,){
final _that = this;
switch (_that) {
case _PartiesApiResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PartiesApiResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PartiesApiResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool success,  int count,  List<PartyApiData> data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PartiesApiResponse() when $default != null:
return $default(_that.success,_that.count,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool success,  int count,  List<PartyApiData> data)  $default,) {final _that = this;
switch (_that) {
case _PartiesApiResponse():
return $default(_that.success,_that.count,_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool success,  int count,  List<PartyApiData> data)?  $default,) {final _that = this;
switch (_that) {
case _PartiesApiResponse() when $default != null:
return $default(_that.success,_that.count,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PartiesApiResponse implements PartiesApiResponse {
  const _PartiesApiResponse({required this.success, required this.count, required final  List<PartyApiData> data}): _data = data;
  factory _PartiesApiResponse.fromJson(Map<String, dynamic> json) => _$PartiesApiResponseFromJson(json);

@override final  bool success;
@override final  int count;
 final  List<PartyApiData> _data;
@override List<PartyApiData> get data {
  if (_data is EqualUnmodifiableListView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_data);
}


/// Create a copy of PartiesApiResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PartiesApiResponseCopyWith<_PartiesApiResponse> get copyWith => __$PartiesApiResponseCopyWithImpl<_PartiesApiResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PartiesApiResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PartiesApiResponse&&(identical(other.success, success) || other.success == success)&&(identical(other.count, count) || other.count == count)&&const DeepCollectionEquality().equals(other._data, _data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,count,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'PartiesApiResponse(success: $success, count: $count, data: $data)';
}


}

/// @nodoc
abstract mixin class _$PartiesApiResponseCopyWith<$Res> implements $PartiesApiResponseCopyWith<$Res> {
  factory _$PartiesApiResponseCopyWith(_PartiesApiResponse value, $Res Function(_PartiesApiResponse) _then) = __$PartiesApiResponseCopyWithImpl;
@override @useResult
$Res call({
 bool success, int count, List<PartyApiData> data
});




}
/// @nodoc
class __$PartiesApiResponseCopyWithImpl<$Res>
    implements _$PartiesApiResponseCopyWith<$Res> {
  __$PartiesApiResponseCopyWithImpl(this._self, this._then);

  final _PartiesApiResponse _self;
  final $Res Function(_PartiesApiResponse) _then;

/// Create a copy of PartiesApiResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = null,Object? count = null,Object? data = null,}) {
  return _then(_PartiesApiResponse(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as List<PartyApiData>,
  ));
}


}


/// @nodoc
mixin _$PartyApiData {

@JsonKey(name: '_id') String get id; String get partyName; String get ownerName; PartyLocation get location;
/// Create a copy of PartyApiData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PartyApiDataCopyWith<PartyApiData> get copyWith => _$PartyApiDataCopyWithImpl<PartyApiData>(this as PartyApiData, _$identity);

  /// Serializes this PartyApiData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PartyApiData&&(identical(other.id, id) || other.id == id)&&(identical(other.partyName, partyName) || other.partyName == partyName)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.location, location) || other.location == location));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,partyName,ownerName,location);

@override
String toString() {
  return 'PartyApiData(id: $id, partyName: $partyName, ownerName: $ownerName, location: $location)';
}


}

/// @nodoc
abstract mixin class $PartyApiDataCopyWith<$Res>  {
  factory $PartyApiDataCopyWith(PartyApiData value, $Res Function(PartyApiData) _then) = _$PartyApiDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String id, String partyName, String ownerName, PartyLocation location
});


$PartyLocationCopyWith<$Res> get location;

}
/// @nodoc
class _$PartyApiDataCopyWithImpl<$Res>
    implements $PartyApiDataCopyWith<$Res> {
  _$PartyApiDataCopyWithImpl(this._self, this._then);

  final PartyApiData _self;
  final $Res Function(PartyApiData) _then;

/// Create a copy of PartyApiData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? partyName = null,Object? ownerName = null,Object? location = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,partyName: null == partyName ? _self.partyName : partyName // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as PartyLocation,
  ));
}
/// Create a copy of PartyApiData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PartyLocationCopyWith<$Res> get location {
  
  return $PartyLocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// Adds pattern-matching-related methods to [PartyApiData].
extension PartyApiDataPatterns on PartyApiData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PartyApiData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PartyApiData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PartyApiData value)  $default,){
final _that = this;
switch (_that) {
case _PartyApiData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PartyApiData value)?  $default,){
final _that = this;
switch (_that) {
case _PartyApiData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String partyName,  String ownerName,  PartyLocation location)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PartyApiData() when $default != null:
return $default(_that.id,_that.partyName,_that.ownerName,_that.location);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String partyName,  String ownerName,  PartyLocation location)  $default,) {final _that = this;
switch (_that) {
case _PartyApiData():
return $default(_that.id,_that.partyName,_that.ownerName,_that.location);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String id,  String partyName,  String ownerName,  PartyLocation location)?  $default,) {final _that = this;
switch (_that) {
case _PartyApiData() when $default != null:
return $default(_that.id,_that.partyName,_that.ownerName,_that.location);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PartyApiData implements PartyApiData {
  const _PartyApiData({@JsonKey(name: '_id') required this.id, required this.partyName, required this.ownerName, required this.location});
  factory _PartyApiData.fromJson(Map<String, dynamic> json) => _$PartyApiDataFromJson(json);

@override@JsonKey(name: '_id') final  String id;
@override final  String partyName;
@override final  String ownerName;
@override final  PartyLocation location;

/// Create a copy of PartyApiData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PartyApiDataCopyWith<_PartyApiData> get copyWith => __$PartyApiDataCopyWithImpl<_PartyApiData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PartyApiDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PartyApiData&&(identical(other.id, id) || other.id == id)&&(identical(other.partyName, partyName) || other.partyName == partyName)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.location, location) || other.location == location));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,partyName,ownerName,location);

@override
String toString() {
  return 'PartyApiData(id: $id, partyName: $partyName, ownerName: $ownerName, location: $location)';
}


}

/// @nodoc
abstract mixin class _$PartyApiDataCopyWith<$Res> implements $PartyApiDataCopyWith<$Res> {
  factory _$PartyApiDataCopyWith(_PartyApiData value, $Res Function(_PartyApiData) _then) = __$PartyApiDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String id, String partyName, String ownerName, PartyLocation location
});


@override $PartyLocationCopyWith<$Res> get location;

}
/// @nodoc
class __$PartyApiDataCopyWithImpl<$Res>
    implements _$PartyApiDataCopyWith<$Res> {
  __$PartyApiDataCopyWithImpl(this._self, this._then);

  final _PartyApiData _self;
  final $Res Function(_PartyApiData) _then;

/// Create a copy of PartyApiData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? partyName = null,Object? ownerName = null,Object? location = null,}) {
  return _then(_PartyApiData(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,partyName: null == partyName ? _self.partyName : partyName // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as PartyLocation,
  ));
}

/// Create a copy of PartyApiData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PartyLocationCopyWith<$Res> get location {
  
  return $PartyLocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// @nodoc
mixin _$PartyDetailApiResponse {

 bool get success; PartyDetailApiData get data;
/// Create a copy of PartyDetailApiResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PartyDetailApiResponseCopyWith<PartyDetailApiResponse> get copyWith => _$PartyDetailApiResponseCopyWithImpl<PartyDetailApiResponse>(this as PartyDetailApiResponse, _$identity);

  /// Serializes this PartyDetailApiResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PartyDetailApiResponse&&(identical(other.success, success) || other.success == success)&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,data);

@override
String toString() {
  return 'PartyDetailApiResponse(success: $success, data: $data)';
}


}

/// @nodoc
abstract mixin class $PartyDetailApiResponseCopyWith<$Res>  {
  factory $PartyDetailApiResponseCopyWith(PartyDetailApiResponse value, $Res Function(PartyDetailApiResponse) _then) = _$PartyDetailApiResponseCopyWithImpl;
@useResult
$Res call({
 bool success, PartyDetailApiData data
});


$PartyDetailApiDataCopyWith<$Res> get data;

}
/// @nodoc
class _$PartyDetailApiResponseCopyWithImpl<$Res>
    implements $PartyDetailApiResponseCopyWith<$Res> {
  _$PartyDetailApiResponseCopyWithImpl(this._self, this._then);

  final PartyDetailApiResponse _self;
  final $Res Function(PartyDetailApiResponse) _then;

/// Create a copy of PartyDetailApiResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = null,Object? data = null,}) {
  return _then(_self.copyWith(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as PartyDetailApiData,
  ));
}
/// Create a copy of PartyDetailApiResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PartyDetailApiDataCopyWith<$Res> get data {
  
  return $PartyDetailApiDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [PartyDetailApiResponse].
extension PartyDetailApiResponsePatterns on PartyDetailApiResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PartyDetailApiResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PartyDetailApiResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PartyDetailApiResponse value)  $default,){
final _that = this;
switch (_that) {
case _PartyDetailApiResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PartyDetailApiResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PartyDetailApiResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool success,  PartyDetailApiData data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PartyDetailApiResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool success,  PartyDetailApiData data)  $default,) {final _that = this;
switch (_that) {
case _PartyDetailApiResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool success,  PartyDetailApiData data)?  $default,) {final _that = this;
switch (_that) {
case _PartyDetailApiResponse() when $default != null:
return $default(_that.success,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PartyDetailApiResponse implements PartyDetailApiResponse {
  const _PartyDetailApiResponse({required this.success, required this.data});
  factory _PartyDetailApiResponse.fromJson(Map<String, dynamic> json) => _$PartyDetailApiResponseFromJson(json);

@override final  bool success;
@override final  PartyDetailApiData data;

/// Create a copy of PartyDetailApiResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PartyDetailApiResponseCopyWith<_PartyDetailApiResponse> get copyWith => __$PartyDetailApiResponseCopyWithImpl<_PartyDetailApiResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PartyDetailApiResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PartyDetailApiResponse&&(identical(other.success, success) || other.success == success)&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,data);

@override
String toString() {
  return 'PartyDetailApiResponse(success: $success, data: $data)';
}


}

/// @nodoc
abstract mixin class _$PartyDetailApiResponseCopyWith<$Res> implements $PartyDetailApiResponseCopyWith<$Res> {
  factory _$PartyDetailApiResponseCopyWith(_PartyDetailApiResponse value, $Res Function(_PartyDetailApiResponse) _then) = __$PartyDetailApiResponseCopyWithImpl;
@override @useResult
$Res call({
 bool success, PartyDetailApiData data
});


@override $PartyDetailApiDataCopyWith<$Res> get data;

}
/// @nodoc
class __$PartyDetailApiResponseCopyWithImpl<$Res>
    implements _$PartyDetailApiResponseCopyWith<$Res> {
  __$PartyDetailApiResponseCopyWithImpl(this._self, this._then);

  final _PartyDetailApiResponse _self;
  final $Res Function(_PartyDetailApiResponse) _then;

/// Create a copy of PartyDetailApiResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = null,Object? data = null,}) {
  return _then(_PartyDetailApiResponse(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as PartyDetailApiData,
  ));
}

/// Create a copy of PartyDetailApiResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PartyDetailApiDataCopyWith<$Res> get data {
  
  return $PartyDetailApiDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// @nodoc
mixin _$PartyDetailApiData {

@JsonKey(name: '_id') String get id; String get partyName; String get ownerName; String? get dateJoined; String get panVatNumber; PartyContact get contact; PartyLocationDetail get location; String? get description; String? get organizationId; String? get createdBy; String? get createdAt; String? get updatedAt;
/// Create a copy of PartyDetailApiData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PartyDetailApiDataCopyWith<PartyDetailApiData> get copyWith => _$PartyDetailApiDataCopyWithImpl<PartyDetailApiData>(this as PartyDetailApiData, _$identity);

  /// Serializes this PartyDetailApiData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PartyDetailApiData&&(identical(other.id, id) || other.id == id)&&(identical(other.partyName, partyName) || other.partyName == partyName)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.dateJoined, dateJoined) || other.dateJoined == dateJoined)&&(identical(other.panVatNumber, panVatNumber) || other.panVatNumber == panVatNumber)&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.location, location) || other.location == location)&&(identical(other.description, description) || other.description == description)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,partyName,ownerName,dateJoined,panVatNumber,contact,location,description,organizationId,createdBy,createdAt,updatedAt);

@override
String toString() {
  return 'PartyDetailApiData(id: $id, partyName: $partyName, ownerName: $ownerName, dateJoined: $dateJoined, panVatNumber: $panVatNumber, contact: $contact, location: $location, description: $description, organizationId: $organizationId, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PartyDetailApiDataCopyWith<$Res>  {
  factory $PartyDetailApiDataCopyWith(PartyDetailApiData value, $Res Function(PartyDetailApiData) _then) = _$PartyDetailApiDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String id, String partyName, String ownerName, String? dateJoined, String panVatNumber, PartyContact contact, PartyLocationDetail location, String? description, String? organizationId, String? createdBy, String? createdAt, String? updatedAt
});


$PartyContactCopyWith<$Res> get contact;$PartyLocationDetailCopyWith<$Res> get location;

}
/// @nodoc
class _$PartyDetailApiDataCopyWithImpl<$Res>
    implements $PartyDetailApiDataCopyWith<$Res> {
  _$PartyDetailApiDataCopyWithImpl(this._self, this._then);

  final PartyDetailApiData _self;
  final $Res Function(PartyDetailApiData) _then;

/// Create a copy of PartyDetailApiData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? partyName = null,Object? ownerName = null,Object? dateJoined = freezed,Object? panVatNumber = null,Object? contact = null,Object? location = null,Object? description = freezed,Object? organizationId = freezed,Object? createdBy = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,partyName: null == partyName ? _self.partyName : partyName // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,dateJoined: freezed == dateJoined ? _self.dateJoined : dateJoined // ignore: cast_nullable_to_non_nullable
as String?,panVatNumber: null == panVatNumber ? _self.panVatNumber : panVatNumber // ignore: cast_nullable_to_non_nullable
as String,contact: null == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as PartyContact,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as PartyLocationDetail,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,organizationId: freezed == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of PartyDetailApiData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PartyContactCopyWith<$Res> get contact {
  
  return $PartyContactCopyWith<$Res>(_self.contact, (value) {
    return _then(_self.copyWith(contact: value));
  });
}/// Create a copy of PartyDetailApiData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PartyLocationDetailCopyWith<$Res> get location {
  
  return $PartyLocationDetailCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// Adds pattern-matching-related methods to [PartyDetailApiData].
extension PartyDetailApiDataPatterns on PartyDetailApiData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PartyDetailApiData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PartyDetailApiData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PartyDetailApiData value)  $default,){
final _that = this;
switch (_that) {
case _PartyDetailApiData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PartyDetailApiData value)?  $default,){
final _that = this;
switch (_that) {
case _PartyDetailApiData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String partyName,  String ownerName,  String? dateJoined,  String panVatNumber,  PartyContact contact,  PartyLocationDetail location,  String? description,  String? organizationId,  String? createdBy,  String? createdAt,  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PartyDetailApiData() when $default != null:
return $default(_that.id,_that.partyName,_that.ownerName,_that.dateJoined,_that.panVatNumber,_that.contact,_that.location,_that.description,_that.organizationId,_that.createdBy,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String partyName,  String ownerName,  String? dateJoined,  String panVatNumber,  PartyContact contact,  PartyLocationDetail location,  String? description,  String? organizationId,  String? createdBy,  String? createdAt,  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PartyDetailApiData():
return $default(_that.id,_that.partyName,_that.ownerName,_that.dateJoined,_that.panVatNumber,_that.contact,_that.location,_that.description,_that.organizationId,_that.createdBy,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String id,  String partyName,  String ownerName,  String? dateJoined,  String panVatNumber,  PartyContact contact,  PartyLocationDetail location,  String? description,  String? organizationId,  String? createdBy,  String? createdAt,  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PartyDetailApiData() when $default != null:
return $default(_that.id,_that.partyName,_that.ownerName,_that.dateJoined,_that.panVatNumber,_that.contact,_that.location,_that.description,_that.organizationId,_that.createdBy,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PartyDetailApiData implements PartyDetailApiData {
  const _PartyDetailApiData({@JsonKey(name: '_id') required this.id, required this.partyName, required this.ownerName, this.dateJoined, required this.panVatNumber, required this.contact, required this.location, this.description, this.organizationId, this.createdBy, this.createdAt, this.updatedAt});
  factory _PartyDetailApiData.fromJson(Map<String, dynamic> json) => _$PartyDetailApiDataFromJson(json);

@override@JsonKey(name: '_id') final  String id;
@override final  String partyName;
@override final  String ownerName;
@override final  String? dateJoined;
@override final  String panVatNumber;
@override final  PartyContact contact;
@override final  PartyLocationDetail location;
@override final  String? description;
@override final  String? organizationId;
@override final  String? createdBy;
@override final  String? createdAt;
@override final  String? updatedAt;

/// Create a copy of PartyDetailApiData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PartyDetailApiDataCopyWith<_PartyDetailApiData> get copyWith => __$PartyDetailApiDataCopyWithImpl<_PartyDetailApiData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PartyDetailApiDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PartyDetailApiData&&(identical(other.id, id) || other.id == id)&&(identical(other.partyName, partyName) || other.partyName == partyName)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.dateJoined, dateJoined) || other.dateJoined == dateJoined)&&(identical(other.panVatNumber, panVatNumber) || other.panVatNumber == panVatNumber)&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.location, location) || other.location == location)&&(identical(other.description, description) || other.description == description)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,partyName,ownerName,dateJoined,panVatNumber,contact,location,description,organizationId,createdBy,createdAt,updatedAt);

@override
String toString() {
  return 'PartyDetailApiData(id: $id, partyName: $partyName, ownerName: $ownerName, dateJoined: $dateJoined, panVatNumber: $panVatNumber, contact: $contact, location: $location, description: $description, organizationId: $organizationId, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PartyDetailApiDataCopyWith<$Res> implements $PartyDetailApiDataCopyWith<$Res> {
  factory _$PartyDetailApiDataCopyWith(_PartyDetailApiData value, $Res Function(_PartyDetailApiData) _then) = __$PartyDetailApiDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String id, String partyName, String ownerName, String? dateJoined, String panVatNumber, PartyContact contact, PartyLocationDetail location, String? description, String? organizationId, String? createdBy, String? createdAt, String? updatedAt
});


@override $PartyContactCopyWith<$Res> get contact;@override $PartyLocationDetailCopyWith<$Res> get location;

}
/// @nodoc
class __$PartyDetailApiDataCopyWithImpl<$Res>
    implements _$PartyDetailApiDataCopyWith<$Res> {
  __$PartyDetailApiDataCopyWithImpl(this._self, this._then);

  final _PartyDetailApiData _self;
  final $Res Function(_PartyDetailApiData) _then;

/// Create a copy of PartyDetailApiData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? partyName = null,Object? ownerName = null,Object? dateJoined = freezed,Object? panVatNumber = null,Object? contact = null,Object? location = null,Object? description = freezed,Object? organizationId = freezed,Object? createdBy = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_PartyDetailApiData(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,partyName: null == partyName ? _self.partyName : partyName // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,dateJoined: freezed == dateJoined ? _self.dateJoined : dateJoined // ignore: cast_nullable_to_non_nullable
as String?,panVatNumber: null == panVatNumber ? _self.panVatNumber : panVatNumber // ignore: cast_nullable_to_non_nullable
as String,contact: null == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as PartyContact,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as PartyLocationDetail,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,organizationId: freezed == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of PartyDetailApiData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PartyContactCopyWith<$Res> get contact {
  
  return $PartyContactCopyWith<$Res>(_self.contact, (value) {
    return _then(_self.copyWith(contact: value));
  });
}/// Create a copy of PartyDetailApiData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PartyLocationDetailCopyWith<$Res> get location {
  
  return $PartyLocationDetailCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// @nodoc
mixin _$PartyContact {

 String get phone; String? get email;
/// Create a copy of PartyContact
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PartyContactCopyWith<PartyContact> get copyWith => _$PartyContactCopyWithImpl<PartyContact>(this as PartyContact, _$identity);

  /// Serializes this PartyContact to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PartyContact&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phone,email);

@override
String toString() {
  return 'PartyContact(phone: $phone, email: $email)';
}


}

/// @nodoc
abstract mixin class $PartyContactCopyWith<$Res>  {
  factory $PartyContactCopyWith(PartyContact value, $Res Function(PartyContact) _then) = _$PartyContactCopyWithImpl;
@useResult
$Res call({
 String phone, String? email
});




}
/// @nodoc
class _$PartyContactCopyWithImpl<$Res>
    implements $PartyContactCopyWith<$Res> {
  _$PartyContactCopyWithImpl(this._self, this._then);

  final PartyContact _self;
  final $Res Function(PartyContact) _then;

/// Create a copy of PartyContact
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phone = null,Object? email = freezed,}) {
  return _then(_self.copyWith(
phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PartyContact].
extension PartyContactPatterns on PartyContact {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PartyContact value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PartyContact() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PartyContact value)  $default,){
final _that = this;
switch (_that) {
case _PartyContact():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PartyContact value)?  $default,){
final _that = this;
switch (_that) {
case _PartyContact() when $default != null:
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
case _PartyContact() when $default != null:
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
case _PartyContact():
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
case _PartyContact() when $default != null:
return $default(_that.phone,_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PartyContact implements PartyContact {
  const _PartyContact({required this.phone, this.email});
  factory _PartyContact.fromJson(Map<String, dynamic> json) => _$PartyContactFromJson(json);

@override final  String phone;
@override final  String? email;

/// Create a copy of PartyContact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PartyContactCopyWith<_PartyContact> get copyWith => __$PartyContactCopyWithImpl<_PartyContact>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PartyContactToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PartyContact&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phone,email);

@override
String toString() {
  return 'PartyContact(phone: $phone, email: $email)';
}


}

/// @nodoc
abstract mixin class _$PartyContactCopyWith<$Res> implements $PartyContactCopyWith<$Res> {
  factory _$PartyContactCopyWith(_PartyContact value, $Res Function(_PartyContact) _then) = __$PartyContactCopyWithImpl;
@override @useResult
$Res call({
 String phone, String? email
});




}
/// @nodoc
class __$PartyContactCopyWithImpl<$Res>
    implements _$PartyContactCopyWith<$Res> {
  __$PartyContactCopyWithImpl(this._self, this._then);

  final _PartyContact _self;
  final $Res Function(_PartyContact) _then;

/// Create a copy of PartyContact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phone = null,Object? email = freezed,}) {
  return _then(_PartyContact(
phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PartyLocation {

 String get address;
/// Create a copy of PartyLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PartyLocationCopyWith<PartyLocation> get copyWith => _$PartyLocationCopyWithImpl<PartyLocation>(this as PartyLocation, _$identity);

  /// Serializes this PartyLocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PartyLocation&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address);

@override
String toString() {
  return 'PartyLocation(address: $address)';
}


}

/// @nodoc
abstract mixin class $PartyLocationCopyWith<$Res>  {
  factory $PartyLocationCopyWith(PartyLocation value, $Res Function(PartyLocation) _then) = _$PartyLocationCopyWithImpl;
@useResult
$Res call({
 String address
});




}
/// @nodoc
class _$PartyLocationCopyWithImpl<$Res>
    implements $PartyLocationCopyWith<$Res> {
  _$PartyLocationCopyWithImpl(this._self, this._then);

  final PartyLocation _self;
  final $Res Function(PartyLocation) _then;

/// Create a copy of PartyLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? address = null,}) {
  return _then(_self.copyWith(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PartyLocation].
extension PartyLocationPatterns on PartyLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PartyLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PartyLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PartyLocation value)  $default,){
final _that = this;
switch (_that) {
case _PartyLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PartyLocation value)?  $default,){
final _that = this;
switch (_that) {
case _PartyLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String address)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PartyLocation() when $default != null:
return $default(_that.address);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String address)  $default,) {final _that = this;
switch (_that) {
case _PartyLocation():
return $default(_that.address);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String address)?  $default,) {final _that = this;
switch (_that) {
case _PartyLocation() when $default != null:
return $default(_that.address);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PartyLocation implements PartyLocation {
  const _PartyLocation({required this.address});
  factory _PartyLocation.fromJson(Map<String, dynamic> json) => _$PartyLocationFromJson(json);

@override final  String address;

/// Create a copy of PartyLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PartyLocationCopyWith<_PartyLocation> get copyWith => __$PartyLocationCopyWithImpl<_PartyLocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PartyLocationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PartyLocation&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address);

@override
String toString() {
  return 'PartyLocation(address: $address)';
}


}

/// @nodoc
abstract mixin class _$PartyLocationCopyWith<$Res> implements $PartyLocationCopyWith<$Res> {
  factory _$PartyLocationCopyWith(_PartyLocation value, $Res Function(_PartyLocation) _then) = __$PartyLocationCopyWithImpl;
@override @useResult
$Res call({
 String address
});




}
/// @nodoc
class __$PartyLocationCopyWithImpl<$Res>
    implements _$PartyLocationCopyWith<$Res> {
  __$PartyLocationCopyWithImpl(this._self, this._then);

  final _PartyLocation _self;
  final $Res Function(_PartyLocation) _then;

/// Create a copy of PartyLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? address = null,}) {
  return _then(_PartyLocation(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PartyLocationDetail {

 String get address; double? get latitude; double? get longitude;
/// Create a copy of PartyLocationDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PartyLocationDetailCopyWith<PartyLocationDetail> get copyWith => _$PartyLocationDetailCopyWithImpl<PartyLocationDetail>(this as PartyLocationDetail, _$identity);

  /// Serializes this PartyLocationDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PartyLocationDetail&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,latitude,longitude);

@override
String toString() {
  return 'PartyLocationDetail(address: $address, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class $PartyLocationDetailCopyWith<$Res>  {
  factory $PartyLocationDetailCopyWith(PartyLocationDetail value, $Res Function(PartyLocationDetail) _then) = _$PartyLocationDetailCopyWithImpl;
@useResult
$Res call({
 String address, double? latitude, double? longitude
});




}
/// @nodoc
class _$PartyLocationDetailCopyWithImpl<$Res>
    implements $PartyLocationDetailCopyWith<$Res> {
  _$PartyLocationDetailCopyWithImpl(this._self, this._then);

  final PartyLocationDetail _self;
  final $Res Function(PartyLocationDetail) _then;

/// Create a copy of PartyLocationDetail
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


/// Adds pattern-matching-related methods to [PartyLocationDetail].
extension PartyLocationDetailPatterns on PartyLocationDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PartyLocationDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PartyLocationDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PartyLocationDetail value)  $default,){
final _that = this;
switch (_that) {
case _PartyLocationDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PartyLocationDetail value)?  $default,){
final _that = this;
switch (_that) {
case _PartyLocationDetail() when $default != null:
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
case _PartyLocationDetail() when $default != null:
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
case _PartyLocationDetail():
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
case _PartyLocationDetail() when $default != null:
return $default(_that.address,_that.latitude,_that.longitude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PartyLocationDetail implements PartyLocationDetail {
  const _PartyLocationDetail({required this.address, this.latitude, this.longitude});
  factory _PartyLocationDetail.fromJson(Map<String, dynamic> json) => _$PartyLocationDetailFromJson(json);

@override final  String address;
@override final  double? latitude;
@override final  double? longitude;

/// Create a copy of PartyLocationDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PartyLocationDetailCopyWith<_PartyLocationDetail> get copyWith => __$PartyLocationDetailCopyWithImpl<_PartyLocationDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PartyLocationDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PartyLocationDetail&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,latitude,longitude);

@override
String toString() {
  return 'PartyLocationDetail(address: $address, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class _$PartyLocationDetailCopyWith<$Res> implements $PartyLocationDetailCopyWith<$Res> {
  factory _$PartyLocationDetailCopyWith(_PartyLocationDetail value, $Res Function(_PartyLocationDetail) _then) = __$PartyLocationDetailCopyWithImpl;
@override @useResult
$Res call({
 String address, double? latitude, double? longitude
});




}
/// @nodoc
class __$PartyLocationDetailCopyWithImpl<$Res>
    implements _$PartyLocationDetailCopyWith<$Res> {
  __$PartyLocationDetailCopyWithImpl(this._self, this._then);

  final _PartyLocationDetail _self;
  final $Res Function(_PartyLocationDetail) _then;

/// Create a copy of PartyLocationDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? address = null,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(_PartyLocationDetail(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$UpdatePartyRequest {

 String get partyName; String get ownerName; String get panVatNumber; UpdatePartyContact get contact; UpdatePartyLocation get location; String? get description;
/// Create a copy of UpdatePartyRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdatePartyRequestCopyWith<UpdatePartyRequest> get copyWith => _$UpdatePartyRequestCopyWithImpl<UpdatePartyRequest>(this as UpdatePartyRequest, _$identity);

  /// Serializes this UpdatePartyRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdatePartyRequest&&(identical(other.partyName, partyName) || other.partyName == partyName)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.panVatNumber, panVatNumber) || other.panVatNumber == panVatNumber)&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.location, location) || other.location == location)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,partyName,ownerName,panVatNumber,contact,location,description);

@override
String toString() {
  return 'UpdatePartyRequest(partyName: $partyName, ownerName: $ownerName, panVatNumber: $panVatNumber, contact: $contact, location: $location, description: $description)';
}


}

/// @nodoc
abstract mixin class $UpdatePartyRequestCopyWith<$Res>  {
  factory $UpdatePartyRequestCopyWith(UpdatePartyRequest value, $Res Function(UpdatePartyRequest) _then) = _$UpdatePartyRequestCopyWithImpl;
@useResult
$Res call({
 String partyName, String ownerName, String panVatNumber, UpdatePartyContact contact, UpdatePartyLocation location, String? description
});


$UpdatePartyContactCopyWith<$Res> get contact;$UpdatePartyLocationCopyWith<$Res> get location;

}
/// @nodoc
class _$UpdatePartyRequestCopyWithImpl<$Res>
    implements $UpdatePartyRequestCopyWith<$Res> {
  _$UpdatePartyRequestCopyWithImpl(this._self, this._then);

  final UpdatePartyRequest _self;
  final $Res Function(UpdatePartyRequest) _then;

/// Create a copy of UpdatePartyRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? partyName = null,Object? ownerName = null,Object? panVatNumber = null,Object? contact = null,Object? location = null,Object? description = freezed,}) {
  return _then(_self.copyWith(
partyName: null == partyName ? _self.partyName : partyName // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,panVatNumber: null == panVatNumber ? _self.panVatNumber : panVatNumber // ignore: cast_nullable_to_non_nullable
as String,contact: null == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as UpdatePartyContact,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as UpdatePartyLocation,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of UpdatePartyRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpdatePartyContactCopyWith<$Res> get contact {
  
  return $UpdatePartyContactCopyWith<$Res>(_self.contact, (value) {
    return _then(_self.copyWith(contact: value));
  });
}/// Create a copy of UpdatePartyRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpdatePartyLocationCopyWith<$Res> get location {
  
  return $UpdatePartyLocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// Adds pattern-matching-related methods to [UpdatePartyRequest].
extension UpdatePartyRequestPatterns on UpdatePartyRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdatePartyRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdatePartyRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdatePartyRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdatePartyRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdatePartyRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdatePartyRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String partyName,  String ownerName,  String panVatNumber,  UpdatePartyContact contact,  UpdatePartyLocation location,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdatePartyRequest() when $default != null:
return $default(_that.partyName,_that.ownerName,_that.panVatNumber,_that.contact,_that.location,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String partyName,  String ownerName,  String panVatNumber,  UpdatePartyContact contact,  UpdatePartyLocation location,  String? description)  $default,) {final _that = this;
switch (_that) {
case _UpdatePartyRequest():
return $default(_that.partyName,_that.ownerName,_that.panVatNumber,_that.contact,_that.location,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String partyName,  String ownerName,  String panVatNumber,  UpdatePartyContact contact,  UpdatePartyLocation location,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _UpdatePartyRequest() when $default != null:
return $default(_that.partyName,_that.ownerName,_that.panVatNumber,_that.contact,_that.location,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdatePartyRequest implements UpdatePartyRequest {
  const _UpdatePartyRequest({required this.partyName, required this.ownerName, required this.panVatNumber, required this.contact, required this.location, this.description});
  factory _UpdatePartyRequest.fromJson(Map<String, dynamic> json) => _$UpdatePartyRequestFromJson(json);

@override final  String partyName;
@override final  String ownerName;
@override final  String panVatNumber;
@override final  UpdatePartyContact contact;
@override final  UpdatePartyLocation location;
@override final  String? description;

/// Create a copy of UpdatePartyRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdatePartyRequestCopyWith<_UpdatePartyRequest> get copyWith => __$UpdatePartyRequestCopyWithImpl<_UpdatePartyRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdatePartyRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdatePartyRequest&&(identical(other.partyName, partyName) || other.partyName == partyName)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.panVatNumber, panVatNumber) || other.panVatNumber == panVatNumber)&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.location, location) || other.location == location)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,partyName,ownerName,panVatNumber,contact,location,description);

@override
String toString() {
  return 'UpdatePartyRequest(partyName: $partyName, ownerName: $ownerName, panVatNumber: $panVatNumber, contact: $contact, location: $location, description: $description)';
}


}

/// @nodoc
abstract mixin class _$UpdatePartyRequestCopyWith<$Res> implements $UpdatePartyRequestCopyWith<$Res> {
  factory _$UpdatePartyRequestCopyWith(_UpdatePartyRequest value, $Res Function(_UpdatePartyRequest) _then) = __$UpdatePartyRequestCopyWithImpl;
@override @useResult
$Res call({
 String partyName, String ownerName, String panVatNumber, UpdatePartyContact contact, UpdatePartyLocation location, String? description
});


@override $UpdatePartyContactCopyWith<$Res> get contact;@override $UpdatePartyLocationCopyWith<$Res> get location;

}
/// @nodoc
class __$UpdatePartyRequestCopyWithImpl<$Res>
    implements _$UpdatePartyRequestCopyWith<$Res> {
  __$UpdatePartyRequestCopyWithImpl(this._self, this._then);

  final _UpdatePartyRequest _self;
  final $Res Function(_UpdatePartyRequest) _then;

/// Create a copy of UpdatePartyRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? partyName = null,Object? ownerName = null,Object? panVatNumber = null,Object? contact = null,Object? location = null,Object? description = freezed,}) {
  return _then(_UpdatePartyRequest(
partyName: null == partyName ? _self.partyName : partyName // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,panVatNumber: null == panVatNumber ? _self.panVatNumber : panVatNumber // ignore: cast_nullable_to_non_nullable
as String,contact: null == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as UpdatePartyContact,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as UpdatePartyLocation,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of UpdatePartyRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpdatePartyContactCopyWith<$Res> get contact {
  
  return $UpdatePartyContactCopyWith<$Res>(_self.contact, (value) {
    return _then(_self.copyWith(contact: value));
  });
}/// Create a copy of UpdatePartyRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpdatePartyLocationCopyWith<$Res> get location {
  
  return $UpdatePartyLocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// @nodoc
mixin _$UpdatePartyContact {

 String get phone; String? get email;
/// Create a copy of UpdatePartyContact
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdatePartyContactCopyWith<UpdatePartyContact> get copyWith => _$UpdatePartyContactCopyWithImpl<UpdatePartyContact>(this as UpdatePartyContact, _$identity);

  /// Serializes this UpdatePartyContact to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdatePartyContact&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phone,email);

@override
String toString() {
  return 'UpdatePartyContact(phone: $phone, email: $email)';
}


}

/// @nodoc
abstract mixin class $UpdatePartyContactCopyWith<$Res>  {
  factory $UpdatePartyContactCopyWith(UpdatePartyContact value, $Res Function(UpdatePartyContact) _then) = _$UpdatePartyContactCopyWithImpl;
@useResult
$Res call({
 String phone, String? email
});




}
/// @nodoc
class _$UpdatePartyContactCopyWithImpl<$Res>
    implements $UpdatePartyContactCopyWith<$Res> {
  _$UpdatePartyContactCopyWithImpl(this._self, this._then);

  final UpdatePartyContact _self;
  final $Res Function(UpdatePartyContact) _then;

/// Create a copy of UpdatePartyContact
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phone = null,Object? email = freezed,}) {
  return _then(_self.copyWith(
phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdatePartyContact].
extension UpdatePartyContactPatterns on UpdatePartyContact {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdatePartyContact value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdatePartyContact() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdatePartyContact value)  $default,){
final _that = this;
switch (_that) {
case _UpdatePartyContact():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdatePartyContact value)?  $default,){
final _that = this;
switch (_that) {
case _UpdatePartyContact() when $default != null:
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
case _UpdatePartyContact() when $default != null:
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
case _UpdatePartyContact():
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
case _UpdatePartyContact() when $default != null:
return $default(_that.phone,_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdatePartyContact implements UpdatePartyContact {
  const _UpdatePartyContact({required this.phone, this.email});
  factory _UpdatePartyContact.fromJson(Map<String, dynamic> json) => _$UpdatePartyContactFromJson(json);

@override final  String phone;
@override final  String? email;

/// Create a copy of UpdatePartyContact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdatePartyContactCopyWith<_UpdatePartyContact> get copyWith => __$UpdatePartyContactCopyWithImpl<_UpdatePartyContact>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdatePartyContactToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdatePartyContact&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phone,email);

@override
String toString() {
  return 'UpdatePartyContact(phone: $phone, email: $email)';
}


}

/// @nodoc
abstract mixin class _$UpdatePartyContactCopyWith<$Res> implements $UpdatePartyContactCopyWith<$Res> {
  factory _$UpdatePartyContactCopyWith(_UpdatePartyContact value, $Res Function(_UpdatePartyContact) _then) = __$UpdatePartyContactCopyWithImpl;
@override @useResult
$Res call({
 String phone, String? email
});




}
/// @nodoc
class __$UpdatePartyContactCopyWithImpl<$Res>
    implements _$UpdatePartyContactCopyWith<$Res> {
  __$UpdatePartyContactCopyWithImpl(this._self, this._then);

  final _UpdatePartyContact _self;
  final $Res Function(_UpdatePartyContact) _then;

/// Create a copy of UpdatePartyContact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phone = null,Object? email = freezed,}) {
  return _then(_UpdatePartyContact(
phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UpdatePartyLocation {

 String get address; double? get latitude; double? get longitude;
/// Create a copy of UpdatePartyLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdatePartyLocationCopyWith<UpdatePartyLocation> get copyWith => _$UpdatePartyLocationCopyWithImpl<UpdatePartyLocation>(this as UpdatePartyLocation, _$identity);

  /// Serializes this UpdatePartyLocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdatePartyLocation&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,latitude,longitude);

@override
String toString() {
  return 'UpdatePartyLocation(address: $address, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class $UpdatePartyLocationCopyWith<$Res>  {
  factory $UpdatePartyLocationCopyWith(UpdatePartyLocation value, $Res Function(UpdatePartyLocation) _then) = _$UpdatePartyLocationCopyWithImpl;
@useResult
$Res call({
 String address, double? latitude, double? longitude
});




}
/// @nodoc
class _$UpdatePartyLocationCopyWithImpl<$Res>
    implements $UpdatePartyLocationCopyWith<$Res> {
  _$UpdatePartyLocationCopyWithImpl(this._self, this._then);

  final UpdatePartyLocation _self;
  final $Res Function(UpdatePartyLocation) _then;

/// Create a copy of UpdatePartyLocation
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


/// Adds pattern-matching-related methods to [UpdatePartyLocation].
extension UpdatePartyLocationPatterns on UpdatePartyLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdatePartyLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdatePartyLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdatePartyLocation value)  $default,){
final _that = this;
switch (_that) {
case _UpdatePartyLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdatePartyLocation value)?  $default,){
final _that = this;
switch (_that) {
case _UpdatePartyLocation() when $default != null:
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
case _UpdatePartyLocation() when $default != null:
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
case _UpdatePartyLocation():
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
case _UpdatePartyLocation() when $default != null:
return $default(_that.address,_that.latitude,_that.longitude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdatePartyLocation implements UpdatePartyLocation {
  const _UpdatePartyLocation({required this.address, this.latitude, this.longitude});
  factory _UpdatePartyLocation.fromJson(Map<String, dynamic> json) => _$UpdatePartyLocationFromJson(json);

@override final  String address;
@override final  double? latitude;
@override final  double? longitude;

/// Create a copy of UpdatePartyLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdatePartyLocationCopyWith<_UpdatePartyLocation> get copyWith => __$UpdatePartyLocationCopyWithImpl<_UpdatePartyLocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdatePartyLocationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdatePartyLocation&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,latitude,longitude);

@override
String toString() {
  return 'UpdatePartyLocation(address: $address, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class _$UpdatePartyLocationCopyWith<$Res> implements $UpdatePartyLocationCopyWith<$Res> {
  factory _$UpdatePartyLocationCopyWith(_UpdatePartyLocation value, $Res Function(_UpdatePartyLocation) _then) = __$UpdatePartyLocationCopyWithImpl;
@override @useResult
$Res call({
 String address, double? latitude, double? longitude
});




}
/// @nodoc
class __$UpdatePartyLocationCopyWithImpl<$Res>
    implements _$UpdatePartyLocationCopyWith<$Res> {
  __$UpdatePartyLocationCopyWithImpl(this._self, this._then);

  final _UpdatePartyLocation _self;
  final $Res Function(_UpdatePartyLocation) _then;

/// Create a copy of UpdatePartyLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? address = null,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(_UpdatePartyLocation(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$CreatePartyRequest {

 String get partyName; String get ownerName; String get dateJoined; String get panVatNumber; CreatePartyContact get contact; CreatePartyLocation get location; String? get description;
/// Create a copy of CreatePartyRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatePartyRequestCopyWith<CreatePartyRequest> get copyWith => _$CreatePartyRequestCopyWithImpl<CreatePartyRequest>(this as CreatePartyRequest, _$identity);

  /// Serializes this CreatePartyRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatePartyRequest&&(identical(other.partyName, partyName) || other.partyName == partyName)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.dateJoined, dateJoined) || other.dateJoined == dateJoined)&&(identical(other.panVatNumber, panVatNumber) || other.panVatNumber == panVatNumber)&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.location, location) || other.location == location)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,partyName,ownerName,dateJoined,panVatNumber,contact,location,description);

@override
String toString() {
  return 'CreatePartyRequest(partyName: $partyName, ownerName: $ownerName, dateJoined: $dateJoined, panVatNumber: $panVatNumber, contact: $contact, location: $location, description: $description)';
}


}

/// @nodoc
abstract mixin class $CreatePartyRequestCopyWith<$Res>  {
  factory $CreatePartyRequestCopyWith(CreatePartyRequest value, $Res Function(CreatePartyRequest) _then) = _$CreatePartyRequestCopyWithImpl;
@useResult
$Res call({
 String partyName, String ownerName, String dateJoined, String panVatNumber, CreatePartyContact contact, CreatePartyLocation location, String? description
});


$CreatePartyContactCopyWith<$Res> get contact;$CreatePartyLocationCopyWith<$Res> get location;

}
/// @nodoc
class _$CreatePartyRequestCopyWithImpl<$Res>
    implements $CreatePartyRequestCopyWith<$Res> {
  _$CreatePartyRequestCopyWithImpl(this._self, this._then);

  final CreatePartyRequest _self;
  final $Res Function(CreatePartyRequest) _then;

/// Create a copy of CreatePartyRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? partyName = null,Object? ownerName = null,Object? dateJoined = null,Object? panVatNumber = null,Object? contact = null,Object? location = null,Object? description = freezed,}) {
  return _then(_self.copyWith(
partyName: null == partyName ? _self.partyName : partyName // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,dateJoined: null == dateJoined ? _self.dateJoined : dateJoined // ignore: cast_nullable_to_non_nullable
as String,panVatNumber: null == panVatNumber ? _self.panVatNumber : panVatNumber // ignore: cast_nullable_to_non_nullable
as String,contact: null == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as CreatePartyContact,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as CreatePartyLocation,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CreatePartyRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreatePartyContactCopyWith<$Res> get contact {
  
  return $CreatePartyContactCopyWith<$Res>(_self.contact, (value) {
    return _then(_self.copyWith(contact: value));
  });
}/// Create a copy of CreatePartyRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreatePartyLocationCopyWith<$Res> get location {
  
  return $CreatePartyLocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// Adds pattern-matching-related methods to [CreatePartyRequest].
extension CreatePartyRequestPatterns on CreatePartyRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreatePartyRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreatePartyRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreatePartyRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreatePartyRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreatePartyRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreatePartyRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String partyName,  String ownerName,  String dateJoined,  String panVatNumber,  CreatePartyContact contact,  CreatePartyLocation location,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreatePartyRequest() when $default != null:
return $default(_that.partyName,_that.ownerName,_that.dateJoined,_that.panVatNumber,_that.contact,_that.location,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String partyName,  String ownerName,  String dateJoined,  String panVatNumber,  CreatePartyContact contact,  CreatePartyLocation location,  String? description)  $default,) {final _that = this;
switch (_that) {
case _CreatePartyRequest():
return $default(_that.partyName,_that.ownerName,_that.dateJoined,_that.panVatNumber,_that.contact,_that.location,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String partyName,  String ownerName,  String dateJoined,  String panVatNumber,  CreatePartyContact contact,  CreatePartyLocation location,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _CreatePartyRequest() when $default != null:
return $default(_that.partyName,_that.ownerName,_that.dateJoined,_that.panVatNumber,_that.contact,_that.location,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreatePartyRequest implements CreatePartyRequest {
  const _CreatePartyRequest({required this.partyName, required this.ownerName, required this.dateJoined, required this.panVatNumber, required this.contact, required this.location, this.description});
  factory _CreatePartyRequest.fromJson(Map<String, dynamic> json) => _$CreatePartyRequestFromJson(json);

@override final  String partyName;
@override final  String ownerName;
@override final  String dateJoined;
@override final  String panVatNumber;
@override final  CreatePartyContact contact;
@override final  CreatePartyLocation location;
@override final  String? description;

/// Create a copy of CreatePartyRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatePartyRequestCopyWith<_CreatePartyRequest> get copyWith => __$CreatePartyRequestCopyWithImpl<_CreatePartyRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreatePartyRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatePartyRequest&&(identical(other.partyName, partyName) || other.partyName == partyName)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.dateJoined, dateJoined) || other.dateJoined == dateJoined)&&(identical(other.panVatNumber, panVatNumber) || other.panVatNumber == panVatNumber)&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.location, location) || other.location == location)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,partyName,ownerName,dateJoined,panVatNumber,contact,location,description);

@override
String toString() {
  return 'CreatePartyRequest(partyName: $partyName, ownerName: $ownerName, dateJoined: $dateJoined, panVatNumber: $panVatNumber, contact: $contact, location: $location, description: $description)';
}


}

/// @nodoc
abstract mixin class _$CreatePartyRequestCopyWith<$Res> implements $CreatePartyRequestCopyWith<$Res> {
  factory _$CreatePartyRequestCopyWith(_CreatePartyRequest value, $Res Function(_CreatePartyRequest) _then) = __$CreatePartyRequestCopyWithImpl;
@override @useResult
$Res call({
 String partyName, String ownerName, String dateJoined, String panVatNumber, CreatePartyContact contact, CreatePartyLocation location, String? description
});


@override $CreatePartyContactCopyWith<$Res> get contact;@override $CreatePartyLocationCopyWith<$Res> get location;

}
/// @nodoc
class __$CreatePartyRequestCopyWithImpl<$Res>
    implements _$CreatePartyRequestCopyWith<$Res> {
  __$CreatePartyRequestCopyWithImpl(this._self, this._then);

  final _CreatePartyRequest _self;
  final $Res Function(_CreatePartyRequest) _then;

/// Create a copy of CreatePartyRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? partyName = null,Object? ownerName = null,Object? dateJoined = null,Object? panVatNumber = null,Object? contact = null,Object? location = null,Object? description = freezed,}) {
  return _then(_CreatePartyRequest(
partyName: null == partyName ? _self.partyName : partyName // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,dateJoined: null == dateJoined ? _self.dateJoined : dateJoined // ignore: cast_nullable_to_non_nullable
as String,panVatNumber: null == panVatNumber ? _self.panVatNumber : panVatNumber // ignore: cast_nullable_to_non_nullable
as String,contact: null == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as CreatePartyContact,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as CreatePartyLocation,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CreatePartyRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreatePartyContactCopyWith<$Res> get contact {
  
  return $CreatePartyContactCopyWith<$Res>(_self.contact, (value) {
    return _then(_self.copyWith(contact: value));
  });
}/// Create a copy of CreatePartyRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreatePartyLocationCopyWith<$Res> get location {
  
  return $CreatePartyLocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// @nodoc
mixin _$CreatePartyContact {

 String get phone; String? get email;
/// Create a copy of CreatePartyContact
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatePartyContactCopyWith<CreatePartyContact> get copyWith => _$CreatePartyContactCopyWithImpl<CreatePartyContact>(this as CreatePartyContact, _$identity);

  /// Serializes this CreatePartyContact to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatePartyContact&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phone,email);

@override
String toString() {
  return 'CreatePartyContact(phone: $phone, email: $email)';
}


}

/// @nodoc
abstract mixin class $CreatePartyContactCopyWith<$Res>  {
  factory $CreatePartyContactCopyWith(CreatePartyContact value, $Res Function(CreatePartyContact) _then) = _$CreatePartyContactCopyWithImpl;
@useResult
$Res call({
 String phone, String? email
});




}
/// @nodoc
class _$CreatePartyContactCopyWithImpl<$Res>
    implements $CreatePartyContactCopyWith<$Res> {
  _$CreatePartyContactCopyWithImpl(this._self, this._then);

  final CreatePartyContact _self;
  final $Res Function(CreatePartyContact) _then;

/// Create a copy of CreatePartyContact
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phone = null,Object? email = freezed,}) {
  return _then(_self.copyWith(
phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreatePartyContact].
extension CreatePartyContactPatterns on CreatePartyContact {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreatePartyContact value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreatePartyContact() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreatePartyContact value)  $default,){
final _that = this;
switch (_that) {
case _CreatePartyContact():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreatePartyContact value)?  $default,){
final _that = this;
switch (_that) {
case _CreatePartyContact() when $default != null:
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
case _CreatePartyContact() when $default != null:
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
case _CreatePartyContact():
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
case _CreatePartyContact() when $default != null:
return $default(_that.phone,_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreatePartyContact implements CreatePartyContact {
  const _CreatePartyContact({required this.phone, this.email});
  factory _CreatePartyContact.fromJson(Map<String, dynamic> json) => _$CreatePartyContactFromJson(json);

@override final  String phone;
@override final  String? email;

/// Create a copy of CreatePartyContact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatePartyContactCopyWith<_CreatePartyContact> get copyWith => __$CreatePartyContactCopyWithImpl<_CreatePartyContact>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreatePartyContactToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatePartyContact&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phone,email);

@override
String toString() {
  return 'CreatePartyContact(phone: $phone, email: $email)';
}


}

/// @nodoc
abstract mixin class _$CreatePartyContactCopyWith<$Res> implements $CreatePartyContactCopyWith<$Res> {
  factory _$CreatePartyContactCopyWith(_CreatePartyContact value, $Res Function(_CreatePartyContact) _then) = __$CreatePartyContactCopyWithImpl;
@override @useResult
$Res call({
 String phone, String? email
});




}
/// @nodoc
class __$CreatePartyContactCopyWithImpl<$Res>
    implements _$CreatePartyContactCopyWith<$Res> {
  __$CreatePartyContactCopyWithImpl(this._self, this._then);

  final _CreatePartyContact _self;
  final $Res Function(_CreatePartyContact) _then;

/// Create a copy of CreatePartyContact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phone = null,Object? email = freezed,}) {
  return _then(_CreatePartyContact(
phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CreatePartyLocation {

 String get address; double get latitude; double get longitude;
/// Create a copy of CreatePartyLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatePartyLocationCopyWith<CreatePartyLocation> get copyWith => _$CreatePartyLocationCopyWithImpl<CreatePartyLocation>(this as CreatePartyLocation, _$identity);

  /// Serializes this CreatePartyLocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatePartyLocation&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,latitude,longitude);

@override
String toString() {
  return 'CreatePartyLocation(address: $address, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class $CreatePartyLocationCopyWith<$Res>  {
  factory $CreatePartyLocationCopyWith(CreatePartyLocation value, $Res Function(CreatePartyLocation) _then) = _$CreatePartyLocationCopyWithImpl;
@useResult
$Res call({
 String address, double latitude, double longitude
});




}
/// @nodoc
class _$CreatePartyLocationCopyWithImpl<$Res>
    implements $CreatePartyLocationCopyWith<$Res> {
  _$CreatePartyLocationCopyWithImpl(this._self, this._then);

  final CreatePartyLocation _self;
  final $Res Function(CreatePartyLocation) _then;

/// Create a copy of CreatePartyLocation
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


/// Adds pattern-matching-related methods to [CreatePartyLocation].
extension CreatePartyLocationPatterns on CreatePartyLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreatePartyLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreatePartyLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreatePartyLocation value)  $default,){
final _that = this;
switch (_that) {
case _CreatePartyLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreatePartyLocation value)?  $default,){
final _that = this;
switch (_that) {
case _CreatePartyLocation() when $default != null:
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
case _CreatePartyLocation() when $default != null:
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
case _CreatePartyLocation():
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
case _CreatePartyLocation() when $default != null:
return $default(_that.address,_that.latitude,_that.longitude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreatePartyLocation implements CreatePartyLocation {
  const _CreatePartyLocation({required this.address, required this.latitude, required this.longitude});
  factory _CreatePartyLocation.fromJson(Map<String, dynamic> json) => _$CreatePartyLocationFromJson(json);

@override final  String address;
@override final  double latitude;
@override final  double longitude;

/// Create a copy of CreatePartyLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatePartyLocationCopyWith<_CreatePartyLocation> get copyWith => __$CreatePartyLocationCopyWithImpl<_CreatePartyLocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreatePartyLocationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatePartyLocation&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,latitude,longitude);

@override
String toString() {
  return 'CreatePartyLocation(address: $address, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class _$CreatePartyLocationCopyWith<$Res> implements $CreatePartyLocationCopyWith<$Res> {
  factory _$CreatePartyLocationCopyWith(_CreatePartyLocation value, $Res Function(_CreatePartyLocation) _then) = __$CreatePartyLocationCopyWithImpl;
@override @useResult
$Res call({
 String address, double latitude, double longitude
});




}
/// @nodoc
class __$CreatePartyLocationCopyWithImpl<$Res>
    implements _$CreatePartyLocationCopyWith<$Res> {
  __$CreatePartyLocationCopyWithImpl(this._self, this._then);

  final _CreatePartyLocation _self;
  final $Res Function(_CreatePartyLocation) _then;

/// Create a copy of CreatePartyLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? address = null,Object? latitude = null,Object? longitude = null,}) {
  return _then(_CreatePartyLocation(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$CreatePartyApiResponse {

 bool get success; PartyDetailApiData get data;
/// Create a copy of CreatePartyApiResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatePartyApiResponseCopyWith<CreatePartyApiResponse> get copyWith => _$CreatePartyApiResponseCopyWithImpl<CreatePartyApiResponse>(this as CreatePartyApiResponse, _$identity);

  /// Serializes this CreatePartyApiResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatePartyApiResponse&&(identical(other.success, success) || other.success == success)&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,data);

@override
String toString() {
  return 'CreatePartyApiResponse(success: $success, data: $data)';
}


}

/// @nodoc
abstract mixin class $CreatePartyApiResponseCopyWith<$Res>  {
  factory $CreatePartyApiResponseCopyWith(CreatePartyApiResponse value, $Res Function(CreatePartyApiResponse) _then) = _$CreatePartyApiResponseCopyWithImpl;
@useResult
$Res call({
 bool success, PartyDetailApiData data
});


$PartyDetailApiDataCopyWith<$Res> get data;

}
/// @nodoc
class _$CreatePartyApiResponseCopyWithImpl<$Res>
    implements $CreatePartyApiResponseCopyWith<$Res> {
  _$CreatePartyApiResponseCopyWithImpl(this._self, this._then);

  final CreatePartyApiResponse _self;
  final $Res Function(CreatePartyApiResponse) _then;

/// Create a copy of CreatePartyApiResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = null,Object? data = null,}) {
  return _then(_self.copyWith(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as PartyDetailApiData,
  ));
}
/// Create a copy of CreatePartyApiResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PartyDetailApiDataCopyWith<$Res> get data {
  
  return $PartyDetailApiDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [CreatePartyApiResponse].
extension CreatePartyApiResponsePatterns on CreatePartyApiResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreatePartyApiResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreatePartyApiResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreatePartyApiResponse value)  $default,){
final _that = this;
switch (_that) {
case _CreatePartyApiResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreatePartyApiResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CreatePartyApiResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool success,  PartyDetailApiData data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreatePartyApiResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool success,  PartyDetailApiData data)  $default,) {final _that = this;
switch (_that) {
case _CreatePartyApiResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool success,  PartyDetailApiData data)?  $default,) {final _that = this;
switch (_that) {
case _CreatePartyApiResponse() when $default != null:
return $default(_that.success,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreatePartyApiResponse implements CreatePartyApiResponse {
  const _CreatePartyApiResponse({required this.success, required this.data});
  factory _CreatePartyApiResponse.fromJson(Map<String, dynamic> json) => _$CreatePartyApiResponseFromJson(json);

@override final  bool success;
@override final  PartyDetailApiData data;

/// Create a copy of CreatePartyApiResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatePartyApiResponseCopyWith<_CreatePartyApiResponse> get copyWith => __$CreatePartyApiResponseCopyWithImpl<_CreatePartyApiResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreatePartyApiResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatePartyApiResponse&&(identical(other.success, success) || other.success == success)&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,data);

@override
String toString() {
  return 'CreatePartyApiResponse(success: $success, data: $data)';
}


}

/// @nodoc
abstract mixin class _$CreatePartyApiResponseCopyWith<$Res> implements $CreatePartyApiResponseCopyWith<$Res> {
  factory _$CreatePartyApiResponseCopyWith(_CreatePartyApiResponse value, $Res Function(_CreatePartyApiResponse) _then) = __$CreatePartyApiResponseCopyWithImpl;
@override @useResult
$Res call({
 bool success, PartyDetailApiData data
});


@override $PartyDetailApiDataCopyWith<$Res> get data;

}
/// @nodoc
class __$CreatePartyApiResponseCopyWithImpl<$Res>
    implements _$CreatePartyApiResponseCopyWith<$Res> {
  __$CreatePartyApiResponseCopyWithImpl(this._self, this._then);

  final _CreatePartyApiResponse _self;
  final $Res Function(_CreatePartyApiResponse) _then;

/// Create a copy of CreatePartyApiResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = null,Object? data = null,}) {
  return _then(_CreatePartyApiResponse(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as PartyDetailApiData,
  ));
}

/// Create a copy of CreatePartyApiResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PartyDetailApiDataCopyWith<$Res> get data {
  
  return $PartyDetailApiDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// @nodoc
mixin _$PartyListItem {

 String get id; String get name; String get ownerName;@JsonKey(name: 'full_address') String get fullAddress;@JsonKey(name: 'phone_number') String? get phoneNumber;@JsonKey(name: 'is_active') bool get isActive;
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
 String id, String name, String ownerName,@JsonKey(name: 'full_address') String fullAddress,@JsonKey(name: 'phone_number') String? phoneNumber,@JsonKey(name: 'is_active') bool isActive
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? ownerName = null,Object? fullAddress = null,Object? phoneNumber = freezed,Object? isActive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,fullAddress: null == fullAddress ? _self.fullAddress : fullAddress // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String ownerName, @JsonKey(name: 'full_address')  String fullAddress, @JsonKey(name: 'phone_number')  String? phoneNumber, @JsonKey(name: 'is_active')  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String ownerName, @JsonKey(name: 'full_address')  String fullAddress, @JsonKey(name: 'phone_number')  String? phoneNumber, @JsonKey(name: 'is_active')  bool isActive)  $default,) {final _that = this;
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String ownerName, @JsonKey(name: 'full_address')  String fullAddress, @JsonKey(name: 'phone_number')  String? phoneNumber, @JsonKey(name: 'is_active')  bool isActive)?  $default,) {final _that = this;
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
  const _PartyListItem({required this.id, required this.name, required this.ownerName, @JsonKey(name: 'full_address') required this.fullAddress, @JsonKey(name: 'phone_number') this.phoneNumber, @JsonKey(name: 'is_active') this.isActive = true});
  factory _PartyListItem.fromJson(Map<String, dynamic> json) => _$PartyListItemFromJson(json);

@override final  String id;
@override final  String name;
@override final  String ownerName;
@override@JsonKey(name: 'full_address') final  String fullAddress;
@override@JsonKey(name: 'phone_number') final  String? phoneNumber;
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
 String id, String name, String ownerName,@JsonKey(name: 'full_address') String fullAddress,@JsonKey(name: 'phone_number') String? phoneNumber,@JsonKey(name: 'is_active') bool isActive
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? ownerName = null,Object? fullAddress = null,Object? phoneNumber = freezed,Object? isActive = null,}) {
  return _then(_PartyListItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,fullAddress: null == fullAddress ? _self.fullAddress : fullAddress // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PartyDetails {

 String get id; String get name; String get ownerName; String get panVatNumber; String get phoneNumber; String? get email; String get fullAddress; double? get latitude; double? get longitude; String? get notes; bool get isActive; String? get dateJoined; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of PartyDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PartyDetailsCopyWith<PartyDetails> get copyWith => _$PartyDetailsCopyWithImpl<PartyDetails>(this as PartyDetails, _$identity);

  /// Serializes this PartyDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PartyDetails&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.panVatNumber, panVatNumber) || other.panVatNumber == panVatNumber)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.email, email) || other.email == email)&&(identical(other.fullAddress, fullAddress) || other.fullAddress == fullAddress)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.dateJoined, dateJoined) || other.dateJoined == dateJoined)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,ownerName,panVatNumber,phoneNumber,email,fullAddress,latitude,longitude,notes,isActive,dateJoined,createdAt,updatedAt);

@override
String toString() {
  return 'PartyDetails(id: $id, name: $name, ownerName: $ownerName, panVatNumber: $panVatNumber, phoneNumber: $phoneNumber, email: $email, fullAddress: $fullAddress, latitude: $latitude, longitude: $longitude, notes: $notes, isActive: $isActive, dateJoined: $dateJoined, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PartyDetailsCopyWith<$Res>  {
  factory $PartyDetailsCopyWith(PartyDetails value, $Res Function(PartyDetails) _then) = _$PartyDetailsCopyWithImpl;
@useResult
$Res call({
 String id, String name, String ownerName, String panVatNumber, String phoneNumber, String? email, String fullAddress, double? latitude, double? longitude, String? notes, bool isActive, String? dateJoined, DateTime? createdAt, DateTime? updatedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? ownerName = null,Object? panVatNumber = null,Object? phoneNumber = null,Object? email = freezed,Object? fullAddress = null,Object? latitude = freezed,Object? longitude = freezed,Object? notes = freezed,Object? isActive = null,Object? dateJoined = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
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
as bool,dateJoined: freezed == dateJoined ? _self.dateJoined : dateJoined // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String ownerName,  String panVatNumber,  String phoneNumber,  String? email,  String fullAddress,  double? latitude,  double? longitude,  String? notes,  bool isActive,  String? dateJoined,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PartyDetails() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String ownerName,  String panVatNumber,  String phoneNumber,  String? email,  String fullAddress,  double? latitude,  double? longitude,  String? notes,  bool isActive,  String? dateJoined,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PartyDetails():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String ownerName,  String panVatNumber,  String phoneNumber,  String? email,  String fullAddress,  double? latitude,  double? longitude,  String? notes,  bool isActive,  String? dateJoined,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PartyDetails() when $default != null:
return $default(_that.id,_that.name,_that.ownerName,_that.panVatNumber,_that.phoneNumber,_that.email,_that.fullAddress,_that.latitude,_that.longitude,_that.notes,_that.isActive,_that.dateJoined,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PartyDetails extends PartyDetails {
  const _PartyDetails({required this.id, required this.name, required this.ownerName, required this.panVatNumber, required this.phoneNumber, this.email, required this.fullAddress, this.latitude, this.longitude, this.notes, this.isActive = true, this.dateJoined, this.createdAt, this.updatedAt}): super._();
  factory _PartyDetails.fromJson(Map<String, dynamic> json) => _$PartyDetailsFromJson(json);

@override final  String id;
@override final  String name;
@override final  String ownerName;
@override final  String panVatNumber;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PartyDetails&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.panVatNumber, panVatNumber) || other.panVatNumber == panVatNumber)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.email, email) || other.email == email)&&(identical(other.fullAddress, fullAddress) || other.fullAddress == fullAddress)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.dateJoined, dateJoined) || other.dateJoined == dateJoined)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,ownerName,panVatNumber,phoneNumber,email,fullAddress,latitude,longitude,notes,isActive,dateJoined,createdAt,updatedAt);

@override
String toString() {
  return 'PartyDetails(id: $id, name: $name, ownerName: $ownerName, panVatNumber: $panVatNumber, phoneNumber: $phoneNumber, email: $email, fullAddress: $fullAddress, latitude: $latitude, longitude: $longitude, notes: $notes, isActive: $isActive, dateJoined: $dateJoined, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PartyDetailsCopyWith<$Res> implements $PartyDetailsCopyWith<$Res> {
  factory _$PartyDetailsCopyWith(_PartyDetails value, $Res Function(_PartyDetails) _then) = __$PartyDetailsCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String ownerName, String panVatNumber, String phoneNumber, String? email, String fullAddress, double? latitude, double? longitude, String? notes, bool isActive, String? dateJoined, DateTime? createdAt, DateTime? updatedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? ownerName = null,Object? panVatNumber = null,Object? phoneNumber = null,Object? email = freezed,Object? fullAddress = null,Object? latitude = freezed,Object? longitude = freezed,Object? notes = freezed,Object? isActive = null,Object? dateJoined = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
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
as bool,dateJoined: freezed == dateJoined ? _self.dateJoined : dateJoined // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
