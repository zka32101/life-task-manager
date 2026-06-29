// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupEntity _$GroupEntityFromJson(Map<String, dynamic> json) => _GroupEntity(
  groupId: json['groupId'] as String,
  name: json['name'] as String,
  ownerUid: json['ownerUid'] as String,
  memberUids:
      (json['memberUids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
  taskCount: (json['taskCount'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$GroupEntityToJson(_GroupEntity instance) =>
    <String, dynamic>{
      'groupId': instance.groupId,
      'name': instance.name,
      'ownerUid': instance.ownerUid,
      'memberUids': instance.memberUids,
      'memberCount': instance.memberCount,
      'taskCount': instance.taskCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
