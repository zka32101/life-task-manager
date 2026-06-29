// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_record_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskRecordEntity _$TaskRecordEntityFromJson(Map<String, dynamic> json) =>
    _TaskRecordEntity(
      recordId: json['recordId'] as String,
      taskId: json['taskId'] as String,
      doneByUid: json['doneByUid'] as String,
      doneByDisplayName: json['doneByDisplayName'] as String?,
      doneAt: DateTime.parse(json['doneAt'] as String),
      scheduledDueAt: json['scheduledDueAt'] == null
          ? null
          : DateTime.parse(json['scheduledDueAt'] as String),
      notes: json['notes'] as String?,
      cost: (json['cost'] as num?)?.toDouble(),
      costCurrency: json['costCurrency'] as String?,
      groupId: json['groupId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$TaskRecordEntityToJson(_TaskRecordEntity instance) =>
    <String, dynamic>{
      'recordId': instance.recordId,
      'taskId': instance.taskId,
      'doneByUid': instance.doneByUid,
      'doneByDisplayName': instance.doneByDisplayName,
      'doneAt': instance.doneAt.toIso8601String(),
      'scheduledDueAt': instance.scheduledDueAt?.toIso8601String(),
      'notes': instance.notes,
      'cost': instance.cost,
      'costCurrency': instance.costCurrency,
      'groupId': instance.groupId,
      'createdAt': instance.createdAt.toIso8601String(),
    };
