/// アプリ全体で共有するカテゴリ定義
class AppCategories {
  AppCategories._();

  // ─────────────────────────────────────────────
  // Level 0: 大カテゴリ  (id, emoji, label)
  // ─────────────────────────────────────────────
  static const List<(String, String, String)> level0 = [
    ('housing',   '🏠', '住宅'),
    ('vehicle',   '🚗', '自動車'),
    ('insurance', '🛡️', '保険'),
    ('health',    '💊', '健康・医療'),
    ('finance',   '💴', 'お金・税金'),
    ('family',    '👨‍👩‍👧', '家族'),
    ('digital',   '📱', 'デジタル'),
    ('work',      '🏢', '仕事・資格'),
    ('pet',       '🐾', 'ペット'),
    ('other',     '📋', 'その他'),
  ];

  // ─────────────────────────────────────────────
  // Level 1: 中カテゴリ
  // ─────────────────────────────────────────────
  static const Map<String, List<(String, String, String)>> level1 = {
    'housing': [
      ('housing_maintenance', '🔨', 'メンテナンス'),
      ('housing_cleaning',    '🧹', '清掃・点検'),
      ('housing_tax',         '💰', '税金・費用'),
      ('housing_equipment',   '🔧', '設備交換'),
      ('housing_reform',      '🏗️', 'リフォーム'),
    ],
    'vehicle': [
      ('vehicle_inspection',  '🔧', '車検・点検'),
      ('vehicle_insurance',   '📋', '保険'),
      ('vehicle_tax',         '💴', '税金'),
      ('vehicle_parts',       '🛞', '消耗品交換'),
    ],
    'insurance': [
      ('insurance_life',      '💗', '生命保険'),
      ('insurance_medical',   '🏥', '医療保険'),
      ('insurance_fire',      '🔥', '火災保険'),
      ('insurance_car',       '🚗', '自動車保険'),
      ('insurance_other',     '📋', 'その他保険'),
    ],
    'health': [
      ('health_checkup',      '🏥', '健康診断'),
      ('health_dental',       '🦷', '歯科'),
      ('health_vaccine',      '💉', '予防接種'),
      ('health_eye',          '👁️', '眼科'),
      ('health_prescription', '💊', '処方箋・薬'),
    ],
    'finance': [
      ('finance_tax',         '📊', '確定申告'),
      ('finance_pension',     '🏦', '年金・社会保険'),
      ('finance_investment',  '📈', '投資・NISA'),
      ('finance_inheritance', '📜', '相続・遺言'),
      ('finance_fixed_cost',  '💳', '固定費見直し'),
    ],
    'family': [
      ('family_education',    '🎒', '学校・教育'),
      ('family_health',       '👶', '子どもの健康'),
      ('family_event',        '🎉', '行事・イベント'),
      ('family_care',         '👴', '介護'),
    ],
    'digital': [
      ('digital_device',      '💻', 'スマホ・PC'),
      ('digital_subscription','📺', 'サブスク'),
      ('digital_security',    '🔒', 'セキュリティ'),
      ('digital_backup',      '💾', 'バックアップ'),
    ],
    'work': [
      ('work_license',     '📜', '資格更新'),
      ('work_insurance',   '🏢', '社会保険'),
      ('work_documents',   '📄', '書類・契約'),
      ('work_renewal',     '🔄', '契約更新'),
    ],
    'pet': [
      ('pet_vaccine',    '💉', 'ワクチン・予防'),
      ('pet_checkup',    '🏥', '健康診断'),
      ('pet_supplies',   '🛒', '定期購入'),
      ('pet_procedure',  '📋', '手続き'),
    ],
  };

  // ─────────────────────────────────────────────
  // Level 2: 小カテゴリ  (id, label)
  // ─────────────────────────────────────────────
  static const Map<String, List<(String, String)>> level2 = {
    'housing_maintenance': [
      ('housing_maintenance_roof',       '屋根・外壁'),
      ('housing_maintenance_plumbing',   '水回り'),
      ('housing_maintenance_electrical', '電気・設備'),
      ('housing_maintenance_garden',     '庭・外構'),
    ],
    'housing_equipment': [
      ('housing_equipment_water_heater', '給湯器'),
      ('housing_equipment_ac',           'エアコン'),
      ('housing_equipment_kitchen',      'キッチン設備'),
      ('housing_equipment_toilet',       'トイレ'),
    ],
    'vehicle_parts': [
      ('vehicle_parts_tire',    'タイヤ'),
      ('vehicle_parts_battery', 'バッテリー'),
      ('vehicle_parts_oil',     'オイル交換'),
      ('vehicle_parts_wiper',   'ワイパー'),
    ],
    'health_checkup': [
      ('health_checkup_general',  '一般健診'),
      ('health_checkup_cancer',   'がん検診'),
      ('health_checkup_blood',    '血液検査'),
    ],
    'family_education': [
      ('family_education_school',    '入学・卒業手続き'),
      ('family_education_insurance', '学校保険'),
      ('family_education_event',     '学校行事'),
    ],
  };

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────

  /// Level0のIDからemoji+labelを返す
  static String getLevel0Label(String id) {
    for (final c in level0) {
      if (c.$1 == id) return '${c.$2} ${c.$3}';
    }
    return id;
  }

  /// 任意のIDからラベルを返す
  static String getLabelById(String id) {
    for (final c in level0) {
      if (c.$1 == id) return c.$3;
    }
    for (final cats in level1.values) {
      for (final c in cats) {
        if (c.$1 == id) return c.$3;
      }
    }
    for (final cats in level2.values) {
      for (final c in cats) {
        if (c.$1 == id) return c.$2;
      }
    }
    return id;
  }
}
