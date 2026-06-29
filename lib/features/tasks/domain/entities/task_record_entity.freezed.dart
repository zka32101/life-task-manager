// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_record_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaskRecordEntity {

 String get recordId; String get taskId; String get doneByUid; String? get doneByDisplayName; DateTime get doneAt; DateTime? get scheduledDueAt; String? get notes; double? get cost; String? get costCurrency; String? get groupId; DateTime get createdAt;
/// Create a copy of TaskRecordEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskRecordEntityCopyWith<TaskRecordEntity> get copyWith => _$TaskRecordEntityCopyWithImpl<TaskRecordEntity>(this as TaskRecordEntity, _$identity);

  /// Serializes this TaskRecordEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskRecordEntity&&(identical(other.recordId, recordId) || other.recordId == recordId)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.doneByUid, doneByUid) || other.doneByUid == doneByUid)&&(identical(other.doneByDisplayName, doneByDisplayName) || other.doneByDisplayName == doneByDisplayName)&&(identical(other.doneAt, doneAt) || other.doneAt == doneAt)&&(identical(other.scheduledDueAt, scheduledDueAt) || other.scheduledDueAt == scheduledDueAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.costCurrency, costCurrency) || other.costCurrency == costCurrency)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recordId,taskId,doneByUid,doneByDisplayName,doneAt,scheduledDueAt,notes,cost,costCurrency,groupId,createdAt);

@override
String toString() {
  return 'TaskRecordEntity(recordId: $recordId, taskId: $taskId, doneByUid: $doneByUid, doneByDisplayName: $doneByDisplayName, doneAt: $doneAt, scheduledDueAt: $scheduledDueAt, notes: $notes, cost: $cost, costCurrency: $costCurrency, groupId: $groupId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TaskRecordEntityCopyWith<$Res>  {
  factory $TaskRecordEntityCopyWith(TaskRecordEntity value, $Res Function(TaskRecordEntity) _then) = _$TaskRecordEntityCopyWithImpl;
@useResult
$Res call({
 String recordId, String taskId, String doneByUid, String? doneByDisplayName, DateTime doneAt, DateTime? scheduledDueAt, String? notes, double? cost, String? costCurrency, String? groupId, DateTime createdAt
});




}
/// @nodoc
class _$TaskRecordEntityCopyWithImpl<$Res>
    implements $TaskRecordEntityCopyWith<$Res> {
  _$TaskRecordEntityCopyWithImpl(this._self, this._then);

  final TaskRecordEntity _self;
  final $Res Function(TaskRecordEntity) _then;

/// Create a copy of TaskRecordEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recordId = null,Object? taskId = null,Object? doneByUid = null,Object? doneByDisplayName = freezed,Object? doneAt = null,Object? scheduledDueAt = freezed,Object? notes = freezed,Object? cost = freezed,Object? costCurrency = freezed,Object? groupId = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
recordId: null == recordId ? _self.recordId : recordId // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,doneByUid: null == doneByUid ? _self.doneByUid : doneByUid // ignore: cast_nullable_to_non_nullable
as String,doneByDisplayName: freezed == doneByDisplayName ? _self.doneByDisplayName : doneByDisplayName // ignore: cast_nullable_to_non_nullable
as String?,doneAt: null == doneAt ? _self.doneAt : doneAt // ignore: cast_nullable_to_non_nullable
as DateTime,scheduledDueAt: freezed == scheduledDueAt ? _self.scheduledDueAt : scheduledDueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,cost: freezed == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as double?,costCurrency: freezed == costCurrency ? _self.costCurrency : costCurrency // ignore: cast_nullable_to_non_nullable
as String?,groupId: freezed == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskRecordEntity].
extension TaskRecordEntityPatterns on TaskRecordEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskRecordEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskRecordEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskRecordEntity value)  $default,){
final _that = this;
switch (_that) {
case _TaskRecordEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskRecordEntity value)?  $default,){
final _that = this;
switch (_that) {
case _TaskRecordEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String recordId,  String taskId,  String doneByUid,  String? doneByDisplayName,  DateTime doneAt,  DateTime? scheduledDueAt,  String? notes,  double? cost,  String? costCurrency,  String? groupId,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskRecordEntity() when $default != null:
return $default(_that.recordId,_that.taskId,_that.doneByUid,_that.doneByDisplayName,_that.doneAt,_that.scheduledDueAt,_that.notes,_that.cost,_that.costCurrency,_that.groupId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String recordId,  String taskId,  String doneByUid,  String? doneByDisplayName,  DateTime doneAt,  DateTime? scheduledDueAt,  String? notes,  double? cost,  String? costCurrency,  String? groupId,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _TaskRecordEntity():
return $default(_that.recordId,_that.taskId,_that.doneByUid,_that.doneByDisplayName,_that.doneAt,_that.scheduledDueAt,_that.notes,_that.cost,_that.costCurrency,_that.groupId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String recordId,  String taskId,  String doneByUid,  String? doneByDisplayName,  DateTime doneAt,  DateTime? scheduledDueAt,  String? notes,  double? cost,  String? costCurrency,  String? groupId,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TaskRecordEntity() when $default != null:
return $default(_that.recordId,_that.taskId,_that.doneByUid,_that.doneByDisplayName,_that.doneAt,_that.scheduledDueAt,_that.notes,_that.cost,_that.costCurrency,_that.groupId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskRecordEntity implements TaskRecordEntity {
  const _TaskRecordEntity({required this.recordId, required this.taskId, required this.doneByUid, this.doneByDisplayName, required this.doneAt, this.scheduledDueAt, this.notes, this.cost, this.costCurrency, this.groupId, required this.createdAt});
  factory _TaskRecordEntity.fromJson(Map<String, dynamic> json) => _$TaskRecordEntityFromJson(json);

@override final  String recordId;
@override final  String taskId;
@override final  String doneByUid;
@override final  String? doneByDisplayName;
@override final  DateTime doneAt;
@override final  DateTime? scheduledDueAt;
@override final  String? notes;
@override final  double? cost;
@override final  String? costCurrency;
@override final  String? groupId;
@override final  DateTime createdAt;

/// Create a copy of TaskRecordEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskRecordEntityCopyWith<_TaskRecordEntity> get copyWith => __$TaskRecordEntityCopyWithImpl<_TaskRecordEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskRecordEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskRecordEntity&&(identical(other.recordId, recordId) || other.recordId == recordId)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.doneByUid, doneByUid) || other.doneByUid == doneByUid)&&(identical(other.doneByDisplayName, doneByDisplayName) || other.doneByDisplayName == doneByDisplayName)&&(identical(other.doneAt, doneAt) || other.doneAt == doneAt)&&(identical(other.scheduledDueAt, scheduledDueAt) || other.scheduledDueAt == scheduledDueAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.costCurrency, costCurrency) || other.costCurrency == costCurrency)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recordId,taskId,doneByUid,doneByDisplayName,doneAt,scheduledDueAt,notes,cost,costCurrency,groupId,createdAt);

@override
String toString() {
  return 'TaskRecordEntity(recordId: $recordId, taskId: $taskId, doneByUid: $doneByUid, doneByDisplayName: $doneByDisplayName, doneAt: $doneAt, scheduledDueAt: $scheduledDueAt, notes: $notes, cost: $cost, costCurrency: $costCurrency, groupId: $groupId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TaskRecordEntityCopyWith<$Res> implements $TaskRecordEntityCopyWith<$Res> {
  factory _$TaskRecordEntityCopyWith(_TaskRecordEntity value, $Res Function(_TaskRecordEntity) _then) = __$TaskRecordEntityCopyWithImpl;
@override @useResult
$Res call({
 String recordId, String taskId, String doneByUid, String? doneByDisplayName, DateTime doneAt, DateTime? scheduledDueAt, String? notes, double? cost, String? costCurrency, String? groupId, DateTime createdAt
});




}
/// @nodoc
class __$TaskRecordEntityCopyWithImpl<$Res>
    implements _$TaskRecordEntityCopyWith<$Res> {
  __$TaskRecordEntityCopyWithImpl(this._self, this._then);

  final _TaskRecordEntity _self;
  final $Res Function(_TaskRecordEntity) _then;

/// Create a copy of TaskRecordEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recordId = null,Object? taskId = null,Object? doneByUid = null,Object? doneByDisplayName = freezed,Object? doneAt = null,Object? scheduledDueAt = freezed,Object? notes = freezed,Object? cost = freezed,Object? costCurrency = freezed,Object? groupId = freezed,Object? createdAt = null,}) {
  return _then(_TaskRecordEntity(
recordId: null == recordId ? _self.recordId : recordId // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,doneByUid: null == doneByUid ? _self.doneByUid : doneByUid // ignore: cast_nullable_to_non_nullable
as String,doneByDisplayName: freezed == doneByDisplayName ? _self.doneByDisplayName : doneByDisplayName // ignore: cast_nullable_to_non_nullable
as String?,doneAt: null == doneAt ? _self.doneAt : doneAt // ignore: cast_nullable_to_non_nullable
as DateTime,scheduledDueAt: freezed == scheduledDueAt ? _self.scheduledDueAt : scheduledDueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,cost: freezed == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as double?,costCurrency: freezed == costCurrency ? _self.costCurrency : costCurrency // ignore: cast_nullable_to_non_nullable
as String?,groupId: freezed == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
