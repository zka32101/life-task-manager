// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invitation_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InvitationEntity {

 String get invitationId; String get groupId; String get inviteeEmail; String get invitedByUid; String get invitedByName; String get status; String get invitationCode; DateTime get expiresAt; DateTime? get acceptedAt; String? get acceptedByUid; DateTime get createdAt;
/// Create a copy of InvitationEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvitationEntityCopyWith<InvitationEntity> get copyWith => _$InvitationEntityCopyWithImpl<InvitationEntity>(this as InvitationEntity, _$identity);

  /// Serializes this InvitationEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvitationEntity&&(identical(other.invitationId, invitationId) || other.invitationId == invitationId)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.inviteeEmail, inviteeEmail) || other.inviteeEmail == inviteeEmail)&&(identical(other.invitedByUid, invitedByUid) || other.invitedByUid == invitedByUid)&&(identical(other.invitedByName, invitedByName) || other.invitedByName == invitedByName)&&(identical(other.status, status) || other.status == status)&&(identical(other.invitationCode, invitationCode) || other.invitationCode == invitationCode)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt)&&(identical(other.acceptedByUid, acceptedByUid) || other.acceptedByUid == acceptedByUid)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,invitationId,groupId,inviteeEmail,invitedByUid,invitedByName,status,invitationCode,expiresAt,acceptedAt,acceptedByUid,createdAt);

@override
String toString() {
  return 'InvitationEntity(invitationId: $invitationId, groupId: $groupId, inviteeEmail: $inviteeEmail, invitedByUid: $invitedByUid, invitedByName: $invitedByName, status: $status, invitationCode: $invitationCode, expiresAt: $expiresAt, acceptedAt: $acceptedAt, acceptedByUid: $acceptedByUid, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $InvitationEntityCopyWith<$Res>  {
  factory $InvitationEntityCopyWith(InvitationEntity value, $Res Function(InvitationEntity) _then) = _$InvitationEntityCopyWithImpl;
@useResult
$Res call({
 String invitationId, String groupId, String inviteeEmail, String invitedByUid, String invitedByName, String status, String invitationCode, DateTime expiresAt, DateTime? acceptedAt, String? acceptedByUid, DateTime createdAt
});




}
/// @nodoc
class _$InvitationEntityCopyWithImpl<$Res>
    implements $InvitationEntityCopyWith<$Res> {
  _$InvitationEntityCopyWithImpl(this._self, this._then);

  final InvitationEntity _self;
  final $Res Function(InvitationEntity) _then;

/// Create a copy of InvitationEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? invitationId = null,Object? groupId = null,Object? inviteeEmail = null,Object? invitedByUid = null,Object? invitedByName = null,Object? status = null,Object? invitationCode = null,Object? expiresAt = null,Object? acceptedAt = freezed,Object? acceptedByUid = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
invitationId: null == invitationId ? _self.invitationId : invitationId // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,inviteeEmail: null == inviteeEmail ? _self.inviteeEmail : inviteeEmail // ignore: cast_nullable_to_non_nullable
as String,invitedByUid: null == invitedByUid ? _self.invitedByUid : invitedByUid // ignore: cast_nullable_to_non_nullable
as String,invitedByName: null == invitedByName ? _self.invitedByName : invitedByName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,invitationCode: null == invitationCode ? _self.invitationCode : invitationCode // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,acceptedAt: freezed == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,acceptedByUid: freezed == acceptedByUid ? _self.acceptedByUid : acceptedByUid // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [InvitationEntity].
extension InvitationEntityPatterns on InvitationEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvitationEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvitationEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvitationEntity value)  $default,){
final _that = this;
switch (_that) {
case _InvitationEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvitationEntity value)?  $default,){
final _that = this;
switch (_that) {
case _InvitationEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String invitationId,  String groupId,  String inviteeEmail,  String invitedByUid,  String invitedByName,  String status,  String invitationCode,  DateTime expiresAt,  DateTime? acceptedAt,  String? acceptedByUid,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvitationEntity() when $default != null:
return $default(_that.invitationId,_that.groupId,_that.inviteeEmail,_that.invitedByUid,_that.invitedByName,_that.status,_that.invitationCode,_that.expiresAt,_that.acceptedAt,_that.acceptedByUid,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String invitationId,  String groupId,  String inviteeEmail,  String invitedByUid,  String invitedByName,  String status,  String invitationCode,  DateTime expiresAt,  DateTime? acceptedAt,  String? acceptedByUid,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _InvitationEntity():
return $default(_that.invitationId,_that.groupId,_that.inviteeEmail,_that.invitedByUid,_that.invitedByName,_that.status,_that.invitationCode,_that.expiresAt,_that.acceptedAt,_that.acceptedByUid,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String invitationId,  String groupId,  String inviteeEmail,  String invitedByUid,  String invitedByName,  String status,  String invitationCode,  DateTime expiresAt,  DateTime? acceptedAt,  String? acceptedByUid,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _InvitationEntity() when $default != null:
return $default(_that.invitationId,_that.groupId,_that.inviteeEmail,_that.invitedByUid,_that.invitedByName,_that.status,_that.invitationCode,_that.expiresAt,_that.acceptedAt,_that.acceptedByUid,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InvitationEntity implements InvitationEntity {
  const _InvitationEntity({required this.invitationId, required this.groupId, required this.inviteeEmail, required this.invitedByUid, required this.invitedByName, this.status = 'pending', required this.invitationCode, required this.expiresAt, this.acceptedAt, this.acceptedByUid, required this.createdAt});
  factory _InvitationEntity.fromJson(Map<String, dynamic> json) => _$InvitationEntityFromJson(json);

@override final  String invitationId;
@override final  String groupId;
@override final  String inviteeEmail;
@override final  String invitedByUid;
@override final  String invitedByName;
@override@JsonKey() final  String status;
@override final  String invitationCode;
@override final  DateTime expiresAt;
@override final  DateTime? acceptedAt;
@override final  String? acceptedByUid;
@override final  DateTime createdAt;

/// Create a copy of InvitationEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvitationEntityCopyWith<_InvitationEntity> get copyWith => __$InvitationEntityCopyWithImpl<_InvitationEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvitationEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvitationEntity&&(identical(other.invitationId, invitationId) || other.invitationId == invitationId)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.inviteeEmail, inviteeEmail) || other.inviteeEmail == inviteeEmail)&&(identical(other.invitedByUid, invitedByUid) || other.invitedByUid == invitedByUid)&&(identical(other.invitedByName, invitedByName) || other.invitedByName == invitedByName)&&(identical(other.status, status) || other.status == status)&&(identical(other.invitationCode, invitationCode) || other.invitationCode == invitationCode)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt)&&(identical(other.acceptedByUid, acceptedByUid) || other.acceptedByUid == acceptedByUid)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,invitationId,groupId,inviteeEmail,invitedByUid,invitedByName,status,invitationCode,expiresAt,acceptedAt,acceptedByUid,createdAt);

@override
String toString() {
  return 'InvitationEntity(invitationId: $invitationId, groupId: $groupId, inviteeEmail: $inviteeEmail, invitedByUid: $invitedByUid, invitedByName: $invitedByName, status: $status, invitationCode: $invitationCode, expiresAt: $expiresAt, acceptedAt: $acceptedAt, acceptedByUid: $acceptedByUid, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$InvitationEntityCopyWith<$Res> implements $InvitationEntityCopyWith<$Res> {
  factory _$InvitationEntityCopyWith(_InvitationEntity value, $Res Function(_InvitationEntity) _then) = __$InvitationEntityCopyWithImpl;
@override @useResult
$Res call({
 String invitationId, String groupId, String inviteeEmail, String invitedByUid, String invitedByName, String status, String invitationCode, DateTime expiresAt, DateTime? acceptedAt, String? acceptedByUid, DateTime createdAt
});




}
/// @nodoc
class __$InvitationEntityCopyWithImpl<$Res>
    implements _$InvitationEntityCopyWith<$Res> {
  __$InvitationEntityCopyWithImpl(this._self, this._then);

  final _InvitationEntity _self;
  final $Res Function(_InvitationEntity) _then;

/// Create a copy of InvitationEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? invitationId = null,Object? groupId = null,Object? inviteeEmail = null,Object? invitedByUid = null,Object? invitedByName = null,Object? status = null,Object? invitationCode = null,Object? expiresAt = null,Object? acceptedAt = freezed,Object? acceptedByUid = freezed,Object? createdAt = null,}) {
  return _then(_InvitationEntity(
invitationId: null == invitationId ? _self.invitationId : invitationId // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,inviteeEmail: null == inviteeEmail ? _self.inviteeEmail : inviteeEmail // ignore: cast_nullable_to_non_nullable
as String,invitedByUid: null == invitedByUid ? _self.invitedByUid : invitedByUid // ignore: cast_nullable_to_non_nullable
as String,invitedByName: null == invitedByName ? _self.invitedByName : invitedByName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,invitationCode: null == invitationCode ? _self.invitationCode : invitationCode // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,acceptedAt: freezed == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,acceptedByUid: freezed == acceptedByUid ? _self.acceptedByUid : acceptedByUid // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
