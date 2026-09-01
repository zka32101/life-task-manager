# LifeTask Manager — デプロイメント準備ガイド

> **最終確認日**: 2026-09-01  
> **対象バージョン**: 1.0.0

## 概要

このドキュメントは、LifeTask Manager をプロダクション環境にリリースするための完全なチェックリストです。

---

## Phase 2-1: Firebase設定

### 1.1 firebase_options.dart の生成

```bash
# 方法A: FlutterFire CLIで自動生成（推奨）
dart pub global activate flutterfire_cli
flutterfire configure

# 方法B: 手動設定
# lib/firebase_options.dart の REPLACE_WITH_* をFire baseコンソールから取得
```

**取得場所**: [Firebase Console](https://console.firebase.google.com/)
- Project Settings → General
- 必須項目:
  - `apiKey`: クライアント API キー
  - `appId`: Firebase App ID
  - `messagingSenderId`: Cloud Messaging 送信者 ID
  - `projectId`: プロジェクト ID
  - `storageBucket`: Cloud Storage バケット

### 1.2 Firestore セットアップ

```bash
# Firestore データーベース作成
firebase firestore:create

# デフォルトセキュリティルール設定
firebase deploy --only firestore:rules

# インデックス設定
firebase deploy --only firestore:indexes
```

**ルール ファイル**: `firestore.rules`  
**インデックス ファイル**: `firestore.indexes.json`

---

## Phase 2-2: RevenueCat設定

### 2.1 RevenueCat API キー取得

1. [RevenueCat Dashboard](https://app.revenuecat.com/) へアクセス
2. Project Settings → API Keys
3. 以下のキーを取得:
   - **Android API Key** 
   - **iOS API Key**

### 2.2 AppConstants.dart 更新

```dart
// lib/core/constants/app_constants.dart
static const String revenueCatApiKeyAndroid = 'YOUR_ANDROID_KEY';
static const String revenueCatApiKeyIos = 'YOUR_IOS_KEY';
```

### 2.3 RevenueCat Entitlements 設定

**対象**: `paywall_screen.dart` で使用

- `pro_plan`: 月額サブスクリプション
- `lifetime`: 一生涯ライセンス

---

## Phase 2-3: Cloud Functions デプロイ

### 3.1 環境変数設定

```bash
cd functions/
cp .env.example .env

# .env ファイルを編集:
# - SENDGRID_API_KEY: メール送信用
# - STRIPE_SECRET_KEY: 決済用（オプション）
```

### 3.2 Functions デプロイ

```bash
# 依存インストール
npm install

# 開発環境でテスト
npm run dev

# 本番環境にデプロイ
firebase deploy --only functions

# デプロイログ確認
firebase functions:log
```

**主要なCloud Functions:**
- `seedLocalePresets`: ロケール推奨タスク シード化
- `onTaskCreated`: タスク作成時の処理
- `notifyUpcomingTasks`: タスク期限リマインダー

---

## Phase 2-4: コード生成

### 4.1 Freezed & JsonSerializable 生成

```bash
# build_runner でコード生成
flutter pub run build_runner build --delete-conflicting-outputs

# または watch モード（開発中）
flutter pub run build_runner watch
```

**対象ファイル:**
- `*_model.dart`: JSON シリアライゼーション
- `*_entity.dart`: 不変オブジェクト

---

## Phase 2-5: Sentry設定（オプション）

### 5.1 Sentry プロジェクト作成

1. [Sentry.io](https://sentry.io/) へ登録
2. 新しいプロジェクト作成（Flutter）
3. DSN を取得

### 5.2 .env 設定

```bash
# .env
SENTRY_DSN=your_sentry_dsn
ENVIRONMENT=production
```

---

## Phase 2-6: E2E テスト実装

### 6.1 Drivers セットアップ

```bash
flutter drive --target=test_driver/app.dart
```

**テストスコープ:**
- ログイン フロー
- タスク作成・編集・削除
- グループ管理
- 通知機能

### 6.2 CI/CD パイプライン

```yaml
# .github/workflows/tests.yml
- E2E テスト自動実行
- ユニット テスト
- ウィジェット テスト
```

---

## Phase 2-7: 本番ビルド

### 7.1 Android ビルド

```bash
flutter build appbundle --release
# → build/app/outputs/bundle/release/app-release.aab
```

**署名設定**: `android/key.properties`
- storeFile
- storePassword
- keyAlias
- keyPassword

### 7.2 iOS ビルド

```bash
flutter build ios --release
# または Xcode でビルド
```

**署名設定**: Xcode の Signing & Capabilities タブ
- Team ID
- Bundle Identifier
- Code Signing Identity

---

## Phase 2-8: ストア設定

### 8.1 Google Play Console

1. 新しいアプリを作成
2. App Bundle をアップロード
3. ストア掲載資料を完成させる:
   - アプリのスクリーンショット
   - 説明文
   - プライバシーポリシー URL
   - カテゴリー

### 8.2 Apple App Store

1. App Store Connect で新規アプリを作成
2. `.ipa` をアップロード（TestFlight）
3. 審査のため提出
4. メタデータ入力:
   - キーワード
   - スクリーンショット
   - 説明

---

## チェックリスト

### Pre-Release（リリース前）

- [ ] Firebase Options 設定完了
- [ ] Firestore ルール デプロイ完了
- [ ] RevenueCat API キー設定完了
- [ ] Cloud Functions デプロイ完了
- [ ] Build Runner コード生成完了
- [ ] E2E テスト実行完了 (全パス)
- [ ] ユニット テスト実行完了 (全パス)
- [ ] Lint/Format チェック完了
- [ ] プライバシーポリシー・利用規約 作成完了
- [ ] スクリーンショット・説明文 準備完了

### Release（リリース時）

- [ ] 本番ビルド作成 (Android & iOS)
- [ ] App Bundle / .ipa アップロード
- [ ] ストア上での テキスト・メタデータ確認
- [ ] 最終レビュー・動作確認
- [ ] リリース承認
- [ ] ロールアウト監視 (初日)

### Post-Release（リリース後）

- [ ] ユーザー フィードバック 監視
- [ ] エラーログ (Sentry) 確認
- [ ] パフォーマンス メトリクス 確認
- [ ] 緊急バグ対応体制 準備

---

## トラブルシューティング

### Firebase 接続エラー

```
error: (permission-denied) Missing or insufficient permissions.
```

**解決**: Firestore セキュリティルール を確認
- 本番環境では認証必須
- テスト環境では制限を緩和

### RevenueCat 初期化エラー

```
PurchasesException: Invalid API key
```

**解決**: AppConstants.dart の API キー確認
- キーのコピーミス
- キーの有効期限

### Cloud Functions デプロイ失敗

```
Error: function failed on load
```

**解決**: 
- `npm install` 再実行
- Node.js バージョン確認 (14+)
- 環境変数 確認

---

## 参考資料

- [FlutterFire ドキュメント](https://firebase.flutter.dev/)
- [RevenueCat ドキュメント](https://docs.revenuecat.com/)
- [Google Play Console ヘルプ](https://support.google.com/googleplay/android-developer)
- [App Store Connect ヘルプ](https://help.apple.com/app-store-connect/)

---

**最終チェック**: すべてのステップが完了したら、本番リリースの準備完了です。
