import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:life_task_manager/core/theme/app_theme.dart';

/// グループ招待受け入れ画面（ディープリンク遷移先）
class InvitationAcceptScreen extends ConsumerStatefulWidget {
  final String invitationCode;

  const InvitationAcceptScreen({super.key, required this.invitationCode});

  @override
  ConsumerState<InvitationAcceptScreen> createState() =>
      _InvitationAcceptScreenState();
}

class _InvitationAcceptScreenState
    extends ConsumerState<InvitationAcceptScreen> {
  _InvitationState _state = _InvitationState.loading;
  Map<String, dynamic>? _invitationData;
  Map<String, dynamic>? _groupData;
  List<Map<String, dynamic>> _members = [];
  String? _errorMessage;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _loadInvitation();
  }

  Future<void> _loadInvitation() async {
    try {
      // invitationCode からグループ全体を横断して招待ドキュメントを検索
      // Firestore の collectionGroup クエリを使用
      final invSnap = await FirebaseFirestore.instance
          .collectionGroup('invitations')
          .where('invitationCode', isEqualTo: widget.invitationCode)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (invSnap.docs.isEmpty) {
        setState(() {
          _state = _InvitationState.invalid;
          _errorMessage = '招待リンクが無効か、期限切れです。';
        });
        return;
      }

      final invDoc = invSnap.docs.first;
      final invData = invDoc.data();

      // 有効期限チェック
      final expiresAt = (invData['expiresAt'] as Timestamp).toDate();
      if (expiresAt.isBefore(DateTime.now())) {
        setState(() {
          _state = _InvitationState.expired;
          _errorMessage = '招待リンクの有効期限が切れています。';
        });
        return;
      }

      final groupId = invData['groupId'] as String;

      // グループ情報を取得
      final groupSnap = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('profile')
          .doc('profile')
          .get();

      if (!groupSnap.exists) {
        setState(() {
          _state = _InvitationState.invalid;
          _errorMessage = 'グループが見つかりませんでした。';
        });
        return;
      }

      // メンバー一覧を取得
      final membersSnap = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .limit(10)
          .get();

      final members =
          membersSnap.docs.map((d) => d.data()).toList();

      setState(() {
        _invitationData = invData;
        _groupData = groupSnap.data();
        _members = members;
        _state = _InvitationState.ready;
      });
    } catch (e) {
      setState(() {
        _state = _InvitationState.invalid;
        _errorMessage = '招待情報の取得に失敗しました: $e';
      });
    }
  }

  Future<void> _acceptInvitation() async {
    if (_invitationData == null) return;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('参加するにはログインが必要です')),
      );
      return;
    }

    setState(() => _isJoining = true);
    try {
      final groupId = _invitationData!['groupId'] as String;
      final invitationId = _invitationData!['invitationId'] as String?
          ?? widget.invitationCode;

      // メンバーとして追加
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(currentUser.uid)
          .set({
        'uid': currentUser.uid,
        'displayName': currentUser.displayName ?? 'ユーザー',
        'email': currentUser.email ?? '',
        'photoUrl': currentUser.photoURL,
        'role': 'member',
        'joinedAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      // 招待ステータスを更新
      await FirebaseFirestore.instance
          .collectionGroup('invitations')
          .where('invitationCode', isEqualTo: widget.invitationCode)
          .limit(1)
          .get()
          .then((snap) async {
        if (snap.docs.isNotEmpty) {
          await snap.docs.first.reference.update({
            'status': 'accepted',
            'acceptedAt': FieldValue.serverTimestamp(),
            'acceptedByUid': currentUser.uid,
          });
        }
      });

      if (mounted) {
        setState(() => _state = _InvitationState.joined);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('参加に失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  void _decline() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: switch (_state) {
        _InvitationState.loading => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                Gap(16),
                Text('招待情報を確認中...'),
              ],
            ),
          ),
        _InvitationState.ready => _ReadyView(
            invitationData: _invitationData!,
            groupData: _groupData!,
            members: _members,
            isJoining: _isJoining,
            onAccept: _acceptInvitation,
            onDecline: _decline,
          ),
        _InvitationState.joined => _JoinedView(
            groupName: _groupData?['name'] as String? ?? 'グループ',
          ),
        _InvitationState.invalid ||
        _InvitationState.expired =>
          _ErrorView(message: _errorMessage ?? '不明なエラー'),
      },
    );
  }
}

enum _InvitationState { loading, ready, joined, invalid, expired }

// ─────────────────── 招待受け入れビュー ───────────────────

class _ReadyView extends StatelessWidget {
  final Map<String, dynamic> invitationData;
  final Map<String, dynamic> groupData;
  final List<Map<String, dynamic>> members;
  final bool isJoining;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _ReadyView({
    required this.invitationData,
    required this.groupData,
    required this.members,
    required this.isJoining,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final groupName = groupData['name'] as String? ?? 'グループ';
    final invitedByName = invitationData['invitedByName'] as String? ?? '誰か';
    final memberCount = members.length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // グループアイコン
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.group_rounded,
                color: AppTheme.primaryColor,
                size: 52,
              ),
            ),
            const Gap(24),

            // 招待者名
            Text(
              '$invitedByNameさんからの招待',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const Gap(8),

            // グループ名
            Text(
              groupName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(20),

            // メンバーアバター一覧
            if (members.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...members.take(5).map((m) {
                    final name = m['displayName'] as String? ?? '?';
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.primaryLight,
                        child: Text(
                          name.isNotEmpty ? name[0] : '?',
                          style: const TextStyle(
                            color: AppTheme.primaryDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }),
                  if (memberCount > 5)
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey.shade200,
                      child: Text(
                        '+${memberCount - 5}',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ),
                ],
              ),
              const Gap(8),
              Text(
                '$memberCount人のメンバー',
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade600),
              ),
              const Gap(32),
            ] else ...[
              const Gap(32),
            ],

            // 参加ボタン
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: isJoining ? null : onAccept,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isJoining
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        '参加する',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const Gap(12),

            // 断るボタン
            TextButton(
              onPressed: isJoining ? null : onDecline,
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('断る'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────── 参加完了ビュー ───────────────────

class _JoinedView extends StatelessWidget {
  final String groupName;

  const _JoinedView({required this.groupName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.accentColor,
              size: 80,
            ),
            const Gap(24),
            Text(
              '$groupNameに参加しました！',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(12),
            Text(
              'グループのタスクを一緒に管理しましょう',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const Gap(32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('グループを確認する'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────── エラービュー ───────────────────

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.link_off_rounded,
                size: 72, color: Colors.grey.shade400),
            const Gap(24),
            const Text(
              '招待リンクが無効です',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Gap(12),
            Text(
              message,
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const Gap(32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('戻る'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
