import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * タスク完了処理
 * - task_records に完了記録を追加
 * - tasks の lastDoneAt, nextDueAt を更新
 */
export const completeTask = functions.https.onCall(
  async (data: { taskId: string; groupId?: string; completedAt?: string }, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Authentication required');
    }

    const uid = context.auth.uid;
    const { taskId, groupId } = data;
    const completedAt = data.completedAt
      ? new Date(data.completedAt)
      : new Date();

    try {
      // タスク取得
      const taskRef = groupId
        ? db.collection('groups').doc(groupId).collection('tasks').doc(taskId)
        : db.collection('users').doc(uid).collection('tasks').doc(taskId);

      const taskDoc = await taskRef.get();
      if (!taskDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Task not found');
      }

      const task = taskDoc.data()!;

      // 次回予定日を計算
      const nextDueAt = _calculateNextDueDate(
        task.nextDueAt.toDate(),
        task.recurrenceType,
        task.recurrenceValue,
        task.recurrenceUnit
      );

      const batch = db.batch();

      // タスクを更新
      batch.update(taskRef, {
        lastDoneAt: admin.firestore.Timestamp.fromDate(completedAt),
        lastDoneByUid: uid,
        nextDueAt: admin.firestore.Timestamp.fromDate(nextDueAt),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedByUid: uid,
      });

      // 完了記録を追加
      const recordRef = groupId
        ? db.collection('groups').doc(groupId).collection('task_records').doc()
        : db.collection('users').doc(uid).collection('task_records').doc();

      batch.set(recordRef, {
        recordId: recordRef.id,
        taskId,
        doneAt: admin.firestore.Timestamp.fromDate(completedAt),
        doneByUid: uid,
        // グループの場合はメンバー名を取得して保存
        ...(groupId ? { doneByName: context.auth.token?.name || '' } : {}),
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      await batch.commit();

      functions.logger.info(`Task ${taskId} completed by ${uid}`);

      return {
        success: true,
        nextDueAt: nextDueAt.toISOString(),
        recordId: recordRef.id,
      };
    } catch (error) {
      if (error instanceof functions.https.HttpsError) throw error;
      functions.logger.error('Complete task error:', error);
      throw new functions.https.HttpsError('internal', 'Failed to complete task');
    }
  }
);

function _calculateNextDueDate(
  currentDueAt: Date,
  recurrenceType: string,
  recurrenceValue?: number,
  recurrenceUnit?: string
): Date {
  const date = new Date(currentDueAt);

  switch (recurrenceType) {
    case 'weekly':
      date.setDate(date.getDate() + 7);
      break;
    case 'biweekly':
      date.setDate(date.getDate() + 14);
      break;
    case 'monthly':
      date.setMonth(date.getMonth() + 1);
      break;
    case 'quarterly':
      date.setMonth(date.getMonth() + 3);
      break;
    case 'yearly':
      date.setFullYear(date.getFullYear() + 1);
      break;
    case 'custom':
      if (recurrenceValue && recurrenceUnit) {
        switch (recurrenceUnit) {
          case 'days':
            date.setDate(date.getDate() + recurrenceValue);
            break;
          case 'weeks':
            date.setDate(date.getDate() + recurrenceValue * 7);
            break;
          case 'months':
            date.setMonth(date.getMonth() + recurrenceValue);
            break;
          case 'years':
            date.setFullYear(date.getFullYear() + recurrenceValue);
            break;
        }
      }
      break;
    default:
      // 'none': 変更なし
      break;
  }

  return date;
}
