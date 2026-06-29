// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exclusion_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExclusionEntity {

 String get excludeId; String get itemId; String get itemType; String get itemName; String? get reason; DateTime get excludedAt; DateTime? get validUntil; bool get isTemporaryExclusion;
/// Create a copy of ExclusionEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExclusionEntityCopyWith<ExclusionEntity> get copyWith => _$ExclusionEntityCopyWithImpl<ExclusionEntity>(this as ExclusionEntity, _$identity);

  /// Serializes this ExclusionEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExclusionEntity&&(identical(other.excludeId, excludeId) || other.excludeId == excludeId)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.itemType, itemType) || other.itemType == itemType)&&(identical(other.itemName, itemName) || other.itemName == itemName)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.excludedAt, excludedAt) || other.excludedAt == excludedAt)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&(identical(other.isTemporaryExclusion, isTemporaryExclusion) || other.isTemporaryExclusion == isTemporaryExclusion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,excludeId,itemId,itemType,itemName,reason,excludedAt,validUntil,isTemporaryExclusion);

@override
String toString() {
  return 'ExclusionEntity(excludeId: $excludeId, itemId: $itemId, itemType: $itemType, itemName: $itemName, reason: $reason, excludedAt: $excludedAt, validUntil: $validUntil, isTemporaryExclusion: $isTemporaryExclusion)';
}


}

/// @nodoc
abstract mixin class $ExclusionEntityCopyWith<$Res>  {
  factory $ExclusionEntityCopyWith(ExclusionEntity value, $Res Function(ExclusionEntity) _then) = _$ExclusionEntityCopyWithImpl;
@useResult
$Res call({
 String excludeId, String itemId, String itemType, String itemName, String? reason, DateTime excludedAt, DateTime? validUntil, bool isTemporaryExclusion
});




}
/// @nodoc
class _$ExclusionEntityCopyWithImpl<$Res>
    implements $ExclusionEntityCopyWith<$Res> {
  _$ExclusionEntityCopyWithImpl(this._self, this._then);

  final ExclusionEntity _self;
  final $Res Function(ExclusionEntity) _then;

/// Create a copy of ExclusionEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? excludeId = null,Object? itemId = null,Object? itemType = null,Object? itemName = null,Object? reason = freezed,Object? excludedAt = null,Object? validUntil = freezed,Object? isTemporaryExclusion = null,}) {
  return _then(_self.copyWith(
excludeId: null == excludeId ? _self.excludeId : excludeId // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,itemType: null == itemType ? _self.itemType : itemType // ignore: cast_nullable_to_non_nullable
as String,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,excludedAt: null == excludedAt ? _self.excludedAt : excludedAt // ignore: cast_nullable_to_non_nullable
as DateTime,validUntil: freezed == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,isTemporaryExclusion: null == isTemporaryExclusion ? _self.isTemporaryExclusion : isTemporaryExclusion // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ExclusionEntity].
extension ExclusionEntityPatterns on ExclusionEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExclusionEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExclusionEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExclusionEntity value)  $default,){
final _that = this;
switch (_that) {
case _ExclusionEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExclusionEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ExclusionEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String excludeId,  String itemId,  String itemType,  String itemName,  String? reason,  DateTime excludedAt,  DateTime? validUntil,  bool isTemporaryExclusion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExclusionEntity() when $default != null:
return $default(_that.excludeId,_that.itemId,_that.itemType,_that.itemName,_that.reason,_that.excludedAt,_that.validUntil,_that.isTemporaryExclusion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String excludeId,  String itemId,  String itemType,  String itemName,  String? reason,  DateTime excludedAt,  DateTime? validUntil,  bool isTemporaryExclusion)  $default,) {final _that = this;
switch (_that) {
case _ExclusionEntity():
return $default(_that.excludeId,_that.itemId,_that.itemType,_that.itemName,_that.reason,_that.excludedAt,_that.validUntil,_that.isTemporaryExclusion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String excludeId,  String itemId,  String itemType,  String itemName,  String? reason,  DateTime excludedAt,  DateTime? validUntil,  bool isTemporaryExclusion)?  $default,) {final _that = this;
switch (_that) {
case _ExclusionEntity() when $default != null:
return $default(_that.excludeId,_that.itemId,_that.itemType,_that.itemName,_that.reason,_that.excludedAt,_that.validUntil,_that.isTemporaryExclusion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExclusionEntity implements ExclusionEntity {
  const _ExclusionEntity({required this.excludeId, required this.itemId, required this.itemType, required this.itemName, this.reason, required this.excludedAt, this.validUntil, this.isTemporaryExclusion = false});
  factory _ExclusionEntity.fromJson(Map<String, dynamic> json) => _$ExclusionEntityFromJson(json);

@override final  String excludeId;
@override final  String itemId;
@override final  String itemType;
@override final  String itemName;
@override final  String? reason;
@override final  DateTime excludedAt;
@override final  DateTime? validUntil;
@override@JsonKey() final  bool isTemporaryExclusion;

/// Create a copy of ExclusionEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExclusionEntityCopyWith<_ExclusionEntity> get copyWith => __$ExclusionEntityCopyWithImpl<_ExclusionEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExclusionEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExclusionEntity&&(identical(other.excludeId, excludeId) || other.excludeId == excludeId)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.itemType, itemType) || other.itemType == itemType)&&(identical(other.itemName, itemName) || other.itemName == itemName)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.excludedAt, excludedAt) || other.excludedAt == excludedAt)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&(identical(other.isTemporaryExclusion, isTemporaryExclusion) || other.isTemporaryExclusion == isTemporaryExclusion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,excludeId,itemId,itemType,itemName,reason,excludedAt,validUntil,isTemporaryExclusion);

@override
String toString() {
  return 'ExclusionEntity(excludeId: $excludeId, itemId: $itemId, itemType: $itemType, itemName: $itemName, reason: $reason, excludedAt: $excludedAt, validUntil: $validUntil, isTemporaryExclusion: $isTemporaryExclusion)';
}


}

/// @nodoc
abstract mixin class _$ExclusionEntityCopyWith<$Res> implements $ExclusionEntityCopyWith<$Res> {
  factory _$ExclusionEntityCopyWith(_ExclusionEntity value, $Res Function(_ExclusionEntity) _then) = __$ExclusionEntityCopyWithImpl;
@override @useResult
$Res call({
 String excludeId, String itemId, String itemType, String itemName, String? reason, DateTime excludedAt, DateTime? validUntil, bool isTemporaryExclusion
});




}
/// @nodoc
class __$ExclusionEntityCopyWithImpl<$Res>
    implements _$ExclusionEntityCopyWith<$Res> {
  __$ExclusionEntityCopyWithImpl(this._self, this._then);

  final _ExclusionEntity _self;
  final $Res Function(_ExclusionEntity) _then;

/// Create a copy of ExclusionEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? excludeId = null,Object? itemId = null,Object? itemType = null,Object? itemName = null,Object? reason = freezed,Object? excludedAt = null,Object? validUntil = freezed,Object? isTemporaryExclusion = null,}) {
  return _then(_ExclusionEntity(
excludeId: null == excludeId ? _self.excludeId : excludeId // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,itemType: null == itemType ? _self.itemType : itemType // ignore: cast_nullable_to_non_nullable
as String,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,excludedAt: null == excludedAt ? _self.excludedAt : excludedAt // ignore: cast_nullable_to_non_nullable
as DateTime,validUntil: freezed == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,isTemporaryExclusion: null == isTemporaryExclusion ? _self.isTemporaryExclusion : isTemporaryExclusion // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
