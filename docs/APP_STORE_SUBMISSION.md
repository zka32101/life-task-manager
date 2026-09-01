# App Store・Google Play 配信準備ガイド

> **最終確認日**: 2026-09-01  
> **LifeTask Manager バージョン**: 1.0.0+1  
> **Phase**: 2-8 デプロイメント準備

## 概要

このガイドでは、LifeTask Manager を App Store Connect と Google Play Console にアップロードし、ユーザーに配信するまでの手順を網羅します。

---

## 1. App Store Connect 登録

### 1.1 App Store Connect アカウント確認

1. [App Store Connect](https://appstoreconnect.apple.com/) にサインイン
2. Account → Membership が有効か確認
3. チームロール: Agent, Admin, または Developer

### 1.2 アプリ作成

1. **My Apps** → **+**
2. **新規アプリ**
3. 以下を入力:
   - **プラットフォーム**: iOS
   - **名前**: LifeTask Manager
   - **主言語**: 日本語
   - **バンドル ID**: `com.petitworks.apps.lifetaskmanager`
   - **SKU**: `lifetask-manager-001` (一意の ID)

### 1.3 サブスクリプション・In-App Purchase 設定

**参照**: `docs/REVENUE_CAT_SETUP.md` Section 2 (App Store Connect 設定)

```
Product IDs:
- com.petitworks.apps.lifetaskmanager.pro_monthly (月額 ¥300)
- com.petitworks.apps.lifetaskmanager.lifetime (¥3,000)
- com.petitworks.apps.lifetaskmanager.lifetime.invited (¥1,490)

Subscription Group:
- lifetime_subscription
```

---

## 2. App Store メタデータ・スクリーンショット

### 2.1 基本情報入力

**App Store Connect → App Information**

```
アプリ名: LifeTask Manager
サブタイトル: 人生のタスクを管理する
プライマリカテゴリ: Productivity
セカンダリカテゴリ: Lifestyle

サポート URL: https://support.lifetaskmanager.com
プライバシーポリシー URL: https://lifetaskmanager.com/privacy
利用規約 URL: https://lifetaskmanager.com/terms
```

### 2.2 アプリの説明

**Version → 説明タブ**

```
LifeTask Manager はあなたの人生を整理するためのタスク管理アプリです。

主な機能:
- 📋 個人タスク・グループタスク管理
- 👥 家族・チーム でのタスク共有
- 🔔 期限リマインダー・カテゴリー別管理
- 💰 サブスクリプション・永遠アクセスプラン
- 🌍 複数言語対応（日本語・英語・中国語）

あなたの人生を、もっと大切に。
```

### 2.3 キーワード

```
タスク管理, 予定表, 日記, リマインダー, グループ管理
```

### 2.4 スクリーンショット

**サイズ**: 1284 x 2778 px（iPhone Pro Max）

**必須スクリーン:**

1. **ホーム画面** - タスク一覧・完了チェック
2. **タスク詳細** - カテゴリ・リマインダー設定
3. **グループ管理** - グループ作成・メンバー招待
4. **プロプラン** - 購入オプション表示

**スクリーンショット例:**

```
Screen 1: Home
[タスク一覧の画像]
"タスクを整理、人生を整理"

Screen 2: Task Details
[タスク詳細画面の画像]
"カテゴリ・期限・リマインダーを細かく設定"

Screen 3: Group Tasks
[グループタスク画面の画像]
"家族・チームでタスク共有"

Screen 4: Pro Plan
[購入画面の画像]
"グループ機能・無制限タスク・広告なし"
```

### 2.5 プレビュー ビデオ（オプション）

30秒以内の動画でアプリの特徴を紹介:

```
- 最初の 5 秒: アプリ起動、ホーム表示
- 次の 10 秒: タスク作成、編集デモ
- 次の 10 秒: グループ機能、購入流れ
- 最後の 5 秒: 「今すぐダウンロード」メッセージ
```

---

## 3. 提出前チェックリスト

### 3.1 機能チェック

```
✅ ログイン・ユーザー登録
✅ タスク作成・編集・削除・完了
✅ グループ管理・招待・参加
✅ プッシュ通知
✅ 購入・復元機能
✅ 言語切り替え（日本語・英語・中国語）
✅ オフライン対応
✅ データシンク
```

### 3.2 ガイドラインコンプライアンス

**App Store Review Guidelines に準拠:**

```
✅ プライバシー
  - ユーザーデータ収集の明示
  - プライバシーポリシー URL 記載
  - 位置情報・カメラ未使用 → 許可不要

✅ 購入・課金
  - 購入画面に価格・説明明記
  - 復元・キャンセル機能
  - 利用規約表示

✅ コンテンツ
  - 年齢制限: 4+
  - 暴力・アダルト: なし
  - 医療情報・弁護士情報: 免責表記有
```

### 3.3 技術チェック

```
✅ iOS 最小バージョン: 12.0+
✅ デバイスタイプ: iPhone, iPad, Apple Watch 対応
✅ ホームインジケータ対応
✅ ダークモード対応
✅ 多言語対応（localizations）
✅ VoiceOver (アクセシビリティ)
```

### 3.4 ビルド・署名チェック

```
✅ ビルド番号正確 (pubspec.yaml と一致)
✅ IPA 署名確認: codesign -vv
✅ ビルドサイズ < 4GB
✅ 必要な権限設定 (Push, CloudKit 等)
```

---

## 4. App Store Connect へのアップロード

### 4.1 Transporter 使用（推奨）

```bash
# Transporter のダウンロード
# App Store Connect → Deliver Your App → macOS App Download

# IPA アップロード
# GUI で操作: IPA 選択 → Deliver

# コマンドラインの場合
xcrun altool --upload-app \
  -f build/ipa/Runner.ipa \
  -t ios \
  -u "your-email@example.com" \
  -p "app-specific-password"
```

### 4.2 App Store Connect Web

1. App Store Connect → **Builds**
2. **+ マーク** → ビルド選択
3. **提出候補**

### 4.3 ビルド処理待機

- アップロード完了後、処理が始まる（通常 10-30 分）
- メール通知で完了を確認
- 「TestFlight に利用可能」と表示される

---

## 5. TestFlight ベータテスト（推奨）

### 5.1 内部テスター招待

1. **ビルド** → **Internal Testing**
2. **+ マーク** でテスター追加
3. メール送信（TestFlight をダウンロード）

### 5.2 テスター フィードバック確認

- テスター から 1-2 日のフィードバック待機
- クラッシュ・機能問題確認
- 問題があれば新ビルドをアップロード

### 5.3 完了確認

```
✅ TestFlight でクラッシュなし
✅ ログイン・購入・通知全機能動作
✅ テスター フィードバック良好
```

---

## 6. App Store 審査提出

### 6.1 審査用情報入力

**Version → App Review Information**

```
ログイン認証情報:
- Email: test@lifetaskmanager.com
- Password: TestPass123!

アカウント情報:
- 国/地域: Japan
- 住所: 東京都渋谷区...
- 連絡先: support@lifetaskmanager.com

デバイス:
- 新デバイス不要
- テスト用 Apple ID でテスト可能
```

### 6.2 審査用メモ

```
このアプリはタスク管理とグループコラボレーション機能を提供します。

重要な情報:
- iCloud キーチェーン使用（認証）
- Cloud Firestore でデータ保存
- Firebase Cloud Messaging で通知配信
- RevenueCat でサブスクリプション管理

テスト用アカウント:
Email: test@lifetaskmanager.com
Password: TestPass123!

1. アプリ起動
2. テストメール でログイン
3. タスク作成・完了・削除テスト
4. グループ機能テスト
5. 購入プロセスまでテスト（決済不要）
```

### 6.3 提出実行

1. **ビルド選択** → **提出**
2. **アプリ提出**
3. 審査開始（通常 1-3 営業日）

---

## 7. Google Play Console 登録

### 7.1 アカウント作成

1. [Google Play Console](https://play.google.com/console) へアクセス
2. **登録** → 支払い設定
3. 開発者登録費: $25 USD (1 回限り)

### 7.2 アプリ作成

1. **すべてのアプリ** → **アプリを作成**
2. **アプリ名**: LifeTask Manager
3. **デフォルト言語**: 日本語
4. **アプリまたはゲーム**: アプリ選択

### 7.3 アプリ署名・Google Play App Signing

Google Play は自動的にアプリ署名を管理します:

```
Google Play Key: Google により生成・管理
Upload Key: ローカルで管理（android/key.properties）
```

**初回アップロード:**

```bash
# キーストアが必要
flutter build appbundle --release
# → build/app/outputs/bundle/release/app-release.aab
```

---

## 8. Google Play ストア情報

### 8.1 ストア掲載情報

**Google Play Console → ストアの登録情報**

```
アプリ名: LifeTask Manager
短い説明: タスク管理とグループコラボレーション

完全な説明: (App Store と同等)

カテゴリ: 生産性
対象年齢: 全年齢
コンテンツ レーティング: 全年齢
```

### 8.2 スクリーンショット

**サイズ**: 1080 x 1920 px (Portrait)

**アップロード:**

```
最小 2 枚
推奨 8 枚

内容: App Store と同等
```

### 8.3 ストアの画像

**アイコン** (512 x 512 px)
**フィーチャー グラフィック** (1024 x 500 px)

```
推奨: 以下 3 つ
- App Icon (高解像度)
- Feature Graphic
- Screenshot 複数枚
```

### 8.4 プライバシー・セキュリティ

**Google Play Console → プライバシー・セキュリティ**

```
プライバシー ポリシー: https://lifetaskmanager.com/privacy
データ セキュリティ: 
- Firebase Firestore で暗号化保存
- Firebase Authentication で安全に認証
- Google Cloud Security

必要な権限:
- インターネット接続
- 通知表示
- INTERNET: インターネット通信
- RECEIVE_BOOT_COMPLETED: 起動時の処理
```

---

## 9. In-App Product 設定

### 9.1 サブスクリプション設定

**Google Play Console → ストア内商品 → サブスクリプション**

```
Product ID 1: com.petitworks.apps.lifetaskmanager.pro_monthly
名前: LifeTask Manager プロ（月額）
説明: 月額 ¥300 で全機能利用可能
価格: ¥300/月（日本）

Product ID 2: com.petitworks.apps.lifetaskmanager.lifetime
名前: LifeTask Manager 永遠アクセス
説明: 一度の購入 ¥3,000 で永遠にすべての機能利用可能
価格: ¥3,000

Product ID 3: com.petitworks.apps.lifetaskmanager.lifetime.invited
名前: LifeTask Manager（招待割引）
説明: グループ招待ユーザー向け ¥1,490
価格: ¥1,490
```

### 9.2 テスト アカウント

**Google Play Console → 設定 → ライセンス テスト**

```
ライセンス テスト アカウント:
- テスト Google アカウント: test@gmail.com を追加
- テスト デバイス: テスト用 Android デバイスを登録
```

---

## 10. Google Play へのアップロード

### 10.1 AAB ファイルアップロード

**Google Play Console → ストア内商品 → アプリリリース**

1. **新規リリースを作成**
2. **AAB ファイルを追加**:
   ```
   build/app/outputs/bundle/release/app-release.aab
   ```
3. **テスト トラック** を選択（まずテスト）

### 10.2 リリース ノート

```
バージョン 1.0.0
リリース日: 2026-09-15

新機能:
- タスク管理とグループコラボレーション
- 複数言語対応（日本語・英語・中国語）
- プッシュ通知・リマインダー
- サブスクリプション / 永遠アクセスプラン
```

### 10.3 処理待機

- アップロード完了後、処理が始まる（通常 1-5 時間）
- テスト トラックで確認
- 問題なければ **本番トラック** に昇格

---

## 11. 審査・公開

### 11.1 審査期間

**App Store:**
- 審査時間: 1-3 営業日
- メール通知で結果報告
- リジェクト → 修正 → 再提出

**Google Play:**
- 自動承認（通常）
- 審査時間: 数時間～1日
- 公開後すぐにユーザーがダウンロード可能

### 11.2 リジェクト対応（App Store）

一般的な リジェクト理由:

```
1. Guideline 3.1 - Business Model
   → 購入オプションの説明が不足
   → 解決: 利用規約・ストア説明 で明記

2. Guideline 5.1 - Legal
   → プライバシーポリシー不足
   → 解決: プライバシーポリシー URL 追加

3. Guideline 2.1 - Performance
   → クラッシュが報告された
   → 解決: Sentry ログ確認・修正・新ビルド提出
```

### 11.3 修正・再提出

```bash
# バグ修正
git commit -m "Fix: App Store rejection issue"
git push

# 新ビルド作成
flutter build ios --release
# Xcode で Archive → IPA 出力

# App Store Connect で新ビルドアップロード
# Transporter で IPA 提出
```

---

## 12. リリース後オペレーション

### 12.1 監視・分析

**App Store Connect:**
- 分析 → ダウンロード数・クラッシュ数
- ユーザー評価・レビュー監視
- パフォーマンス メトリクス

**Google Play Console:**
- 分析 → インストール数・クラッシュ数
- ユーザー評価・レビュー監視
- ANR (アプリケーション無応答)

### 12.2 マーケティング

```
リリース告知:
- Twitter / X: アプリ公開を告知
- Web サイト: リリース情報掲載
- メール: 登録者に通知
```

### 12.3 ユーザーサポート

```
✅ Support Email: support@lifetaskmanager.com
✅ FAQ ページ作成
✅ Sentry で エラー監視
✅ ユーザー フィードバック収集
```

### 12.4 定期メンテナンス

```
毎月:
- Sentry ダッシュボード確認
- ユーザー レビュー返信
- バグ修正・機能改善

毎四半期:
- パフォーマンス最適化
- セキュリティアップデート確認
```

---

## 13. チェックリスト

### Pre-Submission

```
✅ メタデータ完成
  - アプリ説明・キーワード
  - スクリーンショット 4+ 枚
  - プライバシーポリシー URL
  - サポート URL

✅ In-App Product 設定
  - 3 つの Product ID 設定
  - 価格・説明明記
  - テスト アカウント登録

✅ 技術チェック
  - ビルド署名確認
  - 権限設定
  - ダークモード・多言語対応
```

### Submission

```
✅ App Store Connect
  - ビルド アップロード
  - TestFlight ベータテスト
  - 審査情報入力
  - 提出

✅ Google Play Console
  - AAB ファイル アップロード
  - ストア情報入力
  - テスト トラックで確認
  - 本番トラック公開
```

### Post-Release

```
✅ リリース後 24 時間
  - Sentry エラー監視
  - ユーザー レビュー確認
  - ダウンロード数確認

✅ リリース後 1 週間
  - クラッシュレート < 0.1%
  - ユーザー評価 > 4.0 星
  - 緊急バグ報告なし
```

---

## 参考資料

- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Google Play Policies](https://play.google.com/about/developer-content-policy/)

---

**🎉 最後の確認**: すべてのフェーズが完了したら、本番リリースの準備は完了です！

アプリを世界に公開し、ユーザーの人生を整理するのをお手伝いしましょう。

---

**次のステップ:**
1. App Store での審査完了待機
2. Google Play での公開確認
3. ユーザーサポート体制開始
4. 継続的な改善・更新
