# LifeTask Manager — Cloud Functions

Firebase Cloud Functions for LifeTask Manager backend operations.

## Quick Start

### Prerequisites

```bash
# Node.js 20+ インストール確認
node --version

# Firebase CLI インストール
npm install -g firebase-tools

# Firebase ログイン
firebase login
```

### Setup

```bash
cd functions/

# 依存インストール
npm install

# 環境変数設定
cp .env.example .env
# .env ファイルを編集して認証情報を入力

# ビルド
npm run build
```

## Available Functions

| Function | Trigger | Purpose |
|----------|---------|---------|
| `seedLocalePresets` | Callable | ロケール別推奨タスク投入 |
| `onUserCreate` | Auth | ユーザー作成時初期化 |
| `completeTask` | Callable | タスク完了記録 |
| `deferTask` | Callable | タスク延期処理 |
| `sendDailyReminders` | Scheduler | 日次リマインダー通知 |
| `notifyGroupAction` | Firestore | グループアクション通知 |
| `sendInvitationEmail` | Callable | 招待メール送信 |
| `trialExpiryReminder` | Scheduler | トライアル期限リマインダー |
| `migrateToV11` | Callable | データマイグレーション |

## Development

### Local Testing

```bash
# Firebase Emulator Suite 起動
npm run serve

# 別ターミナルで Shell 起動
firebase functions:shell

# Shell 内でテスト
> seedLocalePresets({locale: 'ja-JP'})
```

### Build & Watch

```bash
# ビルド
npm run build

# Watch モード (開発中)
npm run build:watch
```

### Unit Tests

```bash
# テスト実行
npm test

# カバレッジ確認
npm test -- --coverage
```

## Deployment

### Development Environment

```bash
firebase deploy --only functions --project lifetask-manager-dev
```

### Production Environment

```bash
firebase deploy --only functions --project lifetask-manager-prod
```

### View Logs

```bash
# ログ表示
firebase functions:log

# リアルタイム監視
firebase functions:log --follow

# 特定 function のログ
firebase functions:log | grep seedLocalePresets
```

## Environment Variables

### Required

- **SENDGRID_API_KEY**: SendGrid API キー（メール送信）
- **FIREBASE_PROJECT_ID**: Firebase プロジェクト ID

### Optional

- **STRIPE_SECRET_KEY**: Stripe API キー（将来対応）
- **SENTRY_DSN**: Sentry DSN（エラートラッキング）

詳細は `.env.example` を参照。

## Project Structure

```
src/
├── index.ts                    # Function エクスポート
├── migrations/
│   ├── seedLocalePresets.ts   # ロケール推奨タスク
│   └── migrateToV11.ts        # スキーママイグレーション
├── tasks/
│   ├── onUserCreate.ts         # ユーザー作成処理
│   ├── completeTask.ts         # タスク完了
│   └── deferTask.ts            # タスク延期
└── notifications/
    ├── dailyReminderScheduler.ts    # 日次リマインダー
    ├── groupActionNotifier.ts       # グループ通知
    ├── sendInvitationEmail.ts       # 招待メール
    └── trialExpiryReminder.ts       # トライアル期限
```

## Configuration Files

- **package.json**: Dependencies & scripts
- **tsconfig.json**: TypeScript configuration
- **.env.example**: Environment variables template
- **README.md**: This file

## Common Issues

### Cannot find module errors

```bash
npm install
npm run build
```

### Permission denied

```bash
firebase login
firebase projects:list
```

### Function timeout

- Firestore インデックス追加
- バッチ処理最適化
- タイムアウト値調整

詳細は `docs/CLOUD_FUNCTIONS_SETUP.md` を参照。

## Additional Resources

- [CLOUD_FUNCTIONS_SETUP.md](../docs/CLOUD_FUNCTIONS_SETUP.md) - 詳細セットアップガイド
- [Firebase Functions Docs](https://firebase.google.com/docs/functions)
- [TypeScript in Cloud Functions](https://firebase.google.com/docs/functions/typescript)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)

## License

Copyright © 2026 Petitworks. All rights reserved.
