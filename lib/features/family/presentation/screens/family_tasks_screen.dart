import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../providers/family_provider.dart';

/// 家族タスク画面
///
/// 指定メンバー（[targetUid]）が担当する共有グループタスクの一覧を表示する。
class FamilyTasksScreen extends ConsumerWidget {
  final String targetUid;
  final String name;

  const FamilyTasksScreen({
    super.key,
    required this.targetUid,
    required this.name,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(memberSharedTasksProvider(targetUid));

    return Scaffold(
      appBar: AppBar(title: Text('$nameのタスク')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(memberSharedTasksProvider(targetUid));
          await ref.read(memberSharedTasksProvider(targetUid).future);
        },
        child: tasksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('エラー: $e')),
          data: (tasks) {
            if (tasks.isEmpty) {
              return _EmptyView(name: name);
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, i) => _FamilyTaskCard(task: tasks[i]),
            );
          },
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String name;
  const _EmptyView({required this.name});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.task_alt_rounded,
                    size: 64, color: Colors.grey.shade300),
                const Gap(16),
                Text(
                  '$nameが担当する共有タスクはありません',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FamilyTaskCard extends StatelessWidget {
  final TaskEntity task;
  const _FamilyTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final isOverdue = AppDateUtils.isOverdue(task.nextDueAt);
    final daysUntil = AppDateUtils.daysUntil(task.nextDueAt);
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
                color: isOverdue
                    ? AppTheme.errorColor.withOpacity(0.1)
                    : AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.assignment_rounded,
                color: isOverdue ? AppTheme.errorColor : AppTheme.primaryColor,
                size: 20,
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isOverdue ? AppTheme.errorColor : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isOverdue
                    ? '${daysUntil.abs()}日前'
                    : daysUntil == 0
                        ? '今日'
                        : daysUntil == 1
                            ? '明日'
                            : '$daysUntil日後',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isOverdue ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
