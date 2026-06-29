// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CategoryEntity _$CategoryEntityFromJson(Map<String, dynamic> json) =>
    _CategoryEntity(
      categoryId: json['categoryId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      emoji: json['emoji'] as String?,
      parentCategoryId: json['parentCategoryId'] as String?,
      path: json['path'] as String,
      level: (json['level'] as num?)?.toInt() ?? 0,
      order: (json['order'] as num?)?.toInt() ?? 0,
      isDefault: json['isDefault'] as bool? ?? false,
      taskCount: (json['taskCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CategoryEntityToJson(_CategoryEntity instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'name': instance.name,
      'description': instance.description,
      'emoji': instance.emoji,
      'parentCategoryId': instance.parentCategoryId,
      'path': instance.path,
      'level': instance.level,
      'order': instance.order,
      'isDefault': instance.isDefault,
      'taskCount': instance.taskCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
