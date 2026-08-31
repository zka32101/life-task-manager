import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/task_entity.dart';
import '../../presentation/providers/tasks_provider.dart';
import '../widgets/defer_bottom_sheet.dart';
import '../widgets/ai_advisor_sheet.dart';
import '../widgets/complete_task_sheet.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// タスク詳細画面 — Riverpod ベース
class TaskDetailScreen extends ConsumerWidget {
  final String taskId;
  final String? groupId;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
    this.groupId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // taskByIdProvider でタスクを取得
    final taskAsync =
        ref.watch(taskByIdProvider((taskId: taskId, groupId: groupId)));

    return taskAsync.when(
      data: (task) => task != null
          ? _TaskDetailView(task: task, taskId: taskId, groupId: groupId)
          : _ErrorScreen(
              title: 'タスクが見つかりません',
              message: 'このタスクは削除されているか、アクセス権限がありません。',
            ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => _ErrorScreen(
        title: 'エラーが発生しました',
        message: error.toString(),
      ),
    );
  }
}

/// エラー表示画面
class _ErrorScreen extends StatelessWidget {
  final String title;
  final String message;

  const _ErrorScreen({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('タスク詳細')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
            const Gap(16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Gap(8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ),
            const Gap(24),
            FilledButton(
              onPressed: () => context.pop(),
              child: const Text('戻る'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskDetailView extends ConsumerWidget {
  final TaskEntity task;
  final String taskId;
  final String? groupId;

  const _TaskDetailView({
    required this.task,
    required this.taskId,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverdue = AppDateUtils.isOverdue(task.nextDueAt);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final locale =
        profile != null ? '${profile.language}-${profile.country}' : 'ja-JP';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          task.title,
          style: const TextStyle(fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: '編集',
            onPressed: () => context.pushNamed(
              'task-edit',
              pathParameters: {'id': task.taskId},
            ),
          ),
          IconButton(
            icon: const Icon(Icons.support_agent_rounded),
            tooltip: 'AIに相談',
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => AiAdvisorSheet(task: task),
            ),
          ),
          PopupMenuButton<_TaskMenuAction>(
            icon: const Icon(Icons.more_vert),
            onSelected: (action) => _handleMenuAction(context, ref, action),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: _TaskMenuAction.archive,
                child: Row(
                  children: [
                    Icon(Icons.archive_outlined, size: 20),
                    Gap(12),
                    Text('アーカイブ'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: _TaskMenuAction.delete,
                child: Row(
                  children: [
                    Icon(Icons.delete_outline,
                        size: 20, color: AppTheme.errorColor),
                    Gap(12),
                    Text('削除',
                        style: TextStyle(color: AppTheme.errorColor)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // カテゴリパス
                    _CategoryChips(labels: task.categoryLabels),
                    const Gap(20),

                    // 次回予定日（大きく表示）
                    _DueDateSection(
                      dueDate: task.nextDueAt,
                      isOverdue: isOverdue,
                      locale: locale,
                    ),
                    const Gap(16),

                    // 繰り返し設定
                    _InfoRow(
                      icon: Icons.repeat_rounded,
                      label: '繰り返し',
                      value: _recurrenceLabel(task),
                    ),
                    const Divider(height: 24),

                    // リマインダー
                    _InfoRow(
                      icon: Icons.notifications_outlined,
                      label: 'リマインダー',
                      value: task.reminderDaysBefore == 0
                          ? 'なし'
                          : '${task.reminderDaysBefore}日前',
                    ),
                    const Divider(height: 24),

                    // メモ
                    if (task.notes != null && task.notes!.isNotEmpty) ...[
                      _NotesSection(notes: task.notes!),
                      const Divider(height: 24),
                    ],

                    // 費用
                    if (task.cost != null) ...[
                      _InfoRow(
                        icon: Icons.payments_outlined,
                        label: '費用',
                        value:
                            '${task.costCurrency ?? '¥'}${task.cost!.toStringAsFixed(0)}',
                      ),
                      const Divider(height: 24),
                    ],

                    // 延期回数
                    if (task.deferCount > 0) ...[
                      _InfoRow(
                        icon: Icons.redo_rounded,
                        label: '延期回数',
                        value: '${task.deferCount}回',
                        valueColor: AppTheme.warningColor,
                      ),
                      const Divider(height: 24),
                    ],

                    // グループ情報
                    if (task.isGroupTask) ...[
                      _GroupSection(task: task),
                      const Divider(height: 24),
                    ],

                    // 作成日・更新日
                    _MetaSection(task: task, locale: locale),

                    // 最終完了情報
                    if (task.lastDoneAt != null) ...[
                      const Gap(8),
                      _InfoRow(
                        icon: Icons.check_circle_outline,
                        label: '最終完了',
                        value: AppDateUtils.formatDate(task.lastDoneAt!, locale),
                      ),
                    ],

                    const Gap(16),
                  ],
                ),
              ),
            ),

            // Bottom buttons
            _BottomButtons(
              task: task,
              taskId: taskId,
              groupId: groupId,
              locale: locale,
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref,
      _TaskMenuAction action) {
    switch (action) {
      case _TaskMenuAction.archive:
        _confirmArchive(context, ref);
      case _TaskMenuAction.delete:
        _confirmDelete(context, ref);
    }
  }

  void _confirmArchive(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('アーカイブしますか？'),
        content: const Text('このタスクをアーカイブします。後で設定から復元できます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _archiveTask(context, ref);
            },
            child: const Text('アーカイブ'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('タスクを削除しますか？'),
        content: const Text('この操作は元に戻せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _deleteTask(context, ref);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  Future<void> _archiveTask(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(taskNotifierProvider.notifier).updateTask(
            taskId,
            {'isArchived': true},
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('アーカイブしました')),
        );
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _deleteTask(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(taskNotifierProvider.notifier).deleteTask(taskId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('削除しました')),
        );
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  String _recurrenceLabel(TaskEntity task) {
    switch (task.recurrenceType) {
      case 'none':
        return 'なし（1回のみ）';
      case 'weekly':
        return '毎週';
      case 'biweekly':
        return '隔週';
      case 'monthly':
        return '毎月';
      case 'quarterly':
        return '3ヶ月ごと';
      case 'yearly':
        return '毎年';
      case 'custom':
        if (task.recurrenceValue != null && task.recurrenceUnit != null) {
          final unitLabel = _unitLabel(task.recurrenceUnit!);
          return '${task.recurrenceValue}${unitLabel}ごと';
        }
        return 'カスタム';
      default:
        return task.recurrenceType;
    }
  }

  String _unitLabel(String unit) {
    switch (unit) {
      case 'days':
        return '日';
      case 'weeks':
        return '週';
      case 'months':
        return 'ヶ月';
      case 'years':
        return '年';
      default:
        return unit;
    }
  }
}

enum _TaskMenuAction { archive, delete }

// ─────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final List<String> labels;

  const _CategoryChips({required this.labels});

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: labels
          .map(
            (label) => Chip(
              label: Text(
                label,
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: AppTheme.primaryLight,
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          )
          .toList(),
    );
  }
}

class _DueDateSection extends StatelessWidget {
  final DateTime dueDate;
  final bool isOverdue;
  final String locale;

  const _DueDateSection({
    required this.dueDate,
    required this.isOverdue,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final color = isOverdue ? AppTheme.errorColor : AppTheme.primaryColor;
    final relativeLabel = AppDateUtils.formatRelative(dueDate, locale);
    final absoluteLabel = AppDateUtils.formatDate(dueDate, locale);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOverdue
            ? AppTheme.errorColor.withOpacity(0.08)
            : AppTheme.primaryColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOverdue ? Icons.warning_amber_rounded : Icons.calendar_today_rounded,
            color: color,
            size: 28,
          ),
          const Gap(12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '次回予定日',
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(2),
              Text(
                absoluteLabel,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                relativeLabel,
                style: TextStyle(
                  fontSize: 13,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const Gap(12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _NotesSection extends StatelessWidget {
  final String notes;

  const _NotesSection({required this.notes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.notes_rounded, size: 20, color: Colors.grey.shade600),
            const Gap(12),
            Text(
              'メモ',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const Gap(8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            notes,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
      ],
    );
  }
}

class _GroupSection extends StatelessWidget {
  final TaskEntity task;

  const _GroupSection({required this.task});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.group_rounded, size: 20, color: Colors.grey.shade600),
            const Gap(12),
            Text(
              'グループタスク',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        if (task.mainAssigneeUid != null) ...[
          const Gap(8),
          Row(
            children: [
              const Gap(32),
              Text(
                'メイン担当: ',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
              Text(
                task.mainAssigneeUid!,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ],
        if (task.assigneeUids.isNotEmpty) ...[
          const Gap(4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(32),
              Text(
                '担当者: ',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
              Expanded(
                child: Text(
                  task.assigneeUids.join(', '),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _MetaSection extends StatelessWidget {
  final TaskEntity task;
  final String locale;

  const _MetaSection({required this.task, required this.locale});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoRow(
          icon: Icons.add_circle_outline,
          label: '作成日',
          value: AppDateUtils.formatDate(task.createdAt, locale),
        ),
        const Gap(8),
        _InfoRow(
          icon: Icons.update_rounded,
          label: '更新日',
          value: AppDateUtils.formatDate(task.updatedAt, locale),
        ),
      ],
    );
  }
}

class _BottomButtons extends ConsumerWidget {
  final TaskEntity task;
  final String taskId;
  final String? groupId;
  final String locale;

  const _BottomButtons({
    required this.task,
    required this.taskId,
    required this.groupId,
    required this.locale,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => CompleteTaskSheet(
                  task: task,
                  groupId: groupId,
                  locale: locale,
                  onCompleted: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('完了しました！'),
                        backgroundColor: AppTheme.accentColor,
                      ),
                    );
                  },
                ),
              ),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('完了にする'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                minimumSize: const Size(0, 48),
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showDeferSheet(context),
              icon: const Icon(Icons.redo_rounded),
              label: const Text('延期する'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeferSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DeferBottomSheet(
        task: task,
        onDefer: (newDueAt, reason) =>
            _deferTask(context, newDueAt, reason),
      ),
    );
  }

  Future<void> _deferTask(
    BuildContext context,
    DateTime newDueAt,
    String? reason,
  ) async {
    try {
      final updateData = <String, dynamic>{
        'nextDueAt': newDueAt,
        'deferCount': (task.deferCount) + 1,
        'deferredAt': DateTime.now(),
      };

      if (task.originalDueAt == null) {
        updateData['originalDueAt'] = task.nextDueAt;
      }

      if (reason != null && reason.isNotEmpty) {
        updateData['notes'] = reason;
      }

      // Note: updateTask は uid を自動取得します
      // datasource で currentUser を確認する必要があります
      final notifier = context.read(taskNotifierProvider.notifier);
      await notifier.updateTask(taskId, updateData);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('延期しました')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
