import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * 毎日 JST 8:00 に実行
 * 法定締切タスク (60/30/7/1日前) および推奨タスク通知を送信
 * 設計書: notification-system-design.md
 */
export const sendDailyReminders = functions
  .pubsub.schedule('0 23 * * *')  // UTC 23:00 = JST 8:00
  .timeZone('Asia/Tokyo')
  .onRun(async (_context) => {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    try {
      // ──────────────────────────────
      // 1. 法定締切タスク (60/30/7/1日前)
      // ──────────────────────────────
      const reminderDays = [60, 30, 7, 1];

      for (const daysOffset of reminderDays) {
        const targetDate = new Date(today);
        targetDate.setDate(targetDate.getDate() + daysOffset);
        const targetStart = admin.firestore.Timestamp.fromDate(targetDate);
        const targetEnd = admin.firestore.Timestamp.fromDate(
          new Date(targetDate.getTime() + 24 * 60 * 60 * 1000)
        );

        // 個人タスク
        const personalTasks = await db
          .collectionGroup('tasks')
          .where('nextDueAt', '>=', targetStart)
          .where('nextDueAt', '<', targetEnd)
          .where('isArchived', '==', false)
          .get();

        for (const doc of personalTasks.docs) {
          const task = doc.data();
          const uid = doc.ref.parent.parent?.id;
          if (!uid) continue;

          await _sendNotificationToUser(uid, {
            title: `📋 ${task.title}まであと${daysOffset}日です`,
            body: `${task.title} | 残り${daysOffset}日 | ${_formatDate(task.nextDueAt.toDate())}`,
            data: {
              notificationType: 'LEGAL_DEADLINE',
              screen: 'task_detail',
              taskId: task.taskId || doc.id,
            },
            priority: daysOffset <= 7 ? 'high' : 'normal',
          });
        }
      }

      // ──────────────────────────────
      // 2. 推奨タスク通知（月初）
      // ──────────────────────────────
      if (today.getDate() === 1) {
        const allUsers = await db.collection('users').get();
        for (const userDoc of allUsers.docs) {
          await _sendNotificationToUser(userDoc.id, {
            title: '📋 今月のおすすめタスク',
            body: '今月確認すべきタスクがあります',
            data: {
              notificationType: 'RECOMMENDED_MONTHLY',
              screen: 'home',
            },
            priority: 'normal',
          });
        }
      }

      // ──────────────────────────────
      // 3. 季節タスク通知（季節初月の第1週）
      // ──────────────────────────────
      const seasonStartMonths: { [key: string]: number } = {
        spring: 3,
        summer: 6,
        autumn: 9,
        winter: 12,
      };

      const currentMonth = today.getMonth() + 1;
      const currentDay = today.getDate();

      for (const [season, month] of Object.entries(seasonStartMonths)) {
        if (currentMonth === month && currentDay <= 7) {
          const seasonEmojis: { [key: string]: string } = {
            spring: '🌸',
            summer: '☀️',
            autumn: '🍂',
            winter: '❄️',
          };
          const allUsers = await db.collection('users').get();
          for (const userDoc of allUsers.docs) {
            await _sendNotificationToUser(userDoc.id, {
              title: `${seasonEmojis[season] || '🌍'} 季節のメンテナンスシーズンです`,
              body: '季節のタスクを確認しましょう',
              data: {
                notificationType: 'SEASONAL_TASK',
                screen: 'home',
                season,
              },
              priority: 'normal',
            });
          }
        }
      }

      functions.logger.info('Daily reminders sent successfully');
    } catch (error) {
      functions.logger.error('Error sending daily reminders:', error);
    }
  });

async function _sendNotificationToUser(
  uid: string,
  payload: {
    title: string;
    body: string;
    data: Record<string, string>;
    priority: 'high' | 'normal';
  }
): Promise<void> {
  try {
    const prefDoc = await db
      .collection('users')
      .doc(uid)
      .collection('preferences')
      .doc(uid)
      .get();

    if (!prefDoc.exists) return;

    const prefs = prefDoc.data()!;

    // 通知が無効の場合はスキップ
    if (prefs.notificationEnabled === false) return;

    const fcmToken: string | undefined = prefs.fcmToken;
    if (!fcmToken) {
      functions.logger.warn(`No FCM token for user ${uid}`);
      return;
    }

    const message: admin.messaging.Message = {
      token: fcmToken,
      notification: {
        title: payload.title,
        body: payload.body,
      },
      data: payload.data,
      android: {
        priority: payload.priority === 'high' ? 'high' : 'normal',
        notification: {
          sound: prefs.soundEnabled !== false ? 'default' : undefined,
          channelId: payload.priority === 'high'
            ? 'lifetask_legal'
            : 'lifetask_default',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: prefs.soundEnabled !== false ? 'default' : undefined,
            badge: 1,
          },
        },
      },
    };

    await messaging.send(message);
    functions.logger.info(`Notification sent to user ${uid}`);
  } catch (error) {
    functions.logger.error(`Error sending to user ${uid}:`, error);
  }
}

function _formatDate(date: Date): string {
  return date.toLocaleDateString('ja-JP', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  });
}
