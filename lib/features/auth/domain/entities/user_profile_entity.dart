import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_entity.freezed.dart';
part 'user_profile_entity.g.dart';

@freezed
sealed class UserProfileEntity with _$UserProfileEntity {
  const factory UserProfileEntity({
    required String uid,
    required String displayName,
    required String email,
    String? photoUrl,
    @Default('ja') String language,
    @Default('JP') String country,
    @Default('Asia/Tokyo') String timezone,
    @Default(false) bool isPaid,
    String? purchaseType,
    required DateTime trialStartAt,
    DateTime? purchasedAt,
    String? invitedByGroupId,
    String? iapPlatform,
    String? iapTransactionId,
    required DateTime lastActiveAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserProfileEntity;

  factory UserProfileEntity.fromJson(Map<String, dynamic> json) =>
      _$UserProfileEntityFromJson(json);
}
