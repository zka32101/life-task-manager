# RevenueCat 統合ガイド

> **最終確認日**: 2026-09-01  
> **LifeTask Manager バージョン**: 1.0.0

## 概要

RevenueCat を使用した サブスクリプション管理の完全セットアップガイドです。

---

## 1. RevenueCat アカウント準備

### 1.1 プロジェクト作成

1. [RevenueCat.com](https://www.revenuecat.com/) へアクセス
2. サインアップ / ログイン
3. 新しいプロジェクト作成
4. プロジェクト名: "LifeTask Manager"
5. デフォルト通貨: JPY (日本円)

### 1.2 API キー取得

**Project Settings → API Keys** から:
- **Public API Key** (クライアント側で使用)
  - Android: `goog_***` で始まるキー
  - iOS: `appl_***` で始まるキー

---

## 2. App Store Connect 設定

### 2.1 App Store User

1. **App Store Connect** へログイン
2. **App Information → Pricing and Availability**
3. Subscription Group を作成:
   - Group ID: `lifetime_subscription`
   - Group Name: "LifeTask Manager Pro"

### 2.2 In-App Purchase 作成

#### Pro Plan (月額)

```
Product ID: com.petitworks.apps.lifetaskmanager.pro_monthly
Type: Auto-Renewable Subscription
Subscription Duration: 1 month
Free Trial: 7 days (オプション)
Price: ¥300/月
Localization:
  - 日本語: "LifeTask Manager プロ"
  - 説明: "広告なし、全機能利用可能"
```

#### Lifetime Access

```
Product ID: com.petitworks.apps.lifetaskmanager.lifetime
Type: Non-Consumable In-App Purchase
Price: ¥3,000
Localization:
  - 日本語: "LifeTask Manager 永遠アクセス"
  - 説明: "一度の購入で永遠にすべての機能が利用可能"
```

#### Invited Plan (割引)

```
Product ID: com.petitworks.apps.lifetaskmanager.lifetime.invited
Type: Non-Consumable In-App Purchase
Price: ¥1,490
Localization:
  - 日本語: "LifeTask Manager (招待割引)"
  - 説明: "グループ招待ユーザー向け特別価格"
```

---

## 3. Google Play Console 設定

### 3.1 In-App Product 作成

1. **Monetize → In-App products** へ移動
2. 上記と同じ Product IDs で作成
3. 説明・価格を設定
4. **ライセンス テスト ユーザー** を登録

### 3.2 テスト Account

```
Google Play Console → Settings → License Testing
→ License test accounts に自分のメールを追加
```

---

## 4. RevenueCat Configuration

### 4.1 iOS App 設定

1. **Configure Projects → iOS**
2. **Apple In-App Purchases** を接続:
   - App Store Connect Bundle ID 入力
   - App Store Shared Secret 入力
   - iOS Signing Key アップロード

### 4.2 Android App 設定

1. **Configure Projects → Android**
2. **Google Play** を接続:
   - Package Name: `com.petitworks.apps.lifetaskmanager`
   - Google Play Billing Key をアップロード

### 4.3 Entitlements 設定

**Manage Entitlements** で以下を作成:

```
Entitlement ID: lifetime_access
Display Name: "Lifetime Access"
Description: "永遠アクセス権限"
```

### 4.4 Products 設定

**Manage Products** で以下をマッピング:

| RevenueCat | App Store | Google Play | Entitlement |
|-----------|-----------|-------------|------------|
| `pro_monthly` | `com.petitworks...pro_monthly` | `com.petitworks...pro_monthly` | `lifetime_access` |
| `lifetime` | `com.petitworks...lifetime` | `com.petitworks...lifetime` | `lifetime_access` |
| `lifetime_invited` | `com.petitworks...lifetime.invited` | `com.petitworks...lifetime.invited` | `lifetime_access` |

---

## 5. アプリ統合

### 5.1 AppConstants.dart 更新

```dart
// lib/core/constants/app_constants.dart

static const String revenueCatApiKeyAndroid = 'goog_YOUR_ANDROID_KEY';
static const String revenueCatApiKeyIos = 'appl_YOUR_IOS_KEY';
static const String entitlementId = 'lifetime_access';

// Product IDs
static const String productIdAndroid = 'com.petitworks.apps.lifetaskmanager.lifetime';
static const String productIdIos = 'com.petitworks.apps.lifetaskmanager.lifetime';
static const String productIdInvited = 'com.petitworks.apps.lifetaskmanager.lifetime.invited';
```

### 5.2 .env 設定

```bash
# .env (バージョン管理除外)
REVENUE_CAT_API_KEY_ANDROID=goog_YOUR_KEY
REVENUE_CAT_API_KEY_IOS=appl_YOUR_KEY
```

### 5.3 環境変数ロード（オプション）

```dart
// main.dart でロード
import 'package:flutter_dotenv/flutter_dotenv.dart';

final androidKey = dotenv.env['REVENUE_CAT_API_KEY_ANDROID'] ?? AppConstants.revenueCatApiKeyAndroid;
final iosKey = dotenv.env['REVENUE_CAT_API_KEY_IOS'] ?? AppConstants.revenueCatApiKeyIos;

await Purchases.configure(PurchasesConfiguration(Platform.isAndroid ? androidKey : iosKey));
```

---

## 6. テスト

### 6.1 iOS テスト

```dart
// テストデバイスで Sandbox 環境を使用
// App Store Connect → Settings → Internal Testing Users
```

1. Test Flight にビルドをアップロード
2. Internal tester でインストール
3. App Store で購入をテスト
4. RevenueCat Dashboard で確認

### 6.2 Android テスト

```bash
# License test account で Google Play テスト購入
# 実際の支払いは発生しない
```

1. Google Play Console でテストアカウントを登録
2. テストデバイスでアカウントを設定
3. アプリで購入をテスト
4. 自動キャンセル (購入後 5 分以内)

### 6.3 RevenueCat テスト

```dart
// Sandbox 環境でテスト
// RevenueCat Dashboard → Settings → Sandbox Users
// テストユーザーを登録して購入をシミュレート
```

---

## 7. トラブルシューティング

### 問題: 購入画面が表示されない

```
原因: Product ID が一致していない
解決: AppConstants と RevenueCat 設定を確認
```

### 問題: "Invalid API Key" エラー

```
原因: 不正な API キー
確認:
- API キーが正しくコピーされているか
- プラットフォームが正しいか (iOS は appl_*, Android は goog_*)
```

### 問題: 購入トランザクションが記録されない

```
原因: App Store/Google Play と RevenueCat の接続設定不備
解決:
- iOS: Shared Secret が正しく設定されているか
- Android: Google Play Billing Key が最新か
```

### 問題: テスト購入ができない

```
確認:
- テストアカウントが正しく登録されているか
- テストデバイスでそのアカウントがログインしているか
- App Store/Google Play で購入機能が有効か
```

---

## 8. プロダクション チェックリスト

### Pre-Release

- [ ] API キー を本番環境に更新
- [ ] 全 Product IDs が設定されているか確認
- [ ] Entitlements が正しくマッピングされているか確認
- [ ] 通知 Webhook が設定されているか確認
- [ ] テスト購入が正常に機能することを確認
- [ ] Sandbox テスト完了

### Release

- [ ] App Store build をアップロード
- [ ] Google Play build をアップロード
- [ ] 購入フロー全体を確認
- [ ] リセシート処理を確認
- [ ] エラーハンドリング が機能しているか確認

### Post-Release

- [ ] ユーザー購入データを監視
- [ ] Webhook ログを確認
- [ ] エラーログを確認
- [ ] Customer Support 対応体制を準備

---

## 参考資料

- [RevenueCat Official Docs](https://docs.revenuecat.com/)
- [Flutter Purchases SDK](https://github.com/RevenueCat/purchases-flutter)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)

---

**最後の確認**: すべての設定が完了したら、アプリをビルド・テストしてリリースします。
