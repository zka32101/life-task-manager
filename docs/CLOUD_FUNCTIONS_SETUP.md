# Cloud Functions セットアップガイド

> **最終確認日**: 2026-09-01  
> **LifeTask Manager バージョン**: 1.0.0
> **Phase**: 2-3 デプロイメント準備

## 概要

LifeTask Manager の Cloud Functions は以下の役割を担当します：

- **ロケール別推奨タスクのシード化** (`seedLocalePresets`)
- **ユーザー作成時の初期化処理** (`onUserCreate`)
- **タスク完了時の記録処理** (`completeTask`)
- **タスク延期時の処理** (`deferTask`)
- **日次リマインダー通知スケジューラー** (`sendDailyReminders`)
- **グループアクション通知** (`notifyGroupAction`)
- **招待メール送信** (`sendInvitationEmail`)
- **トライアル期限切れリマインダー** (`trialExpiryReminder`)
- **データマイグレーション** (`migrateToV11`)

---

## 1. 環境セットアップ

### 1.1 前提条件

```bash
# Node.js 20+ インストール確認
node --version  # v20.x 以上

# Firebase CLI インストール
npm install -g firebase-tools

# Firebase ログイン
firebase login
```

### 1.2 ローカル環境変数設定

```bash
cd functions/

# .env.example をコピー
cp .env.example .env
```

### 1.3 .env ファイルの設定

```bash
# .env
# ===================================
# SendGrid Email Configuration
# ===================================
SENDGRID_API_KEY=SG.your_sendgrid_api_key_here

# ===================================
# Firebase Configuration
# ===================================
FIREBASE_PROJECT_ID=lifetask-manager-xxxx
FIREBASE_API_KEY=AIzaSyxxxxxxxxxxxxxxxxxxxxxxxx

# ===================================
# Application Settings
# ===================================
ADMIN_EMAIL=admin@petitworks.com
APP_NAME=LifeTask Manager
ENVIRONMENT=development

# ===================================
# Optional: Stripe Integration (Future)
# ===================================
# STRIPE_SECRET_KEY=sk_live_xxxxx
```

### 1.4 .env.example ファイル作成

```bash
cat > functions/.env.example << 'EOF'
# ===================================
# SendGrid Email Configuration
# ===================================
# https://sendgrid.com/docs/for-developers/sending-email/authentication/
SENDGRID_API_KEY=SG.your_sendgrid_api_key_here

# ===================================
# Firebase Configuration
# ===================================
# Project Settings → General から取得
FIREBASE_PROJECT_ID=lifetask-manager-xxxx
FIREBASE_API_KEY=AIzaSyxxxxxxxxxxxxxxxxxxxxxxxx

# ===================================
# Application Settings
# ===================================
ADMIN_EMAIL=admin@petitworks.com
APP_NAME=LifeTask Manager
ENVIRONMENT=development

# ===================================
# Optional: Stripe Integration (Future)
# ===================================
# STRIPE_SECRET_KEY=sk_live_xxxxx
EOF
```

---

## 2. Cloud Functions 詳細

### 2.1 ロケール別推奨タスク シード化

**ファイル**: `functions/src/migrations/seedLocalePresets.ts`  
**トリガー**: Callable Function  
**対応言語**: ja-JP, en-US, zh-CN

#### 機能

- ロケール別の推奨タスクを Firestore に投入
- 複数ロケールの一括シード化対応
- バッチ処理で効率的に処理

#### Firestore 構造

```
locale_presets/{locale}/
  profile/                    - ロケール情報
    locale: string
    taskCount: number
    updatedAt: Timestamp
  recommended_tasks/{taskId}
    taskId: string
    title: string
    categoryId: string
    categoryPath: string[]
    categoryLabels: string[]
    recurrenceType: string
    reminderDaysBefore: number
    notes?: string
```

#### 呼び出し方法

**Firebase CLI 経由:**
```bash
firebase functions:call seedLocalePresets --data '{"locale":"ja-JP"}'
```

**Flutter 経由:**
```dart
import 'package:cloud_functions/cloud_functions.dart';

final result = await FirebaseFunctions.instance
    .httpsCallable('seedLocalePresets')
    .call({'locale': 'ja-JP'});

print(result.data); // {'success': true, 'results': {'ja-JP': 18}}
```

#### サポート済みロケール

| ロケール | タスク数 | 例 |
|---------|--------|-----|
| ja-JP   | 18     | 確定申告、車検、固定資産税 |
| en-US   | 10     | Tax Return, Vehicle Registration |
| zh-CN   | 5      | 个人所得税、车辆年检 |

---

### 2.2 ユーザー作成時の初期化

**ファイル**: `functions/src/tasks/onUserCreate.ts`  
**トリガー**: Firebase Auth ユーザー作成時  
**実行** : 自動

#### 機能

- ユーザープロフィール作成
- トライアル期限設定 (30日後)
- デフォルト設定・通知設定の初期化
- Firestore ユーザードキュメント作成

#### Firestore 構造 (作成されるドキュメント)

```
users/{uid}/
  profile/
    uid: string
    email: string
    displayName?: string
    photoURL?: string
    isPaid: boolean (初期値: false)
    trialStartAt: Timestamp
    trialEndAt: Timestamp (30日後)
    createdAt: Timestamp
    updatedAt: Timestamp

  preferences/
    fcmToken?: string
    notificationsEnabled: boolean (初期値: true)
    dailyReminderTime: string (初期値: "09:00")
    locale: string (デバイス設定から取得)
    theme: string (初期値: "system")
    updatedAt: Timestamp
```

---

### 2.3 タスク完了時の記録

**ファイル**: `functions/src/tasks/completeTask.ts`  
**トリガー**: Callable Function  
**実行**: ユーザーアクション時

#### 機能

- タスク完了を記録
- `task_records` コレクションに履歴を保存
- 次回予定日を計算・更新
- グループ完了時の集計処理

#### 呼び出し方法

```dart
final result = await FirebaseFunctions.instance
    .httpsCallable('completeTask')
    .call({
  'taskId': 'task-123',
  'completedAt': DateTime.now().toIso8601String(),
});
```

---

### 2.4 タスク延期時の処理

**ファイル**: `functions/src/tasks/deferTask.ts`  
**トリガー**: Callable Function  
**実行**: ユーザーアクション時

#### 機能

- タスク延期情報を記録
- 理由をメモとして保存
- 延期カウント増加
- 次回予定日を更新

#### 呼び出し方法

```dart
final result = await FirebaseFunctions.instance
    .httpsCallable('deferTask')
    .call({
  'taskId': 'task-123',
  'newDueAt': DateTime.now().add(Duration(days: 7)).toIso8601String(),
  'reason': 'まだ準備ができていない',
});
```

---

### 2.5 日次リマインダー通知スケジューラー

**ファイル**: `functions/src/notifications/dailyReminderScheduler.ts`  
**トリガー**: Cloud Scheduler (毎日 09:00 JST)  
**実行**: 定期実行

#### 機能

- ユーザーのスケジュール済み時刻にリマインダー配信
- 期限切れタスクの優先度付け通知
- デバイスの言語設定に合わせたメッセージ
- FCM トークンバリデーション

#### Cloud Scheduler 設定

```bash
# スケジューラー作成コマンド
gcloud scheduler jobs create http daily-reminder \
  --schedule="0 9 * * *" \
  --time-zone="Asia/Tokyo" \
  --http-method=POST \
  --uri="https://asia-northeast1-lifetask-manager.cloudfunctions.net/sendDailyReminders" \
  --oidc-service-account-email=<SERVICE_ACCOUNT_EMAIL>
```

#### 送信するメッセージ例

```
📌 本日のタスクリマインダー

期限切れ: 3件
今日の予定: 5件
今週: 12件

アプリを開く →
```

---

### 2.6 グループアクション通知

**ファイル**: `functions/src/notifications/groupActionNotifier.ts`  
**トリガー**: Firestore onChange (groups/{groupId}/tasks)  
**実行**: タスク更新時

#### 機能

- グループメンバーへの変更通知
- グループ内のアクション追跡
- タスク更新時の即座の通知配信
- ユーザー設定に従う配信制御

#### 通知例

```
👥 [グループ名] のタスク更新

田中太郎さんが「年末大掃除」を完了しました
```

---

### 2.7 招待メール送信

**ファイル**: `functions/src/notifications/sendInvitationEmail.ts`  
**トリガー**: Callable Function  
**実行**: グループ招待時

#### 機能

- SendGrid を通じた招待メール送信
- カスタマイズ可能なメールテンプレート
- 招待コード付き参加リンク生成
- HTML + テキスト形式対応

#### 呼び出し方法

```dart
final result = await FirebaseFunctions.instance
    .httpsCallable('sendInvitationEmail')
    .call({
  'recipientEmail': 'friend@example.com',
  'recipientName': '山田太郎',
  'groupName': 'ファミリータスク',
  'invitationCode': 'INV_ABC123XYZ789',
  'senderName': '田中花子',
});
```

#### 環境設定

SendGrid API キー取得:
1. [SendGrid Console](https://app.sendgrid.com/)
2. Settings → API Keys
3. API キー生成 → Full Access
4. `.env` に設定: `SENDGRID_API_KEY=SG_...`

---

### 2.8 トライアル期限切れリマインダー

**ファイル**: `functions/src/notifications/trialExpiryReminder.ts`  
**トリガー**: Cloud Scheduler (毎日 08:00 JST)  
**実行**: 定期実行

#### 機能

- トライアル期限切れ 7 日前にプッシュ通知
- 期限切れユーザーへの復帰促進通知
- 課金オプション提示

#### Firestore トリガー条件

```javascript
// 対象: isPaid === false かつ trialEndAt <= 今日 + 7日
const cutoff = new Date();
cutoff.setDate(cutoff.getDate() + 7);

// Query条件
where('isPaid', '==', false)
where('trialEndAt', '<=', cutoff)
```

#### 通知メッセージ例

```
🎁 トライアル期限があと 7 日です

LifeTask Manager のプロフェッショナルプランで、
グループ機能と無制限タスク管理をお楽しみください。

今なら初月から使用可能です！
```

---

### 2.9 データマイグレーション

**ファイル**: `functions/src/migrations/migrateToV11.ts`  
**トリガー**: Callable Function（管理者のみ）  
**実行**: 手動実行

#### 機能

- Firestore スキーマの段階的更新
- データ変換・正規化
- バージョン互換性確保
- ロールバック対応

#### 呼び出し方法

```bash
firebase functions:call migrateToV11 --data '{"dryRun":true}'
```

---

## 3. デプロイメント

### 3.1 ローカル テスト環境

#### Firebase Emulator Suite のセットアップ

```bash
# インストール
firebase init emulators

# エミュレータ起動
npm run serve

# または手動で
firebase emulators:start --only functions
```

#### エミュレータで Cloud Function をテスト

```bash
# 別ターミナルで実行
firebase functions:shell

# Shell 内でテスト
> seedLocalePresets({locale: 'ja-JP'})
{ success: true, results: { 'ja-JP': 18 } }
```

### 3.2 開発環境へのデプロイ

```bash
# 依存インストール・ビルド
cd functions/
npm install
npm run build

# 開発環境にデプロイ
firebase deploy --only functions --project lifetask-manager-dev

# デプロイログ確認
firebase functions:log --project lifetask-manager-dev
```

### 3.3 本番環境へのデプロイ

```bash
# 本番環境にデプロイ（確認プロンプト有）
firebase deploy --only functions --project lifetask-manager-prod

# デプロイ状況確認
firebase functions:list --project lifetask-manager-prod

# 最新 100 行のログを確認
firebase functions:log --lines 100 --project lifetask-manager-prod
```

### 3.4 デプロイメント チェックリスト

```
Pre-Deployment:
- [ ] npm install 実行 (依存関係最新化)
- [ ] npm run build 実行 (TypeScript コンパイル確認)
- [ ] .env ファイルに全て設定
- [ ] SENDGRID_API_KEY が有効
- [ ] Firebase プロジェクト ID が正しい

Deployment:
- [ ] firebase deploy --only functions 実行
- [ ] デプロイ完了を確認
- [ ] firebase functions:list で新関数を確認

Post-Deployment:
- [ ] firebase functions:log でエラー無し確認
- [ ] 各 Function の動作をテスト
- [ ] Cloud Scheduler の実行確認
- [ ] FCM デバイスの通知受信確認
```

---

## 4. テスト

### 4.1 ユニット テスト

```bash
# テスト実行
npm test

# カバレッジ確認
npm test -- --coverage
```

### 4.2 統合テスト

#### seedLocalePresets テスト

```bash
firebase functions:call seedLocalePresets --data '{"locale":"ja-JP"}'

# 期待される結果
{
  "result": {
    "success": true,
    "results": {
      "ja-JP": 18
    }
  }
}
```

#### sendInvitationEmail テスト

```bash
firebase functions:call sendInvitationEmail --data '{
  "recipientEmail":"test@example.com",
  "recipientName":"テスト太郎",
  "groupName":"テストグループ",
  "invitationCode":"INV_TEST123",
  "senderName":"テスト花子"
}'
```

### 4.3 Emulator でのテスト

```bash
# エミュレータで以下をテスト
firebase emulators:start --only functions,firestore

# 別ターミナルで実行
firebase functions:shell --project=<PROJECT_ID> --debug

# Shell 内で
> seedLocalePresets({locale: 'en-US'})
```

---

## 5. 監視とログ

### 5.1 ログ確認

```bash
# 全 function のログを表示
firebase functions:log --lines 50

# 特定 function のログのみ
firebase functions:log --lines 50 | grep seedLocalePresets

# リアルタイムログ監視
firebase functions:log --follow
```

### 5.2 Cloud Scheduler 確認

```bash
# スケジューラー一覧
gcloud scheduler jobs list --location=asia-northeast1

# 最新実行結果確認
gcloud scheduler jobs describe daily-reminder \
  --location=asia-northeast1

# 手動実行
gcloud scheduler jobs run daily-reminder \
  --location=asia-northeast1
```

### 5.3 エラーハンドリング

| エラー | 原因 | 解決 |
|------|------|-----|
| `Authentication required` | 認証なし呼び出し | Auth コンテキスト確認 |
| `Invalid API Key` | SendGrid キー無効 | `.env` の SENDGRID_API_KEY 確認 |
| `Firestore quota exceeded` | バッチサイズ超過 | BATCH_SIZE を 400 以下に設定 |
| `Function timeout` | 処理時間超過 | タイムアウト値調整、処理最適化 |

---

## 6. トラブルシューティング

### 問題: デプロイ失敗

```
Error: function failed on load
```

**解決:**
```bash
# 依存関係確認
npm install

# TypeScript コンパイル確認
npm run build

# エラー詳細確認
npm run build 2>&1 | tail -20
```

### 問題: Firebase 接続エラー

```
Error: Failed to get document from Firestore
```

**解決:**
```bash
# Firebase 設定確認
firebase projects:list

# Firestore Rules 確認
firebase deploy --only firestore:rules --dry-run
```

### 問題: SendGrid メール送信失敗

```
Error: Invalid API key
```

**解決:**
```bash
# API キー確認
echo $SENDGRID_API_KEY

# .env ファイル確認
cat .env | grep SENDGRID_API_KEY
```

### 問題: タイムアウト

```
Error: Function timeout after 60s
```

**解決:**
- バッチ処理のサイズを減らす
- Firestore インデックス追加
- 非同期処理の最適化

---

## 7. ベストプラクティス

### 7.1 パフォーマンス最適化

```typescript
// ✅ バッチ処理（推奨）
const batch = db.batch();
for (const doc of docs) {
  batch.set(docRef, data);
}
await batch.commit();

// ❌ 連続書き込み（遅い）
for (const doc of docs) {
  await docRef.set(data);
}
```

### 7.2 エラーハンドリング

```typescript
try {
  const result = await someOperation();
  return { success: true, result };
} catch (error) {
  if (error.code === 'permission-denied') {
    throw new functions.https.HttpsError('permission-denied', '権限がありません');
  }
  throw new functions.https.HttpsError('internal', 'エラーが発生しました');
}
```

### 7.3 セキュリティ

```typescript
// ✅ 認証チェック
if (!context.auth) {
  throw new functions.https.HttpsError('unauthenticated', '認証が必要です');
}

// ✅ 権限チェック
if (!isAdmin(context.auth.uid)) {
  throw new functions.https.HttpsError('permission-denied', '管理者権限が必要です');
}
```

---

## 8. チェックリスト

### Pre-Release

- [ ] 全 dependencies npm install で最新化
- [ ] npm run build エラーなし
- [ ] ローカル emulator でテスト完了
- [ ] .env.example に全項目記載
- [ ] SENDGRID_API_KEY 取得・設定完了
- [ ] Firebase Project ID 確認
- [ ] Cloud Scheduler 設定完了

### Deployment

- [ ] firebase deploy --only functions 実行
- [ ] デプロイ完了ログ確認
- [ ] firebase functions:list で新関数を確認
- [ ] firebase functions:log でエラー確認

### Post-Deployment

- [ ] 各 Function を手動テスト
- [ ] Cloud Scheduler の初回実行確認
- [ ] FCM 通知受信テスト
- [ ] Sentry でエラー監視
- [ ] ユーザー報告ログ監視

---

## 参考資料

- [Firebase Functions Official Docs](https://firebase.google.com/docs/functions)
- [Cloud Scheduler Documentation](https://cloud.google.com/scheduler/docs)
- [SendGrid API Reference](https://docs.sendgrid.com/api-reference/)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)

---

**最後の確認**: すべての Cloud Functions がテスト・デプロイされたら、Phase 2-4 Build Runner コード生成に進みます。
