import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_task_manager/core/constants/app_constants.dart';
import 'package:life_task_manager/features/tasks/data/models/task_model.dart';

abstract class TaskFirestoreDatasource {
  Stream<List<TaskModel>> watchUserTasks(
    String uid, {
    bool includeArchived = false,
  });
  Stream<List<TaskModel>> watchGroupTasks(String groupId);
  /// 個人タスクを作成し、新しい taskId を返す
  Future<String> createTask(String uid, TaskModel task);
  /// グループタスクを作成し、新しい taskId を返す
  Future<String> createGroupTask(String groupId, TaskModel task);
  Future<void> updateTask(
    String uid,
    String taskId,
    Map<String, dynamic> data,
  );
  Future<void> deleteTask(String uid, String taskId);
  Future<void> completeTask(
    String uid,
    String taskId,
    DateTime completedAt,
  );
  Future<void> deferTask(
    String uid,
    String taskId,
    DateTime newDueAt,
    String? reason,
  );
  Future<TaskModel?> getTask(String uid, String taskId);
}

class TaskFirestoreDatasourceImpl implements TaskFirestoreDatasource {
  final FirebaseFirestore _firestore;

  TaskFirestoreDatasourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userTasksRef(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection(AppConstants.tasksSubCollection);
  }

  CollectionReference<Map<String, dynamic>> _groupTasksRef(String groupId) {
    return _firestore
        .collection(AppConstants.groupsCollection)
        .doc(groupId)
        .collection(AppConstants.tasksSubCollection);
  }

  @override
  Stream<List<TaskModel>> watchUserTasks(
    String uid, {
    bool includeArchived = false,
  }) {
    Query<Map<String, dynamic>> query = _userTasksRef(uid);
    if (!includeArchived) {
      query = query.where('isArchived', isEqualTo: false);
    }
    query = query.orderBy('nextDueAt');

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Stream<List<TaskModel>> watchGroupTasks(String groupId) {
    return _groupTasksRef(groupId)
        .where('isArchived', isEqualTo: false)
        .orderBy('nextDueAt')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TaskModel.fromFirestore(doc))
              .toList();
        });
  }

  @override
  Future<String> createTask(String uid, TaskModel task) async {
    try {
      final data = task.toFirestore();
      final docRef = await _userTasksRef(uid).add(data);
      return docRef.id;
    } on FirebaseException catch (e) {
      throw Exception('Failed to create task: ${e.message}');
    }
  }

  @override
  Future<String> createGroupTask(String groupId, TaskModel task) async {
    try {
      final data = task.toFirestore();
      final docRef = await _groupTasksRef(groupId).add(data);
      return docRef.id;
    } on FirebaseException catch (e) {
      throw Exception('Failed to create group task: ${e.message}');
    }
  }

  @override
  Future<void> updateTask(
    String uid,
    String taskId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _userTasksRef(uid).doc(taskId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to update task: ${e.message}');
    }
  }

  @override
  Future<void> deleteTask(String uid, String taskId) async {
    try {
      await _userTasksRef(uid).doc(taskId).delete();
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete task: ${e.message}');
    }
  }

  @override
  Future<void> completeTask(
    String uid,
    String taskId,
    DateTime completedAt,
  ) async {
    try {
      await _userTasksRef(uid).doc(taskId).update({
        'lastDoneAt': Timestamp.fromDate(completedAt),
        'lastDoneByUid': uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to complete task: ${e.message}');
    }
  }

  @override
  Future<void> deferTask(
    String uid,
    String taskId,
    DateTime newDueAt,
    String? reason,
  ) async {
    try {
      await _userTasksRef(uid).doc(taskId).update({
        'nextDueAt': Timestamp.fromDate(newDueAt),
        'deferCount': FieldValue.increment(1),
        'deferredAt': FieldValue.serverTimestamp(),
        'deferredByUid': uid,
        if (reason != null) 'notes': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to defer task: ${e.message}');
    }
  }

  @override
  Future<TaskModel?> getTask(String uid, String taskId) async {
    try {
      final doc = await _userTasksRef(uid).doc(taskId).get();
      if (!doc.exists) return null;
      return TaskModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw Exception('Failed to get task: ${e.message}');
    }
  }
}
