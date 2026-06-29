import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_task_manager/features/groups/domain/entities/invitation_entity.dart';

class InvitationModel {
  final String invitationId;
  final String groupId;
  final String inviteeEmail;
  final String invitedByUid;
  final String invitedByName;
  final String status;
  final String invitationCode;
  final DateTime expiresAt;
  final DateTime? acceptedAt;
  final String? acceptedByUid;
  final DateTime createdAt;

  const InvitationModel({
    required this.invitationId,
    required this.groupId,
    required this.inviteeEmail,
    required this.invitedByUid,
    required this.invitedByName,
    this.status = 'pending',
    required this.invitationCode,
    required this.expiresAt,
    this.acceptedAt,
    this.acceptedByUid,
    required this.createdAt,
  });

  static InvitationModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InvitationModel(
      invitationId: doc.id,
      groupId: data['groupId'] as String? ?? '',
      inviteeEmail: data['inviteeEmail'] as String? ?? '',
      invitedByUid: data['invitedByUid'] as String? ?? '',
      invitedByName: data['invitedByName'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      invitationCode: data['invitationCode'] as String? ?? '',
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      acceptedAt: (data['acceptedAt'] as Timestamp?)?.toDate(),
      acceptedByUid: data['acceptedByUid'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'inviteeEmail': inviteeEmail,
      'invitedByUid': invitedByUid,
      'invitedByName': invitedByName,
      'status': status,
      'invitationCode': invitationCode,
      'expiresAt': Timestamp.fromDate(expiresAt),
      if (acceptedAt != null) 'acceptedAt': Timestamp.fromDate(acceptedAt!),
      if (acceptedByUid != null) 'acceptedByUid': acceptedByUid,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  InvitationEntity toEntity() {
    return InvitationEntity(
      invitationId: invitationId,
      groupId: groupId,
      inviteeEmail: inviteeEmail,
      invitedByUid: invitedByUid,
      invitedByName: invitedByName,
      status: status,
      invitationCode: invitationCode,
      expiresAt: expiresAt,
      acceptedAt: acceptedAt,
      acceptedByUid: acceptedByUid,
      createdAt: createdAt,
    );
  }

  static InvitationModel fromEntity(InvitationEntity entity) {
    return InvitationModel(
      invitationId: entity.invitationId,
      groupId: entity.groupId,
      inviteeEmail: entity.inviteeEmail,
      invitedByUid: entity.invitedByUid,
      invitedByName: entity.invitedByName,
      status: entity.status,
      invitationCode: entity.invitationCode,
      expiresAt: entity.expiresAt,
      acceptedAt: entity.acceptedAt,
      acceptedByUid: entity.acceptedByUid,
      createdAt: entity.createdAt,
    );
  }
}
