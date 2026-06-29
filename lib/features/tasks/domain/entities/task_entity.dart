import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_entity.freezed.dart';
part 'task_entity.g.dart';

@freezed
sealed class TaskEntity with _$TaskEntity {
  const factory TaskEntity({
    required String taskId,
    required String title,
    String? description,
    required String categoryId,
    required String categoryPath,
    @Default([]) List<String> categoryLabels,
    required DateTime nextDueAt,
    DateTime? lastDoneAt,
    String? lastDoneByUid,
    @Default('none') String recurrenceType,
    int? recurrenceValue,
    String? recurrenceUnit,
    @Default(0) int reminderDaysBefore,
    String? groupId,
    String? mainAssigneeUid,
    @Default([]) List<String> assigneeUids,
    @Default(0) int deferCount,
    DateTime? originalDueAt,
    DateTime? deferredAt,
    String? deferredByUid,
    DateTime? snoozeUntil,
    String? notes,
    double? cost,
    String? costCurrency,
    @Default(false) bool isArchived,
    @Default(false) bool isLocalePreset,
    String? presetLocale,
    @Default(false) bool isGroupTask,
    required String createdByUid,
    required String updatedByUid,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TaskEntity;

  factory TaskEntity.fromJson(Map<String, dynamic> json) =>
      _$TaskEntityFromJson(json);
}
