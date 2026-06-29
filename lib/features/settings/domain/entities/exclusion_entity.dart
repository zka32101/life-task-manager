import 'package:freezed_annotation/freezed_annotation.dart';

part 'exclusion_entity.freezed.dart';
part 'exclusion_entity.g.dart';

@freezed
sealed class ExclusionEntity with _$ExclusionEntity {
  const factory ExclusionEntity({
    required String excludeId,
    required String itemId,
    required String itemType,
    required String itemName,
    String? reason,
    required DateTime excludedAt,
    DateTime? validUntil,
    @Default(false) bool isTemporaryExclusion,
  }) = _ExclusionEntity;

  factory ExclusionEntity.fromJson(Map<String, dynamic> json) =>
      _$ExclusionEntityFromJson(json);
}
