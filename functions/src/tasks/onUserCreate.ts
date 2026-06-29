import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * 新規ユーザー作成時の初期化処理
 * - users/{uid}/profile にプロフィールを作成
 * - users/{uid}/preferences にデフォルト設定を作成
 * - trialStartAt を記録（30日トライアル開始）
 */
export const onUserCreate = functions.auth.user().onCreate(async (user) => {
  const uid = user.uid;
  const now = admin.firestore.Timestamp.now();

  const batch = db.batch();

  // プロフィール初期化
  const profileRef = db.collection('users').doc(uid).collection('profile').doc('profile');
  batch.set(profileRef, {
    uid,
    displayName: user.displayName || '',
    email: user.email || '',
    photoUrl: user.photoURL || null,
    language: 'ja',
    country: 'JP',
    timezone: 'Asia/Tokyo',
    isPaid: false,
    purchaseType: null,
    trialStartAt: now,           // ← トライアル開始日時
    purchasedAt: null,
    invitedByGroupId: null,
    iapPlatform: null,
    iapTransactionId: null,
    lastActiveAt: now,
    createdAt: now,
    updatedAt: now,
  });

  // デフォルト設定初期化
  const prefsRef = db.collection('users').doc(uid).collection('preferences').doc(uid);
  batch.set(prefsRef, {
    uid,
    darkMode: false,
    notificationEnabled: true,
    emailNotificationEnabled: true,
    reminderLayers: {
      legal: [60, 30, 7, 1],
      recommended: 'monthly',
      seasonal: 'season_start',
    },
    defaultReminder: 7,
    soundEnabled: true,
    vibrationEnabled: true,
    languageChanged: false,
    fcmToken: null,
    fcmTokenUpdatedAt: null,
    createdAt: now,
    updatedAt: now,
  });

  await batch.commit();

  functions.logger.info(`User ${uid} initialized with 30-day trial`);
});
