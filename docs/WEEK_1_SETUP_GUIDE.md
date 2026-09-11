# Week 1: ローカル環境実装・セットアップ完全ガイド

> **対象**: LifeTask Manager 1.0.0+1  
> **実行環境**: ローカル開発マシン（Flutter, Xcode, Android Studio インストール必須）  
> **推定時間**: 3-4時間  
> **前提条件**: Phase 2 ドキュメント完了

---

## 📋 Week 1 全体スケジュール

```
[1] Firebase セットアップ             (30分)
[2] RevenueCat アカウント作成         (20分)
[3] Sentry プロジェクト作成           (20分)
[4] Cloud Functions ローカルテスト    (30分)
[5] ローカル環境検証・テスト実行      (60分)
```

---

## [1] Firebase セットアップ (30分)

### 1.1 Firebase Console でプロジェクト作成

1. **Firebase Console にアクセス**
   ```
   https://console.firebase.google.com/
   ```

2. **新しいプロジェクトを作成**
   - プロジェクト名: `LifeTask Manager` (or `lifetask-manager`)
   - Analytics: **有効化** (推奨)
   - リージョン: `asia-northeast1` (東京)
   - 作成完了まで待機 (~3-5分)

3. **Blaze プランへアップグレード** (オプション)
   - Cloud Functions デプロイに必要
   - 無料枠あり（毎月 240万 関数呼び出し無料）

### 1.2 firebase_options.dart を生成

ローカル環境で以下を実行:

```bash
# プロジェクトルートで実行
flutterfire configure
```

**手順:**
1. Which Firebase project do you want to use? → 上記で作成したプロジェクトを選択
2. Which platforms should be configured? 
   - [x] Android
   - [x] iOS
   - [ ] macOS
   - [ ] Windows
   - [ ] Web

完了後、`lib/firebase_options.dart` が自動生成されます。

### 1.3 firebase_options.dart を git で追跡

```bash
# リモートリポジトリから .gitignore を確認
git check-ignore lib/firebase_options.dart
# Output: lib/firebase_options.dart

# force-add して本番構成を保護しつつ登録
git add -f lib/firebase_options.dart
git commit -m "Firebase options - force added for template (production secrets excluded)"
```

### 1.4 Firestore ルール・インデックスをデプロイ

```bash
# Firebase CLI ログイン
firebase login

# プロジェクト設定確認
firebase list

# Firestore ルールをデプロイ
firebase deploy --only firestore:rules

# Firestore インデックスをデプロイ
firebase deploy --only firestore:indexes
```

**デプロイ確認:**
```bash
firebase functions:list
firebase firestore:indexes:list
```

### 1.5 Cloud Messaging 設定（FCM）

**iOS 設定:**

1. Firebase Console → Project Settings → Cloud Messaging タブ
2. **APNs 認証キー** をアップロード
   - Apple Developer Account で APN キーを作成
   - Firebase に登録

**Android 設定:**

1. Firebase Console で自動設定済み（google-services.json 経由）
2. Google Play Console で "Cloud Messaging API" 有効化

---

## [2] RevenueCat セットアップ (20分)

### 2.1 RevenueCat アカウント作成

1. **RevenueCat にサインアップ**
   ```
   https://app.revenuecat.com/signup
   ```

2. **新しいプロジェクト作成**
   - Project Name: `LifeTask Manager`
   - Environment: `Production` (重要)

### 2.2 Product ID 設定

以下の Product ID を RevenueCat に登録:

| Product ID | プラン | 価格 |
|-----------|-------|------|
| `pro_monthly` | 月間サブスクリプション | $3.99 (US) |
| `lifetime` | ライフタイム購入 | $9.99 (US) |
| `lifetime_invited` | 招待ユーザー割引 | $1.49 (US) |

**RevenueCat ダッシュボード:**
1. Project Settings → Products
2. **+ Add Product** をクリック
3. 各 Product ID を登録

### 2.3 API キー設定

1. RevenueCat Dashboard → Project Settings → API Keys
2. **iOS API Key** をコピー
3. **Android API Key** をコピー

ローカル環境で:

```bash
# pubspec.yaml の場所から .env ファイルを確認
cat .env.example

# .env を作成 (本番 API キーを設定)
cp .env.example .env
```

**.env ファイルを編集:**
```env
# Firebase
FIREBASE_PROJECT_ID=your-firebase-project-id

# RevenueCat API Keys
REVENUE_CAT_API_KEY_IOS=your-revenuecat-ios-key
REVENUE_CAT_API_KEY_ANDROID=your-revenuecat-android-key

# Sentry (後で設定)
SENTRY_DSN=

# Environment
ENVIRONMENT=production
```

**セキュリティ確認:**
```bash
# .env が .gitignore に含まれているか確認
git check-ignore .env
# Output: .env
```

### 2.4 App Store Connect で In-App Purchase 設定

1. **App Store Connect** にアクセス
   - https://appstoreconnect.apple.com/

2. **新しいアプリを作成** (初回のみ)
   - App Name: `LifeTask Manager`
   - Bundle ID: `com.petitworks.apps.lifetaskmanager`
   - SKU: 任意の一意識別子
   - Platforms: iOS, iPadOS

3. **In-App Purchases を設定**
   - 左メニュー → Manage Your In-App Purchases
   - **+ New** をクリック
   - Type: **Subscription** (pro_monthly 用)
     - Reference Name: `Pro Monthly`
     - Product ID: `pro_monthly`
     - Subscription Duration: Monthly
   - Type: **Non-Consumable** (lifetime 用)
     - Reference Name: `Lifetime`
     - Product ID: `lifetime`
   - Type: **Non-Consumable** (lifetime_invited 用)
     - Reference Name: `Lifetime Invited`
     - Product ID: `lifetime_invited`

### 2.5 Google Play Console で In-App Product 設定

1. **Google Play Console** にアクセス
   - https://play.google.com/console/

2. **新しいアプリを作成** (初回のみ)
   - App name: `LifeTask Manager`
   - Default language: English (US)
   - App category: Productivity
   - Target audience: 13+ (コンテンツ規制に応じて)

3. **Monetize → Products → Subscriptions**
   - **Create subscription**
     - Product ID: `pro_monthly`
     - Default price: $3.99 USD
     - Billing period: Monthly

4. **Monetize → Products → In-app products**
   - **Create product**
     - Product ID: `lifetime`
     - Type: Managed product
     - Price: $9.99 USD
   - **Create product**
     - Product ID: `lifetime_invited`
     - Type: Managed product
     - Price: $1.49 USD

### 2.6 RevenueCat を App Store・Google Play に連携

**iOS:**
1. RevenueCat Dashboard → Connections → App Store
2. **Shared Secret** を生成・コピー
3. App Store Connect → Apps → Credentials → Shared Keys
4. Shared Secret を登録

**Android:**
1. RevenueCat Dashboard → Connections → Google Play
2. **Service Account JSON** をアップロード
   - Google Cloud Console でサービスアカウント作成
   - JSON キーをダウンロード
   - RevenueCat に登録

---

## [3] Sentry セットアップ (20分)

### 3.1 Sentry アカウント作成

1. **Sentry にサインアップ**
   ```
   https://sentry.io/signup/
   ```

2. **組織を作成**
   - Organization name: `Petitworks` (or personal)

### 3.2 プロジェクト作成

1. **新しいプロジェクトを作成**
   - Platform: Flutter
   - Project name: `lifetask-manager`
   - Alert frequency: Medium (推奨)

2. **DSN をコピー**
   - Format: `https://<key>@<host>/<projectId>`

### 3.3 .env に DSN を設定

```.env
SENTRY_DSN=https://your-key@o12345.ingest.sentry.io/12345
```

### 3.4 Sentry ダッシュボード設定

**Alerts & Notifications:**
1. Alerts → Create Alert Rule
   - Condition: Issue is first seen
   - Action: Send to Slack/Email (オプション)

**Release Tracking:**
1. Settings → Releases
   - 将来的にアプリリリース時に手動登録

---

## [4] Cloud Functions ローカルテスト (30分)

### 4.1 Firebase Emulator Suite をインストール

```bash
# Java Runtime 確認
java -version

# Firebase CLI で Emulator インストール
firebase setup:emulators:firestore
firebase setup:emulators:functions
firebase setup:emulators:pubsub
```

### 4.2 Emulator を起動

```bash
# プロジェクトルートで
firebase emulators:start --only firestore,functions

# 別のターミナルで確認
curl http://localhost:8080
# Response: OK
```

### 4.3 Functions ローカルテスト

```bash
cd functions

# 依存パッケージをインストール
npm install

# 環境変数を設定
cp .env.example .env
# .env を編集

# ローカルテスト実行
npm test

# または TypeScript ビルド確認
npm run build
```

### 4.4 Functions を Emulator にデプロイ

```bash
# Emulator 起動状態で
firebase deploy --only functions --debug
```

---

## [5] ローカル環境検証・テスト実行 (60分)

### 5.1 Flutter 依存パッケージ更新

```bash
# プロジェクトルートで
flutter pub get

# Build Runner でコード生成（再実行確認用）
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5.2 コード品質チェック

```bash
# Lint チェック
flutter analyze

# フォーマット確認
dart format . --set-exit-if-changed

# 出力: No changes needed.
```

### 5.3 ユニットテスト実行

```bash
# ユニットテスト実行
flutter test

# または特定テストファイル
flutter test test/features/auth/providers/auth_provider_test.dart
```

### 5.4 Firebase Emulator でテスト

**Emulator 起動:**
```bash
firebase emulators:start --only firestore,functions,pubsub
```

**別ターミナルで Flutter 実行:**
```bash
# Emulator に接続してアプリ起動
flutter run --debug \
  --dart-define FIREBASE_EMULATOR_HOST=localhost \
  --dart-define FIRESTORE_EMULATOR_HOST=localhost:8080
```

### 5.5 実デバイス/シミュレーターでのテスト

**iOS:**
```bash
flutter run --release
# または
open -a Simulator
flutter run --release -d "iPhone 15 Pro"
```

**Android:**
```bash
flutter run --release
# または
emulator -avd Pixel_7_Pro &
flutter run --release -d emulator-5554
```

### 5.6 チェックリスト確認

```
✅ firebase_options.dart が生成・設定済み
✅ .env に API キー設定済み
✅ Firestore Rules デプロイ完了
✅ RevenueCat Product ID 登録完了
✅ Sentry DSN 設定完了
✅ Cloud Functions テスト実行成功
✅ flutter analyze エラー: 0
✅ dart format フォーマット確認: OK
✅ flutter test 全テスト合格
✅ Firebase Emulator 接続確認
✅ 実デバイスでアプリ起動確認
```

---

## 🚀 次のステップ

Week 1 完了後:

```
[6] Week 2: テスト・検証
    - ユニット/ウィジェット テスト 100% 合格
    - E2E テスト 全シナリオ実行
    - 実デバイス 機能確認 (iOS + Android)

[7] Week 3: ビルド・署名
    - iOS Release ビルド作成 (IPA)
    - Android Release ビルド作成 (AAB)
    - ビルドサイズ・署名確認

[8] Week 4: ストア配信
    - App Store Connect に提出
    - Google Play Console に提出
    - リリース実行
```

---

## ⚠️ 注意事項

1. **firebase_options.dart**
   - .gitignore で保護されます
   - 本番 API キーが含まれるため、絶対に公開リポジトリにコミットしないこと

2. **API キー・シークレット**
   - .env ファイルは .gitignore 対象
   - バージョン管理システムに含めないこと
   - 安全に保管すること

3. **RevenueCat テスト購入**
   - Sandbox 環境で十分にテストすること
   - 本番環境では最小限の変更のみ

4. **Firebase Emulator**
   - ローカルテスト専用
   - 本番デプロイ前に実プロジェクトで検証

---

## 🆘 トラブルシューティング

### flutterfire configure 失敗時

```bash
# Firebase CLI を再インストール
npm install -g firebase-tools

# キャッシュをクリア
flutter pub cache repair

# 再実行
flutterfire configure
```

### Firebase Emulator 起動失敗

```bash
# Java がインストールされているか確認
java -version

# キャッシュをクリア
rm -rf ~/.cache/firebase-emulator-suite

# 再セットアップ
firebase setup:emulators:all
```

### Build Runner エラー

```bash
# 全削除してリセット
rm -rf .dart_tool/
flutter clean
flutter pub get

# 再実行
flutter pub run build_runner build --delete-conflicting-outputs
```

### RevenueCat Product ID が反映されない

```
問題: App Store/Google Play でアップロードしても Product ID が表示されない
解決:
  1. 24時間待つ（Apple 側の反映遅延）
  2. または App Store Connect で明示的に "提出" ボタンを押す
  3. 期限切れの無料試用版を確認
```

---

**最後の確認**: 上記すべてのチェックボックスが完了したら、Week 1 完成です。  
**次へ進むには**: git でコミット・プッシュして、Week 2 に進みます。
