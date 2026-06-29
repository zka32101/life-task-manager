import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_task_manager/features/groups/domain/entities/group_entity.dart';

class GroupModel {
  final String groupId;
  final String name;
  final String ownerUid;
  final List<String> memberUids;
  final int memberCount;
  final int taskCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GroupModel({
    required this.groupId,
    required this.name,
    required this.ownerUid,
    this.memberUids = const [],
    this.memberCount = 0,
    this.taskCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  static GroupModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupModel(
      groupId: doc.id,
      name: data['name'] as String? ?? '',
      ownerUid: data['ownerUid'] as String? ?? '',
      memberUids: List<String>.from(data['memberUids'] as List? ?? []),
      memberCount: data['memberCount'] as int? ?? 0,
      taskCount: data['taskCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'ownerUid': ownerUid,
      'memberUids': memberUids,
      'memberCount': memberCount,
      'taskCount': taskCount,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  GroupEntity toEntity() {
    return GroupEntity(
      groupId: groupId,
      name: name,
      ownerUid: ownerUid,
      memberUids: memberUids,
      memberCount: memberCount,
      taskCount: taskCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static GroupModel fromEntity(GroupEntity entity) {
    return GroupModel(
      groupId: entity.groupId,
      name: entity.name,
      ownerUid: entity.ownerUid,
      memberUids: entity.memberUids,
      memberCount: entity.memberCount,
      taskCount: entity.taskCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
