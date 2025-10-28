// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home.models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HomeModel {

 int get totalSales; double get revenue; int get totalCustomers; List<RecentSale> get recentSales;
/// Create a copy of HomeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeModelCopyWith<HomeModel> get copyWith => _$HomeModelCopyWithImpl<HomeModel>(this as HomeModel, _$identity);

  /// Serializes this HomeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeModel&&(identical(other.totalSales, totalSales) || other.totalSales == totalSales)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.totalCustomers, totalCustomers) || other.totalCustomers == totalCustomers)&&const DeepCollectionEquality().equals(other.recentSales, recentSales));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalSales,revenue,totalCustomers,const DeepCollectionEquality().hash(recentSales));

@override
String toString() {
  return 'HomeModel(totalSales: $totalSales, revenue: $revenue, totalCustomers: $totalCustomers, recentSales: $recentSales)';
}


}

/// @nodoc
abstract mixin class $HomeModelCopyWith<$Res>  {
  factory $HomeModelCopyWith(HomeModel value, $Res Function(HomeModel) _then) = _$HomeModelCopyWithImpl;
@useResult
$Res call({
 int totalSales, double revenue, int totalCustomers, List<RecentSale> recentSales
});




}
/// @nodoc
class _$HomeModelCopyWithImpl<$Res>
    implements $HomeModelCopyWith<$Res> {
  _$HomeModelCopyWithImpl(this._self, this._then);

  final HomeModel _self;
  final $Res Function(HomeModel) _then;

/// Create a copy of HomeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalSales = null,Object? revenue = null,Object? totalCustomers = null,Object? recentSales = null,}) {
  return _then(_self.copyWith(
totalSales: null == totalSales ? _self.totalSales : totalSales // ignore: cast_nullable_to_non_nullable
as int,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,totalCustomers: null == totalCustomers ? _self.totalCustomers : totalCustomers // ignore: cast_nullable_to_non_nullable
as int,recentSales: null == recentSales ? _self.recentSales : recentSales // ignore: cast_nullable_to_non_nullable
as List<RecentSale>,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeModel].
extension HomeModelPatterns on HomeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeModel value)  $default,){
final _that = this;
switch (_that) {
case _HomeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeModel value)?  $default,){
final _that = this;
switch (_that) {
case _HomeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalSales,  double revenue,  int totalCustomers,  List<RecentSale> recentSales)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeModel() when $default != null:
return $default(_that.totalSales,_that.revenue,_that.totalCustomers,_that.recentSales);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalSales,  double revenue,  int totalCustomers,  List<RecentSale> recentSales)  $default,) {final _that = this;
switch (_that) {
case _HomeModel():
return $default(_that.totalSales,_that.revenue,_that.totalCustomers,_that.recentSales);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalSales,  double revenue,  int totalCustomers,  List<RecentSale> recentSales)?  $default,) {final _that = this;
switch (_that) {
case _HomeModel() when $default != null:
return $default(_that.totalSales,_that.revenue,_that.totalCustomers,_that.recentSales);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeModel implements HomeModel {
  const _HomeModel({required this.totalSales, required this.revenue, required this.totalCustomers, required final  List<RecentSale> recentSales}): _recentSales = recentSales;
  factory _HomeModel.fromJson(Map<String, dynamic> json) => _$HomeModelFromJson(json);

@override final  int totalSales;
@override final  double revenue;
@override final  int totalCustomers;
 final  List<RecentSale> _recentSales;
@override List<RecentSale> get recentSales {
  if (_recentSales is EqualUnmodifiableListView) return _recentSales;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentSales);
}


/// Create a copy of HomeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeModelCopyWith<_HomeModel> get copyWith => __$HomeModelCopyWithImpl<_HomeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeModel&&(identical(other.totalSales, totalSales) || other.totalSales == totalSales)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.totalCustomers, totalCustomers) || other.totalCustomers == totalCustomers)&&const DeepCollectionEquality().equals(other._recentSales, _recentSales));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalSales,revenue,totalCustomers,const DeepCollectionEquality().hash(_recentSales));

@override
String toString() {
  return 'HomeModel(totalSales: $totalSales, revenue: $revenue, totalCustomers: $totalCustomers, recentSales: $recentSales)';
}


}

/// @nodoc
abstract mixin class _$HomeModelCopyWith<$Res> implements $HomeModelCopyWith<$Res> {
  factory _$HomeModelCopyWith(_HomeModel value, $Res Function(_HomeModel) _then) = __$HomeModelCopyWithImpl;
@override @useResult
$Res call({
 int totalSales, double revenue, int totalCustomers, List<RecentSale> recentSales
});




}
/// @nodoc
class __$HomeModelCopyWithImpl<$Res>
    implements _$HomeModelCopyWith<$Res> {
  __$HomeModelCopyWithImpl(this._self, this._then);

  final _HomeModel _self;
  final $Res Function(_HomeModel) _then;

/// Create a copy of HomeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalSales = null,Object? revenue = null,Object? totalCustomers = null,Object? recentSales = null,}) {
  return _then(_HomeModel(
totalSales: null == totalSales ? _self.totalSales : totalSales // ignore: cast_nullable_to_non_nullable
as int,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,totalCustomers: null == totalCustomers ? _self.totalCustomers : totalCustomers // ignore: cast_nullable_to_non_nullable
as int,recentSales: null == recentSales ? _self._recentSales : recentSales // ignore: cast_nullable_to_non_nullable
as List<RecentSale>,
  ));
}


}


/// @nodoc
mixin _$RecentSale {

 String get id; String get productName; double get amount; String get date; String get customerName;
/// Create a copy of RecentSale
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecentSaleCopyWith<RecentSale> get copyWith => _$RecentSaleCopyWithImpl<RecentSale>(this as RecentSale, _$identity);

  /// Serializes this RecentSale to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecentSale&&(identical(other.id, id) || other.id == id)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.customerName, customerName) || other.customerName == customerName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productName,amount,date,customerName);

@override
String toString() {
  return 'RecentSale(id: $id, productName: $productName, amount: $amount, date: $date, customerName: $customerName)';
}


}

/// @nodoc
abstract mixin class $RecentSaleCopyWith<$Res>  {
  factory $RecentSaleCopyWith(RecentSale value, $Res Function(RecentSale) _then) = _$RecentSaleCopyWithImpl;
@useResult
$Res call({
 String id, String productName, double amount, String date, String customerName
});




}
/// @nodoc
class _$RecentSaleCopyWithImpl<$Res>
    implements $RecentSaleCopyWith<$Res> {
  _$RecentSaleCopyWithImpl(this._self, this._then);

  final RecentSale _self;
  final $Res Function(RecentSale) _then;

/// Create a copy of RecentSale
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productName = null,Object? amount = null,Object? date = null,Object? customerName = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RecentSale].
extension RecentSalePatterns on RecentSale {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecentSale value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecentSale() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecentSale value)  $default,){
final _that = this;
switch (_that) {
case _RecentSale():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecentSale value)?  $default,){
final _that = this;
switch (_that) {
case _RecentSale() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String productName,  double amount,  String date,  String customerName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecentSale() when $default != null:
return $default(_that.id,_that.productName,_that.amount,_that.date,_that.customerName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String productName,  double amount,  String date,  String customerName)  $default,) {final _that = this;
switch (_that) {
case _RecentSale():
return $default(_that.id,_that.productName,_that.amount,_that.date,_that.customerName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String productName,  double amount,  String date,  String customerName)?  $default,) {final _that = this;
switch (_that) {
case _RecentSale() when $default != null:
return $default(_that.id,_that.productName,_that.amount,_that.date,_that.customerName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecentSale implements RecentSale {
  const _RecentSale({required this.id, required this.productName, required this.amount, required this.date, required this.customerName});
  factory _RecentSale.fromJson(Map<String, dynamic> json) => _$RecentSaleFromJson(json);

@override final  String id;
@override final  String productName;
@override final  double amount;
@override final  String date;
@override final  String customerName;

/// Create a copy of RecentSale
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecentSaleCopyWith<_RecentSale> get copyWith => __$RecentSaleCopyWithImpl<_RecentSale>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecentSaleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecentSale&&(identical(other.id, id) || other.id == id)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.customerName, customerName) || other.customerName == customerName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productName,amount,date,customerName);

@override
String toString() {
  return 'RecentSale(id: $id, productName: $productName, amount: $amount, date: $date, customerName: $customerName)';
}


}

/// @nodoc
abstract mixin class _$RecentSaleCopyWith<$Res> implements $RecentSaleCopyWith<$Res> {
  factory _$RecentSaleCopyWith(_RecentSale value, $Res Function(_RecentSale) _then) = __$RecentSaleCopyWithImpl;
@override @useResult
$Res call({
 String id, String productName, double amount, String date, String customerName
});




}
/// @nodoc
class __$RecentSaleCopyWithImpl<$Res>
    implements _$RecentSaleCopyWith<$Res> {
  __$RecentSaleCopyWithImpl(this._self, this._then);

  final _RecentSale _self;
  final $Res Function(_RecentSale) _then;

/// Create a copy of RecentSale
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productName = null,Object? amount = null,Object? date = null,Object? customerName = null,}) {
  return _then(_RecentSale(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
