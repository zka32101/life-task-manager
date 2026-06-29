// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InvitationEntity _$InvitationEntityFromJson(Map<String, dynamic> json) =>
    _InvitationEntity(
      invitationId: json['invitationId'] as String,
      groupId: json['groupId'] as String,
      inviteeEmail: json['inviteeEmail'] as String,
      invitedByUid: json['invitedByUid'] as String,
      invitedByName: json['invitedByName'] as String,
      status: json['status'] as String? ?? 'pending',
      invitationCode: json['invitationCode'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      acceptedAt: json['acceptedAt'] == null
          ? null
          : DateTime.parse(json['acceptedAt'] as String),
      acceptedByUid: json['acceptedByUid'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$InvitationEntityToJson(_InvitationEntity instance) =>
    <String, dynamic>{
      'invitationId': instance.invitationId,
      'groupId': instance.groupId,
      'inviteeEmail': instance.inviteeEmail,
      'invitedByUid': instance.invitedByUid,
      'invitedByName': instance.invitedByName,
      'status': instance.status,
      'invitationCode': instance.invitationCode,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'acceptedAt': instance.acceptedAt?.toIso8601String(),
      'acceptedByUid': instance.acceptedByUid,
      'createdAt': instance.createdAt.toIso8601String(),
    };
