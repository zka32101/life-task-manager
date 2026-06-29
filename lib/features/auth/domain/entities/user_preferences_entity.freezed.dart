// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_preferences_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserPreferencesEntity {

 bool get darkMode; bool get notificationEnabled; bool get emailNotificationEnabled; List<int> get reminderLayers; int get defaultReminder; bool get soundEnabled; bool get vibrationEnabled; String? get fcmToken; DateTime? get fcmTokenUpdatedAt;
/// Create a copy of UserPreferencesEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserPreferencesEntityCopyWith<UserPreferencesEntity> get copyWith => _$UserPreferencesEntityCopyWithImpl<UserPreferencesEntity>(this as UserPreferencesEntity, _$identity);

  /// Serializes this UserPreferencesEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserPreferencesEntity&&(identical(other.darkMode, darkMode) || other.darkMode == darkMode)&&(identical(other.notificationEnabled, notificationEnabled) || other.notificationEnabled == notificationEnabled)&&(identical(other.emailNotificationEnabled, emailNotificationEnabled) || other.emailNotificationEnabled == emailNotificationEnabled)&&const DeepCollectionEquality().equals(other.reminderLayers, reminderLayers)&&(identical(other.defaultReminder, defaultReminder) || other.defaultReminder == defaultReminder)&&(identical(other.soundEnabled, soundEnabled) || other.soundEnabled == soundEnabled)&&(identical(other.vibrationEnabled, vibrationEnabled) || other.vibrationEnabled == vibrationEnabled)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.fcmTokenUpdatedAt, fcmTokenUpdatedAt) || other.fcmTokenUpdatedAt == fcmTokenUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,darkMode,notificationEnabled,emailNotificationEnabled,const DeepCollectionEquality().hash(reminderLayers),defaultReminder,soundEnabled,vibrationEnabled,fcmToken,fcmTokenUpdatedAt);

@override
String toString() {
  return 'UserPreferencesEntity(darkMode: $darkMode, notificationEnabled: $notificationEnabled, emailNotificationEnabled: $emailNotificationEnabled, reminderLayers: $reminderLayers, defaultReminder: $defaultReminder, soundEnabled: $soundEnabled, vibrationEnabled: $vibrationEnabled, fcmToken: $fcmToken, fcmTokenUpdatedAt: $fcmTokenUpdatedAt)';
}


}

/// @nodoc
abstract mixin class $UserPreferencesEntityCopyWith<$Res>  {
  factory $UserPreferencesEntityCopyWith(UserPreferencesEntity value, $Res Function(UserPreferencesEntity) _then) = _$UserPreferencesEntityCopyWithImpl;
@useResult
$Res call({
 bool darkMode, bool notificationEnabled, bool emailNotificationEnabled, List<int> reminderLayers, int defaultReminder, bool soundEnabled, bool vibrationEnabled, String? fcmToken, DateTime? fcmTokenUpdatedAt
});




}
/// @nodoc
class _$UserPreferencesEntityCopyWithImpl<$Res>
    implements $UserPreferencesEntityCopyWith<$Res> {
  _$UserPreferencesEntityCopyWithImpl(this._self, this._then);

  final UserPreferencesEntity _self;
  final $Res Function(UserPreferencesEntity) _then;

/// Create a copy of UserPreferencesEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? darkMode = null,Object? notificationEnabled = null,Object? emailNotificationEnabled = null,Object? reminderLayers = null,Object? defaultReminder = null,Object? soundEnabled = null,Object? vibrationEnabled = null,Object? fcmToken = freezed,Object? fcmTokenUpdatedAt = freezed,}) {
  return _then(_self.copyWith(
darkMode: null == darkMode ? _self.darkMode : darkMode // ignore: cast_nullable_to_non_nullable
as bool,notificationEnabled: null == notificationEnabled ? _self.notificationEnabled : notificationEnabled // ignore: cast_nullable_to_non_nullable
as bool,emailNotificationEnabled: null == emailNotificationEnabled ? _self.emailNotificationEnabled : emailNotificationEnabled // ignore: cast_nullable_to_non_nullable
as bool,reminderLayers: null == reminderLayers ? _self.reminderLayers : reminderLayers // ignore: cast_nullable_to_non_nullable
as List<int>,defaultReminder: null == defaultReminder ? _self.defaultReminder : defaultReminder // ignore: cast_nullable_to_non_nullable
as int,soundEnabled: null == soundEnabled ? _self.soundEnabled : soundEnabled // ignore: cast_nullable_to_non_nullable
as bool,vibrationEnabled: null == vibrationEnabled ? _self.vibrationEnabled : vibrationEnabled // ignore: cast_nullable_to_non_nullable
as bool,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,fcmTokenUpdatedAt: freezed == fcmTokenUpdatedAt ? _self.fcmTokenUpdatedAt : fcmTokenUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserPreferencesEntity].
extension UserPreferencesEntityPatterns on UserPreferencesEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserPreferencesEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserPreferencesEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserPreferencesEntity value)  $default,){
final _that = this;
switch (_that) {
case _UserPreferencesEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserPreferencesEntity value)?  $default,){
final _that = this;
switch (_that) {
case _UserPreferencesEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool darkMode,  bool notificationEnabled,  bool emailNotificationEnabled,  List<int> reminderLayers,  int defaultReminder,  bool soundEnabled,  bool vibrationEnabled,  String? fcmToken,  DateTime? fcmTokenUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserPreferencesEntity() when $default != null:
return $default(_that.darkMode,_that.notificationEnabled,_that.emailNotificationEnabled,_that.reminderLayers,_that.defaultReminder,_that.soundEnabled,_that.vibrationEnabled,_that.fcmToken,_that.fcmTokenUpdatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool darkMode,  bool notificationEnabled,  bool emailNotificationEnabled,  List<int> reminderLayers,  int defaultReminder,  bool soundEnabled,  bool vibrationEnabled,  String? fcmToken,  DateTime? fcmTokenUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _UserPreferencesEntity():
return $default(_that.darkMode,_that.notificationEnabled,_that.emailNotificationEnabled,_that.reminderLayers,_that.defaultReminder,_that.soundEnabled,_that.vibrationEnabled,_that.fcmToken,_that.fcmTokenUpdatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool darkMode,  bool notificationEnabled,  bool emailNotificationEnabled,  List<int> reminderLayers,  int defaultReminder,  bool soundEnabled,  bool vibrationEnabled,  String? fcmToken,  DateTime? fcmTokenUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserPreferencesEntity() when $default != null:
return $default(_that.darkMode,_that.notificationEnabled,_that.emailNotificationEnabled,_that.reminderLayers,_that.defaultReminder,_that.soundEnabled,_that.vibrationEnabled,_that.fcmToken,_that.fcmTokenUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserPreferencesEntity implements UserPreferencesEntity {
  const _UserPreferencesEntity({this.darkMode = false, this.notificationEnabled = true, this.emailNotificationEnabled = false, final  List<int> reminderLayers = const [1, 3, 7], this.defaultReminder = 1, this.soundEnabled = true, this.vibrationEnabled = true, this.fcmToken, this.fcmTokenUpdatedAt}): _reminderLayers = reminderLayers;
  factory _UserPreferencesEntity.fromJson(Map<String, dynamic> json) => _$UserPreferencesEntityFromJson(json);

@override@JsonKey() final  bool darkMode;
@override@JsonKey() final  bool notificationEnabled;
@override@JsonKey() final  bool emailNotificationEnabled;
 final  List<int> _reminderLayers;
@override@JsonKey() List<int> get reminderLayers {
  if (_reminderLayers is EqualUnmodifiableListView) return _reminderLayers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reminderLayers);
}

@override@JsonKey() final  int defaultReminder;
@override@JsonKey() final  bool soundEnabled;
@override@JsonKey() final  bool vibrationEnabled;
@override final  String? fcmToken;
@override final  DateTime? fcmTokenUpdatedAt;

/// Create a copy of UserPreferencesEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserPreferencesEntityCopyWith<_UserPreferencesEntity> get copyWith => __$UserPreferencesEntityCopyWithImpl<_UserPreferencesEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserPreferencesEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserPreferencesEntity&&(identical(other.darkMode, darkMode) || other.darkMode == darkMode)&&(identical(other.notificationEnabled, notificationEnabled) || other.notificationEnabled == notificationEnabled)&&(identical(other.emailNotificationEnabled, emailNotificationEnabled) || other.emailNotificationEnabled == emailNotificationEnabled)&&const DeepCollectionEquality().equals(other._reminderLayers, _reminderLayers)&&(identical(other.defaultReminder, defaultReminder) || other.defaultReminder == defaultReminder)&&(identical(other.soundEnabled, soundEnabled) || other.soundEnabled == soundEnabled)&&(identical(other.vibrationEnabled, vibrationEnabled) || other.vibrationEnabled == vibrationEnabled)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.fcmTokenUpdatedAt, fcmTokenUpdatedAt) || other.fcmTokenUpdatedAt == fcmTokenUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,darkMode,notificationEnabled,emailNotificationEnabled,const DeepCollectionEquality().hash(_reminderLayers),defaultReminder,soundEnabled,vibrationEnabled,fcmToken,fcmTokenUpdatedAt);

@override
String toString() {
  return 'UserPreferencesEntity(darkMode: $darkMode, notificationEnabled: $notificationEnabled, emailNotificationEnabled: $emailNotificationEnabled, reminderLayers: $reminderLayers, defaultReminder: $defaultReminder, soundEnabled: $soundEnabled, vibrationEnabled: $vibrationEnabled, fcmToken: $fcmToken, fcmTokenUpdatedAt: $fcmTokenUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserPreferencesEntityCopyWith<$Res> implements $UserPreferencesEntityCopyWith<$Res> {
  factory _$UserPreferencesEntityCopyWith(_UserPreferencesEntity value, $Res Function(_UserPreferencesEntity) _then) = __$UserPreferencesEntityCopyWithImpl;
@override @useResult
$Res call({
 bool darkMode, bool notificationEnabled, bool emailNotificationEnabled, List<int> reminderLayers, int defaultReminder, bool soundEnabled, bool vibrationEnabled, String? fcmToken, DateTime? fcmTokenUpdatedAt
});




}
/// @nodoc
class __$UserPreferencesEntityCopyWithImpl<$Res>
    implements _$UserPreferencesEntityCopyWith<$Res> {
  __$UserPreferencesEntityCopyWithImpl(this._self, this._then);

  final _UserPreferencesEntity _self;
  final $Res Function(_UserPreferencesEntity) _then;

/// Create a copy of UserPreferencesEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? darkMode = null,Object? notificationEnabled = null,Object? emailNotificationEnabled = null,Object? reminderLayers = null,Object? defaultReminder = null,Object? soundEnabled = null,Object? vibrationEnabled = null,Object? fcmToken = freezed,Object? fcmTokenUpdatedAt = freezed,}) {
  return _then(_UserPreferencesEntity(
darkMode: null == darkMode ? _self.darkMode : darkMode // ignore: cast_nullable_to_non_nullable
as bool,notificationEnabled: null == notificationEnabled ? _self.notificationEnabled : notificationEnabled // ignore: cast_nullable_to_non_nullable
as bool,emailNotificationEnabled: null == emailNotificationEnabled ? _self.emailNotificationEnabled : emailNotificationEnabled // ignore: cast_nullable_to_non_nullable
as bool,reminderLayers: null == reminderLayers ? _self._reminderLayers : reminderLayers // ignore: cast_nullable_to_non_nullable
as List<int>,defaultReminder: null == defaultReminder ? _self.defaultReminder : defaultReminder // ignore: cast_nullable_to_non_nullable
as int,soundEnabled: null == soundEnabled ? _self.soundEnabled : soundEnabled // ignore: cast_nullable_to_non_nullable
as bool,vibrationEnabled: null == vibrationEnabled ? _self.vibrationEnabled : vibrationEnabled // ignore: cast_nullable_to_non_nullable
as bool,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,fcmTokenUpdatedAt: freezed == fcmTokenUpdatedAt ? _self.fcmTokenUpdatedAt : fcmTokenUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
