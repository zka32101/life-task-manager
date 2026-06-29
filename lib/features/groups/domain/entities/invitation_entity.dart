import 'package:freezed_annotation/freezed_annotation.dart';

part 'invitation_entity.freezed.dart';
part 'invitation_entity.g.dart';

@freezed
sealed class InvitationEntity with _$InvitationEntity {
  const factory InvitationEntity({
    required String invitationId,
    required String groupId,
    required String inviteeEmail,
    required String invitedByUid,
    required String invitedByName,
    @Default('pending') String status,
    required String invitationCode,
    required DateTime expiresAt,
    DateTime? acceptedAt,
    String? acceptedByUid,
    required DateTime createdAt,
  }) = _InvitationEntity;

  factory InvitationEntity.fromJson(Map<String, dynamic> json) =>
      _$InvitationEntityFromJson(json);
}
