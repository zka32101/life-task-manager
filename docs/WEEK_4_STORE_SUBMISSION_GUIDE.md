# Week 4: ストア配信完全ガイド

> **対象**: LifeTask Manager 1.0.0+1  
> **実行環境**: Web ブラウザ（App Store Connect, Google Play Console）  
> **推定時間**: 5-7時間  
> **前提条件**: Week 1-3 完了（IPA, AAB ファイル用意）

---

## 📋 Week 4 全体スケジュール

```
[1] App Store Connect 準備・提出     (120分)
[2] Google Play Console 準備・提出   (90分)
[3] 審査対応・デプロイ準備          (60分)
[4] リリース実行・監視              (60分)
```

---

## [1] App Store Connect 準備・提出 (120分)

### 1.1 App Store Connect アカウント準備

```
前提条件:
- Apple Developer Program メンバーシップ ($99/年)
- 有効なクレジットカード
- App Store Connect アカウント
```

### 1.2 アプリを App Store Connect に登録（初回のみ）

1. [App Store Connect](https://appstoreconnect.apple.com/) にアクセス
2. **My Apps** → **+** (新規アプリ)
3. **New App**
   - **Platforms**: iOS
   - **App Name**: LifeTask Manager
   - **Primary Language**: Japanese (日本語)
   - **Bundle ID**: `com.petitworks.apps.lifetaskmanager`
   - **SKU**: 任意（例: `lifetask-manager-001`）
4. **Create**

### 1.3 アプリ情報を入力

#### 1.3.1 一般情報

1. **App Information**
   - **Name**: LifeTask Manager
   - **Subtitle**: 人生の大事なタスクを管理する (50 文字以内)
   - **Primary Language**: Japanese
   - **Bundle ID**: `com.petitworks.apps.lifetaskmanager` (自動)

#### 1.3.2 ビジュアル資料

1. **App Icons and Previews**
   - **App Icon** (1024×1024 px): 高品質なアイコン画像をアップロード
   - アイコンは以下の要素を含む:
     - シンプルで認識しやすいデザイン
     - 文字やロゴなし（iPhone のホーム画面で小さい場合）
     - iOS 規格を満たす

2. **Screenshots** (Localization → Japanese)
   - **iPhone 6.7 inch**: 5-10 枚のスクリーンショット
   - 推奨寸法: 1290×2796 px
   - スクリーンショット例:
     1. ログイン画面
     2. ホーム画面（タスク一覧）
     3. タスク作成画面
     4. グループ管理画面
     5. 設定画面
   - テキスト例:
     - "タスク管理を簡単に"
     - "グループで共有"
     - "プッシュ通知で確認"
     - "オフライン対応"

#### 1.3.3 説明文・キーワード

1. **App Description** (最大 4000 文字)

```
人生で本当に大事なタスクを管理するアプリです。

【主な機能】
• タスク管理: シンプルで使いやすいUIで、日々のタスクを管理
• グループ管理: 家族・チームでタスクを共有
• プッシュ通知: 重要なタスクのリマインダーを受け取る
• オフライン対応: インターネット接続がなくても利用可能
• クロスプラットフォーム: iPhone と Android で同期

【特徴】
• Clean Architecture で設計された信頼性の高いアプリ
• Google Sign-In で安全にログイン
• Firebase で クラウドバックアップ
• Sentry でエラー監視

【価格】
• 30日間の無料トライアル
• その後 $3.99/月 のサブスクリプション
• または $9.99 のライフタイム購入

※招待された方には $1.49 の割引価格でご利用いただけます

このアプリで、人生の大事なタスクを、一つずつ、確実に進めていくことをお手伝いします。
```

2. **Keywords** (最大 100 文字、カンマ区切り)

```
タスク管理, グループ管理, To-Do, リマインダー, 生産性, 人生計画, 目標管理, チーム管理
```

3. **Support URL**
   - サポートページ: `https://lifetask-manager.example.com/support`

4. **Privacy Policy URL**
   - プライバシーポリシー: `https://lifetask-manager.example.com/privacy`

5. **Support Email**
   - `support@lifetaskmanager.com`

### 1.4 In-App Purchases 確認

**App Store → In-App Purchases** で以下の 3 つが登録されているか確認:

| Product ID | タイプ | 価格 | 説明 |
|-----------|-------|------|------|
| `pro_monthly` | Subscription | $3.99/月 | 月間サブスクリプション |
| `lifetime` | Non-Consumable | $9.99 | ライフタイム購入 |
| `lifetime_invited` | Non-Consumable | $1.49 | 招待ユーザー割引 |

**登録手順:**
1. **App Store → Manage Subscriptions / In-App Purchases**
2. **+ New** で各商品を登録
3. **Pricing** を設定
4. **Review Information** を入力（Internal Name, Description）
5. **Save**

### 1.5 リリース情報を入力

1. **App Privacy**
   - **Privacy Policy**: URL を入力（GDPR, CCPA 対応）
   - **Data & Privacy** をクリック
   - **Does your app use the Advertising ID?** → No
   - **Do you or your third-party partners collect user data?** → Yes
   - データ収集内容を入力（例: User ID, Email, Firebase Analytics）

2. **Age Rating**
   - **Age Rating Questionnaire** に回答
   - 一般的なアプリは 4+ で十分

3. **App Review Information**
   - **Demo Account**: Google Sign-In テストアカウント (email & password)
   - **Notes**: 
   ```
   - テスト手順を記載
   - 特殊な手順が不要なことを明記
   - 課金テストが完了していることを記載
   ```

### 1.6 ビルドをアップロード

1. **Build** セクション → **+**
2. **Xcode Organizer** で IPA ファイルをアップロード
   ```bash
   # または Transporter で直接アップロード
   # Transporter をダウンロード & インストール
   # IPA ファイルを選択 → Deliver
   ```
3. ビルド確認：審査時間 10-30 分
4. **Ready to Submit** になったら **Submit for Review**

### 1.7 TestFlight でベータテスト（オプション）

```
1. Build セクション → ビルド選択
2. TestFlight タブ
3. Internal Testers → テスターを追加
4. テスターが TestFlight アプリで検証
5. feedback を収集
```

### 1.8 App Store に提出

1. **Build** セクション で ビルド を選択
2. **Version Info** で version number (1.0.0) 確認
3. **Submit for Review**
4. リリース情報を確認 → **Submit**

### 1.9 審査対応

**審査期間**: 1-3 日（平均 24-48 時間）

**リジェクト対応:**
- App Review Guidelines（[Apple ガイドライン](https://developer.apple.com/app-store/review/guidelines/)）を確認
- リジェクト理由に対応
- 修正版を再提出

**合格後:**
- **Status**: Ready for Sale
- リリース予定日を選択（即時 or 予定日）

### 1.10 App Store Connect チェックリスト

```
✅ アプリ登録: 完了
✅ 一般情報: 入力完了
  ☑️ App Name
  ☑️ Subtitle
  ☑️ Bundle ID
✅ ビジュアル資料: アップロード完了
  ☑️ App Icon (1024×1024)
  ☑️ Screenshots (5-10枚)
✅ 説明文・キーワード: 入力完了
  ☑️ Description (4000字以内)
  ☑️ Keywords
  ☑️ Support URL
  ☑️ Privacy Policy URL
✅ In-App Purchases: 3個確認
  ☑️ pro_monthly ($3.99/月)
  ☑️ lifetime ($9.99)
  ☑️ lifetime_invited ($1.49)
✅ プライバシー: 入力完了
✅ Age Rating: 4+ 
✅ ビルドアップロード: 完了
✅ TestFlight (オプション): テスト完了
✅ App Store 提出: 完了
✅ 審査対応: 合格 ✅
```

---

## [2] Google Play Console 準備・提出 (90分)

### 2.1 Google Play Console アカウント準備

```
前提条件:
- Google Play Developer Program メンバーシップ ($25/一回限り)
- Google アカウント
- Google Play Console アカウント
```

### 2.2 アプリを Google Play Console に登録（初回のみ）

1. [Google Play Console](https://play.google.com/console/) にアクセス
2. **Create app**
   - **App name**: LifeTask Manager
   - **Default language**: 日本語
   - **App or game**: App
   - **Free or paid**: Free (In-App Purchases を使用)
3. **Create**

### 2.3 アプリ情報を入力

#### 2.3.1 一般情報

1. **App details**
   - **Category**: Productivity
   - **Contact email**: `support@lifetaskmanager.com`
   - **Website**: `https://lifetask-manager.example.com`
   - **Privacy policy**: `https://lifetask-manager.example.com/privacy`

#### 2.3.2 ストア掲載情報

1. **Store listing**
   - **App name**: LifeTask Manager
   - **Short description**: 人生の大事なタスクを管理する (50 字)
   - **Full description**: (App Store と同じまたは日本語版を別途作成)

2. **Graphics**
   - **App icon** (512×512 px)
   - **Screenshots** (Android 実デバイスサイズ: 1080×1920 px など)
     - 最小 2 枚、最大 8 枚
     - 日本語の説明テキストを含める
   - **Feature graphic** (1024×500 px)
     - 広告用バナー画像

#### 2.3.3 コンテンツレーティング

1. **Content rating**
   - **Content rating questionnaire** に回答
   - 適切なレーティング (例: Everyone, Teen) を取得

#### 2.3.4 プライバシー・権限

1. **App policies**
   - **Privacy policy**: URL 入力
   - **Permissions**: 使用している権限を確認
     - カメラ（不要なら削除）
     - マイク（不要なら削除）
     - 位置情報（不要なら削除）
     - 連絡先（Google Sign-In で使用）
     - カレンダー（タスク連携で使用）

### 2.4 In-App Products 確認

**Monetize → Products**

以下の 3 つが登録されているか確認:

| Product ID | タイプ | 価格 |
|-----------|-------|------|
| `pro_monthly` | Subscription | $3.99 USD |
| `lifetime` | Managed product | $9.99 USD |
| `lifetime_invited` | Managed product | $1.49 USD |

**登録手順:**
1. **Monetize → Products → Subscriptions / In-app products**
2. **Create product**
   - Product ID: 上記を入力
   - Default price: USD で入力（自動換算）
3. **Save**

### 2.5 ビルド（App Bundle）をアップロード

1. **Release → Production**
2. **Create release**
3. **Upload app bundles**
   - `build/app/outputs/bundle/release/app-release.aab` を選択
4. **Review launch details**

### 2.6 リリース前チェックリスト

Google Play Console は以下の警告がないか確認:

```
⚠️ Content rating needed
⚠️ Privacy policy needed
⚠️ Target audience needed
⚠️ Permissions need review
```

すべて完了したら **Ready to publish**

### 2.7 内部テスト（オプション）

1. **Testing → Internal testing**
2. **Create release**
3. テスターを追加（email）
4. テスターが Google Play で検証

### 2.8 ベータテスト（推奨）

1. **Testing → Closed testing**
2. **Create release**
3. テスター数: 少数から始める（例: 10-20 人）
4. フィードバック収集（1-2 週間）

### 2.9 本番リリース

1. **Release → Production**
2. **Create release**
3. **Status**: 自動公開（Google Play は 2-3 時間で公開）

### 2.10 Google Play Console チェックリスト

```
✅ アプリ登録: 完了
✅ ストア掲載情報: 入力完了
  ☑️ App name
  ☑️ Short description
  ☑️ Full description
✅ ビジュアル資料: アップロード完了
  ☑️ App icon (512×512)
  ☑️ Screenshots (2-8枚)
  ☑️ Feature graphic (1024×500)
✅ コンテンツレーティング: 完了
✅ プライバシー・権限: 入力完了
✅ In-App Products: 3個確認
  ☑️ pro_monthly ($3.99/月)
  ☑️ lifetime ($9.99)
  ☑️ lifetime_invited ($1.49)
✅ App Bundle アップロード: 完了
✅ 内部テスト: 完了 (オプション)
✅ ベータテスト: 完了 (推奨)
✅ 本番リリース: 準備完了
```

---

## [3] 審査対応・デプロイ準備 (60分)

### 3.1 App Store 審査対応

**典型的なリジェクト理由と対応:**

| リジェクト理由 | 原因 | 対応 |
|-----------|------|------|
| Guideline 3.1.1 - Business Model | 課金情報が不正確 | Product ID と説明文を確認・修正 |
| Guideline 5.1.1 - Ads | 広告が不適切 | 広告表示を削除 or 最適化 |
| Guideline 2.3.1 - Beta | ベータ版と明記 | リリースノートを修正 |
| Guideline 4.3 - Spam | 類似アプリが多い | 独自性を強調 |

**対応手順:**
1. リジェクト理由を読む
2. コードを修正（必要に応じて）
3. **Version Release** を作成
4. 新しいビルドをアップロード
5. **Resubmit for Review**

### 3.2 リリースノート準備

**App Store:**
```
v1.0.0 - リリース

【新機能】
• タスク管理機能
• グループ管理機能
• プッシュ通知
• オフライン対応

【改善】
• パフォーマンス最適化
• UI/UX 改善

【既知の問題】
• なし
```

**Google Play:**
```
v1.0.0 - 初回リリース

人生の大事なタスクを管理するアプリがリリースされました。

【主な機能】
・タスク管理
・グループ機能
・プッシュ通知
・オフライン対応

ぜひお試しください！

サポート: support@lifetaskmanager.com
プライバシーポリシー: https://lifetask-manager.example.com/privacy
```

### 3.3 マーケティング準備

**App Store Optimization (ASO):**
1. キーワード: タスク管理, グループ管理, To-Do, リマインダー
2. スクリーンショット: 最初の 2 枚が最も重要
3. Icon: シンプルで認識しやすい

**プロモーション:**
- Twitter: リリース告知
- ブログ: 機能紹介
- ニュースレター: 購読者に通知

### 3.4 サポート体制準備

```
✅ サポートメール: support@lifetaskmanager.com
✅ FAQ ページ: https://lifetask-manager.example.com/faq
✅ プライバシーポリシー: https://lifetask-manager.example.com/privacy
✅ 利用規約: https://lifetask-manager.example.com/terms
✅ ユーザー レビュー 対応体制: 毎日チェック
```

---

## [4] リリース実行・監視 (60分)

### 4.1 リリース実行

**App Store:**
```
Status: Ready for Sale
Release date: 日本時間で調整（22:00 推奨: 翌日に日付が変わる）
```

**Google Play:**
```
自動公開（2-3 時間で全ユーザーに配信）
または段階的ロールアウト設定可能
```

### 4.2 リリース後の監視

#### 4.2.1 Sentry でエラー監視

```
✅ Sentry ダッシュボード確認
  ☑️ Crash-free users
  ☑️ New issues
  ☑️ Error trends
```

#### 4.2.2 App Store Connect でダウンロード・クラッシュ率確認

```
Analytics → Metrics
  ☑️ Unique Devices Installed
  ☑️ Sessions
  ☑️ Crashes
  ☑️ Hangs
```

#### 4.2.3 Google Play Console でダウンロード・評価確認

```
Analytics
  ☑️ Installs
  ☑️ Crashes & ANRs (Android Not Responding)
  ☑️ Rating
```

### 4.3 ユーザー レビュー対応

**App Store:**
```
1. My Apps → LifeTask Manager → Ratings and Reviews
2. 低評価レビューに返信
3. 丁寧で迅速な対応で信頼を構築
```

**Google Play:**
```
1. Ratings & reviews
2. Reply to reviews
3. 返信はすべてのユーザーに表示される
```

**対応例:**
```
低評価: クラッシュする
返信: 貴重なご報告ありがとうございます。
     本バージョンで修正されていますので、
     アップデートをお願いします。
     ご不便をおかけして申し訳ありません。
```

### 4.4 アップデート計画

**Week 1-2 後:**
- バグ修正
- パフォーマンス改善
- v1.0.1 リリース

**Week 3-4 後:**
- 新機能追加
- UI/UX 改善
- v1.1 リリース

### 4.5 ユーザー対応体制

```
✅ メール サポート: support@lifetaskmanager.com
✅ FAQ ページ: 常に更新
✅ ソーシャルメディア: Twitter/Instagram で質問対応
✅ ユーザーグループ: Discord/Slack で コミュニティ構築
```

### 4.6 リリース後チェックリスト

```
✅ 48時間後の確認
  ☑️ ダウンロード数
  ☑️ クラッシュ率
  ☑️ ユーザー レビュー数
  ☑️ Sentry エラー状況

✅ 1週間後の確認
  ☑️ 累計ダウンロード数
  ☑️ リテンション (Day 1, Day 7)
  ☑️ 平均評価
  ☑️ レビューコメント分析

✅ 1ヶ月後の確認
  ☑️ 月間アクティブユーザー
  ☑️ 課金転換率
  ☑️ ユーザー フィードバック
  ☑️ 次のバージョン計画
```

---

## 🎯 Week 4 完了チェックリスト

```
✅ [1] App Store Connect 準備・提出
    ✓ アプリ登録: 完了
    ✓ ストア情報: 入力完了
    ✓ In-App Purchases: 確認済み
    ✓ App Review: 合格
    ✓ リリース: 実行済み

✅ [2] Google Play Console 準備・提出
    ✓ アプリ登録: 完了
    ✓ ストア情報: 入力完了
    ✓ In-App Products: 確認済み
    ✓ App Bundle: アップロード完了
    ✓ リリース: 実行済み

✅ [3] 審査対応・デプロイ準備
    ✓ リリースノート: 作成完了
    ✓ ASO: 最適化完了
    ✓ サポート体制: 準備完了

✅ [4] リリース実行・監視
    ✓ App Store: リリース完了
    ✓ Google Play: リリース完了
    ✓ Sentry: 監視開始
    ✓ ユーザー対応: 開始
```

---

## 🚀 本番リリース完了！

```
✅ Phase 1: コード品質改善          [完了]
✅ Phase 2: デプロイメント準備      [完了]
✅ Phase 3: ローカル環境実装
   ✓ Week 1: 環境設定準備          [完了]
   ✓ Week 2: テスト・検証          [完了]
   ✓ Week 3: ビルド・署名          [完了]
   ✓ Week 4: ストア配信            [完了] ✅

🎉 LifeTask Manager v1.0.0 本番リリース成功！
```

---

## 📊 ここからのチェックリスト

### リリース後 1 週間

```
☑️ ダウンロード数 100+ 達成
☑️ 平均評価 4.0+ 確認
☑️ クラッシュ率 < 0.1% 維持
☑️ ユーザー レビュー 10+ 件確認
☑️ バグレポート 対応（あれば）
```

### リリース後 1 ヶ月

```
☑️ 月間アクティブユーザー 500+ 
☑️ 課金ユーザー 10+ 人
☑️ リテンション (Day 30) > 20%
☑️ ユーザー フィードバック 分析
☑️ v1.0.1 バグ修正リリース準備
```

### リリース後 3 ヶ月

```
☑️ v1.1 新機能リリース準備
☑️ ユーザーコミュニティ構築
☑️ マーケティング活動拡大
☑️ AppStore ランキング 100 位以内
```

---

## ⚠️ よくある質問

### Q: 審査にどのくらい時間がかかりますか？

```
App Store: 平均 24-48 時間
  - 通常: 24 時間以内
  - ピーク時: 48-72 時間
  
Google Play: 自動承認（2-3 時間）
  - 追加確認が必要な場合: 1-2 日
```

### Q: リジェクトされた場合はどうしますか？

```
1. リジェクト理由を詳しく読む
2. App Review Guidelines を確認
3. コードを修正
4. 新しいビルドをアップロード
5. 「Resubmit for Review」で再提出
```

### Q: アップデートのリリース頻度は？

```
推奨: 月 1-2 回
- 高頻度: ユーザーに通知疲れ
- 低頻度: アプリが古く見える
```

### Q: ユーザーが購入できない場合は？

```
1. RevenueCat ダッシュボード確認
2. Product ID が正しいか確認
3. ストア設定を確認
4. テスト購入で検証
5. Sentry でエラーログ確認
```

---

**最後の確認**: App Store と Google Play の両方でリリースが完了し、ユーザーがダウンロード・購入できたら、**本番リリース成功** です！

🎉 **LifeTask Manager v1.0.0 本番リリース完成！**
