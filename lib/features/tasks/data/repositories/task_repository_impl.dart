import 'package:life_task_manager/features/tasks/data/datasources/task_firestore_datasource.dart';
import 'package:life_task_manager/features/tasks/data/models/task_model.dart';
import 'package:life_task_manager/features/tasks/domain/entities/task_entity.dart';
import 'package:life_task_manager/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskFirestoreDatasource _datasource;

  TaskRepositoryImpl(this._datasource);

  @override
  Stream<List<TaskEntity>> watchUserTasks(
    String uid, {
    bool includeArchived = false,
  }) {
    return _datasource
        .watchUserTasks(uid, includeArchived: includeArchived)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Stream<List<TaskEntity>> watchGroupTasks(String groupId) {
    return _datasource
        .watchGroupTasks(groupId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<String> createTask(String uid, TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    return _datasource.createTask(uid, model);
  }

  @override
  Future<void> updateTask(
    String uid,
    String taskId,
    Map<String, dynamic> data,
  ) {
    return _datasource.updateTask(uid, taskId, data);
  }

  @override
  Future<void> deleteTask(String uid, String taskId) {
    return _datasource.deleteTask(uid, taskId);
  }

  @override
  Future<void> completeTask(
    String uid,
    String taskId,
    DateTime completedAt,
  ) {
    return _datasource.completeTask(uid, taskId, completedAt);
  }

  @override
  Future<void> deferTask(
    String uid,
    String taskId,
    DateTime newDueAt,
    String? reason,
  ) {
    return _datasource.deferTask(uid, taskId, newDueAt, reason);
  }

  @override
  Future<TaskEntity?> getTask(String uid, String taskId) async {
    final model = await _datasource.getTask(uid, taskId);
    return model?.toEntity();
  }
}
