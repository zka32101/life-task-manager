// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CategoryEntity {

 String get categoryId; String get name; String? get description; String? get emoji; String? get parentCategoryId; String get path; int get level; int get order; bool get isDefault; int get taskCount; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of CategoryEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryEntityCopyWith<CategoryEntity> get copyWith => _$CategoryEntityCopyWithImpl<CategoryEntity>(this as CategoryEntity, _$identity);

  /// Serializes this CategoryEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryEntity&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.parentCategoryId, parentCategoryId) || other.parentCategoryId == parentCategoryId)&&(identical(other.path, path) || other.path == path)&&(identical(other.level, level) || other.level == level)&&(identical(other.order, order) || other.order == order)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.taskCount, taskCount) || other.taskCount == taskCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,name,description,emoji,parentCategoryId,path,level,order,isDefault,taskCount,createdAt,updatedAt);

@override
String toString() {
  return 'CategoryEntity(categoryId: $categoryId, name: $name, description: $description, emoji: $emoji, parentCategoryId: $parentCategoryId, path: $path, level: $level, order: $order, isDefault: $isDefault, taskCount: $taskCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CategoryEntityCopyWith<$Res>  {
  factory $CategoryEntityCopyWith(CategoryEntity value, $Res Function(CategoryEntity) _then) = _$CategoryEntityCopyWithImpl;
@useResult
$Res call({
 String categoryId, String name, String? description, String? emoji, String? parentCategoryId, String path, int level, int order, bool isDefault, int taskCount, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$CategoryEntityCopyWithImpl<$Res>
    implements $CategoryEntityCopyWith<$Res> {
  _$CategoryEntityCopyWithImpl(this._self, this._then);

  final CategoryEntity _self;
  final $Res Function(CategoryEntity) _then;

/// Create a copy of CategoryEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryId = null,Object? name = null,Object? description = freezed,Object? emoji = freezed,Object? parentCategoryId = freezed,Object? path = null,Object? level = null,Object? order = null,Object? isDefault = null,Object? taskCount = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,parentCategoryId: freezed == parentCategoryId ? _self.parentCategoryId : parentCategoryId // ignore: cast_nullable_to_non_nullable
as String?,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,taskCount: null == taskCount ? _self.taskCount : taskCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryEntity].
extension CategoryEntityPatterns on CategoryEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryEntity value)  $default,){
final _that = this;
switch (_that) {
case _CategoryEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryEntity value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String categoryId,  String name,  String? description,  String? emoji,  String? parentCategoryId,  String path,  int level,  int order,  bool isDefault,  int taskCount,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryEntity() when $default != null:
return $default(_that.categoryId,_that.name,_that.description,_that.emoji,_that.parentCategoryId,_that.path,_that.level,_that.order,_that.isDefault,_that.taskCount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String categoryId,  String name,  String? description,  String? emoji,  String? parentCategoryId,  String path,  int level,  int order,  bool isDefault,  int taskCount,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CategoryEntity():
return $default(_that.categoryId,_that.name,_that.description,_that.emoji,_that.parentCategoryId,_that.path,_that.level,_that.order,_that.isDefault,_that.taskCount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String categoryId,  String name,  String? description,  String? emoji,  String? parentCategoryId,  String path,  int level,  int order,  bool isDefault,  int taskCount,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CategoryEntity() when $default != null:
return $default(_that.categoryId,_that.name,_that.description,_that.emoji,_that.parentCategoryId,_that.path,_that.level,_that.order,_that.isDefault,_that.taskCount,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CategoryEntity implements CategoryEntity {
  const _CategoryEntity({required this.categoryId, required this.name, this.description, this.emoji, this.parentCategoryId, required this.path, this.level = 0, this.order = 0, this.isDefault = false, this.taskCount = 0, required this.createdAt, required this.updatedAt});
  factory _CategoryEntity.fromJson(Map<String, dynamic> json) => _$CategoryEntityFromJson(json);

@override final  String categoryId;
@override final  String name;
@override final  String? description;
@override final  String? emoji;
@override final  String? parentCategoryId;
@override final  String path;
@override@JsonKey() final  int level;
@override@JsonKey() final  int order;
@override@JsonKey() final  bool isDefault;
@override@JsonKey() final  int taskCount;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of CategoryEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryEntityCopyWith<_CategoryEntity> get copyWith => __$CategoryEntityCopyWithImpl<_CategoryEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategoryEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryEntity&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.parentCategoryId, parentCategoryId) || other.parentCategoryId == parentCategoryId)&&(identical(other.path, path) || other.path == path)&&(identical(other.level, level) || other.level == level)&&(identical(other.order, order) || other.order == order)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.taskCount, taskCount) || other.taskCount == taskCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,name,description,emoji,parentCategoryId,path,level,order,isDefault,taskCount,createdAt,updatedAt);

@override
String toString() {
  return 'CategoryEntity(categoryId: $categoryId, name: $name, description: $description, emoji: $emoji, parentCategoryId: $parentCategoryId, path: $path, level: $level, order: $order, isDefault: $isDefault, taskCount: $taskCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CategoryEntityCopyWith<$Res> implements $CategoryEntityCopyWith<$Res> {
  factory _$CategoryEntityCopyWith(_CategoryEntity value, $Res Function(_CategoryEntity) _then) = __$CategoryEntityCopyWithImpl;
@override @useResult
$Res call({
 String categoryId, String name, String? description, String? emoji, String? parentCategoryId, String path, int level, int order, bool isDefault, int taskCount, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$CategoryEntityCopyWithImpl<$Res>
    implements _$CategoryEntityCopyWith<$Res> {
  __$CategoryEntityCopyWithImpl(this._self, this._then);

  final _CategoryEntity _self;
  final $Res Function(_CategoryEntity) _then;

/// Create a copy of CategoryEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = null,Object? name = null,Object? description = freezed,Object? emoji = freezed,Object? parentCategoryId = freezed,Object? path = null,Object? level = null,Object? order = null,Object? isDefault = null,Object? taskCount = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_CategoryEntity(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,parentCategoryId: freezed == parentCategoryId ? _self.parentCategoryId : parentCategoryId // ignore: cast_nullable_to_non_nullable
as String?,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,taskCount: null == taskCount ? _self.taskCount : taskCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
