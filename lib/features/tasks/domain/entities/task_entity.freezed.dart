// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaskEntity {

 String get taskId; String get title; String? get description; String get categoryId; String get categoryPath; List<String> get categoryLabels; DateTime get nextDueAt; DateTime? get lastDoneAt; String? get lastDoneByUid; String get recurrenceType; int? get recurrenceValue; String? get recurrenceUnit; int get reminderDaysBefore; String? get groupId; String? get mainAssigneeUid; List<String> get assigneeUids; int get deferCount; DateTime? get originalDueAt; DateTime? get deferredAt; String? get deferredByUid; DateTime? get snoozeUntil; String? get notes; double? get cost; String? get costCurrency; bool get isArchived; bool get isLocalePreset; String? get presetLocale; bool get isGroupTask; String get createdByUid; String get updatedByUid; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of TaskEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskEntityCopyWith<TaskEntity> get copyWith => _$TaskEntityCopyWithImpl<TaskEntity>(this as TaskEntity, _$identity);

  /// Serializes this TaskEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskEntity&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryPath, categoryPath) || other.categoryPath == categoryPath)&&const DeepCollectionEquality().equals(other.categoryLabels, categoryLabels)&&(identical(other.nextDueAt, nextDueAt) || other.nextDueAt == nextDueAt)&&(identical(other.lastDoneAt, lastDoneAt) || other.lastDoneAt == lastDoneAt)&&(identical(other.lastDoneByUid, lastDoneByUid) || other.lastDoneByUid == lastDoneByUid)&&(identical(other.recurrenceType, recurrenceType) || other.recurrenceType == recurrenceType)&&(identical(other.recurrenceValue, recurrenceValue) || other.recurrenceValue == recurrenceValue)&&(identical(other.recurrenceUnit, recurrenceUnit) || other.recurrenceUnit == recurrenceUnit)&&(identical(other.reminderDaysBefore, reminderDaysBefore) || other.reminderDaysBefore == reminderDaysBefore)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.mainAssigneeUid, mainAssigneeUid) || other.mainAssigneeUid == mainAssigneeUid)&&const DeepCollectionEquality().equals(other.assigneeUids, assigneeUids)&&(identical(other.deferCount, deferCount) || other.deferCount == deferCount)&&(identical(other.originalDueAt, originalDueAt) || other.originalDueAt == originalDueAt)&&(identical(other.deferredAt, deferredAt) || other.deferredAt == deferredAt)&&(identical(other.deferredByUid, deferredByUid) || other.deferredByUid == deferredByUid)&&(identical(other.snoozeUntil, snoozeUntil) || other.snoozeUntil == snoozeUntil)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.costCurrency, costCurrency) || other.costCurrency == costCurrency)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.isLocalePreset, isLocalePreset) || other.isLocalePreset == isLocalePreset)&&(identical(other.presetLocale, presetLocale) || other.presetLocale == presetLocale)&&(identical(other.isGroupTask, isGroupTask) || other.isGroupTask == isGroupTask)&&(identical(other.createdByUid, createdByUid) || other.createdByUid == createdByUid)&&(identical(other.updatedByUid, updatedByUid) || other.updatedByUid == updatedByUid)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,taskId,title,description,categoryId,categoryPath,const DeepCollectionEquality().hash(categoryLabels),nextDueAt,lastDoneAt,lastDoneByUid,recurrenceType,recurrenceValue,recurrenceUnit,reminderDaysBefore,groupId,mainAssigneeUid,const DeepCollectionEquality().hash(assigneeUids),deferCount,originalDueAt,deferredAt,deferredByUid,snoozeUntil,notes,cost,costCurrency,isArchived,isLocalePreset,presetLocale,isGroupTask,createdByUid,updatedByUid,createdAt,updatedAt]);

@override
String toString() {
  return 'TaskEntity(taskId: $taskId, title: $title, description: $description, categoryId: $categoryId, categoryPath: $categoryPath, categoryLabels: $categoryLabels, nextDueAt: $nextDueAt, lastDoneAt: $lastDoneAt, lastDoneByUid: $lastDoneByUid, recurrenceType: $recurrenceType, recurrenceValue: $recurrenceValue, recurrenceUnit: $recurrenceUnit, reminderDaysBefore: $reminderDaysBefore, groupId: $groupId, mainAssigneeUid: $mainAssigneeUid, assigneeUids: $assigneeUids, deferCount: $deferCount, originalDueAt: $originalDueAt, deferredAt: $deferredAt, deferredByUid: $deferredByUid, snoozeUntil: $snoozeUntil, notes: $notes, cost: $cost, costCurrency: $costCurrency, isArchived: $isArchived, isLocalePreset: $isLocalePreset, presetLocale: $presetLocale, isGroupTask: $isGroupTask, createdByUid: $createdByUid, updatedByUid: $updatedByUid, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $TaskEntityCopyWith<$Res>  {
  factory $TaskEntityCopyWith(TaskEntity value, $Res Function(TaskEntity) _then) = _$TaskEntityCopyWithImpl;
@useResult
$Res call({
 String taskId, String title, String? description, String categoryId, String categoryPath, List<String> categoryLabels, DateTime nextDueAt, DateTime? lastDoneAt, String? lastDoneByUid, String recurrenceType, int? recurrenceValue, String? recurrenceUnit, int reminderDaysBefore, String? groupId, String? mainAssigneeUid, List<String> assigneeUids, int deferCount, DateTime? originalDueAt, DateTime? deferredAt, String? deferredByUid, DateTime? snoozeUntil, String? notes, double? cost, String? costCurrency, bool isArchived, bool isLocalePreset, String? presetLocale, bool isGroupTask, String createdByUid, String updatedByUid, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$TaskEntityCopyWithImpl<$Res>
    implements $TaskEntityCopyWith<$Res> {
  _$TaskEntityCopyWithImpl(this._self, this._then);

  final TaskEntity _self;
  final $Res Function(TaskEntity) _then;

/// Create a copy of TaskEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? taskId = null,Object? title = null,Object? description = freezed,Object? categoryId = null,Object? categoryPath = null,Object? categoryLabels = null,Object? nextDueAt = null,Object? lastDoneAt = freezed,Object? lastDoneByUid = freezed,Object? recurrenceType = null,Object? recurrenceValue = freezed,Object? recurrenceUnit = freezed,Object? reminderDaysBefore = null,Object? groupId = freezed,Object? mainAssigneeUid = freezed,Object? assigneeUids = null,Object? deferCount = null,Object? originalDueAt = freezed,Object? deferredAt = freezed,Object? deferredByUid = freezed,Object? snoozeUntil = freezed,Object? notes = freezed,Object? cost = freezed,Object? costCurrency = freezed,Object? isArchived = null,Object? isLocalePreset = null,Object? presetLocale = freezed,Object? isGroupTask = null,Object? createdByUid = null,Object? updatedByUid = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,categoryPath: null == categoryPath ? _self.categoryPath : categoryPath // ignore: cast_nullable_to_non_nullable
as String,categoryLabels: null == categoryLabels ? _self.categoryLabels : categoryLabels // ignore: cast_nullable_to_non_nullable
as List<String>,nextDueAt: null == nextDueAt ? _self.nextDueAt : nextDueAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastDoneAt: freezed == lastDoneAt ? _self.lastDoneAt : lastDoneAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastDoneByUid: freezed == lastDoneByUid ? _self.lastDoneByUid : lastDoneByUid // ignore: cast_nullable_to_non_nullable
as String?,recurrenceType: null == recurrenceType ? _self.recurrenceType : recurrenceType // ignore: cast_nullable_to_non_nullable
as String,recurrenceValue: freezed == recurrenceValue ? _self.recurrenceValue : recurrenceValue // ignore: cast_nullable_to_non_nullable
as int?,recurrenceUnit: freezed == recurrenceUnit ? _self.recurrenceUnit : recurrenceUnit // ignore: cast_nullable_to_non_nullable
as String?,reminderDaysBefore: null == reminderDaysBefore ? _self.reminderDaysBefore : reminderDaysBefore // ignore: cast_nullable_to_non_nullable
as int,groupId: freezed == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String?,mainAssigneeUid: freezed == mainAssigneeUid ? _self.mainAssigneeUid : mainAssigneeUid // ignore: cast_nullable_to_non_nullable
as String?,assigneeUids: null == assigneeUids ? _self.assigneeUids : assigneeUids // ignore: cast_nullable_to_non_nullable
as List<String>,deferCount: null == deferCount ? _self.deferCount : deferCount // ignore: cast_nullable_to_non_nullable
as int,originalDueAt: freezed == originalDueAt ? _self.originalDueAt : originalDueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deferredAt: freezed == deferredAt ? _self.deferredAt : deferredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deferredByUid: freezed == deferredByUid ? _self.deferredByUid : deferredByUid // ignore: cast_nullable_to_non_nullable
as String?,snoozeUntil: freezed == snoozeUntil ? _self.snoozeUntil : snoozeUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,cost: freezed == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as double?,costCurrency: freezed == costCurrency ? _self.costCurrency : costCurrency // ignore: cast_nullable_to_non_nullable
as String?,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,isLocalePreset: null == isLocalePreset ? _self.isLocalePreset : isLocalePreset // ignore: cast_nullable_to_non_nullable
as bool,presetLocale: freezed == presetLocale ? _self.presetLocale : presetLocale // ignore: cast_nullable_to_non_nullable
as String?,isGroupTask: null == isGroupTask ? _self.isGroupTask : isGroupTask // ignore: cast_nullable_to_non_nullable
as bool,createdByUid: null == createdByUid ? _self.createdByUid : createdByUid // ignore: cast_nullable_to_non_nullable
as String,updatedByUid: null == updatedByUid ? _self.updatedByUid : updatedByUid // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskEntity].
extension TaskEntityPatterns on TaskEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskEntity value)  $default,){
final _that = this;
switch (_that) {
case _TaskEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskEntity value)?  $default,){
final _that = this;
switch (_that) {
case _TaskEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String taskId,  String title,  String? description,  String categoryId,  String categoryPath,  List<String> categoryLabels,  DateTime nextDueAt,  DateTime? lastDoneAt,  String? lastDoneByUid,  String recurrenceType,  int? recurrenceValue,  String? recurrenceUnit,  int reminderDaysBefore,  String? groupId,  String? mainAssigneeUid,  List<String> assigneeUids,  int deferCount,  DateTime? originalDueAt,  DateTime? deferredAt,  String? deferredByUid,  DateTime? snoozeUntil,  String? notes,  double? cost,  String? costCurrency,  bool isArchived,  bool isLocalePreset,  String? presetLocale,  bool isGroupTask,  String createdByUid,  String updatedByUid,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskEntity() when $default != null:
return $default(_that.taskId,_that.title,_that.description,_that.categoryId,_that.categoryPath,_that.categoryLabels,_that.nextDueAt,_that.lastDoneAt,_that.lastDoneByUid,_that.recurrenceType,_that.recurrenceValue,_that.recurrenceUnit,_that.reminderDaysBefore,_that.groupId,_that.mainAssigneeUid,_that.assigneeUids,_that.deferCount,_that.originalDueAt,_that.deferredAt,_that.deferredByUid,_that.snoozeUntil,_that.notes,_that.cost,_that.costCurrency,_that.isArchived,_that.isLocalePreset,_that.presetLocale,_that.isGroupTask,_that.createdByUid,_that.updatedByUid,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String taskId,  String title,  String? description,  String categoryId,  String categoryPath,  List<String> categoryLabels,  DateTime nextDueAt,  DateTime? lastDoneAt,  String? lastDoneByUid,  String recurrenceType,  int? recurrenceValue,  String? recurrenceUnit,  int reminderDaysBefore,  String? groupId,  String? mainAssigneeUid,  List<String> assigneeUids,  int deferCount,  DateTime? originalDueAt,  DateTime? deferredAt,  String? deferredByUid,  DateTime? snoozeUntil,  String? notes,  double? cost,  String? costCurrency,  bool isArchived,  bool isLocalePreset,  String? presetLocale,  bool isGroupTask,  String createdByUid,  String updatedByUid,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _TaskEntity():
return $default(_that.taskId,_that.title,_that.description,_that.categoryId,_that.categoryPath,_that.categoryLabels,_that.nextDueAt,_that.lastDoneAt,_that.lastDoneByUid,_that.recurrenceType,_that.recurrenceValue,_that.recurrenceUnit,_that.reminderDaysBefore,_that.groupId,_that.mainAssigneeUid,_that.assigneeUids,_that.deferCount,_that.originalDueAt,_that.deferredAt,_that.deferredByUid,_that.snoozeUntil,_that.notes,_that.cost,_that.costCurrency,_that.isArchived,_that.isLocalePreset,_that.presetLocale,_that.isGroupTask,_that.createdByUid,_that.updatedByUid,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String taskId,  String title,  String? description,  String categoryId,  String categoryPath,  List<String> categoryLabels,  DateTime nextDueAt,  DateTime? lastDoneAt,  String? lastDoneByUid,  String recurrenceType,  int? recurrenceValue,  String? recurrenceUnit,  int reminderDaysBefore,  String? groupId,  String? mainAssigneeUid,  List<String> assigneeUids,  int deferCount,  DateTime? originalDueAt,  DateTime? deferredAt,  String? deferredByUid,  DateTime? snoozeUntil,  String? notes,  double? cost,  String? costCurrency,  bool isArchived,  bool isLocalePreset,  String? presetLocale,  bool isGroupTask,  String createdByUid,  String updatedByUid,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _TaskEntity() when $default != null:
return $default(_that.taskId,_that.title,_that.description,_that.categoryId,_that.categoryPath,_that.categoryLabels,_that.nextDueAt,_that.lastDoneAt,_that.lastDoneByUid,_that.recurrenceType,_that.recurrenceValue,_that.recurrenceUnit,_that.reminderDaysBefore,_that.groupId,_that.mainAssigneeUid,_that.assigneeUids,_that.deferCount,_that.originalDueAt,_that.deferredAt,_that.deferredByUid,_that.snoozeUntil,_that.notes,_that.cost,_that.costCurrency,_that.isArchived,_that.isLocalePreset,_that.presetLocale,_that.isGroupTask,_that.createdByUid,_that.updatedByUid,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskEntity implements TaskEntity {
  const _TaskEntity({required this.taskId, required this.title, this.description, required this.categoryId, required this.categoryPath, final  List<String> categoryLabels = const [], required this.nextDueAt, this.lastDoneAt, this.lastDoneByUid, this.recurrenceType = 'none', this.recurrenceValue, this.recurrenceUnit, this.reminderDaysBefore = 0, this.groupId, this.mainAssigneeUid, final  List<String> assigneeUids = const [], this.deferCount = 0, this.originalDueAt, this.deferredAt, this.deferredByUid, this.snoozeUntil, this.notes, this.cost, this.costCurrency, this.isArchived = false, this.isLocalePreset = false, this.presetLocale, this.isGroupTask = false, required this.createdByUid, required this.updatedByUid, required this.createdAt, required this.updatedAt}): _categoryLabels = categoryLabels,_assigneeUids = assigneeUids;
  factory _TaskEntity.fromJson(Map<String, dynamic> json) => _$TaskEntityFromJson(json);

@override final  String taskId;
@override final  String title;
@override final  String? description;
@override final  String categoryId;
@override final  String categoryPath;
 final  List<String> _categoryLabels;
@override@JsonKey() List<String> get categoryLabels {
  if (_categoryLabels is EqualUnmodifiableListView) return _categoryLabels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categoryLabels);
}

@override final  DateTime nextDueAt;
@override final  DateTime? lastDoneAt;
@override final  String? lastDoneByUid;
@override@JsonKey() final  String recurrenceType;
@override final  int? recurrenceValue;
@override final  String? recurrenceUnit;
@override@JsonKey() final  int reminderDaysBefore;
@override final  String? groupId;
@override final  String? mainAssigneeUid;
 final  List<String> _assigneeUids;
@override@JsonKey() List<String> get assigneeUids {
  if (_assigneeUids is EqualUnmodifiableListView) return _assigneeUids;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assigneeUids);
}

@override@JsonKey() final  int deferCount;
@override final  DateTime? originalDueAt;
@override final  DateTime? deferredAt;
@override final  String? deferredByUid;
@override final  DateTime? snoozeUntil;
@override final  String? notes;
@override final  double? cost;
@override final  String? costCurrency;
@override@JsonKey() final  bool isArchived;
@override@JsonKey() final  bool isLocalePreset;
@override final  String? presetLocale;
@override@JsonKey() final  bool isGroupTask;
@override final  String createdByUid;
@override final  String updatedByUid;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of TaskEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskEntityCopyWith<_TaskEntity> get copyWith => __$TaskEntityCopyWithImpl<_TaskEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskEntity&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryPath, categoryPath) || other.categoryPath == categoryPath)&&const DeepCollectionEquality().equals(other._categoryLabels, _categoryLabels)&&(identical(other.nextDueAt, nextDueAt) || other.nextDueAt == nextDueAt)&&(identical(other.lastDoneAt, lastDoneAt) || other.lastDoneAt == lastDoneAt)&&(identical(other.lastDoneByUid, lastDoneByUid) || other.lastDoneByUid == lastDoneByUid)&&(identical(other.recurrenceType, recurrenceType) || other.recurrenceType == recurrenceType)&&(identical(other.recurrenceValue, recurrenceValue) || other.recurrenceValue == recurrenceValue)&&(identical(other.recurrenceUnit, recurrenceUnit) || other.recurrenceUnit == recurrenceUnit)&&(identical(other.reminderDaysBefore, reminderDaysBefore) || other.reminderDaysBefore == reminderDaysBefore)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.mainAssigneeUid, mainAssigneeUid) || other.mainAssigneeUid == mainAssigneeUid)&&const DeepCollectionEquality().equals(other._assigneeUids, _assigneeUids)&&(identical(other.deferCount, deferCount) || other.deferCount == deferCount)&&(identical(other.originalDueAt, originalDueAt) || other.originalDueAt == originalDueAt)&&(identical(other.deferredAt, deferredAt) || other.deferredAt == deferredAt)&&(identical(other.deferredByUid, deferredByUid) || other.deferredByUid == deferredByUid)&&(identical(other.snoozeUntil, snoozeUntil) || other.snoozeUntil == snoozeUntil)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.costCurrency, costCurrency) || other.costCurrency == costCurrency)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.isLocalePreset, isLocalePreset) || other.isLocalePreset == isLocalePreset)&&(identical(other.presetLocale, presetLocale) || other.presetLocale == presetLocale)&&(identical(other.isGroupTask, isGroupTask) || other.isGroupTask == isGroupTask)&&(identical(other.createdByUid, createdByUid) || other.createdByUid == createdByUid)&&(identical(other.updatedByUid, updatedByUid) || other.updatedByUid == updatedByUid)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,taskId,title,description,categoryId,categoryPath,const DeepCollectionEquality().hash(_categoryLabels),nextDueAt,lastDoneAt,lastDoneByUid,recurrenceType,recurrenceValue,recurrenceUnit,reminderDaysBefore,groupId,mainAssigneeUid,const DeepCollectionEquality().hash(_assigneeUids),deferCount,originalDueAt,deferredAt,deferredByUid,snoozeUntil,notes,cost,costCurrency,isArchived,isLocalePreset,presetLocale,isGroupTask,createdByUid,updatedByUid,createdAt,updatedAt]);

@override
String toString() {
  return 'TaskEntity(taskId: $taskId, title: $title, description: $description, categoryId: $categoryId, categoryPath: $categoryPath, categoryLabels: $categoryLabels, nextDueAt: $nextDueAt, lastDoneAt: $lastDoneAt, lastDoneByUid: $lastDoneByUid, recurrenceType: $recurrenceType, recurrenceValue: $recurrenceValue, recurrenceUnit: $recurrenceUnit, reminderDaysBefore: $reminderDaysBefore, groupId: $groupId, mainAssigneeUid: $mainAssigneeUid, assigneeUids: $assigneeUids, deferCount: $deferCount, originalDueAt: $originalDueAt, deferredAt: $deferredAt, deferredByUid: $deferredByUid, snoozeUntil: $snoozeUntil, notes: $notes, cost: $cost, costCurrency: $costCurrency, isArchived: $isArchived, isLocalePreset: $isLocalePreset, presetLocale: $presetLocale, isGroupTask: $isGroupTask, createdByUid: $createdByUid, updatedByUid: $updatedByUid, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TaskEntityCopyWith<$Res> implements $TaskEntityCopyWith<$Res> {
  factory _$TaskEntityCopyWith(_TaskEntity value, $Res Function(_TaskEntity) _then) = __$TaskEntityCopyWithImpl;
@override @useResult
$Res call({
 String taskId, String title, String? description, String categoryId, String categoryPath, List<String> categoryLabels, DateTime nextDueAt, DateTime? lastDoneAt, String? lastDoneByUid, String recurrenceType, int? recurrenceValue, String? recurrenceUnit, int reminderDaysBefore, String? groupId, String? mainAssigneeUid, List<String> assigneeUids, int deferCount, DateTime? originalDueAt, DateTime? deferredAt, String? deferredByUid, DateTime? snoozeUntil, String? notes, double? cost, String? costCurrency, bool isArchived, bool isLocalePreset, String? presetLocale, bool isGroupTask, String createdByUid, String updatedByUid, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$TaskEntityCopyWithImpl<$Res>
    implements _$TaskEntityCopyWith<$Res> {
  __$TaskEntityCopyWithImpl(this._self, this._then);

  final _TaskEntity _self;
  final $Res Function(_TaskEntity) _then;

/// Create a copy of TaskEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskId = null,Object? title = null,Object? description = freezed,Object? categoryId = null,Object? categoryPath = null,Object? categoryLabels = null,Object? nextDueAt = null,Object? lastDoneAt = freezed,Object? lastDoneByUid = freezed,Object? recurrenceType = null,Object? recurrenceValue = freezed,Object? recurrenceUnit = freezed,Object? reminderDaysBefore = null,Object? groupId = freezed,Object? mainAssigneeUid = freezed,Object? assigneeUids = null,Object? deferCount = null,Object? originalDueAt = freezed,Object? deferredAt = freezed,Object? deferredByUid = freezed,Object? snoozeUntil = freezed,Object? notes = freezed,Object? cost = freezed,Object? costCurrency = freezed,Object? isArchived = null,Object? isLocalePreset = null,Object? presetLocale = freezed,Object? isGroupTask = null,Object? createdByUid = null,Object? updatedByUid = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_TaskEntity(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,categoryPath: null == categoryPath ? _self.categoryPath : categoryPath // ignore: cast_nullable_to_non_nullable
as String,categoryLabels: null == categoryLabels ? _self._categoryLabels : categoryLabels // ignore: cast_nullable_to_non_nullable
as List<String>,nextDueAt: null == nextDueAt ? _self.nextDueAt : nextDueAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastDoneAt: freezed == lastDoneAt ? _self.lastDoneAt : lastDoneAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastDoneByUid: freezed == lastDoneByUid ? _self.lastDoneByUid : lastDoneByUid // ignore: cast_nullable_to_non_nullable
as String?,recurrenceType: null == recurrenceType ? _self.recurrenceType : recurrenceType // ignore: cast_nullable_to_non_nullable
as String,recurrenceValue: freezed == recurrenceValue ? _self.recurrenceValue : recurrenceValue // ignore: cast_nullable_to_non_nullable
as int?,recurrenceUnit: freezed == recurrenceUnit ? _self.recurrenceUnit : recurrenceUnit // ignore: cast_nullable_to_non_nullable
as String?,reminderDaysBefore: null == reminderDaysBefore ? _self.reminderDaysBefore : reminderDaysBefore // ignore: cast_nullable_to_non_nullable
as int,groupId: freezed == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String?,mainAssigneeUid: freezed == mainAssigneeUid ? _self.mainAssigneeUid : mainAssigneeUid // ignore: cast_nullable_to_non_nullable
as String?,assigneeUids: null == assigneeUids ? _self._assigneeUids : assigneeUids // ignore: cast_nullable_to_non_nullable
as List<String>,deferCount: null == deferCount ? _self.deferCount : deferCount // ignore: cast_nullable_to_non_nullable
as int,originalDueAt: freezed == originalDueAt ? _self.originalDueAt : originalDueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deferredAt: freezed == deferredAt ? _self.deferredAt : deferredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deferredByUid: freezed == deferredByUid ? _self.deferredByUid : deferredByUid // ignore: cast_nullable_to_non_nullable
as String?,snoozeUntil: freezed == snoozeUntil ? _self.snoozeUntil : snoozeUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,cost: freezed == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as double?,costCurrency: freezed == costCurrency ? _self.costCurrency : costCurrency // ignore: cast_nullable_to_non_nullable
as String?,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,isLocalePreset: null == isLocalePreset ? _self.isLocalePreset : isLocalePreset // ignore: cast_nullable_to_non_nullable
as bool,presetLocale: freezed == presetLocale ? _self.presetLocale : presetLocale // ignore: cast_nullable_to_non_nullable
as String?,isGroupTask: null == isGroupTask ? _self.isGroupTask : isGroupTask // ignore: cast_nullable_to_non_nullable
as bool,createdByUid: null == createdByUid ? _self.createdByUid : createdByUid // ignore: cast_nullable_to_non_nullable
as String,updatedByUid: null == updatedByUid ? _self.updatedByUid : updatedByUid // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
