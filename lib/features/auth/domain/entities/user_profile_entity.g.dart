// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfileEntity _$UserProfileEntityFromJson(Map<String, dynamic> json) =>
    _UserProfileEntity(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      language: json['language'] as String? ?? 'ja',
      country: json['country'] as String? ?? 'JP',
      timezone: json['timezone'] as String? ?? 'Asia/Tokyo',
      isPaid: json['isPaid'] as bool? ?? false,
      purchaseType: json['purchaseType'] as String?,
      trialStartAt: DateTime.parse(json['trialStartAt'] as String),
      purchasedAt: json['purchasedAt'] == null
          ? null
          : DateTime.parse(json['purchasedAt'] as String),
      invitedByGroupId: json['invitedByGroupId'] as String?,
      iapPlatform: json['iapPlatform'] as String?,
      iapTransactionId: json['iapTransactionId'] as String?,
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserProfileEntityToJson(_UserProfileEntity instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'displayName': instance.displayName,
      'email': instance.email,
      'photoUrl': instance.photoUrl,
      'language': instance.language,
      'country': instance.country,
      'timezone': instance.timezone,
      'isPaid': instance.isPaid,
      'purchaseType': instance.purchaseType,
      'trialStartAt': instance.trialStartAt.toIso8601String(),
      'purchasedAt': instance.purchasedAt?.toIso8601String(),
      'invitedByGroupId': instance.invitedByGroupId,
      'iapPlatform': instance.iapPlatform,
      'iapTransactionId': instance.iapTransactionId,
      'lastActiveAt': instance.lastActiveAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
