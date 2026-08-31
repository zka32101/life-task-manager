import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/presentation/widgets/error_handler.dart';
import '../../../../core/utils/date_utils.dart';
import '../providers/family_provider.dart';

/// 家族監視画面
///
/// 共有グループのメンバー一覧と、各メンバーの担当タスク状況（期限超過件数）を表示する。
class FamilyMonitorScreen extends ConsumerWidget {
  const FamilyMonitorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(familyMembersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('家族')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(familyMembersProvider);
          await ref.read(familyMembersProvider.future);
        },
        child: membersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorHandlerWidget(
        errorInfo: ErrorInfo.fromException(e),
      ),
          data: (members) {
            if (members.isEmpty) {
              return _EmptyView();
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: members.length,
              itemBuilder: (context, i) {
                final member = members[i];
                return _FamilyMemberCard(
                  uid: member.uid,
                  displayName: member.displayName,
                  email: member.email,
                  groupNames: member.groupNames,
                  onTap: () => context.goNamed(
                    'family-tasks',
                    queryParameters: {
                      'uid': member.uid,
                      'name': member.displayName,
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
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
                Icon(Icons.family_restroom_rounded,
                    size: 64, color: Colors.grey.shade300),
                const Gap(16),
                Text(
                  '共有グループに参加すると\n家族のタスク状況を確認できます',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500),
                ),
                const Gap(16),
                OutlinedButton(
                  onPressed: () => context.goNamed('groups'),
                  child: const Text('グループを見る'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FamilyMemberCard extends ConsumerWidget {
  final String uid;
  final String displayName;
  final String email;
  final List<String> groupNames;
  final VoidCallback onTap;

  const _FamilyMemberCard({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.groupNames,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(memberSharedTasksProvider(uid));
    final overdueCount = tasksAsync.valueOrNull
            ?.where((t) => AppDateUtils.isOverdue(t.nextDueAt))
            .length ??
        0;
    final totalCount = tasksAsync.valueOrNull?.length ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.primaryLight,
                child: Text(
                  displayName.isNotEmpty ? displayName[0] : '?',
                  style: const TextStyle(
                    color: AppTheme.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      groupNames.join(' / '),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              if (overdueCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '期限超過 $overdueCount',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                )
              else if (totalCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '順調',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentColor,
                    ),
                  ),
                ),
              const Gap(4),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
