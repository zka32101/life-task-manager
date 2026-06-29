import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:life_task_manager/core/theme/app_theme.dart';

/// 対象外アイテム管理画面
class ExclusionItemsScreen extends ConsumerWidget {
  const ExclusionItemsScreen({super.key});

  String get _currentUid =>
      FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_currentUid.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('対象外アイテム')),
        body: const Center(child: Text('ログインが必要です')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('対象外アイテム'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUid)
            .collection('excluded_items')
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 48, color: AppTheme.errorColor),
                  const Gap(16),
                  Text('エラーが発生しました: ${snap.error}'),
                ],
              ),
            );
          }

          final docs = snap.data?.docs ?? [];

          if (docs.isEmpty) {
            return const _EmptyExclusionsView();
          }

          final now = DateTime.now();

          // 有効な除外と期限切れに分類
          final active = <QueryDocumentSnapshot>[];
          final expired = <QueryDocumentSnapshot>[];

          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final validUntilTs = data['validUntil'] as Timestamp?;
            final isTemporary = data['isTemporaryExclusion'] as bool? ?? false;
            if (isTemporary && validUntilTs != null) {
              final validUntil = validUntilTs.toDate();
              if (validUntil.isBefore(now)) {
                expired.add(doc);
              } else {
                active.add(doc);
              }
            } else {
              active.add(doc);
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (active.isNotEmpty) ...[
                Text(
                  '現在有効な除外',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Gap(8),
                ...active.map((doc) => _ExclusionCard(
                      doc: doc,
                      isExpired: false,
                      onRestore: () => _restoreItem(context, doc.id),
                    )),
              ],
              if (expired.isNotEmpty) ...[
                if (active.isNotEmpty) const Gap(16),
                Text(
                  '期限切れ',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Gap(8),
                ...expired.map((doc) => _ExclusionCard(
                      doc: doc,
                      isExpired: true,
                      onRestore: () => _restoreItem(context, doc.id),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _restoreItem(BuildContext context, String excludeId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUid)
          .collection('excluded_items')
          .doc(excludeId)
          .delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('アイテムを復活させました')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('復活に失敗しました: $e')),
        );
      }
    }
  }
}

class _ExclusionCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final bool isExpired;
  final VoidCallback onRestore;

  const _ExclusionCard({
    required this.doc,
    required this.isExpired,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final itemName = data['itemName'] as String? ?? '不明なアイテム';
    final itemType = data['itemType'] as String? ?? 'task';
    final reason = data['reason'] as String?;
    final isTemporary = data['isTemporaryExclusion'] as bool? ?? false;
    final validUntilTs = data['validUntil'] as Timestamp?;

    final icon = _iconForItemType(itemType);
    final statusText = _statusText(isTemporary, validUntilTs, isExpired);

    return Opacity(
      opacity: isExpired ? 0.5 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(icon, style: const TextStyle(fontSize: 20)),
                  const Gap(10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: isExpired
                                ? Colors.grey.shade500
                                : Colors.black87,
                          ),
                        ),
                        if (reason != null && reason.isNotEmpty) ...[
                          const Gap(4),
                          Row(
                            children: [
                              Text(
                                '理由: ',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500),
                              ),
                              Expanded(
                                child: Text(
                                  reason,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const Gap(4),
                        Row(
                          children: [
                            Icon(
                              isExpired
                                  ? Icons.timer_off_rounded
                                  : Icons.schedule_rounded,
                              size: 12,
                              color: isExpired
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade500,
                            ),
                            const Gap(4),
                            Text(
                              isExpired ? '期限切れ（自動解除済み）' : statusText,
                              style: TextStyle(
                                fontSize: 12,
                                color: isExpired
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onRestore,
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.accentColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: const Size(80, 32),
                  ),
                  child: Text(
                    isExpired ? '完全に削除' : '復活させる',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _iconForItemType(String itemType) {
    switch (itemType) {
      case 'category':
        return '🏠';
      case 'task':
        return '🎌';
      default:
        return '📋';
    }
  }

  String _statusText(
      bool isTemporary, Timestamp? validUntilTs, bool isExpired) {
    if (!isTemporary || validUntilTs == null) {
      return 'ステータス: 永続除外';
    }
    final dt = validUntilTs.toDate();
    final formatted =
        '${dt.year}年${dt.month}月${dt.day}日';
    return 'ステータス: ${formatted}まで';
  }
}

class _EmptyExclusionsView extends StatelessWidget {
  const _EmptyExclusionsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded,
                size: 72, color: Colors.grey.shade300),
            const Gap(24),
            Text(
              '対象外に設定したアイテムはありません',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              'タスク追加・編集画面から設定できます',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
