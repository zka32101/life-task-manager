import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_task_manager/features/auth/presentation/providers/auth_provider.dart';
import 'package:life_task_manager/features/tasks/data/datasources/task_firestore_datasource.dart';
import 'package:life_task_manager/features/tasks/data/models/task_model.dart';
import 'package:life_task_manager/features/tasks/domain/entities/task_entity.dart';

// ---------------------------------------------------------------------------
// DataSource Provider
// ---------------------------------------------------------------------------

final taskDatasourceProvider = Provider<TaskFirestoreDatasource>((ref) {
  return TaskFirestoreDatasourceImpl();
});

// ---------------------------------------------------------------------------
// 選択中グループ
// ---------------------------------------------------------------------------

/// 現在選択中のグループID（null = 個人タスク表示）
final selectedGroupIdProvider = StateProvider<String?>((ref) => null);

// ---------------------------------------------------------------------------
// タスク一覧
// ---------------------------------------------------------------------------

/// ログイン中ユーザーの個人タスクをリアルタイム監視
final userTasksProvider = StreamProvider<List<TaskEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  return ref
      .watch(taskDatasourceProvider)
      .watchUserTasks(user.uid)
      .map((models) => models.map((m) => m.toEntity()).toList());
});

/// 指定グループのタスクをリアルタイム監視
final groupTasksProvider =
    StreamProvider.family<List<TaskEntity>, String>((ref, groupId) {
  return ref
      .watch(taskDatasourceProvider)
      .watchGroupTasks(groupId)
      .map((models) => models.map((m) => m.toEntity()).toList());
});

// ---------------------------------------------------------------------------
// フィルタ済みタスク
// ---------------------------------------------------------------------------

/// 今日以前が期限のタスク（今日のタスク一覧 / ホーム表示用）
final todayTasksProvider = Provider<AsyncValue<List<TaskEntity>>>((ref) {
  final tasksAsync = ref.watch(userTasksProvider);
  return tasksAsync.whenData((tasks) {
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return tasks
        .where((t) => t.nextDueAt.isBefore(todayEnd) || _isSameDay(t.nextDueAt, now))
        .toList();
  });
});

/// 今週が期限のタスク
final thisWeekTasksProvider = Provider<AsyncValue<List<TaskEntity>>>((ref) {
  final tasksAsync = ref.watch(userTasksProvider);
  return tasksAsync.whenData((tasks) {
    final now = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));
    return tasks
        .where((t) => !t.nextDueAt.isAfter(weekEnd))
        .toList();
  });
});

/// 期限切れタスク数（バッジ用）
final overdueTaskCountProvider = Provider<int>((ref) {
  final tasksAsync = ref.watch(userTasksProvider);
  return tasksAsync.when(
    data: (tasks) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return tasks
          .where((t) => t.nextDueAt.isBefore(today) && !t.isArchived)
          .length;
    },
    loading: () => 0,
    error: (e, st) => 0,
  );
});

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

// ---------------------------------------------------------------------------
// TaskNotifier — CRUD 操作
// ---------------------------------------------------------------------------

class TaskNotifier extends StateNotifier<AsyncValue<void>> {
  TaskNotifier(this._datasource, this._uid)
      : super(const AsyncValue.data(null));

  final TaskFirestoreDatasource _datasource;
  final String? _uid;

  String get _requireUid {
    final uid = _uid;
    if (uid == null) throw Exception('User not logged in');
    return uid;
  }

  /// タスクを作成し、新しい taskId を返す
  /// task.isGroupTask == true のとき、groups/{groupId}/tasks に保存する
  Future<String> createTask(TaskEntity task) async {
    state = const AsyncValue.loading();
    String taskId = '';
    state = await AsyncValue.guard(() async {
      final model = TaskModel.fromEntity(task);
      if (task.isGroupTask && task.groupId != null) {
        taskId = await _datasource.createGroupTask(task.groupId!, model);
      } else {
        taskId = await _datasource.createTask(_requireUid, model);
      }
    });
    // guard がエラーをキャッチした場合は再スロー（LateInitializationError を防ぐ）
    final currentState = state;
    if (currentState is AsyncError) {
      throw currentState.error;
    }
    return taskId;
  }

  /// タスクの任意フィールドを更新
  Future<void> updateTask(String taskId, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _datasource.updateTask(_requireUid, taskId, data);
    });
  }

  /// タスクを削除
  Future<void> deleteTask(String taskId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _datasource.deleteTask(_requireUid, taskId);
    });
  }

  /// タスクを完了済みにする
  Future<void> completeTask(String taskId, {DateTime? completedAt}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _datasource.completeTask(
        _requireUid,
        taskId,
        completedAt ?? DateTime.now(),
      );
    });
  }

  /// タスクを延期する
  Future<void> deferTask(
    String taskId,
    DateTime newDueAt, {
    String? reason,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _datasource.deferTask(_requireUid, taskId, newDueAt, reason);
    });
  }

  /// タスクをアーカイブする（isArchived = true）
  Future<void> archiveTask(String taskId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _datasource.updateTask(_requireUid, taskId, {'isArchived': true});
    });
  }
}

final taskNotifierProvider =
    StateNotifierProvider<TaskNotifier, AsyncValue<void>>((ref) {
  final user = ref.watch(currentUserProvider);
  return TaskNotifier(ref.watch(taskDatasourceProvider), user?.uid);
});
