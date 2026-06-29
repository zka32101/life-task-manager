import * as admin from 'firebase-admin';

admin.initializeApp();

// 通知系 Functions
export { sendDailyReminders } from './notifications/dailyReminderScheduler';
export { notifyGroupAction } from './notifications/groupActionNotifier';
export { sendInvitationEmail } from './notifications/sendInvitationEmail';
export { trialExpiryReminder } from './notifications/trialExpiryReminder';

// タスク管理 Functions
export { completeTask } from './tasks/completeTask';
export { deferTask } from './tasks/deferTask';
export { onUserCreate } from './tasks/onUserCreate';

// マイグレーション・シード
export { migrateToV11 } from './migrations/migrateToV11';
export { seedLocalePresets } from './migrations/seedLocalePresets';
