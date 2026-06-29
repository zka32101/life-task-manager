import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * v1.0 → v1.1 マイグレーション
 * - tasks に isLocalePreset フィールドを追加
 * - ロケール別推奨タスクを自動インポート
 * 設計書: rollout-migration-plan.md §3
 */
export const migrateToV11 = functions.https.onCall(
  async (_data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Authentication required');
    }

    const uid = context.auth.uid;

    try {
      const profileDoc = await db
        .collection('users')
        .doc(uid)
        .collection('profile')
        .doc('profile')
        .get();

      if (!profileDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'User profile not found');
      }

      const profile = profileDoc.data()!;
      const language = profile.language || 'ja';
      const country = profile.country || 'JP';
      const localeCode = `${language}-${country}`;

      const tasksRef = db.collection('users').doc(uid).collection('tasks');
      const tasks = await tasksRef.get();

      // バッチは500件制限があるため分割
      const BATCH_SIZE = 400;
      let batchCount = 0;
      let currentBatch = db.batch();

      for (const doc of tasks.docs) {
        if (!doc.data().hasOwnProperty('isLocalePreset')) {
          currentBatch.update(doc.ref, {
            isLocalePreset: false,
            presetLocale: null,
          });
          batchCount++;

          if (batchCount >= BATCH_SIZE) {
            await currentBatch.commit();
            currentBatch = db.batch();
            batchCount = 0;
          }
        }
      }

      // 推奨タスクを追加
      const recommendedTasks = await db
        .collection('locale_presets')
        .doc(localeCode)
        .collection('recommended_tasks')
        .where('isPopular', '==', true)
        .get();

      for (const doc of recommendedTasks.docs) {
        const task = doc.data();
        currentBatch.set(
          db.collection('users').doc(uid).collection('tasks').doc(),
          {
            title: task.title,
            description: task.description || null,
            categoryId: task.category,
            categoryPath: task.category,
            categoryLabels: [task.category],
            nextDueAt: admin.firestore.Timestamp.now(),
            lastDoneAt: null,
            lastDoneByUid: null,
            recurrenceType: task.recurrenceType,
            recurrenceValue: null,
            recurrenceUnit: null,
            reminderDaysBefore: task.reminderDaysBefore || 7,
            groupId: null,
            mainAssigneeUid: null,
            assigneeUids: [],
            deferCount: 0,
            originalDueAt: null,
            deferredAt: null,
            deferredByUid: null,
            snoozeUntil: null,
            notes: task.notes || null,
            cost: null,
            costCurrency: null,
            isArchived: false,
            isLocalePreset: true,
            presetLocale: localeCode,
            isGroupTask: false,
            createdByUid: uid,
            updatedByUid: uid,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          }
        );
        batchCount++;

        if (batchCount >= BATCH_SIZE) {
          await currentBatch.commit();
          currentBatch = db.batch();
          batchCount = 0;
        }
      }

      if (batchCount > 0) {
        await currentBatch.commit();
      }

      functions.logger.info(`Migration to v1.1 completed for user ${uid}`);

      return {
        success: true,
        message: `Migrated to v1.1 for user ${uid}`,
        tasksUpdated: tasks.size,
        tasksAdded: recommendedTasks.size,
      };
    } catch (error) {
      if (error instanceof functions.https.HttpsError) throw error;
      functions.logger.error('Migration error:', error);
      throw new functions.https.HttpsError('internal', 'Migration failed');
    }
  }
);
