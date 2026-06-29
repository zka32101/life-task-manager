import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/trial_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../groups/presentation/providers/groups_provider.dart';
import '../providers/tasks_provider.dart';
import '../../domain/entities/task_entity.dart';

/// ホーム画面
/// - タスク一覧（今日/今週/すべて）
/// - トライアル残日数バナー（残7日以下）
/// - FAB でタスク追加
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedGroupIndex = 0; // 0=個人、1以降=グループ

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remainingTrialDays = ref.watch(remainingTrialDaysProvider);
    final accessStatus = ref.watch(userAccessStatusProvider);
    final isPaid = accessStatus == UserAccessStatus.paid;
    final bool showTrialWarning =
        !isPaid && remainingTrialDays > 0 && remainingTrialDays <= AppConstants.trialWarningDays;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'LifeTask Manager',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.goNamed('search'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.goNamed('settings'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '今日'),
            Tab(text: '今週'),
            Tab(text: 'すべて'),
          ],
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
        ),
      ),
      body: Column(
        children: [
          // トライアル警告バナー
          if (showTrialWarning)
            _TrialWarningBanner(remainingDays: remainingTrialDays),

          // グループタブ（個人 + グループ一覧）
          _GroupSelector(
            selectedIndex: _selectedGroupIndex,
            onChanged: (i) => setState(() => _selectedGroupIndex = i),
          ),

          // タスク一覧
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _TaskList(
                  filter: TaskFilter.today,
                  groupIndex: _selectedGroupIndex,
                ),
                _TaskList(
                  filter: TaskFilter.thisWeek,
                  groupIndex: _selectedGroupIndex,
                ),
                _TaskList(
                  filter: TaskFilter.all,
                  groupIndex: _selectedGroupIndex,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.goNamed('task-new'),
        child: const Icon(Icons.add_rounded),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'ホーム',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group_rounded),
            label: 'グループ',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: '設定',
          ),
        ],
        selectedIndex: 0,
        onDestinationSelected: (i) {
          switch (i) {
            case 1:
              context.goNamed('groups');
            case 2:
              context.goNamed('settings');
          }
        },
      ),
    );
  }
}

/// トライアル警告バナー（残 N 日以下で表示）
class _TrialWarningBanner extends StatelessWidget {
  final int remainingDays;

  const _TrialWarningBanner({required this.remainingDays});

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      backgroundColor: AppTheme.warningColor.withOpacity(0.1),
      leading: const Icon(Icons.warning_amber_rounded,
          color: AppTheme.warningColor),
      content: Text(
        '⚠️ 無料期間残 $remainingDays 日',
        style: const TextStyle(
          color: AppTheme.warningColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.goNamed(
            'paywall',
            queryParameters: {'remaining': remainingDays.toString()},
          ),
          child: const Text('今すぐ購入して続ける →'),
        ),
      ],
    );
  }
}

/// グループ選択バー
class _GroupSelector extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _GroupSelector({
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(userGroupsProvider);
    final groups = groupsAsync.valueOrNull ?? [];

    return Container(
      color: Colors.white,
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: groups.length + 2, // 個人 + グループ数 + 追加ボタン
        itemBuilder: (context, i) {
          // 最後のアイテムはグループ追加ボタン
          if (i == groups.length + 1) {
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ActionChip(
                avatar: const Icon(Icons.add, size: 16),
                label: const Text('グループ'),
                onPressed: () => context.goNamed('groups'),
              ),
            );
          }
          // i==0 は「個人」
          final label = i == 0 ? '個人' : groups[i - 1].name;
          final isSelected = selectedIndex == i;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onChanged(i),
              selectedColor: AppTheme.primaryLight,
            ),
          );
        },
      ),
    );
  }
}

enum TaskFilter { today, thisWeek, all }

/// タスク一覧（Riverpod 接続済み）
class _TaskList extends ConsumerWidget {
  final TaskFilter filter;
  final int groupIndex;

  const _TaskList({
    required this.filter,
    required this.groupIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(userGroupsProvider);
    final groups = groupsAsync.valueOrNull ?? [];

    // グループタスク or 個人タスクを選択
    AsyncValue<List<TaskEntity>> tasksAsync;
    if (groupIndex > 0 && groups.length >= groupIndex) {
      final groupId = groups[groupIndex - 1].groupId;
      tasksAsync = ref.watch(groupTasksProvider(groupId));
    } else {
      switch (filter) {
        case TaskFilter.today:
          tasksAsync = ref.watch(todayTasksProvider);
        case TaskFilter.thisWeek:
          tasksAsync = ref.watch(thisWeekTasksProvider);
        case TaskFilter.all:
          tasksAsync = ref.watch(userTasksProvider);
      }
    }

    return tasksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('エラー: $e')),
      data: (tasks) {
        // 非アーカイブのみ表示
        final visible = tasks.where((t) => !t.isArchived).toList();

        if (visible.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.checklist_rounded,
                    size: 64, color: Colors.grey.shade300),
                const Gap(16),
                Text(
                  'タスクはありません',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
                const Gap(8),
                TextButton.icon(
                  onPressed: () => context.goNamed('task-new'),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('タスクを追加'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: visible.length,
          itemBuilder: (context, i) => _TaskCard(task: visible[i]),
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskEntity task;

  const _TaskCard({required this.task});

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
          queryParameters: task.groupId != null ? {'groupId': task.groupId!} : {},
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
                    if (task.isGroupTask) ...[
                      const Gap(2),
                      Row(
                        children: [
                          Icon(Icons.group, size: 12, color: Colors.grey.shade400),
                          const Gap(4),
                          Text(
                            'グループタスク',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // 期限バッジ
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
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
