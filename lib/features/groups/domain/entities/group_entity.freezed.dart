// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroupEntity {

 String get groupId; String get name; String get ownerUid; List<String> get memberUids; int get memberCount; int get taskCount; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of GroupEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupEntityCopyWith<GroupEntity> get copyWith => _$GroupEntityCopyWithImpl<GroupEntity>(this as GroupEntity, _$identity);

  /// Serializes this GroupEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupEntity&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerUid, ownerUid) || other.ownerUid == ownerUid)&&const DeepCollectionEquality().equals(other.memberUids, memberUids)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.taskCount, taskCount) || other.taskCount == taskCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,groupId,name,ownerUid,const DeepCollectionEquality().hash(memberUids),memberCount,taskCount,createdAt,updatedAt);

@override
String toString() {
  return 'GroupEntity(groupId: $groupId, name: $name, ownerUid: $ownerUid, memberUids: $memberUids, memberCount: $memberCount, taskCount: $taskCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $GroupEntityCopyWith<$Res>  {
  factory $GroupEntityCopyWith(GroupEntity value, $Res Function(GroupEntity) _then) = _$GroupEntityCopyWithImpl;
@useResult
$Res call({
 String groupId, String name, String ownerUid, List<String> memberUids, int memberCount, int taskCount, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$GroupEntityCopyWithImpl<$Res>
    implements $GroupEntityCopyWith<$Res> {
  _$GroupEntityCopyWithImpl(this._self, this._then);

  final GroupEntity _self;
  final $Res Function(GroupEntity) _then;

/// Create a copy of GroupEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groupId = null,Object? name = null,Object? ownerUid = null,Object? memberUids = null,Object? memberCount = null,Object? taskCount = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerUid: null == ownerUid ? _self.ownerUid : ownerUid // ignore: cast_nullable_to_non_nullable
as String,memberUids: null == memberUids ? _self.memberUids : memberUids // ignore: cast_nullable_to_non_nullable
as List<String>,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,taskCount: null == taskCount ? _self.taskCount : taskCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupEntity].
extension GroupEntityPatterns on GroupEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupEntity value)  $default,){
final _that = this;
switch (_that) {
case _GroupEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupEntity value)?  $default,){
final _that = this;
switch (_that) {
case _GroupEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String groupId,  String name,  String ownerUid,  List<String> memberUids,  int memberCount,  int taskCount,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupEntity() when $default != null:
return $default(_that.groupId,_that.name,_that.ownerUid,_that.memberUids,_that.memberCount,_that.taskCount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String groupId,  String name,  String ownerUid,  List<String> memberUids,  int memberCount,  int taskCount,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _GroupEntity():
return $default(_that.groupId,_that.name,_that.ownerUid,_that.memberUids,_that.memberCount,_that.taskCount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String groupId,  String name,  String ownerUid,  List<String> memberUids,  int memberCount,  int taskCount,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _GroupEntity() when $default != null:
return $default(_that.groupId,_that.name,_that.ownerUid,_that.memberUids,_that.memberCount,_that.taskCount,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GroupEntity implements GroupEntity {
  const _GroupEntity({required this.groupId, required this.name, required this.ownerUid, final  List<String> memberUids = const [], this.memberCount = 0, this.taskCount = 0, required this.createdAt, required this.updatedAt}): _memberUids = memberUids;
  factory _GroupEntity.fromJson(Map<String, dynamic> json) => _$GroupEntityFromJson(json);

@override final  String groupId;
@override final  String name;
@override final  String ownerUid;
 final  List<String> _memberUids;
@override@JsonKey() List<String> get memberUids {
  if (_memberUids is EqualUnmodifiableListView) return _memberUids;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_memberUids);
}

@override@JsonKey() final  int memberCount;
@override@JsonKey() final  int taskCount;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of GroupEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupEntityCopyWith<_GroupEntity> get copyWith => __$GroupEntityCopyWithImpl<_GroupEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupEntity&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerUid, ownerUid) || other.ownerUid == ownerUid)&&const DeepCollectionEquality().equals(other._memberUids, _memberUids)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.taskCount, taskCount) || other.taskCount == taskCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,groupId,name,ownerUid,const DeepCollectionEquality().hash(_memberUids),memberCount,taskCount,createdAt,updatedAt);

@override
String toString() {
  return 'GroupEntity(groupId: $groupId, name: $name, ownerUid: $ownerUid, memberUids: $memberUids, memberCount: $memberCount, taskCount: $taskCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$GroupEntityCopyWith<$Res> implements $GroupEntityCopyWith<$Res> {
  factory _$GroupEntityCopyWith(_GroupEntity value, $Res Function(_GroupEntity) _then) = __$GroupEntityCopyWithImpl;
@override @useResult
$Res call({
 String groupId, String name, String ownerUid, List<String> memberUids, int memberCount, int taskCount, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$GroupEntityCopyWithImpl<$Res>
    implements _$GroupEntityCopyWith<$Res> {
  __$GroupEntityCopyWithImpl(this._self, this._then);

  final _GroupEntity _self;
  final $Res Function(_GroupEntity) _then;

/// Create a copy of GroupEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groupId = null,Object? name = null,Object? ownerUid = null,Object? memberUids = null,Object? memberCount = null,Object? taskCount = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_GroupEntity(
groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerUid: null == ownerUid ? _self.ownerUid : ownerUid // ignore: cast_nullable_to_non_nullable
as String,memberUids: null == memberUids ? _self._memberUids : memberUids // ignore: cast_nullable_to_non_nullable
as List<String>,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,taskCount: null == taskCount ? _self.taskCount : taskCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
