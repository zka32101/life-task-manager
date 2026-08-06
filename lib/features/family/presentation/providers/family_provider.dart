import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../groups/presentation/providers/groups_provider.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../domain/entities/family_member_entity.dart';

/// ログイン中ユーザーが所属する全グループのメンバー（自分以外）を集約した一覧
final familyMembersProvider =
    FutureProvider<List<FamilyMemberEntity>>((ref) async {
  final currentUid = ref.watch(currentUserProvider)?.uid;
  if (currentUid == null) return [];

  final groups = await ref.watch(userGroupsProvider.future);
  if (groups.isEmpty) return [];

  final merged = <String, FamilyMemberEntity>{};
  for (final group in groups) {
    final membersSnap = await FirebaseFirestore.instance
        .collection('groups')
        .doc(group.groupId)
        .collection('members')
        .get();

    for (final doc in membersSnap.docs) {
      final uid = doc.id;
      if (uid == currentUid) continue;
      final data = doc.data();
      final existing = merged[uid];
      if (existing != null) {
        merged[uid] = FamilyMemberEntity(
          uid: uid,
          displayName: existing.displayName,
          email: existing.email,
          photoUrl: existing.photoUrl,
          groupIds: [...existing.groupIds, group.groupId],
          groupNames: [...existing.groupNames, group.name],
        );
      } else {
        merged[uid] = FamilyMemberEntity(
          uid: uid,
          displayName: data['displayName'] as String? ?? 'メンバー',
          email: data['email'] as String? ?? '',
          photoUrl: data['photoUrl'] as String?,
          groupIds: [group.groupId],
          groupNames: [group.name],
        );
      }
    }
  }
  return merged.values.toList();
});

/// 指定メンバーが担当している共有グループタスク一覧
/// （mainAssigneeUid または assigneeUids に targetUid を含むもの）
final memberSharedTasksProvider =
    FutureProvider.family<List<TaskEntity>, String>((ref, targetUid) async {
  final groups = await ref.watch(userGroupsProvider.future);
  final sharedGroups =
      groups.where((g) => g.memberUids.contains(targetUid)).toList();
  if (sharedGroups.isEmpty) return [];

  final fs = FirebaseFirestore.instance;
  final results = <TaskEntity>[];

  for (final group in sharedGroups) {
    final tasksRef = fs
        .collection('groups')
        .doc(group.groupId)
        .collection('tasks')
        .where('isArchived', isEqualTo: false);

    final mainSnap =
        await tasksRef.where('mainAssigneeUid', isEqualTo: targetUid).get();
    final assigneeSnap =
        await tasksRef.where('assigneeUids', arrayContains: targetUid).get();

    final seen = <String>{};
    for (final doc in [...mainSnap.docs, ...assigneeSnap.docs]) {
      if (seen.add(doc.id)) {
        results.add(TaskModel.fromFirestore(doc).toEntity());
      }
    }
  }

  results.sort((a, b) => a.nextDueAt.compareTo(b.nextDueAt));
  return results;
});
