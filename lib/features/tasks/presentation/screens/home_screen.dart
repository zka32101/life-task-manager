import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/trial_service.dart';
import '../../../../core/presentation/widgets/error_handler.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../groups/presentation/providers/groups_provider.dart';
import '../providers/tasks_provider.dart';
import '../../domain/entities/task_entity.dart';
import '../../../../core/services/health_score_service.dart';
import '../widgets/defer_bottom_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _filterIndex = 0; // 0=今日 1=今週 2=すべて
  int _selectedGroupIndex = 0;

  @override
  Widget build(BuildContext context) {
    final remainingTrialDays = ref.watch(remainingTrialDaysProvider);
    final isPaid = ref.watch(userAccessStatusProvider) == UserAccessStatus.paid;
    final showTrial = !isPaid &&
        remainingTrialDays > 0 &&
        remainingTrialDays <= AppConstants.trialWarningDays;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: _buildAppBar(context, showTrial, remainingTrialDays, isPaid),
      body: Column(
        children: [
          // ① ダッシュボードカード（1枚に統合）
          _DashboardCard(),

          // ② グループ + フィルター（1行）
          _FilterBar(
            filterIndex: _filterIndex,
            groupIndex: _selectedGroupIndex,
            onFilterChanged: (i) => setState(() => _filterIndex = i),
            onGroupChanged: (i) => setState(() => _selectedGroupIndex = i),
          ),

          // ③ タスク一覧
          Expanded(
            child: _TaskList(
              filterIndex: _filterIndex,
              groupIndex: _selectedGroupIndex,
            ),
          ),
        ],
      ),
      floatingActionButton: _QuickActionFab(),
      bottomNavigationBar: _BottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool showTrial,
    int remainingDays,
    bool isPaid,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          const Text(
            'LifeTask',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          // トライアル残日数チップ（AppBarに小さく）
          if (showTrial) ...[
            const Gap(8),
            GestureDetector(
              onTap: () => context.goNamed(
                'paywall',
                queryParameters: {'remaining': remainingDays.toString()},
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.warningColor.withOpacity(0.4),
                  ),
                ),
                child: Text(
                  '残$remainingDays日',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.warningColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        _NotificationBellButton(),
        IconButton(
          icon: const Icon(Icons.search_rounded),
          tooltip: '検索',
          onPressed: () => context.goNamed('search'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// 通知ベルボタン（未読バッジ付き）
// ─────────────────────────────────────────────────────────
class _NotificationBellButton extends StatelessWidget {
  const _NotificationBellButton();

  Stream<int> _unreadStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value(0);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notificationLogs')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _unreadStream(),
      builder: (context, snap) {
        final count = snap.data ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              tooltip: '通知',
              onPressed: () => context.goNamed('notifications'),
            ),
            if (count > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
// ① ダッシュボードカード（損失防止 + スコア + 予算を1枚に）
// ─────────────────────────────────────────────────────────
class _DashboardCard extends ConsumerWidget {
  const _DashboardCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scores = ref.watch(localHealthScoresProvider);
    final overall = HealthScoreService.overallScore(scores);
    final prevented = ref.watch(preventedLossProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final budget = profile?.yearlyBudgetTotal ?? 0.0;

    final overallColor = overall >= 80
        ? Colors.green.shade600
        : overall >= 60
            ? Colors.orange.shade600
            : Colors.red.shade600;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 総合スコア（大きく）
          GestureDetector(
            onTap: () => _showScoreDetail(context, scores, overall),
            child: Column(
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: overall / 100,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(overallColor),
                        strokeWidth: 5,
                      ),
                      Text(
                        '$overall',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: overallColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(4),
                Text(
                  '家計スコア',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
          Container(width: 1, height: 52, color: Colors.grey.shade100),
          const Gap(12),
          // 損失防止額 + 予算
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (prevented > 0) ...[
                  Row(
                    children: [
                      Icon(Icons.shield_rounded,
                          size: 14, color: Colors.green.shade600),
                      const Gap(4),
                      Text(
                        '今年の防衛額',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _fmt(prevented),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const Gap(4),
                ],
                if (budget > 0) ...[
                  Row(
                    children: [
                      Icon(Icons.event_note_rounded,
                          size: 14, color: Colors.blue.shade600),
                      const Gap(4),
                      Text(
                        '年間メンテ予算',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _fmt(budget),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
                if (prevented <= 0 && budget <= 0)
                  Text(
                    'タスクを完了するとここに\n実績が表示されます',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                      height: 1.4,
                    ),
                  ),
              ],
            ),
          ),
          const Gap(4),
          // 詳細へ
          Icon(Icons.chevron_right, color: Colors.grey.shade300, size: 20),
        ],
      ),
    );
  }

  void _showScoreDetail(
    BuildContext context,
    Map<String, int> scores,
    int overall,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ScoreDetailSheet(scores: scores, overall: overall),
    );
  }

  String _fmt(double v) => v >= 10000
      ? '¥${(v / 10000).toStringAsFixed(1)}万'
      : '¥${v.toInt()}';
}

class _ScoreDetailSheet extends StatelessWidget {
  final Map<String, int> scores;
  final int overall;

  const _ScoreDetailSheet({required this.scores, required this.overall});

  @override
  Widget build(BuildContext context) {
    const categories = [
      ('house', '🏠', '住宅'),
      ('vehicle', '🚗', '車'),
      ('health', '💊', '健康'),
      ('finance', '💰', 'お金'),
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '家計の健康スコア',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '総合 $overall点',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: overall >= 80
                      ? Colors.green
                      : overall >= 60
                          ? Colors.orange
                          : Colors.red,
                ),
              ),
            ],
          ),
          const Gap(16),
          ...categories.map((cat) {
            final score = scores[cat.$1] ?? 100;
            final color = score >= 80
                ? Colors.green
                : score >= 60
                    ? Colors.orange
                    : Colors.red;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Text(cat.$2, style: const TextStyle(fontSize: 20)),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(cat.$3,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w500)),
                            Text(
                              '$score点',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: color),
                            ),
                          ],
                        ),
                        const Gap(4),
                        LinearProgressIndicator(
                          value: score / 100,
                          color: color,
                          backgroundColor: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const Gap(8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// ② フィルターバー（グループ + 今日/今週/すべて）
// ─────────────────────────────────────────────────────────
class _FilterBar extends ConsumerWidget {
  final int filterIndex;
  final int groupIndex;
  final ValueChanged<int> onFilterChanged;
  final ValueChanged<int> onGroupChanged;

  const _FilterBar({
    required this.filterIndex,
    required this.groupIndex,
    required this.onFilterChanged,
    required this.onGroupChanged,
  });

  static const _filterLabels = ['今日', '今週', 'すべて'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(userGroupsProvider).valueOrNull ?? [];

    // 件数取得
    final todayCount = ref.watch(todayTasksProvider).whenOrNull(
          data: (t) => t.where((x) => !x.isArchived).length,
        ) ?? 0;
    final weekCount = ref.watch(thisWeekTasksProvider).whenOrNull(
          data: (t) => t.where((x) => !x.isArchived).length,
        ) ?? 0;
    final allCount = ref.watch(userTasksProvider).whenOrNull(
          data: (t) => t.where((x) => !x.isArchived).length,
        ) ?? 0;
    final counts = [todayCount, weekCount, allCount];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // グループ選択（グループがある場合）
          if (groups.isNotEmpty) ...[
            SizedBox(
              height: 32,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: groups.length + 1,
                itemBuilder: (ctx, i) {
                  final label = i == 0 ? '個人' : groups[i - 1].name;
                  final selected = groupIndex == i;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(label, style: const TextStyle(fontSize: 12)),
                      selected: selected,
                      onSelected: (_) => onGroupChanged(i),
                      selectedColor: AppTheme.primaryLight,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                },
              ),
            ),
            Container(
              width: 1,
              height: 24,
              color: Colors.grey.shade200,
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ],

          // 今日/今週/すべて セグメント（件数付き）
          Expanded(
            child: Row(
              children: List.generate(_filterLabels.length, (i) {
                final selected = filterIndex == i;
                final count = counts[i];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onFilterChanged(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _filterLabels[i],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: selected
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          ),
                          if (count > 0) ...[
                            const Gap(3),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: selected
                                    ? Colors.white.withOpacity(0.3)
                                    : AppTheme.primaryColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: selected
                                      ? Colors.white
                                      : AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// ③ タスク一覧
// ─────────────────────────────────────────────────────────
class _TaskList extends ConsumerWidget {
  final int filterIndex;
  final int groupIndex;

  const _TaskList({required this.filterIndex, required this.groupIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(userGroupsProvider).valueOrNull ?? [];

    AsyncValue<List<TaskEntity>> tasksAsync;
    if (groupIndex > 0 && groups.length >= groupIndex) {
      tasksAsync = ref.watch(groupTasksProvider(groups[groupIndex - 1].groupId));
    } else {
      tasksAsync = switch (filterIndex) {
        0 => ref.watch(todayTasksProvider),
        1 => ref.watch(thisWeekTasksProvider),
        _ => ref.watch(userTasksProvider),
      };
    }

    return tasksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorHandlerWidget(
        errorInfo: ErrorInfo.fromException(e),
      ),
      data: (tasks) {
        final visible = tasks.where((t) => !t.isArchived).toList();
        if (visible.isEmpty) return _EmptyState(filterIndex: filterIndex);

        // 期限切れを上に
        visible.sort((a, b) {
          final aOver = AppDateUtils.isOverdue(a.nextDueAt) ? 0 : 1;
          final bOver = AppDateUtils.isOverdue(b.nextDueAt) ? 0 : 1;
          if (aOver != bOver) return aOver.compareTo(bOver);
          return a.nextDueAt.compareTo(b.nextDueAt);
        });

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
          // +1 for swipe hint row at index 0
          itemCount: visible.length + 1,
          itemBuilder: (ctx, i) {
            if (i == 0) return const _SwipeHintRow();
            return _TaskCard(task: visible[i - 1]);
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final int filterIndex;
  const _EmptyState({required this.filterIndex});

  @override
  Widget build(BuildContext context) {
    final messages = [
      ('今日の期限タスクはありません', '予定通りです！'),
      ('今週の期限タスクはありません', 'ゆとりのある週です'),
      ('タスクがありません', 'LifeTaskを使い始めましょう'),
    ];
    final msg = messages[filterIndex.clamp(0, 2)];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt_rounded, size: 56, color: Colors.grey.shade300),
          const Gap(12),
          Text(
            msg.$1,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(4),
          Text(
            msg.$2,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
          const Gap(20),
          OutlinedButton.icon(
            onPressed: () => context.goNamed('task-new'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('タスクを追加'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// タスクカード（スワイプ操作対応版）
//   右スワイプ → 完了（緑）
//   左スワイプ → 延期シート（オレンジ）
// ─────────────────────────────────────────────────────────
class _TaskCard extends ConsumerWidget {
  final TaskEntity task;
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(task.taskId),
      background: _SwipeBg(
        color: Colors.green.shade500,
        icon: Icons.check_circle_rounded,
        label: '完了',
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _SwipeBg(
        color: AppTheme.warningColor,
        icon: Icons.redo_rounded,
        label: '延期',
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          HapticFeedback.mediumImpact();
          await _quickComplete(context, ref);
          return true;
        } else {
          HapticFeedback.lightImpact();
          await _showDeferSheet(context, ref);
          return false;
        }
      },
      child: _TaskCardContent(task: task),
    );
  }

  Future<void> _quickComplete(BuildContext context, WidgetRef ref) async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;

    final now = DateTime.now();
    final hasRecurrence = task.recurrenceType != 'none';

    final taskRef = task.isGroupTask && task.groupId != null
        ? FirebaseFirestore.instance
            .collection('groups')
            .doc(task.groupId)
            .collection('tasks')
            .doc(task.taskId)
        : FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('tasks')
            .doc(task.taskId);

    final updateData = <String, dynamic>{
      'lastDoneAt': Timestamp.fromDate(now),
      'lastDoneByUid': uid,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedByUid': uid,
    };

    if (hasRecurrence) {
      final nextDue = AppDateUtils.calculateNextDueDate(
        currentDueAt: task.nextDueAt,
        recurrenceType: task.recurrenceType,
        recurrenceValue: task.recurrenceValue,
        recurrenceUnit: task.recurrenceUnit,
      );
      updateData['nextDueAt'] = Timestamp.fromDate(nextDue);
      updateData['deferCount'] = 0;
    } else {
      updateData['isArchived'] = true;
    }

    try {
      await taskRef.update(updateData);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('「${task.title}」を完了しました'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 80),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('完了処理に失敗しました')),
        );
      }
    }
  }

  Future<void> _showDeferSheet(BuildContext context, WidgetRef ref) async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DeferBottomSheet(
        task: task,
        onDefer: (newDueAt, reason) async {
          final taskRef = task.isGroupTask && task.groupId != null
              ? FirebaseFirestore.instance
                  .collection('groups')
                  .doc(task.groupId)
                  .collection('tasks')
                  .doc(task.taskId)
              : FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('tasks')
                  .doc(task.taskId);

          final now = DateTime.now();
          final updateData = <String, dynamic>{
            'nextDueAt': Timestamp.fromDate(newDueAt),
            'deferCount': task.deferCount + 1,
            'deferredAt': Timestamp.fromDate(now),
            'deferredByUid': uid,
            'updatedAt': FieldValue.serverTimestamp(),
            'updatedByUid': uid,
          };
          if (task.originalDueAt == null) {
            updateData['originalDueAt'] =
                Timestamp.fromDate(task.nextDueAt);
          }
          if (reason != null && reason.isNotEmpty) {
            updateData['notes'] = reason;
          }
          await taskRef.update(updateData);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('延期しました'),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.fromLTRB(12, 0, 12, 80),
              ),
            );
          }
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// スワイプ操作ヒント（リスト先頭）
// ─────────────────────────────────────────────────────────
class _SwipeHintRow extends StatelessWidget {
  const _SwipeHintRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.swipe_right_alt_rounded,
              size: 14, color: Colors.green.shade400),
          const Gap(4),
          Text(
            '右: 完了',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          const Gap(16),
          Text(
            '左: 延期',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          const Gap(4),
          Icon(Icons.swipe_left_alt_rounded,
              size: 14, color: Colors.orange.shade400),
        ],
      ),
    );
  }
}

class _SwipeBg extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final Alignment alignment;

  const _SwipeBg({
    required this.color,
    required this.icon,
    required this.label,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment == Alignment.centerLeft;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isLeft
            ? [
                Icon(icon, color: Colors.white, size: 22),
                const Gap(6),
                Text(label,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ]
            : [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const Gap(6),
                Icon(icon, color: Colors.white, size: 22),
              ],
      ),
    );
  }
}

class _TaskCardContent extends StatelessWidget {
  final TaskEntity task;
  const _TaskCardContent({required this.task});

  @override
  Widget build(BuildContext context) {
    final daysUntil = AppDateUtils.daysUntil(task.nextDueAt);
    final isOverdue = AppDateUtils.isOverdue(task.nextDueAt);
    final isUrgent = daysUntil <= 7 && !isOverdue;

    final accentColor = isOverdue
        ? AppTheme.errorColor
        : isUrgent
            ? AppTheme.warningColor
            : AppTheme.primaryColor;

    final bgColor = isOverdue
        ? AppTheme.errorColor.withOpacity(0.06)
        : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: isOverdue
            ? Border.all(color: AppTheme.errorColor.withOpacity(0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.goNamed(
          'task-detail',
          pathParameters: {'id': task.taskId},
          queryParameters:
              task.groupId != null ? {'groupId': task.groupId!} : {},
        ),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // カテゴリアイコン
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: Text(
                    _categoryEmoji(task.categoryPath),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const Gap(12),

              // タイトル + 情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isOverdue ? AppTheme.errorColor : Colors.black87,
                      ),
                    ),
                    const Gap(3),
                    Row(
                      children: [
                        if (task.categoryLabels.isNotEmpty)
                          Expanded(
                            child: Text(
                              task.categoryLabels.last,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        else
                          const Spacer(),
                        // 繰り返し周期バッジ
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _recurrenceShortLabel(task),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                        if (task.isGroupTask) ...[
                          const Gap(4),
                          Icon(Icons.group_rounded,
                              size: 11, color: Colors.grey.shade400),
                        ],
                      ],
                    ),
                    // 期限切れ損失リスク表示
                    if (isOverdue && task.cost != null && task.cost! > 0) ...[
                      const Gap(2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '損失リスク ${_fmtCost(task.cost!)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.errorColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // 期限バッジ
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOverdue
                          ? AppTheme.errorColor
                          : isUrgent
                              ? AppTheme.warningColor
                              : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _daysLabel(daysUntil, isOverdue),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isOverdue || isUrgent
                            ? Colors.white
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  if (task.cost != null && task.cost! > 0 && !isOverdue) ...[
                    const Gap(4),
                    Text(
                      _fmtCost(task.cost!),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _daysLabel(int days, bool overdue) {
    if (overdue) return '${days.abs()}日超過';
    if (days == 0) return '今日';
    if (days == 1) return '明日';
    return '$days日後';
  }

  String _fmtCost(double cost) => cost >= 10000
      ? '¥${(cost / 10000).toStringAsFixed(1)}万'
      : '¥${cost.toInt()}';

  String _categoryEmoji(String path) {
    final p = path.toLowerCase();
    if (p.contains('house') || p.contains('住宅') || p.contains('外壁') ||
        p.contains('屋根') || p.contains('設備')) return '🏠';
    if (p.contains('vehicle') || p.contains('車') || p.contains('自動車') ||
        p.contains('バイク') || p.contains('車検')) return '🚗';
    if (p.contains('health') || p.contains('健康') || p.contains('医療') ||
        p.contains('歯科') || p.contains('検診')) return '🏥';
    if (p.contains('insurance') || p.contains('保険')) return '🛡️';
    if (p.contains('tax') || p.contains('税') || p.contains('確定申告')) return '📊';
    if (p.contains('finance') || p.contains('金融') || p.contains('年金') ||
        p.contains('投資') || p.contains('銀行')) return '💴';
    if (p.contains('legal') || p.contains('法') || p.contains('契約')) return '📝';
    if (p.contains('education') || p.contains('学') || p.contains('習い事')) return '📚';
    return '✅';
  }

  String _recurrenceShortLabel(TaskEntity task) {
    switch (task.recurrenceType) {
      case 'none': return '1回';
      case 'weekly': return '毎週';
      case 'biweekly': return '隔週';
      case 'monthly': return '毎月';
      case 'quarterly': return '3ヶ月毎';
      case 'yearly': return '毎年';
      case 'custom':
        if (task.recurrenceValue != null && task.recurrenceUnit != null) {
          final u = {'days': '日', 'weeks': '週', 'months': 'ヶ月', 'years': '年'}[task.recurrenceUnit] ?? '';
          return '${task.recurrenceValue}${u}毎';
        }
        return '繰り返し';
      default: return '';
    }
  }
}

// ─────────────────────────────────────────────────────────
// FAB（クイックアクション）
// ─────────────────────────────────────────────────────────
class _QuickActionFab extends StatelessWidget {
  const _QuickActionFab();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showQuickActions(context),
      child: const Icon(Icons.add_rounded),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_task_rounded,
                    color: AppTheme.primaryColor),
              ),
              title: const Text('タスクを追加',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('期限・費用・繰り返しを設定'),
              onTap: () {
                Navigator.pop(context);
                context.goNamed('task-new');
              },
            ),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.document_scanner_rounded,
                    color: Colors.purple.shade600),
              ),
              title: const Text('書類をスキャン',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('保険証券・車検証などを撮影して自動登録'),
              onTap: () {
                Navigator.pop(context);
                context.goNamed('scan');
              },
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// ボトムナビゲーション
// ─────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'ホーム',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history_rounded),
          label: '履歴',
        ),
        NavigationDestination(
          icon: Icon(Icons.group_outlined),
          selectedIcon: Icon(Icons.group_rounded),
          label: 'グループ',
        ),
        NavigationDestination(
          icon: Icon(Icons.family_restroom_outlined),
          selectedIcon: Icon(Icons.family_restroom_rounded),
          label: '家族',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings_rounded),
          label: '設定',
        ),
      ],
      onDestinationSelected: (i) {
        switch (i) {
          case 1: context.goNamed('history');
          case 2: context.goNamed('groups');
          case 3: context.goNamed('family');
          case 4: context.goNamed('settings');
        }
      },
    );
  }
}
