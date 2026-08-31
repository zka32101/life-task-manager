import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:life_task_manager/core/theme/app_theme.dart';
import '../../../../core/presentation/widgets/error_handler.dart';
import '../providers/groups_provider.dart';

/// グループ詳細画面
class GroupDetailScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategoryId = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .snapshots(),
      builder: (context, profileSnap) {
        final snapData = (profileSnap.hasData && profileSnap.data!.exists)
            ? profileSnap.data!.data() as Map<String, dynamic>?
            : null;
        final groupName = snapData?['name'] as String? ?? 'グループ';
        final ownerUid = snapData?['ownerUid'] as String? ?? '';
        final isOwner = ownerUid == _currentUid;

        return Scaffold(
          appBar: AppBar(
            title: Text(groupName),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_rounded),
                onPressed: () =>
                    _showSettingsDialog(context, groupName, isOwner),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'タスク'),
                Tab(text: 'メンバー'),
              ],
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.primaryColor,
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _TasksTab(
                groupId: widget.groupId,
                selectedCategoryId: _selectedCategoryId,
                onCategoryChanged: (id) =>
                    setState(() => _selectedCategoryId = id),
              ),
              _MembersTab(
                groupId: widget.groupId,
                ownerUid: ownerUid,
                currentUid: _currentUid,
                groupName: groupName,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSettingsDialog(
      BuildContext context, String groupName, bool isOwner) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _GroupSettingsSheet(
        groupId: widget.groupId,
        groupName: groupName,
        isOwner: isOwner,
        currentUid: _currentUid,
      ),
    );
  }
}

// ─────────────────── タスクタブ ───────────────────

class _TasksTab extends StatelessWidget {
  final String groupId;
  final String selectedCategoryId;
  final ValueChanged<String> onCategoryChanged;

  const _TasksTab({
    required this.groupId,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('tasks')
          .where('isArchived', isEqualTo: false)
          .orderBy('nextDueAt')
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('エラー: ${snap.error}'));
        }

        final allDocs = snap.data?.docs ?? [];

        // カテゴリフィルター用のカテゴリ一覧を収集
        final categories = <String, String>{'all': 'すべて'};
        for (final doc in allDocs) {
          final data = doc.data() as Map<String, dynamic>;
          final catId = data['categoryId'] as String?;
          final catLabels = data['categoryLabels'] as List?;
          if (catId != null && catId.isNotEmpty) {
            final label = catLabels != null && catLabels.isNotEmpty
                ? catLabels.last as String
                : catId;
            categories[catId] = label;
          }
        }

        // フィルタリング
        final filteredDocs = selectedCategoryId == 'all'
            ? allDocs
            : allDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['categoryId'] == selectedCategoryId;
              }).toList();

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: Column(
            children: [
              // カテゴリフィルター
              if (categories.length > 1)
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: categories.entries.map((e) {
                      final selected = e.key == selectedCategoryId;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8, top: 8),
                        child: FilterChip(
                          label: Text(e.value),
                          selected: selected,
                          onSelected: (_) => onCategoryChanged(e.key),
                          selectedColor: AppTheme.primaryLight,
                          checkmarkColor: AppTheme.primaryDark,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              Expanded(
                child: filteredDocs.isEmpty
                    ? const _EmptyTasksView()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, i) {
                          final data = filteredDocs[i].data()
                              as Map<String, dynamic>;
                          return _TaskCard(data: data);
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.goNamed(
              'task-new',
              queryParameters: {'groupId': groupId},
            ),
            child: const Icon(Icons.add_rounded),
          ),
        );
      },
    );
  }
}

class _EmptyTasksView extends StatelessWidget {
  const _EmptyTasksView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt_rounded, size: 64, color: Colors.grey.shade300),
          const Gap(16),
          Text(
            'タスクがありません',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const Gap(8),
          Text(
            '右下の＋ボタンでタスクを追加しましょう',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _TaskCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final title = data['title'] as String? ?? '無題';
    final nextDueAt =
        (data['nextDueAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final catLabels = data['categoryLabels'] as List?;
    final categoryLabel =
        catLabels != null && catLabels.isNotEmpty ? catLabels.last as String : null;
    final isOverdue = nextDueAt.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
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
                color:
                    isOverdue ? AppTheme.errorColor : AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const Gap(4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 12, color: isOverdue ? AppTheme.errorColor : Colors.grey.shade500),
                      const Gap(4),
                      Text(
                        _formatDate(nextDueAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: isOverdue ? AppTheme.errorColor : Colors.grey.shade600,
                          fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      if (categoryLabel != null) ...[
                        const Gap(8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            categoryLabel,
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(DateTime(now.year, now.month, now.day)).inDays;
    if (diff == 0) return '今日';
    if (diff == 1) return '明日';
    if (diff == -1) return '昨日';
    if (diff < 0) return '${diff.abs()}日前';
    return '${dt.month}/${dt.day}';
  }
}

// ─────────────────── メンバータブ ───────────────────

class _MembersTab extends StatelessWidget {
  final String groupId;
  final String ownerUid;
  final String currentUid;
  final String groupName;

  const _MembersTab({
    required this.groupId,
    required this.ownerUid,
    required this.currentUid,
    required this.groupName,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('エラー: ${snap.error}'));
        }

        final members = snap.data?.docs ?? [];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...members.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final uid = doc.id;
              final displayName = data['displayName'] as String? ?? 'ユーザー';
              final email = data['email'] as String? ?? '';
              final isThisOwner = uid == ownerUid;
              final isCurrentUser = uid == currentUid;

              return _MemberCard(
                uid: uid,
                displayName: displayName,
                email: email,
                isOwner: isThisOwner,
                canRemove:
                    currentUid == ownerUid && !isThisOwner,
                onRemove: () => _removeMember(context, uid, displayName),
              );
            }),
            const Gap(16),
            OutlinedButton.icon(
              onPressed: () => _showInviteDialog(context),
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('メンバーを招待する'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: const BorderSide(color: AppTheme.primaryColor),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeMember(
      BuildContext context, String uid, String displayName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('メンバーを削除'),
        content: Text('$displayName をグループから削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              minimumSize: const Size(80, 40),
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .collection('members')
            .doc(uid)
            .delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$displayName を削除しました')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('削除に失敗しました: $e')),
          );
        }
      }
    }
  }

  void _showInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _InviteDialog(groupId: groupId, groupName: groupName),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final String uid;
  final String displayName;
  final String email;
  final bool isOwner;
  final bool canRemove;
  final VoidCallback onRemove;

  const _MemberCard({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.isOwner,
    required this.canRemove,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primaryLight,
              child: Text(
                displayName.isNotEmpty ? displayName[0] : '?',
                style: const TextStyle(
                    color: AppTheme.primaryDark, fontWeight: FontWeight.bold),
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      if (isOwner) ...[
                        const Gap(8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'オーナー',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Gap(2),
                  Text(
                    email,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (canRemove)
              TextButton(
                onPressed: onRemove,
                style: TextButton.styleFrom(
                    foregroundColor: AppTheme.errorColor),
                child: const Text('削除'),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────── 招待ダイアログ ───────────────────

class _InviteDialog extends ConsumerStatefulWidget {
  final String groupId;
  final String groupName;

  const _InviteDialog({required this.groupId, required this.groupName});

  @override
  ConsumerState<_InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends ConsumerState<_InviteDialog> {
  final _emailController = TextEditingController();
  bool _isSending = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _invite() async {
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
      title: Text('${widget.groupName}に招待'),
      content: _sent
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppTheme.accentColor, size: 48),
                const Gap(12),
                const Text('招待メールを送信しました！'),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  '招待リンクを含むメールが送信されます。リンクは7日間有効です。',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
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
                  onPressed: _invite,
                  child: const Text('招待する'),
                ),
      ],
    );
  }
}

// ─────────────────── グループ設定シート ───────────────────

class _GroupSettingsSheet extends StatefulWidget {
  final String groupId;
  final String groupName;
  final bool isOwner;
  final String currentUid;

  const _GroupSettingsSheet({
    required this.groupId,
    required this.groupName,
    required this.isOwner,
    required this.currentUid,
  });

  @override
  State<_GroupSettingsSheet> createState() => _GroupSettingsSheetState();
}

class _GroupSettingsSheetState extends State<_GroupSettingsSheet> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('グループ名を変更'),
              onTap: () {
                Navigator.of(context).pop();
                _showRenameDialog(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app_rounded,
                  color: AppTheme.warningColor),
              title: const Text('グループを退出',
                  style: TextStyle(color: AppTheme.warningColor)),
              onTap: () {
                Navigator.of(context).pop();
                _confirmLeave(context);
              },
            ),
            if (widget.isOwner)
              ListTile(
                leading: const Icon(Icons.delete_rounded,
                    color: AppTheme.errorColor),
                title: const Text('グループを削除',
                    style: TextStyle(color: AppTheme.errorColor)),
                onTap: () {
                  Navigator.of(context).pop();
                  _confirmDelete(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context) {
    final controller =
        TextEditingController(text: widget.groupName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('グループ名を変更'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'グループ名'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;
              try {
                await FirebaseFirestore.instance
                    .collection('groups')
                    .doc(widget.groupId)
                    .update({
                  'name': newName,
                  'updatedAt': FieldValue.serverTimestamp(),
                });
                if (ctx.mounted) Navigator.of(ctx).pop();
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('更新に失敗しました: $e')),
                  );
                }
              }
            },
            child: const Text('変更'),
          ),
        ],
      ),
    );
  }

  void _confirmLeave(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('グループを退出'),
        content: Text('「${widget.groupName}」を退出しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('groups')
                    .doc(widget.groupId)
                    .collection('members')
                    .doc(widget.currentUid)
                    .delete();
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  Navigator.of(ctx).pop(); // 詳細画面も閉じる
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('退出に失敗しました: $e')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.warningColor,
              minimumSize: const Size(80, 40),
            ),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('グループを削除'),
        content: Text('「${widget.groupName}」を完全に削除しますか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('groups')
                    .doc(widget.groupId)
                    .delete();
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  Navigator.of(ctx).pop();
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('削除に失敗しました: $e')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              minimumSize: const Size(80, 40),
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}
