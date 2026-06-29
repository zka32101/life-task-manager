import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_entity.freezed.dart';
part 'group_entity.g.dart';

@freezed
sealed class GroupEntity with _$GroupEntity {
  const factory GroupEntity({
    required String groupId,
    required String name,
    required String ownerUid,
    @Default([]) List<String> memberUids,
    @Default(0) int memberCount,
    @Default(0) int taskCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _GroupEntity;

  factory GroupEntity.fromJson(Map<String, dynamic> json) =>
      _$GroupEntityFromJson(json);
}
