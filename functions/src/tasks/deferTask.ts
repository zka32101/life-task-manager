import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * タスク延期処理
 * - deferCount をインクリメント
 * - nextDueAt を更新
 * - originalDueAt（初回延期時）を記録
 */
export const deferTask = functions.https.onCall(
  async (
    data: { taskId: string; groupId?: string; newDueAt: string; reason?: string },
    context
  ) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Authentication required');
    }

    const uid = context.auth.uid;
    const { taskId, groupId, reason } = data;
    const newDueAt = new Date(data.newDueAt);

    if (isNaN(newDueAt.getTime())) {
      throw new functions.https.HttpsError('invalid-argument', 'Invalid newDueAt date');
    }

    try {
      const taskRef = groupId
        ? db.collection('groups').doc(groupId).collection('tasks').doc(taskId)
        : db.collection('users').doc(uid).collection('tasks').doc(taskId);

      const taskDoc = await taskRef.get();
      if (!taskDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Task not found');
      }

      const task = taskDoc.data()!;
      const isFirstDefer = !task.originalDueAt;

      await taskRef.update({
        nextDueAt: admin.firestore.Timestamp.fromDate(newDueAt),
        deferCount: admin.firestore.FieldValue.increment(1),
        deferredAt: admin.firestore.FieldValue.serverTimestamp(),
        deferredByUid: uid,
        // 初回延期時のみ originalDueAt を記録
        ...(isFirstDefer ? { originalDueAt: task.nextDueAt } : {}),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedByUid: uid,
      });

      functions.logger.info(`Task ${taskId} deferred by ${uid} to ${newDueAt.toISOString()}`);

      return {
        success: true,
        newDueAt: newDueAt.toISOString(),
        deferCount: (task.deferCount || 0) + 1,
      };
    } catch (error) {
      if (error instanceof functions.https.HttpsError) throw error;
      functions.logger.error('Defer task error:', error);
      throw new functions.https.HttpsError('internal', 'Failed to defer task');
    }
  }
);
