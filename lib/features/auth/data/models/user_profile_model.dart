import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_task_manager/features/auth/domain/entities/user_profile_entity.dart';

class UserProfileModel {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String language;
  final String country;
  final String timezone;
  final bool isPaid;
  final String? purchaseType;
  final DateTime trialStartAt;
  final DateTime? purchasedAt;
  final String? invitedByGroupId;
  final String? iapPlatform;
  final String? iapTransactionId;
  final DateTime lastActiveAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfileModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.language = 'ja',
    this.country = 'JP',
    this.timezone = 'Asia/Tokyo',
    this.isPaid = false,
    this.purchaseType,
    required this.trialStartAt,
    this.purchasedAt,
    this.invitedByGroupId,
    this.iapPlatform,
    this.iapTransactionId,
    required this.lastActiveAt,
    required this.createdAt,
    required this.updatedAt,
  });

  static UserProfileModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfileModel(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      language: data['language'] as String? ?? 'ja',
      country: data['country'] as String? ?? 'JP',
      timezone: data['timezone'] as String? ?? 'Asia/Tokyo',
      isPaid: data['isPaid'] as bool? ?? false,
      purchaseType: data['purchaseType'] as String?,
      trialStartAt: (data['trialStartAt'] as Timestamp).toDate(),
      purchasedAt: (data['purchasedAt'] as Timestamp?)?.toDate(),
      invitedByGroupId: data['invitedByGroupId'] as String?,
      iapPlatform: data['iapPlatform'] as String?,
      iapTransactionId: data['iapTransactionId'] as String?,
      lastActiveAt: (data['lastActiveAt'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'language': language,
      'country': country,
      'timezone': timezone,
      'isPaid': isPaid,
      if (purchaseType != null) 'purchaseType': purchaseType,
      'trialStartAt': Timestamp.fromDate(trialStartAt),
      if (purchasedAt != null) 'purchasedAt': Timestamp.fromDate(purchasedAt!),
      if (invitedByGroupId != null) 'invitedByGroupId': invitedByGroupId,
      if (iapPlatform != null) 'iapPlatform': iapPlatform,
      if (iapTransactionId != null) 'iapTransactionId': iapTransactionId,
      'lastActiveAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserProfileEntity toEntity() {
    return UserProfileEntity(
      uid: uid,
      displayName: displayName,
      email: email,
      photoUrl: photoUrl,
      language: language,
      country: country,
      timezone: timezone,
      isPaid: isPaid,
      purchaseType: purchaseType,
      trialStartAt: trialStartAt,
      purchasedAt: purchasedAt,
      invitedByGroupId: invitedByGroupId,
      iapPlatform: iapPlatform,
      iapTransactionId: iapTransactionId,
      lastActiveAt: lastActiveAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static UserProfileModel fromEntity(UserProfileEntity entity) {
    return UserProfileModel(
      uid: entity.uid,
      displayName: entity.displayName,
      email: entity.email,
      photoUrl: entity.photoUrl,
      language: entity.language,
      country: entity.country,
      timezone: entity.timezone,
      isPaid: entity.isPaid,
      purchaseType: entity.purchaseType,
      trialStartAt: entity.trialStartAt,
      purchasedAt: entity.purchasedAt,
      invitedByGroupId: entity.invitedByGroupId,
      iapPlatform: entity.iapPlatform,
      iapTransactionId: entity.iapTransactionId,
      lastActiveAt: entity.lastActiveAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
