import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_record_entity.freezed.dart';
part 'task_record_entity.g.dart';

@freezed
sealed class TaskRecordEntity with _$TaskRecordEntity {
  const factory TaskRecordEntity({
    required String recordId,
    required String taskId,
    required String doneByUid,
    String? doneByDisplayName,
    required DateTime doneAt,
    DateTime? scheduledDueAt,
    String? notes,
    double? cost,
    String? costCurrency,
    String? groupId,
    required DateTime createdAt,
  }) = _TaskRecordEntity;

  factory TaskRecordEntity.fromJson(Map<String, dynamic> json) =>
      _$TaskRecordEntityFromJson(json);
}
