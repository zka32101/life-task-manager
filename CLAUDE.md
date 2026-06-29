# LifeTask Manager — CLAUDE.md

## プロジェクト概要

人生の大事なタスクを管理するFlutterアプリ。

- **パッケージ名**: `com.petitworks.apps.lifetaskmanager`
- **バージョン**: 1.0.0+1
- **Firebase プロジェクト**: TBD（要セットアップ）
- **設計書バージョン**: v3.1（2026-05-25確定）

## アーキテクチャ

Clean Architecture + Riverpod

```
lib/
├── core/
│   ├── constants/    - AppConstants, RecurrenceType, etc.
│   ├── theme/        - AppTheme（Material 3）
│   └── utils/        - TrialService, AppDateUtils
├── features/
│   ├── auth/         - Google Sign-In, UserProfile
│   ├── tasks/        - タスク管理（個人・グループ）
│   ├── groups/       - グループ・招待管理
│   ├── notifications/ - FCM + ローカル通知
│   ├── onboarding/   - 初回設定（ロケール・推奨タスク）
│   ├── paywall/      - PaywallScreen（3パターン）
│   └── settings/     - 設定・対象外管理
├── app_router.dart   - GoRouter 定義
└── main.dart         - Firebase初期化、Sentry、通知
```

## トライアル仕様（v3.1）

| 状態 | 条件 | アクセス |
|------|------|---------|
| トライアル中 | isPaid=false, 30日未満 | フルアクセス |
| トライアル期限切れ | isPaid=false, 30日以上 | 完全ロック |
| 有料 | isPaid=true | 永遠にフルアクセス |

- 残7日以下 → HomeScreen に黄色バナー表示
- 期限切れ → PaywallScreen 強制表示（「あとで」なし）
- 招待ユーザー → $1.49 の割引価格

## Firebase セットアップ

1. `firebase_options.dart` を生成: `flutterfire configure`
2. `.env` を `.env.example` からコピーして設定
3. Firestore Rules: `firebase deploy --only firestore:rules`
4. Firestore Indexes: `firebase deploy --only firestore:indexes`
5. Cloud Functions: `cd functions && npm install && firebase deploy --only functions`

## 主要パッケージ

- `flutter_riverpod` + `riverpod_annotation` — 状態管理
- `cloud_firestore` + `firebase_auth` — バックエンド
- `go_router` — ルーティング
- `purchases_flutter` — RevenueCat 課金
- `firebase_messaging` + `flutter_local_notifications` — 通知
- `freezed` + `json_annotation` — コードジェネレーション
- `sentry_flutter` — エラートラッキング

## コードジェネレーション

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## テスト実行

```bash
flutter test                              # ユニットテスト
flutter test integration_test/           # インテグレーションテスト
cd functions && npm test                  # Cloud Functions テスト
```

## リリース

設計書: `rollout-migration-plan.md`

```bash
# Android
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Firestore コレクション構造

```
users/{uid}/
  profile          - ユーザープロフィール（isPaid, trialStartAt）
  preferences      - 設定（通知, FCMトークン）
  tasks/{taskId}   - 個人タスク
  task_records/    - 完了記録
  excluded_items/  - 対象外設定

groups/{groupId}/
  profile          - グループ情報
  members/{uid}    - メンバー
  invitations/     - 招待
  tasks/{taskId}   - グループタスク
  task_records/    - グループ完了記録
  categories/      - 階層カテゴリ（最大5階層）

locale_presets/{locale}/
  profile          - ロケール情報
  recommended_tasks/ - 地域別推奨タスク
  fiscal_year_info - 会計年度情報
```

## カテゴリ構造（階層）

```
住宅（housing）
  └─ メンテナンス（housing_maintenance）
       └─ 屋根（housing_maintenance_roof）
       └─ 水回り（housing_maintenance_plumbing）
  └─ 清掃（housing_cleaning）
  └─ 税金（housing_tax）
自動車（vehicle）
保険（insurance）
健康（health）
金融（finance）
その他（other）
```

## TODO（手動セットアップ必須）

- [ ] `firebase_options.dart` 設定（`flutterfire configure` で上書き）
- [ ] RevenueCat API キー設定（AppConstants の revenueCatApiKeyIos/Android を本番キーに置換）
- [ ] E2E テスト実装
- [ ] `dart run build_runner build --delete-conflicting-outputs`（freezed ファイル生成）
- [ ] Firestore デプロイ（`firebase deploy --only firestore`）
- [ ] Cloud Functions デプロイ（`cd functions && firebase deploy --only functions`）

## 完了済み

- [x] authProvider (Riverpod) — auth_provider.dart
- [x] tasksProvider (Riverpod) — tasks_provider.dart  
- [x] groupsProvider (Riverpod) — groups_provider.dart
- [x] exclusionProvider (Riverpod) — exclusion_provider.dart
- [x] preferencesProvider (Riverpod) — preferences_provider.dart
- [x] purchaseProvider (RevenueCat) — purchase_provider.dart
- [x] TaskDetailScreen — task_detail_screen.dart
- [x] DeferBottomSheet（ロケール修正済み）— defer_bottom_sheet.dart
- [x] SplashScreen — splash_screen.dart
- [x] HomeScreen（Riverpod 完全接続）— home_screen.dart
- [x] TaskSearchScreen — task_search_screen.dart
- [x] TaskAddEditScreen — task_add_edit_screen.dart
- [x] GroupDetailScreen — group_detail_screen.dart
- [x] GroupScreen — group_screen.dart
- [x] ExclusionItemsScreen — exclusion_items_screen.dart
- [x] InvitationAcceptScreen — invitation_accept_screen.dart
- [x] LanguageScreen — language_screen.dart
- [x] SettingsScreen（言語・通知・URL・アカウント削除）— settings_screen.dart
- [x] PaywallScreen（RevenueCat 購入・復元）— paywall_screen.dart
- [x] LoginScreen — login_screen.dart
- [x] OnboardingScreen（Firestore 推奨タスク接続）— onboarding_screen.dart
- [x] firebase_options.dart（プレースホルダー）
- [x] LocalePreset シードデータ Cloud Function — seedLocalePresets.ts
- [x] LocalePresetRepository — locale_preset_repository.dart
- [x] UserPreferencesModel — user_preferences_model.dart
- [x] URL ランチャー（プライバシーポリシー・利用規約）
- [x] アカウント削除機能
- [x] RevenueCat restorePurchases 実装
- [x] 通知設定の Firestore 永続化
- [x] Widget テスト（paywall, login）
- [x] 全画面への Riverpod プロバイダー接続
- [x] GoRouter ルーティング完全実装
