# Sentry エラートラッキング セットアップガイド

> **最終確認日**: 2026-09-01  
> **LifeTask Manager バージョン**: 1.0.0
> **Phase**: 2-5 デプロイメント準備

## 概要

Sentry は本番環境でのアプリクラッシュとエラーを自動的に検出・報告するサービスです。ユーザーが遭遇するバグを即座に把握し、修正の優先順位を効率的に決定できます。

**主要機能:**
- クラッシュレポート自動送信
- スタックトレース解析
- ユーザーコンテキスト（UID, メール）の記録
- パンくずリスト（ユーザーアクション追跡）
- リリース管理・バージョン追跡

---

## 1. Sentry アカウント設定

### 1.1 アカウント作成

1. [Sentry.io](https://sentry.io) へアクセス
2. **Sign Up** をクリック
3. メールアドレス・パスワード入力
4. メール認証

### 1.2 プロジェクト作成

1. ダッシュボード → **Create Project**
2. プラットフォーム: **Flutter** 選択
3. プロジェクト名: `LifeTask Manager`
4. チーム: デフォルト
5. **Create Project**

### 1.3 DSN 取得

プロジェクト設定画面から DSN（Data Source Name）を取得：

```
DSN format:
https://PUBLIC_KEY@SENTRY_HOST/PROJECT_ID

例:
https://examplePublicKey@o0.ingest.sentry.io/0
```

**取得手順:**
- Settings → Projects → LifeTask Manager
- Client Keys (DSN)
- DSN をコピー

---

## 2. Flutter 統合

### 2.1 パッケージ追加

`pubspec.yaml` に以下を追加:

```yaml
dependencies:
  sentry_flutter: ^7.17.0
  sentry_logging: ^7.17.0
```

インストール:

```bash
flutter pub get
```

### 2.2 初期化 (main.dart)

```dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase初期化（既存）
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Sentry初期化
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://YOUR_DSN@ingest.sentry.io/PROJECT_ID';
      options.environment = kDebugMode ? 'development' : 'production';
      options.tracesSampleRate = 1.0; // 100% で全トランザクション追跡
      options.attachStacktrace = true; // スタックトレース自動添付
      options.includeLocalPackages = true;
      
      // リリースバージョン
      options.release = '1.0.0+1'; // pubspec.yaml から自動取得推奨
      
      // ユーザーコンテキスト設定
      options.beforeSend = (SentryEvent event, {Hint? hint}) {
        return event; // フィルタリングロジック（後述）
      };
    },
    appRunner: () => runApp(const MyApp()),
  );
}
```

### 2.3 ユーザーコンテキスト設定

ユーザーログイン時にコンテキストを設定:

```dart
// lib/features/auth/presentation/providers/auth_provider.dart
import 'package:sentry_flutter/sentry_flutter.dart';

// ログイン成功時
final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  Sentry.captureUserFeedback(
    SentryUserFeedback(
      eventId: '', // または SentryId
      comments: 'User logged in',
      email: user.email,
      name: user.displayName,
    ),
  );
  
  // または直接設定
  Sentry.setUser(SentryUser(
    id: user.uid,
    email: user.email,
    username: user.displayName,
    ipAddress: '127.0.0.1',
  ));
}

// ログアウト時
await Sentry.captureException(Exception('User logged out'));
Sentry.setUser(null);
```

---

## 3. エラーハンドリング統合

### 3.1 自動クラッシュレポート

Sentry Flutter はメインアイソレートのクラッシュを自動的にキャッチします:

```dart
// 自動キャッチ
Future<void> riskyOperation() async {
  // エラーが発生すると自動的に Sentry に報告
  throw Exception('This will be captured');
}
```

### 3.2 手動レポート

特定のエラーを手動で報告:

```dart
try {
  await taskRepository.createTask(task);
} catch (exception, stackTrace) {
  // エラーを Sentry に送信
  await Sentry.captureException(
    exception,
    stackTrace: stackTrace,
    hint: Hint.withMap({
      'taskId': task.id,
      'operation': 'createTask',
    }),
  );
  
  // アプリの処理は続ける
  rethrow;
}
```

### 3.3 メッセージレベル記録

```dart
// 重大度レベル
Sentry.captureMessage(
  'Task completed',
  level: SentryLevel.info,
);

Sentry.captureMessage(
  'Validation failed',
  level: SentryLevel.warning,
);

Sentry.captureMessage(
  'Critical operation failure',
  level: SentryLevel.fatal,
);
```

### 3.4 トランザクション追跡

```dart
final transaction = Sentry.startTransaction(
  'TaskCreation',
  'task.create',
  bindToScope: true,
);

try {
  await taskRepository.createTask(task);
  
  transaction.status = SentrySpanStatus.ok();
} catch (exception) {
  transaction.status = SentrySpanStatus.internalError();
  rethrow;
} finally {
  await transaction.finish();
}
```

---

## 4. Breadcrumbs（パンくずリスト）

ユーザーのアクション履歴を記録して、エラーの原因追跡を支援:

```dart
// パンくずを手動追加
Sentry.addBreadcrumb(
  SentryBreadcrumb(
    message: 'User navigated to TaskDetailScreen',
    level: SentryLevel.info,
    category: 'navigation',
    data: {
      'taskId': taskId,
      'route': '/tasks/:id',
    },
  ),
);

// UI イベント
Sentry.addBreadcrumb(
  SentryBreadcrumb(
    message: 'Complete Task button tapped',
    level: SentryLevel.debug,
    category: 'ui.click',
  ),
);

// Network リクエスト
Sentry.addBreadcrumb(
  SentryBreadcrumb(
    message: 'Firestore query executed',
    level: SentryLevel.debug,
    category: 'http',
    data: {
      'method': 'query',
      'collection': 'users/tasks',
      'duration': '125ms',
    },
  ),
);
```

---

## 5. エラーフィルタリング

### 5.1 特定エラーの無視

```dart
options.beforeSend = (SentryEvent event, {Hint? hint}) {
  // アプリ内エラーのみ送信
  final exception = event.throwable;
  if (exception is TimeoutException) {
    return null; // 無視
  }
  
  // ネットワークエラーはログレベルを下げる
  if (exception is FirebaseException && exception.code == 'unavailable') {
    event = event.copyWith(level: SentryLevel.warning);
  }
  
  return event;
};
```

### 5.2 個人情報のマスキング

```dart
options.beforeSend = (SentryEvent event, {Hint? hint}) {
  // Breadcrumbs から個人情報を削除
  final breadcrumbs = event.breadcrumbs
      ?.map((crumb) {
        if (crumb.category == 'http') {
          // URL のクエリパラメータを削除
          crumb = crumb.copyWith(
            data: crumb.data?..remove('api_key'),
          );
        }
        return crumb;
      })
      .toList();
  
  return event.copyWith(breadcrumbs: breadcrumbs);
};
```

---

## 6. 環境別設定

### 6.1 .env ファイル設定

```bash
# .env
SENTRY_DSN=https://examplePublicKey@o0.ingest.sentry.io/0
SENTRY_ENVIRONMENT=production
SENTRY_RELEASE=1.0.0+1
```

### 6.2 環境変数ロード

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  final dsn = dotenv.env['SENTRY_DSN']!;
  final environment = dotenv.env['SENTRY_ENVIRONMENT'] ?? 'development';
  final release = dotenv.env['SENTRY_RELEASE'] ?? '1.0.0+1';

  await SentryFlutter.init(
    (options) {
      options.dsn = dsn;
      options.environment = environment;
      options.release = release;
    },
    appRunner: () => runApp(const MyApp()),
  );
}
```

### 6.3 ビルド別設定

```dart
const String appFlavor = String.fromEnvironment('APP_FLAVOR', defaultValue: 'dev');

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = _getDsn(appFlavor);
      options.environment = appFlavor;
      options.tracesSampleRate = appFlavor == 'prod' ? 0.5 : 1.0;
    },
    appRunner: () => runApp(const MyApp()),
  );
}

String _getDsn(String flavor) {
  switch (flavor) {
    case 'prod':
      return 'https://prod-dsn@o0.ingest.sentry.io/0';
    case 'staging':
      return 'https://staging-dsn@o0.ingest.sentry.io/0';
    default:
      return 'https://dev-dsn@o0.ingest.sentry.io/0';
  }
}
```

---

## 7. Cloud Functions での Sentry

### 7.1 Sentry SDK インストール

Cloud Functions で Sentry を使用する場合:

```bash
cd functions/
npm install @sentry/node
```

### 7.2 初期化

```typescript
import * as Sentry from '@sentry/node';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.ENVIRONMENT || 'development',
  tracesSampleRate: 1.0,
});

export const myFunction = functions.https.onCall(async (data, context) => {
  try {
    // 処理
  } catch (error) {
    Sentry.captureException(error, {
      contexts: {
        task: {
          taskId: data.taskId,
          operation: 'createTask',
        },
      },
    });
    throw error;
  }
});
```

---

## 8. ダッシュボード・監視

### 8.1 ダッシュボード確認

1. [Sentry Dashboard](https://sentry.io/organizations) へログイン
2. プロジェクト **LifeTask Manager** 選択
3. **Issues** タブ
   - クラッシュ一覧
   - エラー頻度
   - ユーザー影響度

### 8.2 アラート設定

1. **Alerts** → **Create Alert Rule**
2. トリガー条件:
   - 新規 Issue
   - エラー数が閾値を超過
   - 特定キーワード含む

```
例: "Firestore permission denied" が 5 回以上
```

### 8.3 通知設定

1. Settings → Integrations
2. Slack / Email / PagerDuty 連携
3. 本番環境エラーは Slack に即通知

---

## 9. テスト

### 9.1 テストエラー送信

```dart
// ボタンタップでテストエラーを送信
FloatingActionButton(
  onPressed: () async {
    try {
      throw Exception('Test Sentry integration');
    } catch (exception, stackTrace) {
      await Sentry.captureException(exception, stackTrace: stackTrace);
    }
  },
  tooltip: 'Send test error to Sentry',
  child: const Icon(Icons.bug_report),
)
```

### 9.2 ダッシュボード確認

1. 上記ボタンをタップ
2. Sentry ダッシュボードで Issue が表示される
3. 数秒～数分でアラート通知が届く

---

## 10. ベストプラクティス

### 10.1 機密情報のフィルタリング

```dart
options.beforeSend = (SentryEvent event, {Hint? hint}) {
  // Firebase auth tokens を削除
  event = event.copyWith(
    request: event.request?.copyWith(
      headers: event.request?.headers
          ?..removeWhere((key, _) => key.toLowerCase() == 'authorization'),
    ),
  );
  
  // Message から API キーを削除
  if (event.message != null) {
    event = event.copyWith(
      message: SentryMessage(
        event.message!.formatted.replaceAll(RegExp(r'sk_\w+'), '***'),
      ),
    );
  }
  
  return event;
};
```

### 10.2 本番環境のみでエラー報告

```dart
await SentryFlutter.init(
  (options) {
    if (kDebugMode) {
      options.dsn = ''; // 開発環境では無効
    } else {
      options.dsn = 'https://YOUR_DSN@ingest.sentry.io/PROJECT_ID';
    }
  },
  appRunner: () => runApp(const MyApp()),
);
```

### 10.3 レート制限

```dart
options.beforeSend = (SentryEvent event, {Hint? hint}) {
  // 同じエラーが連続する場合は一部をスキップ
  static DateTime? _lastErrorTime;
  
  if (_lastErrorTime != null &&
      DateTime.now().difference(_lastErrorTime!).inSeconds < 5) {
    return null; // 無視
  }
  
  _lastErrorTime = DateTime.now();
  return event;
};
```

---

## 11. チェックリスト

### Pre-Release

- [ ] Sentry.io でプロジェクト作成
- [ ] DSN 取得・.env に設定
- [ ] sentry_flutter パッケージ追加
- [ ] main.dart で Sentry.init()
- [ ] ユーザーコンテキスト設定
- [ ] テストエラー送信で動作確認

### Deployment

- [ ] 本番環境 DSN で初期化
- [ ] beforeSend フィルタ設定完了
- [ ] Slack / Email 通知設定完了
- [ ] アラートルール作成完了

### Post-Release

- [ ] Issues ダッシュボード監視
- [ ] 本番エラー通知を確認
- [ ] クリティカルバグ対応体制準備
- [ ] 定期的にレビュー・分析

---

## 12. トラブルシューティング

### 問題: イベントが Sentry に表示されない

```dart
// デバッグモードでログ出力
options.debug = true;

// DSN が正しいか確認
print(options.dsn);

// ネットワーク接続確認
await Sentry.captureMessage('Test');
```

### 問題: 個人情報が記録されている

```dart
// beforeSend で個人情報をマスク
options.beforeSend = (event, {hint}) {
  event = event.copyWith(
    user: event.user?.copyWith(email: '***'),
  );
  return event;
};
```

### 問題: パフォーマンス低下

```dart
// トランザクション頻度を減らす
options.tracesSampleRate = 0.1; // 10%
```

---

## 参考資料

- [Sentry Flutter Docs](https://docs.sentry.io/platforms/flutter/)
- [Sentry Dashboard](https://sentry.io)
- [Best Practices](https://docs.sentry.io/product/best-practices/)
- [sentry_flutter Package](https://pub.dev/packages/sentry_flutter)

---

**最後の確認**: Sentry エラートラッキングが設定されたら、Phase 2-6 E2E テスト実装に進みます。
