import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_task_manager/features/auth/domain/entities/user_preferences_entity.dart';

class UserPreferencesModel {
  final bool notificationEnabled;
  final bool emailNotificationEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String? fcmToken;

  const UserPreferencesModel({
    this.notificationEnabled = true,
    this.emailNotificationEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.fcmToken,
  });

  factory UserPreferencesModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserPreferencesModel(
      notificationEnabled: data['notificationEnabled'] as bool? ?? true,
      emailNotificationEnabled:
          data['emailNotificationEnabled'] as bool? ?? true,
      soundEnabled: data['soundEnabled'] as bool? ?? true,
      vibrationEnabled: data['vibrationEnabled'] as bool? ?? true,
      fcmToken: data['fcmToken'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'notificationEnabled': notificationEnabled,
        'emailNotificationEnabled': emailNotificationEnabled,
        'soundEnabled': soundEnabled,
        'vibrationEnabled': vibrationEnabled,
        if (fcmToken != null) 'fcmToken': fcmToken,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  UserPreferencesEntity toEntity() => UserPreferencesEntity(
        notificationEnabled: notificationEnabled,
        emailNotificationEnabled: emailNotificationEnabled,
        soundEnabled: soundEnabled,
        vibrationEnabled: vibrationEnabled,
        fcmToken: fcmToken,
      );
}
