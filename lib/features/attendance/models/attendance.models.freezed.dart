// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance.models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttendanceRecord {

 String get id; DateTime get date; DateTime? get checkInTime; DateTime? get checkOutTime; AttendanceStatus get status; String? get notes; String? get location; int get totalHoursWorked;
/// Create a copy of AttendanceRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceRecordCopyWith<AttendanceRecord> get copyWith => _$AttendanceRecordCopyWithImpl<AttendanceRecord>(this as AttendanceRecord, _$identity);

  /// Serializes this AttendanceRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.checkInTime, checkInTime) || other.checkInTime == checkInTime)&&(identical(other.checkOutTime, checkOutTime) || other.checkOutTime == checkOutTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.location, location) || other.location == location)&&(identical(other.totalHoursWorked, totalHoursWorked) || other.totalHoursWorked == totalHoursWorked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,checkInTime,checkOutTime,status,notes,location,totalHoursWorked);

@override
String toString() {
  return 'AttendanceRecord(id: $id, date: $date, checkInTime: $checkInTime, checkOutTime: $checkOutTime, status: $status, notes: $notes, location: $location, totalHoursWorked: $totalHoursWorked)';
}


}

/// @nodoc
abstract mixin class $AttendanceRecordCopyWith<$Res>  {
  factory $AttendanceRecordCopyWith(AttendanceRecord value, $Res Function(AttendanceRecord) _then) = _$AttendanceRecordCopyWithImpl;
@useResult
$Res call({
 String id, DateTime date, DateTime? checkInTime, DateTime? checkOutTime, AttendanceStatus status, String? notes, String? location, int totalHoursWorked
});




}
/// @nodoc
class _$AttendanceRecordCopyWithImpl<$Res>
    implements $AttendanceRecordCopyWith<$Res> {
  _$AttendanceRecordCopyWithImpl(this._self, this._then);

  final AttendanceRecord _self;
  final $Res Function(AttendanceRecord) _then;

/// Create a copy of AttendanceRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? date = null,Object? checkInTime = freezed,Object? checkOutTime = freezed,Object? status = null,Object? notes = freezed,Object? location = freezed,Object? totalHoursWorked = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,checkInTime: freezed == checkInTime ? _self.checkInTime : checkInTime // ignore: cast_nullable_to_non_nullable
as DateTime?,checkOutTime: freezed == checkOutTime ? _self.checkOutTime : checkOutTime // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttendanceStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,totalHoursWorked: null == totalHoursWorked ? _self.totalHoursWorked : totalHoursWorked // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendanceRecord].
extension AttendanceRecordPatterns on AttendanceRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceRecord value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceRecord value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime date,  DateTime? checkInTime,  DateTime? checkOutTime,  AttendanceStatus status,  String? notes,  String? location,  int totalHoursWorked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceRecord() when $default != null:
return $default(_that.id,_that.date,_that.checkInTime,_that.checkOutTime,_that.status,_that.notes,_that.location,_that.totalHoursWorked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime date,  DateTime? checkInTime,  DateTime? checkOutTime,  AttendanceStatus status,  String? notes,  String? location,  int totalHoursWorked)  $default,) {final _that = this;
switch (_that) {
case _AttendanceRecord():
return $default(_that.id,_that.date,_that.checkInTime,_that.checkOutTime,_that.status,_that.notes,_that.location,_that.totalHoursWorked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime date,  DateTime? checkInTime,  DateTime? checkOutTime,  AttendanceStatus status,  String? notes,  String? location,  int totalHoursWorked)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceRecord() when $default != null:
return $default(_that.id,_that.date,_that.checkInTime,_that.checkOutTime,_that.status,_that.notes,_that.location,_that.totalHoursWorked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttendanceRecord implements AttendanceRecord {
  const _AttendanceRecord({required this.id, required this.date, this.checkInTime, this.checkOutTime, required this.status, this.notes, this.location, this.totalHoursWorked = 0});
  factory _AttendanceRecord.fromJson(Map<String, dynamic> json) => _$AttendanceRecordFromJson(json);

@override final  String id;
@override final  DateTime date;
@override final  DateTime? checkInTime;
@override final  DateTime? checkOutTime;
@override final  AttendanceStatus status;
@override final  String? notes;
@override final  String? location;
@override@JsonKey() final  int totalHoursWorked;

/// Create a copy of AttendanceRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceRecordCopyWith<_AttendanceRecord> get copyWith => __$AttendanceRecordCopyWithImpl<_AttendanceRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.checkInTime, checkInTime) || other.checkInTime == checkInTime)&&(identical(other.checkOutTime, checkOutTime) || other.checkOutTime == checkOutTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.location, location) || other.location == location)&&(identical(other.totalHoursWorked, totalHoursWorked) || other.totalHoursWorked == totalHoursWorked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,checkInTime,checkOutTime,status,notes,location,totalHoursWorked);

@override
String toString() {
  return 'AttendanceRecord(id: $id, date: $date, checkInTime: $checkInTime, checkOutTime: $checkOutTime, status: $status, notes: $notes, location: $location, totalHoursWorked: $totalHoursWorked)';
}


}

/// @nodoc
abstract mixin class _$AttendanceRecordCopyWith<$Res> implements $AttendanceRecordCopyWith<$Res> {
  factory _$AttendanceRecordCopyWith(_AttendanceRecord value, $Res Function(_AttendanceRecord) _then) = __$AttendanceRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime date, DateTime? checkInTime, DateTime? checkOutTime, AttendanceStatus status, String? notes, String? location, int totalHoursWorked
});




}
/// @nodoc
class __$AttendanceRecordCopyWithImpl<$Res>
    implements _$AttendanceRecordCopyWith<$Res> {
  __$AttendanceRecordCopyWithImpl(this._self, this._then);

  final _AttendanceRecord _self;
  final $Res Function(_AttendanceRecord) _then;

/// Create a copy of AttendanceRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? date = null,Object? checkInTime = freezed,Object? checkOutTime = freezed,Object? status = null,Object? notes = freezed,Object? location = freezed,Object? totalHoursWorked = null,}) {
  return _then(_AttendanceRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,checkInTime: freezed == checkInTime ? _self.checkInTime : checkInTime // ignore: cast_nullable_to_non_nullable
as DateTime?,checkOutTime: freezed == checkOutTime ? _self.checkOutTime : checkOutTime // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttendanceStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,totalHoursWorked: null == totalHoursWorked ? _self.totalHoursWorked : totalHoursWorked // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AttendanceSummary {

 int get totalDays; int get presentDays; int get absentDays; int get lateDays; int get leaveDays; double get attendancePercentage; int get totalHoursWorked;
/// Create a copy of AttendanceSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceSummaryCopyWith<AttendanceSummary> get copyWith => _$AttendanceSummaryCopyWithImpl<AttendanceSummary>(this as AttendanceSummary, _$identity);

  /// Serializes this AttendanceSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceSummary&&(identical(other.totalDays, totalDays) || other.totalDays == totalDays)&&(identical(other.presentDays, presentDays) || other.presentDays == presentDays)&&(identical(other.absentDays, absentDays) || other.absentDays == absentDays)&&(identical(other.lateDays, lateDays) || other.lateDays == lateDays)&&(identical(other.leaveDays, leaveDays) || other.leaveDays == leaveDays)&&(identical(other.attendancePercentage, attendancePercentage) || other.attendancePercentage == attendancePercentage)&&(identical(other.totalHoursWorked, totalHoursWorked) || other.totalHoursWorked == totalHoursWorked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalDays,presentDays,absentDays,lateDays,leaveDays,attendancePercentage,totalHoursWorked);

@override
String toString() {
  return 'AttendanceSummary(totalDays: $totalDays, presentDays: $presentDays, absentDays: $absentDays, lateDays: $lateDays, leaveDays: $leaveDays, attendancePercentage: $attendancePercentage, totalHoursWorked: $totalHoursWorked)';
}


}

/// @nodoc
abstract mixin class $AttendanceSummaryCopyWith<$Res>  {
  factory $AttendanceSummaryCopyWith(AttendanceSummary value, $Res Function(AttendanceSummary) _then) = _$AttendanceSummaryCopyWithImpl;
@useResult
$Res call({
 int totalDays, int presentDays, int absentDays, int lateDays, int leaveDays, double attendancePercentage, int totalHoursWorked
});




}
/// @nodoc
class _$AttendanceSummaryCopyWithImpl<$Res>
    implements $AttendanceSummaryCopyWith<$Res> {
  _$AttendanceSummaryCopyWithImpl(this._self, this._then);

  final AttendanceSummary _self;
  final $Res Function(AttendanceSummary) _then;

/// Create a copy of AttendanceSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalDays = null,Object? presentDays = null,Object? absentDays = null,Object? lateDays = null,Object? leaveDays = null,Object? attendancePercentage = null,Object? totalHoursWorked = null,}) {
  return _then(_self.copyWith(
totalDays: null == totalDays ? _self.totalDays : totalDays // ignore: cast_nullable_to_non_nullable
as int,presentDays: null == presentDays ? _self.presentDays : presentDays // ignore: cast_nullable_to_non_nullable
as int,absentDays: null == absentDays ? _self.absentDays : absentDays // ignore: cast_nullable_to_non_nullable
as int,lateDays: null == lateDays ? _self.lateDays : lateDays // ignore: cast_nullable_to_non_nullable
as int,leaveDays: null == leaveDays ? _self.leaveDays : leaveDays // ignore: cast_nullable_to_non_nullable
as int,attendancePercentage: null == attendancePercentage ? _self.attendancePercentage : attendancePercentage // ignore: cast_nullable_to_non_nullable
as double,totalHoursWorked: null == totalHoursWorked ? _self.totalHoursWorked : totalHoursWorked // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendanceSummary].
extension AttendanceSummaryPatterns on AttendanceSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceSummary value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceSummary value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalDays,  int presentDays,  int absentDays,  int lateDays,  int leaveDays,  double attendancePercentage,  int totalHoursWorked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceSummary() when $default != null:
return $default(_that.totalDays,_that.presentDays,_that.absentDays,_that.lateDays,_that.leaveDays,_that.attendancePercentage,_that.totalHoursWorked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalDays,  int presentDays,  int absentDays,  int lateDays,  int leaveDays,  double attendancePercentage,  int totalHoursWorked)  $default,) {final _that = this;
switch (_that) {
case _AttendanceSummary():
return $default(_that.totalDays,_that.presentDays,_that.absentDays,_that.lateDays,_that.leaveDays,_that.attendancePercentage,_that.totalHoursWorked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalDays,  int presentDays,  int absentDays,  int lateDays,  int leaveDays,  double attendancePercentage,  int totalHoursWorked)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceSummary() when $default != null:
return $default(_that.totalDays,_that.presentDays,_that.absentDays,_that.lateDays,_that.leaveDays,_that.attendancePercentage,_that.totalHoursWorked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttendanceSummary implements AttendanceSummary {
  const _AttendanceSummary({required this.totalDays, required this.presentDays, required this.absentDays, required this.lateDays, required this.leaveDays, required this.attendancePercentage, required this.totalHoursWorked});
  factory _AttendanceSummary.fromJson(Map<String, dynamic> json) => _$AttendanceSummaryFromJson(json);

@override final  int totalDays;
@override final  int presentDays;
@override final  int absentDays;
@override final  int lateDays;
@override final  int leaveDays;
@override final  double attendancePercentage;
@override final  int totalHoursWorked;

/// Create a copy of AttendanceSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceSummaryCopyWith<_AttendanceSummary> get copyWith => __$AttendanceSummaryCopyWithImpl<_AttendanceSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceSummary&&(identical(other.totalDays, totalDays) || other.totalDays == totalDays)&&(identical(other.presentDays, presentDays) || other.presentDays == presentDays)&&(identical(other.absentDays, absentDays) || other.absentDays == absentDays)&&(identical(other.lateDays, lateDays) || other.lateDays == lateDays)&&(identical(other.leaveDays, leaveDays) || other.leaveDays == leaveDays)&&(identical(other.attendancePercentage, attendancePercentage) || other.attendancePercentage == attendancePercentage)&&(identical(other.totalHoursWorked, totalHoursWorked) || other.totalHoursWorked == totalHoursWorked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalDays,presentDays,absentDays,lateDays,leaveDays,attendancePercentage,totalHoursWorked);

@override
String toString() {
  return 'AttendanceSummary(totalDays: $totalDays, presentDays: $presentDays, absentDays: $absentDays, lateDays: $lateDays, leaveDays: $leaveDays, attendancePercentage: $attendancePercentage, totalHoursWorked: $totalHoursWorked)';
}


}

/// @nodoc
abstract mixin class _$AttendanceSummaryCopyWith<$Res> implements $AttendanceSummaryCopyWith<$Res> {
  factory _$AttendanceSummaryCopyWith(_AttendanceSummary value, $Res Function(_AttendanceSummary) _then) = __$AttendanceSummaryCopyWithImpl;
@override @useResult
$Res call({
 int totalDays, int presentDays, int absentDays, int lateDays, int leaveDays, double attendancePercentage, int totalHoursWorked
});




}
/// @nodoc
class __$AttendanceSummaryCopyWithImpl<$Res>
    implements _$AttendanceSummaryCopyWith<$Res> {
  __$AttendanceSummaryCopyWithImpl(this._self, this._then);

  final _AttendanceSummary _self;
  final $Res Function(_AttendanceSummary) _then;

/// Create a copy of AttendanceSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalDays = null,Object? presentDays = null,Object? absentDays = null,Object? lateDays = null,Object? leaveDays = null,Object? attendancePercentage = null,Object? totalHoursWorked = null,}) {
  return _then(_AttendanceSummary(
totalDays: null == totalDays ? _self.totalDays : totalDays // ignore: cast_nullable_to_non_nullable
as int,presentDays: null == presentDays ? _self.presentDays : presentDays // ignore: cast_nullable_to_non_nullable
as int,absentDays: null == absentDays ? _self.absentDays : absentDays // ignore: cast_nullable_to_non_nullable
as int,lateDays: null == lateDays ? _self.lateDays : lateDays // ignore: cast_nullable_to_non_nullable
as int,leaveDays: null == leaveDays ? _self.leaveDays : leaveDays // ignore: cast_nullable_to_non_nullable
as int,attendancePercentage: null == attendancePercentage ? _self.attendancePercentage : attendancePercentage // ignore: cast_nullable_to_non_nullable
as double,totalHoursWorked: null == totalHoursWorked ? _self.totalHoursWorked : totalHoursWorked // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TodayAttendance {

 DateTime? get checkInTime; DateTime? get checkOutTime; bool get isCheckedIn; bool get isCheckedOut; String? get location; int get hoursWorked;
/// Create a copy of TodayAttendance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayAttendanceCopyWith<TodayAttendance> get copyWith => _$TodayAttendanceCopyWithImpl<TodayAttendance>(this as TodayAttendance, _$identity);

  /// Serializes this TodayAttendance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayAttendance&&(identical(other.checkInTime, checkInTime) || other.checkInTime == checkInTime)&&(identical(other.checkOutTime, checkOutTime) || other.checkOutTime == checkOutTime)&&(identical(other.isCheckedIn, isCheckedIn) || other.isCheckedIn == isCheckedIn)&&(identical(other.isCheckedOut, isCheckedOut) || other.isCheckedOut == isCheckedOut)&&(identical(other.location, location) || other.location == location)&&(identical(other.hoursWorked, hoursWorked) || other.hoursWorked == hoursWorked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,checkInTime,checkOutTime,isCheckedIn,isCheckedOut,location,hoursWorked);

@override
String toString() {
  return 'TodayAttendance(checkInTime: $checkInTime, checkOutTime: $checkOutTime, isCheckedIn: $isCheckedIn, isCheckedOut: $isCheckedOut, location: $location, hoursWorked: $hoursWorked)';
}


}

/// @nodoc
abstract mixin class $TodayAttendanceCopyWith<$Res>  {
  factory $TodayAttendanceCopyWith(TodayAttendance value, $Res Function(TodayAttendance) _then) = _$TodayAttendanceCopyWithImpl;
@useResult
$Res call({
 DateTime? checkInTime, DateTime? checkOutTime, bool isCheckedIn, bool isCheckedOut, String? location, int hoursWorked
});




}
/// @nodoc
class _$TodayAttendanceCopyWithImpl<$Res>
    implements $TodayAttendanceCopyWith<$Res> {
  _$TodayAttendanceCopyWithImpl(this._self, this._then);

  final TodayAttendance _self;
  final $Res Function(TodayAttendance) _then;

/// Create a copy of TodayAttendance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? checkInTime = freezed,Object? checkOutTime = freezed,Object? isCheckedIn = null,Object? isCheckedOut = null,Object? location = freezed,Object? hoursWorked = null,}) {
  return _then(_self.copyWith(
checkInTime: freezed == checkInTime ? _self.checkInTime : checkInTime // ignore: cast_nullable_to_non_nullable
as DateTime?,checkOutTime: freezed == checkOutTime ? _self.checkOutTime : checkOutTime // ignore: cast_nullable_to_non_nullable
as DateTime?,isCheckedIn: null == isCheckedIn ? _self.isCheckedIn : isCheckedIn // ignore: cast_nullable_to_non_nullable
as bool,isCheckedOut: null == isCheckedOut ? _self.isCheckedOut : isCheckedOut // ignore: cast_nullable_to_non_nullable
as bool,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,hoursWorked: null == hoursWorked ? _self.hoursWorked : hoursWorked // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TodayAttendance].
extension TodayAttendancePatterns on TodayAttendance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodayAttendance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodayAttendance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodayAttendance value)  $default,){
final _that = this;
switch (_that) {
case _TodayAttendance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodayAttendance value)?  $default,){
final _that = this;
switch (_that) {
case _TodayAttendance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? checkInTime,  DateTime? checkOutTime,  bool isCheckedIn,  bool isCheckedOut,  String? location,  int hoursWorked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodayAttendance() when $default != null:
return $default(_that.checkInTime,_that.checkOutTime,_that.isCheckedIn,_that.isCheckedOut,_that.location,_that.hoursWorked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? checkInTime,  DateTime? checkOutTime,  bool isCheckedIn,  bool isCheckedOut,  String? location,  int hoursWorked)  $default,) {final _that = this;
switch (_that) {
case _TodayAttendance():
return $default(_that.checkInTime,_that.checkOutTime,_that.isCheckedIn,_that.isCheckedOut,_that.location,_that.hoursWorked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? checkInTime,  DateTime? checkOutTime,  bool isCheckedIn,  bool isCheckedOut,  String? location,  int hoursWorked)?  $default,) {final _that = this;
switch (_that) {
case _TodayAttendance() when $default != null:
return $default(_that.checkInTime,_that.checkOutTime,_that.isCheckedIn,_that.isCheckedOut,_that.location,_that.hoursWorked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TodayAttendance implements TodayAttendance {
  const _TodayAttendance({this.checkInTime, this.checkOutTime, this.isCheckedIn = false, this.isCheckedOut = false, this.location, this.hoursWorked = 0});
  factory _TodayAttendance.fromJson(Map<String, dynamic> json) => _$TodayAttendanceFromJson(json);

@override final  DateTime? checkInTime;
@override final  DateTime? checkOutTime;
@override@JsonKey() final  bool isCheckedIn;
@override@JsonKey() final  bool isCheckedOut;
@override final  String? location;
@override@JsonKey() final  int hoursWorked;

/// Create a copy of TodayAttendance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodayAttendanceCopyWith<_TodayAttendance> get copyWith => __$TodayAttendanceCopyWithImpl<_TodayAttendance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TodayAttendanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodayAttendance&&(identical(other.checkInTime, checkInTime) || other.checkInTime == checkInTime)&&(identical(other.checkOutTime, checkOutTime) || other.checkOutTime == checkOutTime)&&(identical(other.isCheckedIn, isCheckedIn) || other.isCheckedIn == isCheckedIn)&&(identical(other.isCheckedOut, isCheckedOut) || other.isCheckedOut == isCheckedOut)&&(identical(other.location, location) || other.location == location)&&(identical(other.hoursWorked, hoursWorked) || other.hoursWorked == hoursWorked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,checkInTime,checkOutTime,isCheckedIn,isCheckedOut,location,hoursWorked);

@override
String toString() {
  return 'TodayAttendance(checkInTime: $checkInTime, checkOutTime: $checkOutTime, isCheckedIn: $isCheckedIn, isCheckedOut: $isCheckedOut, location: $location, hoursWorked: $hoursWorked)';
}


}

/// @nodoc
abstract mixin class _$TodayAttendanceCopyWith<$Res> implements $TodayAttendanceCopyWith<$Res> {
  factory _$TodayAttendanceCopyWith(_TodayAttendance value, $Res Function(_TodayAttendance) _then) = __$TodayAttendanceCopyWithImpl;
@override @useResult
$Res call({
 DateTime? checkInTime, DateTime? checkOutTime, bool isCheckedIn, bool isCheckedOut, String? location, int hoursWorked
});




}
/// @nodoc
class __$TodayAttendanceCopyWithImpl<$Res>
    implements _$TodayAttendanceCopyWith<$Res> {
  __$TodayAttendanceCopyWithImpl(this._self, this._then);

  final _TodayAttendance _self;
  final $Res Function(_TodayAttendance) _then;

/// Create a copy of TodayAttendance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? checkInTime = freezed,Object? checkOutTime = freezed,Object? isCheckedIn = null,Object? isCheckedOut = null,Object? location = freezed,Object? hoursWorked = null,}) {
  return _then(_TodayAttendance(
checkInTime: freezed == checkInTime ? _self.checkInTime : checkInTime // ignore: cast_nullable_to_non_nullable
as DateTime?,checkOutTime: freezed == checkOutTime ? _self.checkOutTime : checkOutTime // ignore: cast_nullable_to_non_nullable
as DateTime?,isCheckedIn: null == isCheckedIn ? _self.isCheckedIn : isCheckedIn // ignore: cast_nullable_to_non_nullable
as bool,isCheckedOut: null == isCheckedOut ? _self.isCheckedOut : isCheckedOut // ignore: cast_nullable_to_non_nullable
as bool,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,hoursWorked: null == hoursWorked ? _self.hoursWorked : hoursWorked // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
