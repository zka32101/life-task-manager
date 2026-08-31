import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/presentation/widgets/error_handler.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/tasks_provider.dart';

/// タスク検索画面
///
/// ユーザーの個人タスクをタイトル・カテゴリで絞り込み検索する。
class TaskSearchScreen extends ConsumerStatefulWidget {
  const TaskSearchScreen({super.key});

  @override
  ConsumerState<TaskSearchScreen> createState() => _TaskSearchScreenState();
}

class _TaskSearchScreenState extends ConsumerState<TaskSearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(userTasksProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'タスクを検索...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
          ),
          onChanged: (v) => setState(() => _query = v.trim()),
        ),
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorHandlerWidget(
        errorInfo: ErrorInfo.fromException(e),
      ),
        data: (tasks) {
          if (_query.isEmpty) {
            return _EmptyQueryView();
          }

          final lower = _query.toLowerCase();
          final results = tasks.where((t) {
            if (t.isArchived) return false;
            if (t.title.toLowerCase().contains(lower)) return true;
            if (t.categoryLabels.any((l) => l.toLowerCase().contains(lower))) {
              return true;
            }
            if (t.description?.toLowerCase().contains(lower) == true) {
              return true;
            }
            if (t.notes?.toLowerCase().contains(lower) == true) return true;
            return false;
          }).toList();

          if (results.isEmpty) {
            return _NoResultsView(query: _query);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, i) => _SearchResultCard(task: results[i]),
          );
        },
      ),
    );
  }
}

class _EmptyQueryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded, size: 64, color: Colors.grey.shade300),
          const Gap(16),
          Text(
            'タイトル・カテゴリで検索',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _NoResultsView extends StatelessWidget {
  final String query;
  const _NoResultsView({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
          const Gap(16),
          Text(
            '「$query」に一致するタスクがありません',
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final TaskEntity task;
  const _SearchResultCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final daysUntil = AppDateUtils.daysUntil(task.nextDueAt);
    final isOverdue = AppDateUtils.isOverdue(task.nextDueAt);
    final isUrgent = daysUntil <= 7 && !isOverdue;
    final categoryLabel = task.categoryLabels.isNotEmpty
        ? task.categoryLabels.join(' > ')
        : task.categoryId;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.goNamed(
          'task-detail',
          pathParameters: {'id': task.taskId},
          queryParameters:
              task.groupId != null ? {'groupId': task.groupId!} : {},
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // カテゴリアイコン
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isOverdue
                      ? AppTheme.errorColor.withOpacity(0.1)
                      : isUrgent
                          ? AppTheme.warningColor.withOpacity(0.1)
                          : AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.task_alt_rounded,
                  color: isOverdue
                      ? AppTheme.errorColor
                      : isUrgent
                          ? AppTheme.warningColor
                          : AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const Gap(12),
              // タイトル・カテゴリ
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
              // 期限バッジ
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOverdue
                      ? AppTheme.errorColor
                      : isUrgent
                          ? AppTheme.warningColor
                          : Colors.grey.shade100,
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
                    color: isOverdue || isUrgent
                        ? Colors.white
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
