/// アプリ全体の定数
class AppConstants {
  AppConstants._();

  // アプリ情報
  static const String appName = 'LifeTask Manager';
  static const String appVersion = '1.0.0';

  // トライアル設定
  static const int trialDays = 30;
  static const double appPrice = 2.99;
  static const double invitedPrice = 1.49;
  static const String priceDisplay = '¥300';

  // RevenueCat
  static const String revenueCatApiKeyAndroid = 'goog_hfnpNEDGjpBVoViONtWnJUNNlVA';
  static const String revenueCatApiKeyIos = 'your_revenuecat_ios_key';
  static const String entitlementId = 'lifetime_access';
  static const String productIdAndroid = 'com.petitworks.apps.lifetaskmanager.lifetime';
  static const String productIdIos = 'com.petitworks.apps.lifetaskmanager.lifetime';
  static const String productIdInvited = 'com.petitworks.apps.lifetaskmanager.lifetime.invited';

  // トライアル警告表示（残 N 日以下でバナー表示）
  static const int trialWarningDays = 7;

  // タスク設定
  static const int titleMaxLength = 50;
  static const int descriptionMaxLength = 1000;
  static const int notesMaxLength = 500;
  static const int categoryMaxDepth = 5;

  // グループ招待
  static const int invitationExpiryDays = 7;

  // リマインダー選択肢（日前）
  static const List<int> reminderOptions = [0, 1, 3, 7, 14];

  // デフォルトリマインダー
  static const int defaultReminderDays = 7;

  // Firestore コレクション名
  static const String usersCollection = 'users';
  static const String groupsCollection = 'groups';
  static const String localePresetsCollection = 'locale_presets';
  static const String appConfigCollection = 'app_config';

  static const String profileDoc = 'profile';
  static const String preferencesDoc = 'preferences';
  static const String tasksSubCollection = 'tasks';
  static const String taskRecordsSubCollection = 'task_records';
  static const String excludedItemsSubCollection = 'excluded_items';
  static const String membersSubCollection = 'members';
  static const String invitationsSubCollection = 'invitations';
  static const String categoriesSubCollection = 'categories';
  static const String recommendedTasksSubCollection = 'recommended_tasks';

  // サポートロケール
  static const List<String> supportedLocales = [
    'ja-JP',
    'en-US',
    'en-GB',
    'en-AU',
    'en-CA',
    'zh-CN',
    'zh-TW',
    'de-DE',
    'fr-FR',
    'es-ES',
    'ko-KR',
    'pt-BR',
  ];

  // デフォルトカテゴリ ID
  static const List<String> defaultCategoryIds = [
    'housing',
    'vehicle',
    'insurance',
    'health',
    'finance',
    'other',
  ];
}

/// 繰り返しタイプ
enum RecurrenceType {
  none,
  weekly,
  biweekly,
  monthly,
  quarterly,
  yearly,
  custom;

  String get displayName {
    switch (this) {
      case RecurrenceType.none:
        return '繰り返しなし';
      case RecurrenceType.weekly:
        return '毎週';
      case RecurrenceType.biweekly:
        return '隔週';
      case RecurrenceType.monthly:
        return '毎月';
      case RecurrenceType.quarterly:
        return '四半期ごと';
      case RecurrenceType.yearly:
        return '毎年';
      case RecurrenceType.custom:
        return 'カスタム';
    }
  }

  static RecurrenceType fromString(String value) {
    return RecurrenceType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RecurrenceType.none,
    );
  }
}

/// 除外アイテムタイプ
enum ExclusionItemType {
  localePresetTask,
  category,
  categoryWithChildren;

  String get value {
    switch (this) {
      case ExclusionItemType.localePresetTask:
        return 'locale_preset_task';
      case ExclusionItemType.category:
        return 'category';
      case ExclusionItemType.categoryWithChildren:
        return 'category_with_children';
    }
  }

  static ExclusionItemType fromString(String value) {
    switch (value) {
      case 'locale_preset_task':
        return ExclusionItemType.localePresetTask;
      case 'category':
        return ExclusionItemType.category;
      case 'category_with_children':
        return ExclusionItemType.categoryWithChildren;
      default:
        return ExclusionItemType.localePresetTask;
    }
  }
}

/// 招待ステータス
enum InvitationStatus {
  pending,
  accepted,
  declined,
  expired;

  String get value => name;

  static InvitationStatus fromString(String value) {
    return InvitationStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => InvitationStatus.pending,
    );
  }
}
