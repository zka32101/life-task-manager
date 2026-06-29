// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskEntity _$TaskEntityFromJson(Map<String, dynamic> json) => _TaskEntity(
  taskId: json['taskId'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  categoryId: json['categoryId'] as String,
  categoryPath: json['categoryPath'] as String,
  categoryLabels:
      (json['categoryLabels'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  nextDueAt: DateTime.parse(json['nextDueAt'] as String),
  lastDoneAt: json['lastDoneAt'] == null
      ? null
      : DateTime.parse(json['lastDoneAt'] as String),
  lastDoneByUid: json['lastDoneByUid'] as String?,
  recurrenceType: json['recurrenceType'] as String? ?? 'none',
  recurrenceValue: (json['recurrenceValue'] as num?)?.toInt(),
  recurrenceUnit: json['recurrenceUnit'] as String?,
  reminderDaysBefore: (json['reminderDaysBefore'] as num?)?.toInt() ?? 0,
  groupId: json['groupId'] as String?,
  mainAssigneeUid: json['mainAssigneeUid'] as String?,
  assigneeUids:
      (json['assigneeUids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  deferCount: (json['deferCount'] as num?)?.toInt() ?? 0,
  originalDueAt: json['originalDueAt'] == null
      ? null
      : DateTime.parse(json['originalDueAt'] as String),
  deferredAt: json['deferredAt'] == null
      ? null
      : DateTime.parse(json['deferredAt'] as String),
  deferredByUid: json['deferredByUid'] as String?,
  snoozeUntil: json['snoozeUntil'] == null
      ? null
      : DateTime.parse(json['snoozeUntil'] as String),
  notes: json['notes'] as String?,
  cost: (json['cost'] as num?)?.toDouble(),
  costCurrency: json['costCurrency'] as String?,
  isArchived: json['isArchived'] as bool? ?? false,
  isLocalePreset: json['isLocalePreset'] as bool? ?? false,
  presetLocale: json['presetLocale'] as String?,
  isGroupTask: json['isGroupTask'] as bool? ?? false,
  createdByUid: json['createdByUid'] as String,
  updatedByUid: json['updatedByUid'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$TaskEntityToJson(_TaskEntity instance) =>
    <String, dynamic>{
      'taskId': instance.taskId,
      'title': instance.title,
      'description': instance.description,
      'categoryId': instance.categoryId,
      'categoryPath': instance.categoryPath,
      'categoryLabels': instance.categoryLabels,
      'nextDueAt': instance.nextDueAt.toIso8601String(),
      'lastDoneAt': instance.lastDoneAt?.toIso8601String(),
      'lastDoneByUid': instance.lastDoneByUid,
      'recurrenceType': instance.recurrenceType,
      'recurrenceValue': instance.recurrenceValue,
      'recurrenceUnit': instance.recurrenceUnit,
      'reminderDaysBefore': instance.reminderDaysBefore,
      'groupId': instance.groupId,
      'mainAssigneeUid': instance.mainAssigneeUid,
      'assigneeUids': instance.assigneeUids,
      'deferCount': instance.deferCount,
      'originalDueAt': instance.originalDueAt?.toIso8601String(),
      'deferredAt': instance.deferredAt?.toIso8601String(),
      'deferredByUid': instance.deferredByUid,
      'snoozeUntil': instance.snoozeUntil?.toIso8601String(),
      'notes': instance.notes,
      'cost': instance.cost,
      'costCurrency': instance.costCurrency,
      'isArchived': instance.isArchived,
      'isLocalePreset': instance.isLocalePreset,
      'presetLocale': instance.presetLocale,
      'isGroupTask': instance.isGroupTask,
      'createdByUid': instance.createdByUid,
      'updatedByUid': instance.updatedByUid,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
