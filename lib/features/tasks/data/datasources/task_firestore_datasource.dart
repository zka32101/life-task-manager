import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_task_manager/core/constants/app_constants.dart';
import 'package:life_task_manager/features/tasks/data/models/task_model.dart';

// ---------------------------------------------------------------------------
// Firestore例外ラッパー
// ---------------------------------------------------------------------------

/// Firestore操作のカスタム例外型
class FirestorePersistenceException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  FirestorePersistenceException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'FirestorePersistenceException: $message${code != null ? ' (code: $code)' : ''}';
}

abstract class TaskFirestoreDatasource {
  /// ユーザーのタスクをリアルタイム監視（キャッシュ対応）
  Stream<List<TaskModel>> watchUserTasks(
    String uid, {
    bool includeArchived = false,
  });

  /// グループタスクをリアルタイム監視（キャッシュ対応）
  Stream<List<TaskModel>> watchGroupTasks(String groupId);

  /// 個人タスクを作成し、新しい taskId を返す
  Future<String> createTask(String uid, TaskModel task);

  /// グループタスクを作成し、新しい taskId を返す
  Future<String> createGroupTask(String groupId, TaskModel task);

  /// 複数タスクをバッチ作成
  Future<List<String>> createTasksBatch(String uid, List<TaskModel> tasks);

  /// タスク情報を更新
  Future<void> updateTask(
    String uid,
    String taskId,
    Map<String, dynamic> data,
  );

  /// 複数タスクをバッチ更新
  Future<void> updateTasksBatch(
    String uid,
    List<({String taskId, Map<String, dynamic> data})> updates,
  );

  /// タスクを削除
  Future<void> deleteTask(String uid, String taskId);

  /// タスクを完了済みにする
  Future<void> completeTask(
    String uid,
    String taskId,
    DateTime completedAt,
  );

  /// タスクを延期する
  Future<void> deferTask(
    String uid,
    String taskId,
    DateTime newDueAt,
    String? reason,
  );

  /// タスクを取得（キャッシュ対応）
  Future<TaskModel?> getTask(String uid, String taskId);
}

class TaskFirestoreDatasourceImpl implements TaskFirestoreDatasource {
  final FirebaseFirestore _firestore;

  /// Stream キャッシュ（メモリ内）
  final Map<String, Stream<List<TaskModel>>> _streamCache = {};

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

  /// Firestore例外を安全にハンドル
  FirestorePersistenceException _handleFirestoreError(
    dynamic error,
    String operation,
  ) {
    if (error is FirebaseException) {
      return FirestorePersistenceException(
        message: 'タスク $operation に失敗しました: ${error.message}',
        code: error.code,
        originalError: error,
      );
    }
    return FirestorePersistenceException(
      message: 'タスク $operation に予期しないエラーが発生しました',
      originalError: error,
    );
  }

  @override
  Stream<List<TaskModel>> watchUserTasks(
    String uid, {
    bool includeArchived = false,
  }) {
    // キャッシュキーを生成
    final cacheKey = 'user_tasks_${uid}_archived_$includeArchived';

    // キャッシュに存在すれば返す
    if (_streamCache.containsKey(cacheKey)) {
      return _streamCache[cacheKey]!;
    }

    Query<Map<String, dynamic>> query = _userTasksRef(uid);
    if (!includeArchived) {
      query = query.where('isArchived', isEqualTo: false);
    }
    query = query.orderBy('nextDueAt');

    // Stream をキャッシュに保存（.share() で複数購読を効率化）
    final stream = query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();
    }).asBroadcastStream();

    _streamCache[cacheKey] = stream;
    return stream;
  }

  @override
  Stream<List<TaskModel>> watchGroupTasks(String groupId) {
    // キャッシュキーを生成
    final cacheKey = 'group_tasks_$groupId';

    // キャッシュに存在すれば返す
    if (_streamCache.containsKey(cacheKey)) {
      return _streamCache[cacheKey]!;
    }

    // Stream をキャッシュに保存（.share() で複数購読を効率化）
    final stream = _groupTasksRef(groupId)
        .where('isArchived', isEqualTo: false)
        .orderBy('nextDueAt')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TaskModel.fromFirestore(doc))
              .toList();
        })
        .asBroadcastStream();

    _streamCache[cacheKey] = stream;
    return stream;
  }

  @override
  Future<String> createTask(String uid, TaskModel task) async {
    try {
      final data = task.toFirestore();
      final docRef = await _userTasksRef(uid).add(data);
      return docRef.id;
    } catch (e) {
      throw _handleFirestoreError(e, '作成');
    }
  }

  @override
  Future<String> createGroupTask(String groupId, TaskModel task) async {
    try {
      final data = task.toFirestore();
      final docRef = await _groupTasksRef(groupId).add(data);
      return docRef.id;
    } catch (e) {
      throw _handleFirestoreError(e, 'グループタスク作成');
    }
  }

  @override
  Future<List<String>> createTasksBatch(String uid, List<TaskModel> tasks) async {
    try {
      final batch = _firestore.batch();
      final taskIds = <String>[];

      for (final task in tasks) {
        final docRef = _userTasksRef(uid).doc();
        batch.set(docRef, task.toFirestore());
        taskIds.add(docRef.id);
      }

      await batch.commit();
      return taskIds;
    } catch (e) {
      throw _handleFirestoreError(e, 'バッチ作成');
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
    } catch (e) {
      throw _handleFirestoreError(e, '更新');
    }
  }

  @override
  Future<void> updateTasksBatch(
    String uid,
    List<({String taskId, Map<String, dynamic> data})> updates,
  ) async {
    try {
      final batch = _firestore.batch();

      for (final update in updates) {
        batch.update(
          _userTasksRef(uid).doc(update.taskId),
          {
            ...update.data,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
      }

      await batch.commit();
    } catch (e) {
      throw _handleFirestoreError(e, 'バッチ更新');
    }
  }

  @override
  Future<void> deleteTask(String uid, String taskId) async {
    try {
      await _userTasksRef(uid).doc(taskId).delete();
    } catch (e) {
      throw _handleFirestoreError(e, '削除');
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
    } catch (e) {
      throw _handleFirestoreError(e, '完了');
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
    } catch (e) {
      throw _handleFirestoreError(e, '延期');
    }
  }

  @override
  Future<TaskModel?> getTask(String uid, String taskId) async {
    try {
      final doc = await _userTasksRef(uid).doc(taskId).get();
      if (!doc.exists) return null;
      return TaskModel.fromFirestore(doc);
    } catch (e) {
      throw _handleFirestoreError(e, '取得');
    }
  }
}
