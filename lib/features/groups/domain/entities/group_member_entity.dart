import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_member_entity.freezed.dart';
part 'group_member_entity.g.dart';

@freezed
sealed class GroupMemberEntity with _$GroupMemberEntity {
  const factory GroupMemberEntity({
    required String uid,
    required String displayName,
    required String email,
    String? photoUrl,
    @Default('member') String role,
    required DateTime joinedAt,
    @Default('active') String status,
  }) = _GroupMemberEntity;

  factory GroupMemberEntity.fromJson(Map<String, dynamic> json) =>
      _$GroupMemberEntityFromJson(json);
}
