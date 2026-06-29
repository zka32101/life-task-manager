// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_member_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroupMemberEntity {

 String get uid; String get displayName; String get email; String? get photoUrl; String get role; DateTime get joinedAt; String get status;
/// Create a copy of GroupMemberEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupMemberEntityCopyWith<GroupMemberEntity> get copyWith => _$GroupMemberEntityCopyWithImpl<GroupMemberEntity>(this as GroupMemberEntity, _$identity);

  /// Serializes this GroupMemberEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupMemberEntity&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.role, role) || other.role == role)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,displayName,email,photoUrl,role,joinedAt,status);

@override
String toString() {
  return 'GroupMemberEntity(uid: $uid, displayName: $displayName, email: $email, photoUrl: $photoUrl, role: $role, joinedAt: $joinedAt, status: $status)';
}


}

/// @nodoc
abstract mixin class $GroupMemberEntityCopyWith<$Res>  {
  factory $GroupMemberEntityCopyWith(GroupMemberEntity value, $Res Function(GroupMemberEntity) _then) = _$GroupMemberEntityCopyWithImpl;
@useResult
$Res call({
 String uid, String displayName, String email, String? photoUrl, String role, DateTime joinedAt, String status
});




}
/// @nodoc
class _$GroupMemberEntityCopyWithImpl<$Res>
    implements $GroupMemberEntityCopyWith<$Res> {
  _$GroupMemberEntityCopyWithImpl(this._self, this._then);

  final GroupMemberEntity _self;
  final $Res Function(GroupMemberEntity) _then;

/// Create a copy of GroupMemberEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? displayName = null,Object? email = null,Object? photoUrl = freezed,Object? role = null,Object? joinedAt = null,Object? status = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupMemberEntity].
extension GroupMemberEntityPatterns on GroupMemberEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupMemberEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupMemberEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupMemberEntity value)  $default,){
final _that = this;
switch (_that) {
case _GroupMemberEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupMemberEntity value)?  $default,){
final _that = this;
switch (_that) {
case _GroupMemberEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String displayName,  String email,  String? photoUrl,  String role,  DateTime joinedAt,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupMemberEntity() when $default != null:
return $default(_that.uid,_that.displayName,_that.email,_that.photoUrl,_that.role,_that.joinedAt,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String displayName,  String email,  String? photoUrl,  String role,  DateTime joinedAt,  String status)  $default,) {final _that = this;
switch (_that) {
case _GroupMemberEntity():
return $default(_that.uid,_that.displayName,_that.email,_that.photoUrl,_that.role,_that.joinedAt,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String displayName,  String email,  String? photoUrl,  String role,  DateTime joinedAt,  String status)?  $default,) {final _that = this;
switch (_that) {
case _GroupMemberEntity() when $default != null:
return $default(_that.uid,_that.displayName,_that.email,_that.photoUrl,_that.role,_that.joinedAt,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GroupMemberEntity implements GroupMemberEntity {
  const _GroupMemberEntity({required this.uid, required this.displayName, required this.email, this.photoUrl, this.role = 'member', required this.joinedAt, this.status = 'active'});
  factory _GroupMemberEntity.fromJson(Map<String, dynamic> json) => _$GroupMemberEntityFromJson(json);

@override final  String uid;
@override final  String displayName;
@override final  String email;
@override final  String? photoUrl;
@override@JsonKey() final  String role;
@override final  DateTime joinedAt;
@override@JsonKey() final  String status;

/// Create a copy of GroupMemberEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupMemberEntityCopyWith<_GroupMemberEntity> get copyWith => __$GroupMemberEntityCopyWithImpl<_GroupMemberEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupMemberEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupMemberEntity&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.role, role) || other.role == role)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,displayName,email,photoUrl,role,joinedAt,status);

@override
String toString() {
  return 'GroupMemberEntity(uid: $uid, displayName: $displayName, email: $email, photoUrl: $photoUrl, role: $role, joinedAt: $joinedAt, status: $status)';
}


}

/// @nodoc
abstract mixin class _$GroupMemberEntityCopyWith<$Res> implements $GroupMemberEntityCopyWith<$Res> {
  factory _$GroupMemberEntityCopyWith(_GroupMemberEntity value, $Res Function(_GroupMemberEntity) _then) = __$GroupMemberEntityCopyWithImpl;
@override @useResult
$Res call({
 String uid, String displayName, String email, String? photoUrl, String role, DateTime joinedAt, String status
});




}
/// @nodoc
class __$GroupMemberEntityCopyWithImpl<$Res>
    implements _$GroupMemberEntityCopyWith<$Res> {
  __$GroupMemberEntityCopyWithImpl(this._self, this._then);

  final _GroupMemberEntity _self;
  final $Res Function(_GroupMemberEntity) _then;

/// Create a copy of GroupMemberEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? displayName = null,Object? email = null,Object? photoUrl = freezed,Object? role = null,Object? joinedAt = null,Object? status = null,}) {
  return _then(_GroupMemberEntity(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
