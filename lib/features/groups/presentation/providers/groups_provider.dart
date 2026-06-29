import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_task_manager/core/constants/app_constants.dart';
import 'package:life_task_manager/features/auth/presentation/providers/auth_provider.dart';
import 'package:life_task_manager/features/groups/data/models/group_model.dart';
import 'package:life_task_manager/features/groups/domain/entities/group_entity.dart';
import 'package:life_task_manager/features/groups/domain/entities/group_member_entity.dart';

// ---------------------------------------------------------------------------
// Firestore helpers
// ---------------------------------------------------------------------------

FirebaseFirestore get _fs => FirebaseFirestore.instance;

CollectionReference<Map<String, dynamic>> get _groupsRef =>
    _fs.collection(AppConstants.groupsCollection);

// ---------------------------------------------------------------------------
// グループ一覧
// ---------------------------------------------------------------------------

/// ログイン中ユーザーが所属するグループをリアルタイム監視
final userGroupsProvider = StreamProvider<List<GroupEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  return _groupsRef
      .where('memberUids', arrayContains: user.uid)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => GroupModel.fromFirestore(doc).toEntity()).toList());
});

/// 指定グループのプロフィールをリアルタイム監視
final selectedGroupProfileProvider =
    StreamProvider.family<GroupEntity?, String>((ref, groupId) {
  return _groupsRef.doc(groupId).snapshots().map((doc) {
    if (!doc.exists) return null;
    return GroupModel.fromFirestore(doc).toEntity();
  });
});

/// 指定グループのメンバー一覧をリアルタイム監視
final groupMembersProvider =
    StreamProvider.family<List<GroupMemberEntity>, String>((ref, groupId) {
  return _groupsRef
      .doc(groupId)
      .collection(AppConstants.membersSubCollection)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return GroupMemberEntity(
            uid: doc.id,
            displayName: data['displayName'] as String? ?? '',
            email: data['email'] as String? ?? '',
            photoUrl: data['photoUrl'] as String?,
            role: data['role'] as String? ?? 'member',
            joinedAt: (data['joinedAt'] as Timestamp).toDate(),
            status: data['status'] as String? ?? 'active',
          );
        }).toList();
      });
});

// ---------------------------------------------------------------------------
// GroupNotifier — CRUD / メンバー管理
// ---------------------------------------------------------------------------

class GroupNotifier extends StateNotifier<AsyncValue<void>> {
  GroupNotifier(this._uid) : super(const AsyncValue.data(null));

  final String? _uid;

  String get _requireUid {
    final uid = _uid;
    if (uid == null) throw Exception('User not logged in');
    return uid;
  }

  /// 新しいグループを作成し、groupId を返す
  Future<String> createGroup(String name) async {
    state = const AsyncValue.loading();
    late String groupId;
    state = await AsyncValue.guard(() async {
      final uid = _requireUid;
      final now = DateTime.now();
      final model = GroupModel(
        groupId: '',
        name: name,
        ownerUid: uid,
        memberUids: [uid],
        memberCount: 1,
        createdAt: now,
        updatedAt: now,
      );
      final docRef = await _groupsRef.add(model.toFirestore());
      groupId = docRef.id;

      // 作成者をメンバーとして登録
      final userDoc = await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      final userData = userDoc.data() ?? {};
      await docRef
          .collection(AppConstants.membersSubCollection)
          .doc(uid)
          .set({
        'displayName': userData['displayName'] ?? '',
        'email': userData['email'] ?? '',
        'photoUrl': userData['photoUrl'],
        'role': 'owner',
        'joinedAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });
    });
    return groupId;
  }

  /// グループ名を更新
  Future<void> updateGroup(String groupId, String name) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _groupsRef.doc(groupId).update({
        'name': name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// 招待メールを送信（invitations サブコレクションへ書き込み）
  Future<void> inviteMember(String groupId, String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final uid = _requireUid;
      final userDoc = await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      final inviterName =
          (userDoc.data()?['displayName'] as String?) ?? '';
      final code = _generateInvitationCode();
      final expiresAt = DateTime.now()
          .add(Duration(days: AppConstants.invitationExpiryDays));

      await _groupsRef
          .doc(groupId)
          .collection(AppConstants.invitationsSubCollection)
          .add({
        'groupId': groupId,
        'inviteeEmail': email,
        'invitedByUid': uid,
        'invitedByName': inviterName,
        'status': 'pending',
        'invitationCode': code,
        'expiresAt': Timestamp.fromDate(expiresAt),
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// 招待コードを使ってグループに参加する
  Future<void> acceptInvitation(String groupId, String invitationCode) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final uid = _requireUid;
      final fs = FirebaseFirestore.instance;

      // 招待ドキュメントを検索
      final invQuery = await _groupsRef
          .doc(groupId)
          .collection(AppConstants.invitationsSubCollection)
          .where('invitationCode', isEqualTo: invitationCode)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (invQuery.docs.isEmpty) {
        throw Exception('Invalid or expired invitation code');
      }

      final invDoc = invQuery.docs.first;
      final expiresAt =
          (invDoc.data()['expiresAt'] as Timestamp).toDate();
      if (DateTime.now().isAfter(expiresAt)) {
        throw Exception('Invitation has expired');
      }

      // ユーザー情報取得
      final userDoc = await fs
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      final userData = userDoc.data() ?? {};

      final batch = fs.batch();

      // メンバー追加
      batch.set(
        _groupsRef
            .doc(groupId)
            .collection(AppConstants.membersSubCollection)
            .doc(uid),
        {
          'displayName': userData['displayName'] ?? '',
          'email': userData['email'] ?? '',
          'photoUrl': userData['photoUrl'],
          'role': 'member',
          'joinedAt': FieldValue.serverTimestamp(),
          'status': 'active',
        },
      );

      // グループの memberUids / memberCount 更新
      batch.update(_groupsRef.doc(groupId), {
        'memberUids': FieldValue.arrayUnion([uid]),
        'memberCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 招待ステータスを accepted に
      batch.update(invDoc.reference, {
        'status': 'accepted',
        'acceptedByUid': uid,
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    });
  }

  /// グループから脱退する
  Future<void> leaveGroup(String groupId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final uid = _requireUid;
      final fs = FirebaseFirestore.instance;
      final batch = fs.batch();

      batch.delete(
        _groupsRef
            .doc(groupId)
            .collection(AppConstants.membersSubCollection)
            .doc(uid),
      );
      batch.update(_groupsRef.doc(groupId), {
        'memberUids': FieldValue.arrayRemove([uid]),
        'memberCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    });
  }

  /// メンバーをグループから除名する（オーナー専用）
  Future<void> removeMember(String groupId, String memberUid) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final fs = FirebaseFirestore.instance;
      final batch = fs.batch();

      batch.delete(
        _groupsRef
            .doc(groupId)
            .collection(AppConstants.membersSubCollection)
            .doc(memberUid),
      );
      batch.update(_groupsRef.doc(groupId), {
        'memberUids': FieldValue.arrayRemove([memberUid]),
        'memberCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    });
  }

  /// グループを削除する（オーナー専用）
  Future<void> deleteGroup(String groupId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _groupsRef.doc(groupId).delete();
    });
  }

  // ランダムな招待コードを生成
  String _generateInvitationCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(8, (i) => chars[(random >> i) % chars.length]).join();
  }
}

final groupNotifierProvider =
    StateNotifierProvider<GroupNotifier, AsyncValue<void>>((ref) {
  final user = ref.watch(currentUserProvider);
  return GroupNotifier(user?.uid);
});
