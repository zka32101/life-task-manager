import 'package:life_task_manager/features/tasks/domain/entities/task_entity.dart';

abstract class TaskRepository {
  Stream<List<TaskEntity>> watchUserTasks(
    String uid, {
    bool includeArchived = false,
  });
  Stream<List<TaskEntity>> watchGroupTasks(String groupId);
  Future<String> createTask(String uid, TaskEntity task);
  Future<void> updateTask(
    String uid,
    String taskId,
    Map<String, dynamic> data,
  );
  Future<void> deleteTask(String uid, String taskId);
  Future<void> completeTask(String uid, String taskId, DateTime completedAt);
  Future<void> deferTask(
    String uid,
    String taskId,
    DateTime newDueAt,
    String? reason,
  );
  Future<TaskEntity?> getTask(String uid, String taskId);
}
