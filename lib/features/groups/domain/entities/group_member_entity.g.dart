// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_member_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupMemberEntity _$GroupMemberEntityFromJson(Map<String, dynamic> json) =>
    _GroupMemberEntity(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      role: json['role'] as String? ?? 'member',
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      status: json['status'] as String? ?? 'active',
    );

Map<String, dynamic> _$GroupMemberEntityToJson(_GroupMemberEntity instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'displayName': instance.displayName,
      'email': instance.email,
      'photoUrl': instance.photoUrl,
      'role': instance.role,
      'joinedAt': instance.joinedAt.toIso8601String(),
      'status': instance.status,
    };
