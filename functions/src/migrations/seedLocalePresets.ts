import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

/**
 * ロケール別推奨タスクを Firestore に投入する callable Function。
 *
 * 呼び出し方:
 *   firebase functions:call seedLocalePresets --data '{"locale":"ja-JP"}'
 *   または Flutter 側から CloudFunctions.instance.httpsCallable('seedLocalePresets').call({'locale': 'ja-JP'})
 *
 * コレクション構造:
 *   locale_presets/{locale}/recommended_tasks/{taskId}
 */

interface RecommendedTask {
  taskId: string;
  title: string;
  categoryId: string;
  categoryPath: string[];
  categoryLabels: string[];
  recurrenceType: string;
  recurrenceValue?: number;
  recurrenceUnit?: string;
  reminderDaysBefore: number;
  notes?: string;
}

// ---------------------------------------------------------------------------
// ja-JP 推奨タスク
// ---------------------------------------------------------------------------
const jaJpTasks: RecommendedTask[] = [
  // 金融・税金
  {
    taskId: 'ja_kakuteishinkoku',
    title: '確定申告',
    categoryId: 'finance_tax',
    categoryPath: ['finance', 'finance_tax'],
    categoryLabels: ['金融', '税金'],
    recurrenceType: 'yearly',
    reminderDaysBefore: 30,
    notes: '毎年2月16日〜3月15日が申告期間（源泉徴収票・医療費の領収書を準備）',
  },
  {
    taskId: 'ja_juuminzei',
    title: '住民税納付',
    categoryId: 'finance_tax',
    categoryPath: ['finance', 'finance_tax'],
    categoryLabels: ['金融', '税金'],
    recurrenceType: 'yearly',
    reminderDaysBefore: 7,
    notes: '普通徴収の場合、6月・8月・10月・翌1月の4回払い',
  },
  {
    taskId: 'ja_koteitashisan',
    title: '固定資産税納付',
    categoryId: 'finance_tax',
    categoryPath: ['finance', 'finance_tax'],
    categoryLabels: ['金融', '税金'],
    recurrenceType: 'yearly',
    reminderDaysBefore: 14,
    notes: '4月送付。一括または4期分割（4月・7月・12月・翌2月）',
  },
  // 住宅
  {
    taskId: 'ja_ekibosei',
    title: '火災保険更新確認',
    categoryId: 'housing_tax',
    categoryPath: ['housing', 'housing_tax'],
    categoryLabels: ['住宅', '保険'],
    recurrenceType: 'yearly',
    reminderDaysBefore: 60,
  },
  {
    taskId: 'ja_boofusei',
    title: '雨樋・屋根の点検',
    categoryId: 'housing_maintenance_roof',
    categoryPath: ['housing', 'housing_maintenance', 'housing_maintenance_roof'],
    categoryLabels: ['住宅', 'メンテナンス', '屋根'],
    recurrenceType: 'yearly',
    reminderDaysBefore: 7,
    notes: '梅雨前（5月）と台風後（10月）の年2回が目安',
  },
  {
    taskId: 'ja_eakon_filter',
    title: 'エアコンフィルター清掃',
    categoryId: 'housing_cleaning',
    categoryPath: ['housing', 'housing_cleaning'],
    categoryLabels: ['住宅', '清掃'],
    recurrenceType: 'monthly',
    reminderDaysBefore: 3,
  },
  {
    taskId: 'ja_kyushuki',
    title: '給湯器の点検',
    categoryId: 'housing_maintenance_plumbing',
    categoryPath: ['housing', 'housing_maintenance', 'housing_maintenance_plumbing'],
    categoryLabels: ['住宅', 'メンテナンス', '水回り'],
    recurrenceType: 'yearly',
    reminderDaysBefore: 14,
    notes: '製造から10年で交換時期の目安。年に一度専門業者に点検依頼推奨',
  },
  // 自動車
  {
    taskId: 'ja_shakken',
    title: '車検',
    categoryId: 'vehicle',
    categoryPath: ['vehicle'],
    categoryLabels: ['自動車'],
    recurrenceType: 'custom',
    recurrenceValue: 2,
    recurrenceUnit: 'years',
    reminderDaysBefore: 30,
    notes: '有効期限の1ヶ月前から受検可能',
  },
  {
    taskId: 'ja_jidosha_hoken',
    title: '自動車保険更新',
    categoryId: 'vehicle',
    categoryPath: ['vehicle'],
    categoryLabels: ['自動車'],
    recurrenceType: 'yearly',
    reminderDaysBefore: 60,
  },
  {
    taskId: 'ja_jidosha_zei',
    title: '自動車税納付',
    categoryId: 'vehicle',
    categoryPath: ['vehicle'],
    categoryLabels: ['自動車'],
    recurrenceType: 'yearly',
    reminderDaysBefore: 7,
    notes: '毎年5月中旬に送付。5月末が納付期限',
  },
  {
    taskId: 'ja_taiya_koukan',
    title: 'タイヤ交換（冬→夏）',
    categoryId: 'vehicle',
    categoryPath: ['vehicle'],
    categoryLabels: ['自動車'],
    recurrenceType: 'yearly',
    reminderDaysBefore: 7,
    notes: '概ね3月〜4月。気温7℃以上が目安',
  },
  {
    taskId: 'ja_taiya_koukan_fuyu',
    title: 'タイヤ交換（夏→冬）',
    categoryId: 'vehicle',
    categoryPath: ['vehicle'],
    categoryLabels: ['自動車'],
    recurrenceType: 'yearly',
    reminderDaysBefore: 7,
    notes: '概ね11月〜12月初旬。気温7℃以下が目安',
  },
  // 保険
  {
    taskId: 'ja_seimei_hoken',
    title: '生命保険証券確認・見直し',
    categoryId: 'insurance',
    categoryPath: ['insurance'],
    categoryLabels: ['保険'],
    recurrenceType: 'yearly',
    reminderDaysBefore: 7,
    notes: '年に一度、保障内容の見直しと受取人確認を推奨',
  },
  // 健康
  {
    taskId: 'ja_kenkousindan',
    title: '健康診断',
    categoryId: 'health',
    categoryPath: ['health'],
    categoryLabels: ['健康'],
    recurrenceType: 'yearly',
    reminderDaysBefore: 14,
    notes: '企業健診の場合、会社の案内に従う。自費の場合は年1回受診推奨',
  },
  {
    taskId: 'ja_ganken_shindan',
    title: '眼科・歯科定期検診',
    categoryId: 'health',
    categoryPath: ['health'],
    categoryLabels: ['健康'],
    recurrenceType: 'monthly',
    recurrenceValue: 6,
    recurrenceUnit: 'months',
    reminderDaysBefore: 7,
  },
  // 年賀状
  {
    taskId: 'ja_nengajo',
    title: '年賀状作成・投函',
    categoryId: 'other',
    categoryPath: ['other'],
    categoryLabels: ['その他'],
    recurrenceType: 'yearly',
    reminderDaysBefore: 14,
    notes: '12月25日までに投函すると元旦に届く',
  },
];

// ---------------------------------------------------------------------------
// en-US 推奨タスク
// ---------------------------------------------------------------------------
const enUsTasks: RecommendedTask[] = [
  {
    taskId: 'us_tax_return',
    title: 'File Federal Tax Return',
    categoryId: 'finance_tax',
    categoryPath: ['finance', 'finance_tax'],
    categoryLabels: ['Finance', 'Taxes'],
    recurrenceType: 'yearly',
    reminderDaysBefore: 30,
    notes: 'April 15 deadline. Use Form 1040. File extension by deadline if needed.',
  },
  {
    taskId: 'us_state_tax',
    title: 'File State Tax Return',
    categoryId: 'finance_tax',
    categoryPath: ['finance', 'finance_tax'],
    categoryLabels: ['Finance', 'Taxes'],
    recurrenceType: 'yearly',
    reminderDaysBefore: 30,
  },
  {
    taskId: 'us_property_tax',
    title: 'Property Tax Payment',
    categoryId: 'housing_tax',
    categoryPath: ['housing', 'housing_tax'],
    categoryLabels: ['Housing', 'Taxes'],
    recurrenceType: 'yearly',
    reminderDaysBefore: 14,
    notes: 'Typically due in April and October (varies by county)',
  },
  {
    taskId: 'us_car_registration',
    title: 'Vehicle Registration Renewal',
    categoryId: 'vehicle',
    categoryPath: ['vehicle'],
    categoryLabels: ['Vehicle'],
    recurrenceType: 'yearly',
    reminderDaysBefore: 30,
  },
  {
    taskId: 'us_car_insurance',
    title: 'Auto Insurance Renewal',
    categoryId: 'vehicle',
    categoryPath: ['vehicle'],
    categoryLabels: ['Vehicle'],
    recurrenceType: 'yearly',
    reminderDaysBefore: 30,
  },
  {
    taskId: 'us_home_insurance',
    title: 'Homeowner\'s Insurance Review',
    categoryId: 'insurance',
    categoryPath: ['insurance'],
    categoryLabels: ['Insurance'],
    recurrenceType: 'yearly',
    reminderDaysBefore: 60,
  },
  {
    taskId: 'us_annual_checkup',
    title: 'Annual Physical Checkup',
    categoryId: 'health',
    categoryPath: ['health'],
    categoryLabels: ['Health'],
    recurrenceType: 'yearly',
    reminderDaysBefore: 14,
  },
  {
    taskId: 'us_dental_checkup',
    title: 'Dental Cleaning & Checkup',
    categoryId: 'health',
    categoryPath: ['health'],
    categoryLabels: ['Health'],
    recurrenceType: 'custom',
    recurrenceValue: 6,
    recurrenceUnit: 'months',
    reminderDaysBefore: 7,
  },
  {
    taskId: 'us_hvac_filter',
    title: 'Replace HVAC Air Filter',
    categoryId: 'housing_maintenance',
    categoryPath: ['housing', 'housing_maintenance'],
    categoryLabels: ['Housing', 'Maintenance'],
    recurrenceType: 'monthly',
    recurrenceValue: 3,
    recurrenceUnit: 'months',
    reminderDaysBefore: 3,
  },
  {
    taskId: 'us_smoke_detector',
    title: 'Test Smoke & CO Detectors',
    categoryId: 'housing_maintenance',
    categoryPath: ['housing', 'housing_maintenance'],
    categoryLabels: ['Housing', 'Maintenance'],
    recurrenceType: 'monthly',
    recurrenceValue: 6,
    recurrenceUnit: 'months',
    reminderDaysBefore: 3,
    notes: 'Change batteries annually (when clocks change is a good reminder)',
  },
];

// ---------------------------------------------------------------------------
// zh-CN 推奨タスク
// ---------------------------------------------------------------------------
const zhCnTasks: RecommendedTask[] = [
  {
    taskId: 'cn_tax_return',
    title: '个人所得税年度汇算',
    categoryId: 'finance_tax',
    categoryPath: ['finance', 'finance_tax'],
    categoryLabels: ['金融', '税务'],
    recurrenceType: 'yearly',
    reminderDaysBefore: 30,
    notes: '每年3月1日至6月30日，通过个人所得税App办理',
  },
  {
    taskId: 'cn_car_annual',
    title: '车辆年检',
    categoryId: 'vehicle',
    categoryPath: ['vehicle'],
    categoryLabels: ['车辆'],
    recurrenceType: 'yearly',
    reminderDaysBefore: 30,
  },
  {
    taskId: 'cn_car_insurance',
    title: '车险续保',
    categoryId: 'vehicle',
    categoryPath: ['vehicle'],
    categoryLabels: ['车辆'],
    recurrenceType: 'yearly',
    reminderDaysBefore: 30,
  },
  {
    taskId: 'cn_health_checkup',
    title: '年度体检',
    categoryId: 'health',
    categoryPath: ['health'],
    categoryLabels: ['健康'],
    recurrenceType: 'yearly',
    reminderDaysBefore: 14,
  },
  {
    taskId: 'cn_social_insurance',
    title: '社会保险缴费确认',
    categoryId: 'finance',
    categoryPath: ['finance'],
    categoryLabels: ['金融'],
    recurrenceType: 'yearly',
    reminderDaysBefore: 7,
    notes: '确认养老、医疗、失业、工伤等保险正常缴纳',
  },
];

// ---------------------------------------------------------------------------
// Locale → tasks map
// ---------------------------------------------------------------------------
const localeTasksMap: Record<string, RecommendedTask[]> = {
  'ja-JP': jaJpTasks,
  'en-US': enUsTasks,
  'zh-CN': zhCnTasks,
};

// ---------------------------------------------------------------------------
// Cloud Function
// ---------------------------------------------------------------------------
export const seedLocalePresets = functions
  .region('asia-northeast1')
  .https.onCall(async (data, context) => {
    // 管理者チェック（production では適切な権限チェックを実装すること）
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Authentication required',
      );
    }

    const locale: string | undefined = data?.locale;
    const localesToSeed = locale
      ? [locale]
      : Object.keys(localeTasksMap);

    const db = admin.firestore();
    const results: Record<string, number> = {};

    for (const loc of localesToSeed) {
      const tasks = localeTasksMap[loc];
      if (!tasks) {
        results[loc] = 0;
        continue;
      }

      const presetsRef = db
        .collection('locale_presets')
        .doc(loc)
        .collection('recommended_tasks');

      // バッチ書き込み（500件ずつ）
      const BATCH_SIZE = 400;
      let count = 0;

      for (let i = 0; i < tasks.length; i += BATCH_SIZE) {
        const batch = db.batch();
        const chunk = tasks.slice(i, i + BATCH_SIZE);
        for (const task of chunk) {
          const docRef = presetsRef.doc(task.taskId);
          batch.set(docRef, {
            ...task,
            locale: loc,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          count++;
        }
        await batch.commit();
      }

      // locale_presets/{locale} の profile ドキュメントも更新
      await db.collection('locale_presets').doc(loc).set(
        {
          locale: loc,
          taskCount: tasks.length,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      results[loc] = count;
    }

    return { success: true, results };
  });
