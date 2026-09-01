# E2E テスト実装ガイド

> **最終確認日**: 2026-09-01  
> **LifeTask Manager バージョン**: 1.0.0
> **Phase**: 2-6 デプロイメント準備

## 概要

E2E (End-to-End) テストは、アプリの重要なユーザーフロー全体を自動でテストします。UI から Firestore データベースまで、実際のユーザー操作を模擬します。

**テスト対象フロー:**
- ログイン・登録フロー
- タスク CRUD 操作
- グループ招待・参加
- 購入フロー（RevenueCat）
- トライアル期限表示
- 通知受信

---

## 1. セットアップ

### 1.1 テストドライバー配置

```bash
# テストドライバー作成
mkdir -p test_driver
touch test_driver/app.dart
```

### 1.2 依存パッケージ追加

`pubspec.yaml` に追加:

```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  fake_cloud_firestore: ^1.3.0  # Firestore モック
```

インストール:

```bash
flutter pub get
```

---

## 2. テストドライバー (test_driver/app.dart)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:life_task_manager/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('LifeTask Manager E2E Tests', () {
    testWidgets('Complete login and task creation flow', (tester) async {
      // アプリ起動
      app.main();
      await tester.pumpAndSettle();

      // テストロジックはここに記述
    });
  });
}
```

---

## 3. テストケース

### 3.1 ログインフロー

**ファイル**: `integration_test/auth_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:life_task_manager/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Tests', () {
    testWidgets('Login with valid Google account', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Splash → Login 画面へ遷移
      expect(find.byType(LoginScreen), findsOneWidget);

      // Google Sign-In ボタンをタップ
      await tester.tap(find.byKey(Key('google_signin_button')));
      await tester.pumpAndSettle(Duration(seconds: 5));

      // ホーム画面が表示される
      expect(find.byType(HomeScreen), findsOneWidget);

      // ユーザー情報が表示される
      expect(find.text('LifeTask Manager'), findsWidgets);
    });

    testWidgets('Logout functionality', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // ログイン後、設定画面へ
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // ログアウトボタン
      await tester.tap(find.byKey(Key('logout_button')));
      await tester.pumpAndSettle();

      // 確認ダイアログ
      await tester.tap(find.byKey(Key('logout_confirm')));
      await tester.pumpAndSettle();

      // ログイン画面に戻る
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
```

### 3.2 タスク作成フロー

**ファイル**: `integration_test/task_test.dart`

```dart
testWidgets('Create task with all fields', (tester) async {
  app.main();
  await tester.pumpAndSettle();

  // ログイン（Firestore mock を使用）
  await _loginUser(tester);

  // ホーム画面でタスク作成ボタンをタップ
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();

  // TaskAddEditScreen が表示される
  expect(find.byType(TaskAddEditScreen), findsOneWidget);

  // タスク タイトル入力
  await tester.enterText(find.byKey(Key('title_field')), 'テストタスク');
  await tester.pump();

  // カテゴリ選択
  await tester.tap(find.byKey(Key('category_dropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('金融').first);
  await tester.pumpAndSettle();

  // 予定日時設定
  await tester.tap(find.byKey(Key('due_date_field')));
  await tester.pumpAndSettle();
  
  // 日付ピッカー
  await tester.tap(find.byKey(Key('date_picker_confirm')));
  await tester.pumpAndSettle();

  // 保存
  await tester.tap(find.byKey(Key('save_button')));
  await tester.pumpAndSettle(Duration(seconds: 2));

  // ホーム画面に戻る
  expect(find.byType(HomeScreen), findsOneWidget);

  // 作成したタスクが表示される
  expect(find.text('テストタスク'), findsOneWidget);
});

testWidgets('Edit task', (tester) async {
  app.main();
  await tester.pumpAndSettle();

  await _loginUser(tester);

  // タスクを長押し
  await tester.longPress(find.text('テストタスク'));
  await tester.pumpAndSettle();

  // 編集オプション
  await tester.tap(find.byIcon(Icons.edit));
  await tester.pumpAndSettle();

  // タイトル変更
  await tester.enterText(find.byKey(Key('title_field')), '更新されたタスク');
  await tester.pump();

  // 保存
  await tester.tap(find.byKey(Key('save_button')));
  await tester.pumpAndSettle();

  // 変更が反映される
  expect(find.text('更新されたタスク'), findsOneWidget);
});

testWidgets('Complete task', (tester) async {
  app.main();
  await tester.pumpAndSettle();

  await _loginUser(tester);

  // タスク完了チェックボックス
  final checkbox = find.byKey(Key('task_complete_checkbox'));
  await tester.tap(checkbox);
  await tester.pumpAndSettle();

  // チェック状態を確認
  expect(
    find.byWidgetPredicate(
      (widget) => widget is Checkbox && widget.value == true,
    ),
    findsWidgets,
  );
});

testWidgets('Delete task', (tester) async {
  app.main();
  await tester.pumpAndSettle();

  await _loginUser(tester);

  // タスク削除ボタン
  await tester.tap(find.byIcon(Icons.delete).first);
  await tester.pumpAndSettle();

  // 確認ダイアログ
  await tester.tap(find.text('削除'));
  await tester.pumpAndSettle();

  // タスクが削除される
  expect(find.text('テストタスク'), findsNothing);
});
```

### 3.3 グループ管理フロー

**ファイル**: `integration_test/group_test.dart`

```dart
testWidgets('Create group', (tester) async {
  app.main();
  await tester.pumpAndSettle();

  await _loginUser(tester);

  // グループ画面へ
  await tester.tap(find.byIcon(Icons.group));
  await tester.pumpAndSettle();

  // グループ作成ボタン
  await tester.tap(find.byKey(Key('create_group_button')));
  await tester.pumpAndSettle();

  // グループ名入力
  await tester.enterText(find.byKey(Key('group_name')), 'ファミリータスク');
  await tester.pump();

  // 作成
  await tester.tap(find.byKey(Key('create_button')));
  await tester.pumpAndSettle();

  // グループが表示される
  expect(find.text('ファミリータスク'), findsOneWidget);
});

testWidgets('Invite member to group', (tester) async {
  app.main();
  await tester.pumpAndSettle();

  await _loginUser(tester);

  // グループを選択
  await tester.tap(find.text('ファミリータスク'));
  await tester.pumpAndSettle();

  // 招待ボタン
  await tester.tap(find.byIcon(Icons.person_add));
  await tester.pumpAndSettle();

  // 招待メール入力
  await tester.enterText(find.byKey(Key('invite_email')), 'friend@example.com');
  await tester.pump();

  // 送信
  await tester.tap(find.byKey(Key('send_invite_button')));
  await tester.pumpAndSettle();

  // 成功メッセージ
  expect(find.text('招待を送信しました'), findsOneWidget);
});
```

### 3.4 購入フロー

**ファイル**: `integration_test/purchase_test.dart`

```dart
testWidgets('Open paywall screen', (tester) async {
  app.main();
  await tester.pumpAndSettle();

  await _loginUser(tester);

  // 設定 → プロプラン
  await tester.tap(find.byIcon(Icons.settings));
  await tester.pumpAndSettle();

  await tester.tap(find.text('プロプラン'));
  await tester.pumpAndSettle();

  // Paywall が表示される
  expect(find.byType(PaywallScreen), findsOneWidget);
});

testWidgets('Restore purchase', (tester) async {
  app.main();
  await tester.pumpAndSettle();

  await _loginUser(tester);

  // Paywall へ移動
  await tester.tap(find.byIcon(Icons.settings));
  await tester.pumpAndSettle();
  await tester.tap(find.text('プロプラン'));
  await tester.pumpAndSettle();

  // 復元ボタン
  await tester.tap(find.byKey(Key('restore_purchase_button')));
  await tester.pumpAndSettle();

  // 復元完了メッセージ
  expect(find.text('購入を復元しました'), findsOneWidget);
});
```

### 3.5 通知フロー

**ファイル**: `integration_test/notification_test.dart`

```dart
testWidgets('Receive daily reminder notification', (tester) async {
  app.main();
  await tester.pumpAndSettle();

  await _loginUser(tester);

  // 設定 → 通知設定
  await tester.tap(find.byIcon(Icons.settings));
  await tester.pumpAndSettle();

  await tester.tap(find.text('通知設定'));
  await tester.pumpAndSettle();

  // 通知有効化確認
  expect(find.byKey(Key('notification_toggle')), findsOneWidget);

  final toggle = find.byType(Switch);
  await tester.tap(toggle.first);
  await tester.pump();

  // 通知が有効化される
  expect(find.text('通知有効'), findsOneWidget);
});
```

---

## 4. ヘルパー関数

**ファイル**: `integration_test/helpers.dart`

```dart
import 'package:flutter_test/flutter_test.dart';

/// テストユーザーでログイン
Future<void> _loginUser(WidgetTester tester) async {
  // 実装: Firebase Auth mock またはテストユーザーでサインイン
  // 本番では OAuth flow をモック化
  
  // ここでは簡略化して、ローカルデータを使用する場合の例
  // 実際のテストでは Firebase Auth Emulator を推奨
}

/// タスク作成ヘルパー
Future<void> createTestTask(
  WidgetTester tester, {
  required String title,
  required String category,
  DateTime? dueDate,
}) async {
  // タスク追加ボタン
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();

  // タイトル入力
  await tester.enterText(find.byKey(Key('title_field')), title);
  await tester.pump();

  // カテゴリ選択（必要に応じて）
  if (category.isNotEmpty) {
    await tester.tap(find.byKey(Key('category_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(category));
    await tester.pumpAndSettle();
  }

  // 保存
  await tester.tap(find.byKey(Key('save_button')));
  await tester.pumpAndSettle(Duration(seconds: 2));
}

/// グループ作成ヘルパー
Future<void> createTestGroup(
  WidgetTester tester, {
  required String groupName,
}) async {
  // グループ画面へ
  await tester.tap(find.byIcon(Icons.group));
  await tester.pumpAndSettle();

  // グループ作成ボタン
  await tester.tap(find.byKey(Key('create_group_button')));
  await tester.pumpAndSettle();

  // グループ名入力
  await tester.enterText(find.byKey(Key('group_name')), groupName);
  await tester.pump();

  // 作成
  await tester.tap(find.byKey(Key('create_button')));
  await tester.pumpAndSettle();
}
```

---

## 5. テスト実行

### 5.1 ローカル実行（iOS）

```bash
# iOS Simulator で E2E テスト実行
flutter drive \
  --target=test_driver/app.dart \
  --driver=test_driver/app.dart \
  -d iPhone
```

### 5.2 ローカル実行（Android）

```bash
# Android Emulator で E2E テスト実行
flutter drive \
  --target=test_driver/app.dart \
  --driver=test_driver/app.dart \
  -d emulator-5554
```

### 5.3 テスト結果確認

```bash
# テスト実行ログ
# テスト完了時に以下が表示される:
# ✅ All tests passed!
# または
# ❌ Test failed: [エラーメッセージ]
```

---

## 6. Firebase Emulator での テスト

### 6.1 Emulator Suite 起動

```bash
firebase emulators:start --only auth,firestore,functions
```

### 6.2 E2E テストで Emulator 使用

```dart
import 'package:firebase_core/firebase_core.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Firebase を Emulator に指定
    await Firebase.initializeApp();

    // ローカルホストで動作している Emulator に接続
    if (kDebugMode) {
      FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    }
  });
}
```

---

## 7. CI/CD パイプラインでの E2E テスト

### 7.1 GitHub Actions 設定

**ファイル**: `.github/workflows/e2e_tests.yml`

```yaml
name: E2E Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  e2e_tests:
    runs-on: macos-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Start Firebase Emulator
        run: |
          npm install -g firebase-tools
          firebase emulators:start --only auth,firestore &
          sleep 10
      
      - name: Run E2E tests (iOS Simulator)
        run: |
          xcrun simctl boot "iPhone 14"
          flutter drive \
            --target=test_driver/app.dart \
            --driver=test_driver/app.dart \
            -d iPhone
      
      - name: Upload test results
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: e2e_test_results
          path: test_results/
```

---

## 8. トラブルシューティング

### 8.1 "Failed to connect to Firebase Emulator"

```bash
# Emulator が起動しているか確認
ps aux | grep emulator

# 手動で起動
firebase emulators:start --only auth,firestore
```

### 8.2 テストタイムアウト

```dart
// タイムアウト時間を増やす
testWidgets('Long running test', (tester) async {
  tester.binding.window.physicalSizeTestValue = Size(1080, 1920);
  addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

  // タイムアウト 30 秒に延長
  final result = await tester
      .pumpAndSettle(Duration(seconds: 30));
});
```

### 8.3 Widget 検出失敗

```dart
// デバッグ表示
testWidgets('Debug widget tree', (tester) async {
  app.main();
  await tester.pumpAndSettle();

  // Widget ツリー出力
  expect(find.byType(HomeScreen), findsOneWidget);
  debugPrintWidgetTree(tester.element(find.byType(MaterialApp)));
});
```

---

## 9. ベストプラクティス

### 9.1 テスト独立性

```dart
// ❌ テスト間で状態が共有される
setUp(() {
  // ここでログイン状態を設定
  _currentUser = testUser;
});

// ✅ 各テストが独立している
testWidgets('Test 1', (tester) async {
  await _loginUser(tester);
  // テスト内容
});

testWidgets('Test 2', (tester) async {
  await _loginUser(tester);
  // テスト内容
});
```

### 9.2 明示的な待機

```dart
// ❌ 固定待機
await Future.delayed(Duration(seconds: 2));

// ✅ UI 更新完了を待つ
await tester.pumpAndSettle(Duration(seconds: 2));

// ✅ 特定 Widget が表示されるまで待つ
expect(find.text('Success'), findsOneWidget);
```

### 9.3 テストデータの管理

```dart
// テストユーザー用のエントリーポイント
void main() {
  // Firebase Auth を mock
  setupMockFirebaseAuth();
  
  // Firestore を mock
  setupMockFirestore();
  
  // テスト実行
  integrationTestMain();
}
```

---

## 10. チェックリスト

### Pre-Testing

- [ ] integration_test パッケージ追加
- [ ] Firebase Emulator インストール
- [ ] テストドライバー作成
- [ ] ヘルパー関数実装
- [ ] テストキー を Widget に追加

### Testing

- [ ] ローカルで E2E テスト実行（iOS）
- [ ] ローカルで E2E テスト実行（Android）
- [ ] テスト成功率 100%
- [ ] CI/CD パイプライン設定完了

### Post-Testing

- [ ] GitHub Actions で自動実行確認
- [ ] テスト結果ログ保存設定
- [ ] Slack 通知設定（テスト失敗時）

---

## 参考資料

- [Flutter Integration Testing Docs](https://flutter.dev/docs/testing/integration-tests)
- [Firebase Testing Guide](https://firebase.flutter.dev/docs/testing/overview/)
- [flutter_test API Reference](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html)

---

**最後の確認**: E2E テストが実装されたら、Phase 2-7 本番ビルド作成に進みます。
