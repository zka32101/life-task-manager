import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_task_manager/features/tasks/domain/entities/task_entity.dart';

class TaskModel {
  final String taskId;
  final String title;
  final String? description;
  final String categoryId;
  final String categoryPath;
  final List<String> categoryLabels;
  final DateTime nextDueAt;
  final DateTime? lastDoneAt;
  final String? lastDoneByUid;
  final String recurrenceType;
  final int? recurrenceValue;
  final String? recurrenceUnit;
  final int reminderDaysBefore;
  final String? groupId;
  final String? mainAssigneeUid;
  final List<String> assigneeUids;
  final int deferCount;
  final DateTime? originalDueAt;
  final DateTime? deferredAt;
  final String? deferredByUid;
  final DateTime? snoozeUntil;
  final String? notes;
  final double? cost;
  final String? costCurrency;
  final bool isArchived;
  final bool isLocalePreset;
  final String? presetLocale;
  final bool isGroupTask;
  final String createdByUid;
  final String updatedByUid;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskModel({
    required this.taskId,
    required this.title,
    this.description,
    required this.categoryId,
    required this.categoryPath,
    this.categoryLabels = const [],
    required this.nextDueAt,
    this.lastDoneAt,
    this.lastDoneByUid,
    this.recurrenceType = 'none',
    this.recurrenceValue,
    this.recurrenceUnit,
    this.reminderDaysBefore = 0,
    this.groupId,
    this.mainAssigneeUid,
    this.assigneeUids = const [],
    this.deferCount = 0,
    this.originalDueAt,
    this.deferredAt,
    this.deferredByUid,
    this.snoozeUntil,
    this.notes,
    this.cost,
    this.costCurrency,
    this.isArchived = false,
    this.isLocalePreset = false,
    this.presetLocale,
    this.isGroupTask = false,
    required this.createdByUid,
    required this.updatedByUid,
    required this.createdAt,
    required this.updatedAt,
  });

  static TaskModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      taskId: doc.id,
      title: data['title'] as String,
      description: data['description'] as String?,
      categoryId: data['categoryId'] as String? ?? '',
      categoryPath: data['categoryPath'] as String? ?? '',
      categoryLabels: List<String>.from(data['categoryLabels'] as List? ?? []),
      nextDueAt: (data['nextDueAt'] as Timestamp).toDate(),
      lastDoneAt: (data['lastDoneAt'] as Timestamp?)?.toDate(),
      lastDoneByUid: data['lastDoneByUid'] as String?,
      recurrenceType: data['recurrenceType'] as String? ?? 'none',
      recurrenceValue: data['recurrenceValue'] as int?,
      recurrenceUnit: data['recurrenceUnit'] as String?,
      reminderDaysBefore: data['reminderDaysBefore'] as int? ?? 0,
      groupId: data['groupId'] as String?,
      mainAssigneeUid: data['mainAssigneeUid'] as String?,
      assigneeUids: List<String>.from(data['assigneeUids'] as List? ?? []),
      deferCount: data['deferCount'] as int? ?? 0,
      originalDueAt: (data['originalDueAt'] as Timestamp?)?.toDate(),
      deferredAt: (data['deferredAt'] as Timestamp?)?.toDate(),
      deferredByUid: data['deferredByUid'] as String?,
      snoozeUntil: (data['snoozeUntil'] as Timestamp?)?.toDate(),
      notes: data['notes'] as String?,
      cost: (data['cost'] as num?)?.toDouble(),
      costCurrency: data['costCurrency'] as String?,
      isArchived: data['isArchived'] as bool? ?? false,
      isLocalePreset: data['isLocalePreset'] as bool? ?? false,
      presetLocale: data['presetLocale'] as String?,
      isGroupTask: data['isGroupTask'] as bool? ?? false,
      createdByUid: data['createdByUid'] as String? ?? '',
      updatedByUid: data['updatedByUid'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      if (description != null) 'description': description,
      'categoryId': categoryId,
      'categoryPath': categoryPath,
      'categoryLabels': categoryLabels,
      'nextDueAt': Timestamp.fromDate(nextDueAt),
      if (lastDoneAt != null) 'lastDoneAt': Timestamp.fromDate(lastDoneAt!),
      if (lastDoneByUid != null) 'lastDoneByUid': lastDoneByUid,
      'recurrenceType': recurrenceType,
      if (recurrenceValue != null) 'recurrenceValue': recurrenceValue,
      if (recurrenceUnit != null) 'recurrenceUnit': recurrenceUnit,
      'reminderDaysBefore': reminderDaysBefore,
      if (groupId != null) 'groupId': groupId,
      if (mainAssigneeUid != null) 'mainAssigneeUid': mainAssigneeUid,
      'assigneeUids': assigneeUids,
      'deferCount': deferCount,
      if (originalDueAt != null)
        'originalDueAt': Timestamp.fromDate(originalDueAt!),
      if (deferredAt != null) 'deferredAt': Timestamp.fromDate(deferredAt!),
      if (deferredByUid != null) 'deferredByUid': deferredByUid,
      if (snoozeUntil != null) 'snoozeUntil': Timestamp.fromDate(snoozeUntil!),
      if (notes != null) 'notes': notes,
      if (cost != null) 'cost': cost,
      if (costCurrency != null) 'costCurrency': costCurrency,
      'isArchived': isArchived,
      'isLocalePreset': isLocalePreset,
      if (presetLocale != null) 'presetLocale': presetLocale,
      'isGroupTask': isGroupTask,
      'createdByUid': createdByUid,
      'updatedByUid': updatedByUid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toFirestoreUpdate() {
    return {
      'title': title,
      if (description != null) 'description': description,
      'categoryId': categoryId,
      'categoryPath': categoryPath,
      'categoryLabels': categoryLabels,
      'nextDueAt': Timestamp.fromDate(nextDueAt),
      if (lastDoneAt != null) 'lastDoneAt': Timestamp.fromDate(lastDoneAt!),
      if (lastDoneByUid != null) 'lastDoneByUid': lastDoneByUid,
      'recurrenceType': recurrenceType,
      if (recurrenceValue != null) 'recurrenceValue': recurrenceValue,
      if (recurrenceUnit != null) 'recurrenceUnit': recurrenceUnit,
      'reminderDaysBefore': reminderDaysBefore,
      if (groupId != null) 'groupId': groupId,
      if (mainAssigneeUid != null) 'mainAssigneeUid': mainAssigneeUid,
      'assigneeUids': assigneeUids,
      'deferCount': deferCount,
      if (originalDueAt != null)
        'originalDueAt': Timestamp.fromDate(originalDueAt!),
      if (deferredAt != null) 'deferredAt': Timestamp.fromDate(deferredAt!),
      if (deferredByUid != null) 'deferredByUid': deferredByUid,
      if (snoozeUntil != null) 'snoozeUntil': Timestamp.fromDate(snoozeUntil!),
      if (notes != null) 'notes': notes,
      if (cost != null) 'cost': cost,
      if (costCurrency != null) 'costCurrency': costCurrency,
      'isArchived': isArchived,
      'isLocalePreset': isLocalePreset,
      if (presetLocale != null) 'presetLocale': presetLocale,
      'isGroupTask': isGroupTask,
      'updatedByUid': updatedByUid,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  TaskEntity toEntity() {
    return TaskEntity(
      taskId: taskId,
      title: title,
      description: description,
      categoryId: categoryId,
      categoryPath: categoryPath,
      categoryLabels: categoryLabels,
      nextDueAt: nextDueAt,
      lastDoneAt: lastDoneAt,
      lastDoneByUid: lastDoneByUid,
      recurrenceType: recurrenceType,
      recurrenceValue: recurrenceValue,
      recurrenceUnit: recurrenceUnit,
      reminderDaysBefore: reminderDaysBefore,
      groupId: groupId,
      mainAssigneeUid: mainAssigneeUid,
      assigneeUids: assigneeUids,
      deferCount: deferCount,
      originalDueAt: originalDueAt,
      deferredAt: deferredAt,
      deferredByUid: deferredByUid,
      snoozeUntil: snoozeUntil,
      notes: notes,
      cost: cost,
      costCurrency: costCurrency,
      isArchived: isArchived,
      isLocalePreset: isLocalePreset,
      presetLocale: presetLocale,
      isGroupTask: isGroupTask,
      createdByUid: createdByUid,
      updatedByUid: updatedByUid,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static TaskModel fromEntity(TaskEntity entity) {
    return TaskModel(
      taskId: entity.taskId,
      title: entity.title,
      description: entity.description,
      categoryId: entity.categoryId,
      categoryPath: entity.categoryPath,
      categoryLabels: entity.categoryLabels,
      nextDueAt: entity.nextDueAt,
      lastDoneAt: entity.lastDoneAt,
      lastDoneByUid: entity.lastDoneByUid,
      recurrenceType: entity.recurrenceType,
      recurrenceValue: entity.recurrenceValue,
      recurrenceUnit: entity.recurrenceUnit,
      reminderDaysBefore: entity.reminderDaysBefore,
      groupId: entity.groupId,
      mainAssigneeUid: entity.mainAssigneeUid,
      assigneeUids: entity.assigneeUids,
      deferCount: entity.deferCount,
      originalDueAt: entity.originalDueAt,
      deferredAt: entity.deferredAt,
      deferredByUid: entity.deferredByUid,
      snoozeUntil: entity.snoozeUntil,
      notes: entity.notes,
      cost: entity.cost,
      costCurrency: entity.costCurrency,
      isArchived: entity.isArchived,
      isLocalePreset: entity.isLocalePreset,
      presetLocale: entity.presetLocale,
      isGroupTask: entity.isGroupTask,
      createdByUid: entity.createdByUid,
      updatedByUid: entity.updatedByUid,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
