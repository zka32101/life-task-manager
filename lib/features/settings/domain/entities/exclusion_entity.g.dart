// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exclusion_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExclusionEntity _$ExclusionEntityFromJson(Map<String, dynamic> json) =>
    _ExclusionEntity(
      excludeId: json['excludeId'] as String,
      itemId: json['itemId'] as String,
      itemType: json['itemType'] as String,
      itemName: json['itemName'] as String,
      reason: json['reason'] as String?,
      excludedAt: DateTime.parse(json['excludedAt'] as String),
      validUntil: json['validUntil'] == null
          ? null
          : DateTime.parse(json['validUntil'] as String),
      isTemporaryExclusion: json['isTemporaryExclusion'] as bool? ?? false,
    );

Map<String, dynamic> _$ExclusionEntityToJson(_ExclusionEntity instance) =>
    <String, dynamic>{
      'excludeId': instance.excludeId,
      'itemId': instance.itemId,
      'itemType': instance.itemType,
      'itemName': instance.itemName,
      'reason': instance.reason,
      'excludedAt': instance.excludedAt.toIso8601String(),
      'validUntil': instance.validUntil?.toIso8601String(),
      'isTemporaryExclusion': instance.isTemporaryExclusion,
    };
