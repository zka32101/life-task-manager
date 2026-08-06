import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:life_task_manager/core/theme/app_theme.dart';

/// 通知センター — Firestore notificationLogs をリアルタイム表示
class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  final _uid = FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _col {
    if (_uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('notificationLogs');
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Scaffold(
        body: Center(child: Text('ログインが必要です')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('通知センター'),
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: const Text('すべて既読'),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _col!
            .orderBy('createdAt', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('エラー: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const _EmptyState();
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              return _NotificationTile(
                doc: doc,
                onTap: () => _onTap(doc),
                onDismiss: () => doc.reference.delete(),
              );
            },
          );
        },
      ),
    );
  }

  void _onTap(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    // 既読にする
    if (!(doc.data()['isRead'] as bool? ?? false)) {
      doc.reference.update({'isRead': true});
    }

    final taskId = doc.data()['taskId'] as String?;
    if (taskId != null && taskId.isNotEmpty) {
      context.goNamed('task-detail', pathParameters: {'id': taskId});
    }
  }

  Future<void> _markAllRead() async {
    final snap = await _col!.where('isRead', isEqualTo: false).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}

// ─────────────────────────────────────────────────────────
// Parts
// ─────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.doc,
    required this.onTap,
    required this.onDismiss,
  });

  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final isRead = data['isRead'] as bool? ?? false;
    final title = data['title'] as String? ?? '';
    final body = data['body'] as String? ?? '';
    final ts = data['createdAt'] as Timestamp?;
    final createdAt = ts?.toDate();
    final isLegal = data['notificationType'] == 'LEGAL_DEADLINE';

    return Dismissible(
      key: Key(doc.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: Colors.red.shade400,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDismiss(),
      child: ListTile(
        onTap: onTap,
        leading: _LeadingIcon(isLegal: isLegal, isRead: isRead),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(body, maxLines: 2, overflow: TextOverflow.ellipsis),
            if (createdAt != null)
              Text(
                _fmtDate(createdAt),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
          ],
        ),
        isThreeLine: true,
        tileColor: isRead ? null : AppTheme.primaryColor.withOpacity(0.04),
      ),
    );
  }

  String _fmtDate(DateTime dt) {
    final now = DateTime.now();
    if (_isSameDay(dt, now)) {
      return DateFormat('HH:mm').format(dt);
    } else if (dt.isAfter(now.subtract(const Duration(days: 7)))) {
      return DateFormat('M/d HH:mm').format(dt);
    } else {
      return DateFormat('yyyy/M/d').format(dt);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.isLegal, required this.isRead});
  final bool isLegal;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          backgroundColor: isLegal
              ? Colors.red.shade100
              : AppTheme.primaryColor.withOpacity(0.12),
          child: Icon(
            isLegal ? Icons.warning_amber_rounded : Icons.notifications_outlined,
            color: isLegal ? Colors.red.shade700 : AppTheme.primaryColor,
            size: 20,
          ),
        ),
        if (!isRead)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none_rounded,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('通知はありません',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 未読バッジ用 Stream
// ─────────────────────────────────────────────────────────

/// 未読通知数を返す Stream
Stream<int> unreadNotificationCountStream() {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value(0);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('notificationLogs')
      .where('isRead', isEqualTo: false)
      .snapshots()
      .map((snap) => snap.docs.length);
}
