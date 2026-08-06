import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/providers/tasks_provider.dart';

/// 完了履歴画面
///
/// 過去に完了したタスクを月ごとにグルーピングして表示する。
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(completedTasksHistoryProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final locale =
        profile != null ? '${profile.language}-${profile.country}' : 'ja-JP';

    return Scaffold(
      appBar: AppBar(title: const Text('完了履歴')),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (tasks) {
          if (tasks.isEmpty) {
            return _EmptyView();
          }
          final groups = _groupByMonth(tasks);
          final monthKeys = groups.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: monthKeys.length,
            itemBuilder: (context, i) {
              final monthKey = monthKeys[i];
              final monthTasks = groups[monthKey]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Text(
                      _formatMonthLabel(monthKey, locale),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  ...monthTasks.map(
                    (task) => _HistoryCard(task: task, locale: locale),
                  ),
                  const Gap(8),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Map<String, List<TaskEntity>> _groupByMonth(List<TaskEntity> tasks) {
    final map = <String, List<TaskEntity>>{};
    for (final task in tasks) {
      final d = task.lastDoneAt!;
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => []).add(task);
    }
    return map;
  }

  String _formatMonthLabel(String key, String locale) {
    final parts = key.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final lang = locale.split('-').first;
    if (lang == 'ja') return '$year年$month月';
    return '$year/$month';
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade300),
          const Gap(16),
          Text(
            'まだ完了したタスクがありません',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final TaskEntity task;
  final String locale;
  const _HistoryCard({required this.task, required this.locale});

  @override
  Widget build(BuildContext context) {
    final dateLabel = AppDateUtils.formatShort(task.lastDoneAt!, locale);
    final categoryLabel = task.categoryLabels.isNotEmpty
        ? task.categoryLabels.join(' > ')
        : task.categoryId;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppTheme.accentColor,
                size: 22,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    categoryLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  dateLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (task.cost != null) ...[
                  const Gap(2),
                  Text(
                    '¥${task.cost!.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
