import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as sgMail from '@sendgrid/mail';

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * 毎日 JST 9:00 に実行
 * トライアル期限切れリマインダー通知（設計書 v3.1 §7）
 *
 * スケジュール:
 *   - trialStartAt から 23日後（残7日）→ 1回目のリマインダー
 *   - trialStartAt から 28日後（残2日）→ 2回目のリマインダー
 *   - trialStartAt から 30日後（期限切れ当日）→ 期限切れ通知
 */
export const trialExpiryReminder = functions
  .pubsub.schedule('0 0 * * *')  // UTC 0:00 = JST 9:00
  .timeZone('Asia/Tokyo')
  .onRun(async (_context) => {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const reminders = [
      { daysFromStart: 23, remainingDays: 7, isExpiry: false },
      { daysFromStart: 28, remainingDays: 2, isExpiry: false },
      { daysFromStart: 30, remainingDays: 0, isExpiry: true },
    ];

    for (const reminder of reminders) {
      const targetTrialStart = new Date(today);
      targetTrialStart.setDate(targetTrialStart.getDate() - reminder.daysFromStart);
      const startOfDay = admin.firestore.Timestamp.fromDate(targetTrialStart);
      const endOfDay = admin.firestore.Timestamp.fromDate(
        new Date(targetTrialStart.getTime() + 24 * 60 * 60 * 1000)
      );

      // 対象ユーザー取得（trialStartAt が指定日 && isPaid=false）
      const users = await db
        .collection('users')
        .where('isPaid', '==', false)
        .get();

      for (const userDoc of users.docs) {
        const profile = userDoc.data();
        const trialStartAt: admin.firestore.Timestamp | undefined =
          profile.trialStartAt;

        if (!trialStartAt) continue;

        const trialStart = trialStartAt.toDate();
        trialStart.setHours(0, 0, 0, 0);

        if (
          trialStart >= startOfDay.toDate() &&
          trialStart < endOfDay.toDate()
        ) {
          const uid = userDoc.id;
          const email: string | undefined = profile.email;
          const displayName: string = profile.displayName || 'ユーザー';

          if (reminder.isExpiry) {
            // 期限切れ通知
            await _sendExpiryNotification(uid, displayName, email);
          } else {
            // リマインダー通知
            await _sendReminderNotification(
              uid,
              displayName,
              email,
              reminder.remainingDays
            );
          }
        }
      }
    }

    functions.logger.info('Trial expiry reminders sent');
  });

async function _sendReminderNotification(
  uid: string,
  displayName: string,
  email: string | undefined,
  remainingDays: number
): Promise<void> {
  // プッシュ通知
  await _sendPushToUser(uid, {
    title: `⏰ 無料期間があと${remainingDays}日で終わります`,
    body: `${displayName}さん、LifeTask Managerの無料トライアルは残り${remainingDays}日です。`,
    data: {
      notificationType: 'TRIAL_REMINDER',
      screen: 'paywall',
      remainingDays: String(remainingDays),
    },
  });

  // メール通知
  if (email) {
    await _sendEmail({
      to: email,
      subject: `LifeTask Manager の無料期間が残り ${remainingDays} 日です`,
      html: `
        <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto;">
          <div style="background-color: #1E88E5; color: white; padding: 20px; border-radius: 8px 8px 0 0;">
            <h1 style="margin: 0;">LifeTask Manager</h1>
          </div>
          <div style="padding: 24px; background: #f9f9f9;">
            <p>${displayName}さん、</p>
            <p>LifeTask Manager の無料トライアル期間が<strong>残り ${remainingDays} 日</strong>になりました。</p>
            <p>期限後はデータは保持されますが、閲覧・編集できなくなります。</p>
            <p>¥300 で永遠に使い続けることができます。</p>
            <a href="https://lifetask.app/paywall"
               style="display: inline-block; background: #1E88E5; color: white; padding: 12px 24px;
                      border-radius: 8px; text-decoration: none; margin-top: 16px;">
              今すぐ購入する（¥300）
            </a>
          </div>
        </div>
      `,
    });
  }
}

async function _sendExpiryNotification(
  uid: string,
  displayName: string,
  email: string | undefined
): Promise<void> {
  // プッシュ通知
  await _sendPushToUser(uid, {
    title: '🔒 無料期間が終了しました',
    body: 'LifeTask Managerの無料トライアルが終了しました。続けて使うには購入が必要です。',
    data: {
      notificationType: 'TRIAL_EXPIRED',
      screen: 'paywall',
      forced: 'true',
    },
  });

  // メール通知
  if (email) {
    await _sendEmail({
      to: email,
      subject: 'LifeTask Manager の無料期間が終了しました',
      html: `
        <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto;">
          <div style="background-color: #E53935; color: white; padding: 20px; border-radius: 8px 8px 0 0;">
            <h1 style="margin: 0;">LifeTask Manager</h1>
          </div>
          <div style="padding: 24px; background: #f9f9f9;">
            <p>${displayName}さん、</p>
            <p>LifeTask Manager の無料トライアル期間が終了しました。</p>
            <p><strong>データはそのまま保持されています</strong>が、現在はアクセスできない状態です。</p>
            <p>¥300 で購入すると、すべてのデータに再度アクセスできます。</p>
            <a href="https://lifetask.app/paywall"
               style="display: inline-block; background: #1E88E5; color: white; padding: 12px 24px;
                      border-radius: 8px; text-decoration: none; margin-top: 16px;">
              今すぐ購入する（¥300）
            </a>
          </div>
        </div>
      `,
    });
  }
}

async function _sendPushToUser(
  uid: string,
  payload: { title: string; body: string; data: Record<string, string> }
): Promise<void> {
  try {
    const prefDoc = await db
      .collection('users')
      .doc(uid)
      .collection('preferences')
      .doc(uid)
      .get();
    if (!prefDoc.exists) return;

    const fcmToken: string | undefined = prefDoc.data()?.fcmToken;
    if (!fcmToken) return;

    await messaging.send({
      token: fcmToken,
      notification: { title: payload.title, body: payload.body },
      data: payload.data,
      android: { priority: 'high' },
      apns: { payload: { aps: { sound: 'default', badge: 1 } } },
    });
  } catch (error) {
    functions.logger.error(`Push error for user ${uid}:`, error);
  }
}

async function _sendEmail(payload: {
  to: string;
  subject: string;
  html: string;
}): Promise<void> {
  const apiKey = process.env.SENDGRID_API_KEY;
  if (!apiKey) {
    functions.logger.warn('SendGrid API key not configured');
    return;
  }
  sgMail.setApiKey(apiKey);
  try {
    await sgMail.send({
      to: payload.to,
      from: 'noreply@lifetask.app',
      subject: payload.subject,
      html: payload.html,
    });
  } catch (error) {
    functions.logger.error('SendGrid error:', error);
  }
}
