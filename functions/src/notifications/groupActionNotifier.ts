import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * グループタスク完了時にメンバー全員へリアルタイム通知
 * 設計書: notification-system-design.md §2
 */
export const notifyGroupAction = functions.firestore
  .document('groups/{groupId}/task_records/{recordId}')
  .onCreate(async (snap, context) => {
    const record = snap.data();
    const { groupId } = context.params;

    try {
      // グループメンバーを取得
      const groupProfileDoc = await db
        .collection('groups')
        .doc(groupId)
        .collection('profile')
        .doc('profile')
        .get();

      if (!groupProfileDoc.exists) return;

      const memberUids: string[] = groupProfileDoc.data()?.memberUids || [];

      // 完了した人以外に通知
      const otherMembers = memberUids.filter(
        (uid: string) => uid !== record.doneByUid
      );

      if (otherMembers.length === 0) return;

      // タスク名を取得
      let taskTitle = 'タスク';
      if (record.taskId) {
        const taskDoc = await db
          .collection('groups')
          .doc(groupId)
          .collection('tasks')
          .doc(record.taskId)
          .get();
        if (taskDoc.exists) {
          taskTitle = taskDoc.data()?.title || 'タスク';
        }
      }

      const payload = {
        title: `🎉 ${record.doneByName || 'メンバー'}がタスクを完了しました`,
        body: `「${taskTitle}」を完了しました`,
        data: {
          notificationType: 'GROUP_ACTION',
          actionType: 'task_completed',
          screen: 'task_detail',
          taskId: record.taskId || '',
          groupId,
        },
      };

      // 各メンバーに通知
      for (const uid of otherMembers) {
        await _sendToUser(uid, payload);
      }

      functions.logger.info(`Group action notification sent to ${otherMembers.length} members`);
    } catch (error) {
      functions.logger.error('Error sending group notification:', error);
    }
  });

async function _sendToUser(
  uid: string,
  payload: {
    title: string;
    body: string;
    data: Record<string, string>;
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
    if (prefDoc.data()?.notificationEnabled === false) return;

    const fcmToken: string | undefined = prefDoc.data()?.fcmToken;
    if (!fcmToken) return;

    await messaging.send({
      token: fcmToken,
      notification: { title: payload.title, body: payload.body },
      data: payload.data,
      android: {
        priority: 'normal',
        notification: { sound: 'default' },
      },
      apns: {
        payload: { aps: { sound: 'default' } },
      },
    });
  } catch (error) {
    functions.logger.error(`Error sending to user ${uid}:`, error);
  }
}
