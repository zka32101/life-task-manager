// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserPreferencesEntity _$UserPreferencesEntityFromJson(
  Map<String, dynamic> json,
) => _UserPreferencesEntity(
  darkMode: json['darkMode'] as bool? ?? false,
  notificationEnabled: json['notificationEnabled'] as bool? ?? true,
  emailNotificationEnabled: json['emailNotificationEnabled'] as bool? ?? false,
  reminderLayers:
      (json['reminderLayers'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [1, 3, 7],
  defaultReminder: (json['defaultReminder'] as num?)?.toInt() ?? 1,
  soundEnabled: json['soundEnabled'] as bool? ?? true,
  vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
  fcmToken: json['fcmToken'] as String?,
  fcmTokenUpdatedAt: json['fcmTokenUpdatedAt'] == null
      ? null
      : DateTime.parse(json['fcmTokenUpdatedAt'] as String),
);

Map<String, dynamic> _$UserPreferencesEntityToJson(
  _UserPreferencesEntity instance,
) => <String, dynamic>{
  'darkMode': instance.darkMode,
  'notificationEnabled': instance.notificationEnabled,
  'emailNotificationEnabled': instance.emailNotificationEnabled,
  'reminderLayers': instance.reminderLayers,
  'defaultReminder': instance.defaultReminder,
  'soundEnabled': instance.soundEnabled,
  'vibrationEnabled': instance.vibrationEnabled,
  'fcmToken': instance.fcmToken,
  'fcmTokenUpdatedAt': instance.fcmTokenUpdatedAt?.toIso8601String(),
};
