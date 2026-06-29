import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_preferences_entity.freezed.dart';
part 'user_preferences_entity.g.dart';

@freezed
sealed class UserPreferencesEntity with _$UserPreferencesEntity {
  const factory UserPreferencesEntity({
    @Default(false) bool darkMode,
    @Default(true) bool notificationEnabled,
    @Default(false) bool emailNotificationEnabled,
    @Default([1, 3, 7]) List<int> reminderLayers,
    @Default(1) int defaultReminder,
    @Default(true) bool soundEnabled,
    @Default(true) bool vibrationEnabled,
    String? fcmToken,
    DateTime? fcmTokenUpdatedAt,
  }) = _UserPreferencesEntity;

  factory UserPreferencesEntity.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesEntityFromJson(json);
}
