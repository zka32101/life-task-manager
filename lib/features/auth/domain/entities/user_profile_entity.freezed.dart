// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfileEntity {

 String get uid; String get displayName; String get email; String? get photoUrl; String get language; String get country; String get timezone; bool get isPaid; String? get purchaseType; DateTime get trialStartAt; DateTime? get purchasedAt; String? get invitedByGroupId; String? get iapPlatform; String? get iapTransactionId; DateTime get lastActiveAt; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of UserProfileEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileEntityCopyWith<UserProfileEntity> get copyWith => _$UserProfileEntityCopyWithImpl<UserProfileEntity>(this as UserProfileEntity, _$identity);

  /// Serializes this UserProfileEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfileEntity&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.language, language) || other.language == language)&&(identical(other.country, country) || other.country == country)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.purchaseType, purchaseType) || other.purchaseType == purchaseType)&&(identical(other.trialStartAt, trialStartAt) || other.trialStartAt == trialStartAt)&&(identical(other.purchasedAt, purchasedAt) || other.purchasedAt == purchasedAt)&&(identical(other.invitedByGroupId, invitedByGroupId) || other.invitedByGroupId == invitedByGroupId)&&(identical(other.iapPlatform, iapPlatform) || other.iapPlatform == iapPlatform)&&(identical(other.iapTransactionId, iapTransactionId) || other.iapTransactionId == iapTransactionId)&&(identical(other.lastActiveAt, lastActiveAt) || other.lastActiveAt == lastActiveAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,displayName,email,photoUrl,language,country,timezone,isPaid,purchaseType,trialStartAt,purchasedAt,invitedByGroupId,iapPlatform,iapTransactionId,lastActiveAt,createdAt,updatedAt);

@override
String toString() {
  return 'UserProfileEntity(uid: $uid, displayName: $displayName, email: $email, photoUrl: $photoUrl, language: $language, country: $country, timezone: $timezone, isPaid: $isPaid, purchaseType: $purchaseType, trialStartAt: $trialStartAt, purchasedAt: $purchasedAt, invitedByGroupId: $invitedByGroupId, iapPlatform: $iapPlatform, iapTransactionId: $iapTransactionId, lastActiveAt: $lastActiveAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $UserProfileEntityCopyWith<$Res>  {
  factory $UserProfileEntityCopyWith(UserProfileEntity value, $Res Function(UserProfileEntity) _then) = _$UserProfileEntityCopyWithImpl;
@useResult
$Res call({
 String uid, String displayName, String email, String? photoUrl, String language, String country, String timezone, bool isPaid, String? purchaseType, DateTime trialStartAt, DateTime? purchasedAt, String? invitedByGroupId, String? iapPlatform, String? iapTransactionId, DateTime lastActiveAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$UserProfileEntityCopyWithImpl<$Res>
    implements $UserProfileEntityCopyWith<$Res> {
  _$UserProfileEntityCopyWithImpl(this._self, this._then);

  final UserProfileEntity _self;
  final $Res Function(UserProfileEntity) _then;

/// Create a copy of UserProfileEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? displayName = null,Object? email = null,Object? photoUrl = freezed,Object? language = null,Object? country = null,Object? timezone = null,Object? isPaid = null,Object? purchaseType = freezed,Object? trialStartAt = null,Object? purchasedAt = freezed,Object? invitedByGroupId = freezed,Object? iapPlatform = freezed,Object? iapTransactionId = freezed,Object? lastActiveAt = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,purchaseType: freezed == purchaseType ? _self.purchaseType : purchaseType // ignore: cast_nullable_to_non_nullable
as String?,trialStartAt: null == trialStartAt ? _self.trialStartAt : trialStartAt // ignore: cast_nullable_to_non_nullable
as DateTime,purchasedAt: freezed == purchasedAt ? _self.purchasedAt : purchasedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,invitedByGroupId: freezed == invitedByGroupId ? _self.invitedByGroupId : invitedByGroupId // ignore: cast_nullable_to_non_nullable
as String?,iapPlatform: freezed == iapPlatform ? _self.iapPlatform : iapPlatform // ignore: cast_nullable_to_non_nullable
as String?,iapTransactionId: freezed == iapTransactionId ? _self.iapTransactionId : iapTransactionId // ignore: cast_nullable_to_non_nullable
as String?,lastActiveAt: null == lastActiveAt ? _self.lastActiveAt : lastActiveAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfileEntity].
extension UserProfileEntityPatterns on UserProfileEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfileEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfileEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfileEntity value)  $default,){
final _that = this;
switch (_that) {
case _UserProfileEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfileEntity value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfileEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String displayName,  String email,  String? photoUrl,  String language,  String country,  String timezone,  bool isPaid,  String? purchaseType,  DateTime trialStartAt,  DateTime? purchasedAt,  String? invitedByGroupId,  String? iapPlatform,  String? iapTransactionId,  DateTime lastActiveAt,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfileEntity() when $default != null:
return $default(_that.uid,_that.displayName,_that.email,_that.photoUrl,_that.language,_that.country,_that.timezone,_that.isPaid,_that.purchaseType,_that.trialStartAt,_that.purchasedAt,_that.invitedByGroupId,_that.iapPlatform,_that.iapTransactionId,_that.lastActiveAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String displayName,  String email,  String? photoUrl,  String language,  String country,  String timezone,  bool isPaid,  String? purchaseType,  DateTime trialStartAt,  DateTime? purchasedAt,  String? invitedByGroupId,  String? iapPlatform,  String? iapTransactionId,  DateTime lastActiveAt,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _UserProfileEntity():
return $default(_that.uid,_that.displayName,_that.email,_that.photoUrl,_that.language,_that.country,_that.timezone,_that.isPaid,_that.purchaseType,_that.trialStartAt,_that.purchasedAt,_that.invitedByGroupId,_that.iapPlatform,_that.iapTransactionId,_that.lastActiveAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String displayName,  String email,  String? photoUrl,  String language,  String country,  String timezone,  bool isPaid,  String? purchaseType,  DateTime trialStartAt,  DateTime? purchasedAt,  String? invitedByGroupId,  String? iapPlatform,  String? iapTransactionId,  DateTime lastActiveAt,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserProfileEntity() when $default != null:
return $default(_that.uid,_that.displayName,_that.email,_that.photoUrl,_that.language,_that.country,_that.timezone,_that.isPaid,_that.purchaseType,_that.trialStartAt,_that.purchasedAt,_that.invitedByGroupId,_that.iapPlatform,_that.iapTransactionId,_that.lastActiveAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfileEntity implements UserProfileEntity {
  const _UserProfileEntity({required this.uid, required this.displayName, required this.email, this.photoUrl, this.language = 'ja', this.country = 'JP', this.timezone = 'Asia/Tokyo', this.isPaid = false, this.purchaseType, required this.trialStartAt, this.purchasedAt, this.invitedByGroupId, this.iapPlatform, this.iapTransactionId, required this.lastActiveAt, required this.createdAt, required this.updatedAt});
  factory _UserProfileEntity.fromJson(Map<String, dynamic> json) => _$UserProfileEntityFromJson(json);

@override final  String uid;
@override final  String displayName;
@override final  String email;
@override final  String? photoUrl;
@override@JsonKey() final  String language;
@override@JsonKey() final  String country;
@override@JsonKey() final  String timezone;
@override@JsonKey() final  bool isPaid;
@override final  String? purchaseType;
@override final  DateTime trialStartAt;
@override final  DateTime? purchasedAt;
@override final  String? invitedByGroupId;
@override final  String? iapPlatform;
@override final  String? iapTransactionId;
@override final  DateTime lastActiveAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of UserProfileEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileEntityCopyWith<_UserProfileEntity> get copyWith => __$UserProfileEntityCopyWithImpl<_UserProfileEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfileEntity&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.language, language) || other.language == language)&&(identical(other.country, country) || other.country == country)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.purchaseType, purchaseType) || other.purchaseType == purchaseType)&&(identical(other.trialStartAt, trialStartAt) || other.trialStartAt == trialStartAt)&&(identical(other.purchasedAt, purchasedAt) || other.purchasedAt == purchasedAt)&&(identical(other.invitedByGroupId, invitedByGroupId) || other.invitedByGroupId == invitedByGroupId)&&(identical(other.iapPlatform, iapPlatform) || other.iapPlatform == iapPlatform)&&(identical(other.iapTransactionId, iapTransactionId) || other.iapTransactionId == iapTransactionId)&&(identical(other.lastActiveAt, lastActiveAt) || other.lastActiveAt == lastActiveAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,displayName,email,photoUrl,language,country,timezone,isPaid,purchaseType,trialStartAt,purchasedAt,invitedByGroupId,iapPlatform,iapTransactionId,lastActiveAt,createdAt,updatedAt);

@override
String toString() {
  return 'UserProfileEntity(uid: $uid, displayName: $displayName, email: $email, photoUrl: $photoUrl, language: $language, country: $country, timezone: $timezone, isPaid: $isPaid, purchaseType: $purchaseType, trialStartAt: $trialStartAt, purchasedAt: $purchasedAt, invitedByGroupId: $invitedByGroupId, iapPlatform: $iapPlatform, iapTransactionId: $iapTransactionId, lastActiveAt: $lastActiveAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserProfileEntityCopyWith<$Res> implements $UserProfileEntityCopyWith<$Res> {
  factory _$UserProfileEntityCopyWith(_UserProfileEntity value, $Res Function(_UserProfileEntity) _then) = __$UserProfileEntityCopyWithImpl;
@override @useResult
$Res call({
 String uid, String displayName, String email, String? photoUrl, String language, String country, String timezone, bool isPaid, String? purchaseType, DateTime trialStartAt, DateTime? purchasedAt, String? invitedByGroupId, String? iapPlatform, String? iapTransactionId, DateTime lastActiveAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$UserProfileEntityCopyWithImpl<$Res>
    implements _$UserProfileEntityCopyWith<$Res> {
  __$UserProfileEntityCopyWithImpl(this._self, this._then);

  final _UserProfileEntity _self;
  final $Res Function(_UserProfileEntity) _then;

/// Create a copy of UserProfileEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? displayName = null,Object? email = null,Object? photoUrl = freezed,Object? language = null,Object? country = null,Object? timezone = null,Object? isPaid = null,Object? purchaseType = freezed,Object? trialStartAt = null,Object? purchasedAt = freezed,Object? invitedByGroupId = freezed,Object? iapPlatform = freezed,Object? iapTransactionId = freezed,Object? lastActiveAt = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_UserProfileEntity(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,purchaseType: freezed == purchaseType ? _self.purchaseType : purchaseType // ignore: cast_nullable_to_non_nullable
as String?,trialStartAt: null == trialStartAt ? _self.trialStartAt : trialStartAt // ignore: cast_nullable_to_non_nullable
as DateTime,purchasedAt: freezed == purchasedAt ? _self.purchasedAt : purchasedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,invitedByGroupId: freezed == invitedByGroupId ? _self.invitedByGroupId : invitedByGroupId // ignore: cast_nullable_to_non_nullable
as String?,iapPlatform: freezed == iapPlatform ? _self.iapPlatform : iapPlatform // ignore: cast_nullable_to_non_nullable
as String?,iapTransactionId: freezed == iapTransactionId ? _self.iapTransactionId : iapTransactionId // ignore: cast_nullable_to_non_nullable
as String?,lastActiveAt: null == lastActiveAt ? _self.lastActiveAt : lastActiveAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
