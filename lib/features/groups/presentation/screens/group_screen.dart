import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/groups_provider.dart';
import '../../domain/entities/group_entity.dart';

/// グループ管理画面
class GroupScreen extends ConsumerWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(userGroupsProvider);
    final currentUid = ref.watch(currentUserProvider)?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('グループ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showCreateGroupDialog(context, ref),
          ),
        ],
      ),
      body: groupsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (groups) {
          if (groups.isEmpty) {
            return _EmptyGroupView(
              onCreateGroup: () => _showCreateGroupDialog(context, ref),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            itemBuilder: (context, i) => _GroupCard(
              group: groups[i],
              currentUid: currentUid,
            ),
          );
        },
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _CreateGroupDialog(ref: ref),
    );
  }
}

class _EmptyGroupView extends StatelessWidget {
  final VoidCallback onCreateGroup;

  const _EmptyGroupView({required this.onCreateGroup});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_rounded, size: 72, color: Colors.grey.shade300),
            const Gap(24),
            Text(
              'グループをまだ作成していません',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const Gap(8),
            Text(
              '家族やチームでタスクを共同管理できます',
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const Gap(24),
            FilledButton.icon(
              onPressed: onCreateGroup,
              icon: const Icon(Icons.add_rounded),
              label: const Text('グループを作成する'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final GroupEntity group;
  final String currentUid;

  const _GroupCard({required this.group, required this.currentUid});

  @override
  Widget build(BuildContext context) {
    final isOwner = group.ownerUid == currentUid;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.goNamed(
          'group-detail',
          pathParameters: {'groupId': group.groupId},
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.group_rounded,
                        color: AppTheme.primaryColor),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${group.memberCount}人のメンバー',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isOwner)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'オーナー',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ),
                ],
              ),
              const Gap(12),
              Row(
                children: [
                  Icon(Icons.task_alt_rounded,
                      size: 16, color: Colors.grey.shade500),
                  const Gap(4),
                  Text(
                    'グループタスク',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => GroupInviteDialog(
                          groupId: group.groupId,
                          groupName: group.name,
                        ),
                      );
                    },
                    child: const Text('メンバーを招待'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateGroupDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const _CreateGroupDialog({required this.ref});

  @override
  ConsumerState<_CreateGroupDialog> createState() =>
      _CreateGroupDialogState();
}

class _CreateGroupDialogState extends ConsumerState<_CreateGroupDialog> {
  final _nameController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _isCreating = true);
    try {
      await ref.read(groupNotifierProvider.notifier).createGroup(name);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('作成に失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('グループを作成'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'グループ名',
              hintText: '例: 田中家',
            ),
            autofocus: true,
            onSubmitted: (_) => _create(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        _isCreating
            ? const Padding(
                padding: EdgeInsets.all(8),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : FilledButton(
                onPressed: _create,
                child: const Text('作成'),
              ),
      ],
    );
  }
}

/// グループ招待ダイアログ
class GroupInviteDialog extends ConsumerStatefulWidget {
  final String groupId;
  final String groupName;

  const GroupInviteDialog({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  ConsumerState<GroupInviteDialog> createState() => _GroupInviteDialogState();
}

class _GroupInviteDialogState extends ConsumerState<GroupInviteDialog> {
  final _emailController = TextEditingController();
  bool _isSending = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendInvitation() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    setState(() => _isSending = true);
    try {
      await ref
          .read(groupNotifierProvider.notifier)
          .inviteMember(widget.groupId, email);
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('招待に失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.groupName}にメンバーを招待'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_sent) ...[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'メールアドレス',
                hintText: 'example@email.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const Gap(8),
            Text(
              '招待メールが送信されます。リンクは7日間有効です。',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ] else ...[
            const Icon(Icons.check_circle_rounded,
                color: AppTheme.accentColor, size: 48),
            const Gap(12),
            const Text('招待メールを送信しました！'),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
        if (!_sent)
          _isSending
              ? const Padding(
                  padding: EdgeInsets.all(8),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : FilledButton(
                  onPressed: _sendInvitation,
                  child: const Text('招待する'),
                ),
      ],
    );
  }
}
