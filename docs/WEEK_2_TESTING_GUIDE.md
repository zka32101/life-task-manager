# Week 2: テスト・検証完全ガイド

> **対象**: LifeTask Manager 1.0.0+1  
> **実行環境**: ローカル開発マシン（Flutter テスト環境）  
> **推定時間**: 4-5時間  
> **前提条件**: Week 1 環境設定完了

---

## 📋 Week 2 全体スケジュール

```
[1] コード生成・品質チェック        (30分)
[2] ユニットテスト実行             (45分)
[3] ウィジェットテスト実行         (30分)
[4] E2E テスト (Firebase Emulator)  (60分)
[5] 実デバイス・機能チェック       (45分)
```

---

## [1] コード生成・品質チェック (30分)

### 1.1 Build Runner でコード生成

```bash
cd /path/to/life-task-manager

# 依存パッケージ再確認
flutter pub get

# Build Runner 実行（コード生成）
flutter pub run build_runner build --delete-conflicting-outputs

# 出力確認（9つの *.freezed.dart と 9つの *.g.dart が生成）
find lib -name "*.freezed.dart" | wc -l  # 9 個
find lib -name "*.g.dart" | wc -l        # 9 個
```

**出力ファイル確認:**
```
lib/features/auth/domain/entities/user_profile_entity.freezed.dart
lib/features/auth/domain/entities/user_profile_entity.g.dart
lib/features/auth/domain/entities/user_preferences_entity.freezed.dart
lib/features/auth/domain/entities/user_preferences_entity.g.dart
lib/features/tasks/domain/entities/task_entity.freezed.dart
lib/features/tasks/domain/entities/task_entity.g.dart
lib/features/tasks/domain/entities/category_entity.freezed.dart
lib/features/tasks/domain/entities/category_entity.g.dart
lib/features/tasks/domain/entities/task_record_entity.freezed.dart
lib/features/tasks/domain/entities/task_record_entity.g.dart
lib/features/groups/domain/entities/group_entity.freezed.dart
lib/features/groups/domain/entities/group_entity.g.dart
lib/features/groups/domain/entities/group_member_entity.freezed.dart
lib/features/groups/domain/entities/group_member_entity.g.dart
lib/features/groups/domain/entities/invitation_entity.freezed.dart
lib/features/groups/domain/entities/invitation_entity.g.dart
lib/features/settings/domain/entities/exclusion_entity.freezed.dart
lib/features/settings/domain/entities/exclusion_entity.g.dart
```

### 1.2 Lint チェック

```bash
flutter analyze

# エラーがない場合の出力:
# No issues found! (と表示)
```

### 1.3 フォーマット確認

```bash
dart format . --set-exit-if-changed

# 出力:
# No changes needed.
# または
# Formatted 5 files. (ある場合は自動修正)
```

### 1.4 チェックリスト確認

```
✅ Build Runner コード生成: 完了
✅ *.freezed.dart: 9 ファイル
✅ *.g.dart: 9 ファイル
✅ flutter analyze: エラー 0
✅ dart format: フォーマット確認完了
```

---

## [2] ユニットテスト実行 (45分)

### 2.1 全テスト実行

```bash
flutter test

# または詳細出力
flutter test --verbose

# または coverage を生成
flutter test --coverage
```

**テスト実行時間**: 15-20分

**期待される出力例:**
```
✓ test/core/utils/app_date_utils_test.dart (3 tests)
✓ test/features/auth/providers/auth_provider_test.dart (5 tests)
✓ test/features/tasks/providers/tasks_provider_test.dart (8 tests)
✓ test/features/groups/providers/groups_provider_test.dart (6 tests)
✓ test/features/settings/providers/exclusion_provider_test.dart (4 tests)
...
════════════════════════════════════════════════════════════════════════════════
All tests passed!                                                       (26 tests)
════════════════════════════════════════════════════════════════════════════════
```

### 2.2 特定テストファイル実行（オプション）

```bash
# Auth テストのみ
flutter test test/features/auth/

# Tasks テストのみ
flutter test test/features/tasks/

# Groups テストのみ
flutter test test/features/groups/

# 特定ファイル
flutter test test/features/auth/providers/auth_provider_test.dart
```

### 2.3 Coverage レポート生成（オプション）

```bash
# Coverage 生成
flutter test --coverage

# HTML レポート生成（genhtml が必要）
genhtml coverage/lcov.info -o coverage/html

# または lcov で確認
lcov --list coverage/lcov.info
```

**Coverage 目標:**
- Line Coverage: >= 70%
- Branch Coverage: >= 60%

### 2.4 テスト結果サマリー

```
✅ ユニットテスト実行: 全テスト合格
✅ テスト数: 26+ テスト
✅ 成功率: 100%
✅ Coverage: 70% 以上 (推奨)
```

---

## [3] ウィジェットテスト実行 (30分)

### 3.1 ウィジェットテスト実行

```bash
# 全ウィジェットテスト
flutter test test/features/

# または特定スクリーン
flutter test test/features/paywall/screens/paywall_screen_test.dart
flutter test test/features/auth/screens/login_screen_test.dart
```

### 3.2 主要スクリーンテスト対象

```
✅ PaywallScreen
   - 3つのパターン表示 (Trial, Expired, Invited)
   - 購入ボタン動作
   - 価格表示

✅ LoginScreen
   - Google Sign-In ボタン表示
   - エラーメッセージ表示

✅ TaskDetailScreen
   - タスク詳細情報表示
   - 完了ボタン動作
   - ドロップダウン選択

✅ HomeScreen
   - タスク一覧表示
   - トライアルバナー表示
   - フローティングボタン動作

✅ OnboardingScreen
   - 初回設定フロー
   - 言語選択
   - 推奨タスク表示
```

### 3.3 ウィジェットテスト結果

```
✅ ウィジェットテスト実行: 全テスト合格
✅ スクリーン数: 8+ スクリーン
✅ テストケース: 20+ テストケース
```

---

## [4] E2E テスト (Firebase Emulator) (60分)

### 4.1 Firebase Emulator 起動

```bash
# 別のターミナルで Emulator 起動
firebase emulators:start --only firestore,functions,pubsub

# 出力例:
# ✓ firestore: listening on 127.0.0.1:8080
# ✓ functions: listening on 127.0.0.1:5001
# ✓ pubsub: listening on 127.0.0.1:8085
# Emulator UI: http://127.0.0.1:4000/
```

### 4.2 E2E テスト実行

```bash
# Emulator に接続して E2E テスト実行
flutter drive \
  --target=test_driver/app.dart \
  --dart-define FIREBASE_EMULATOR_HOST=localhost \
  --dart-define FIRESTORE_EMULATOR_HOST=localhost:8080

# または簡潔版
flutter drive --target=test_driver/app.dart
```

**テスト実行時間**: 20-30分

### 4.3 E2E テスト シナリオ

#### [4.3.1] ログインフロー

```dart
// test_driver/main_test.dart
void main() {
  group('Login Flow E2E', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await driver.close();
    });

    test('Google Sign-In successful login', () async {
      // 1. ログインボタンをタップ
      await driver.tap(find.byType('ElevatedButton'));
      
      // 2. ホーム画面が表示されるまで待機
      await driver.waitFor(find.byType('HomeScreen'));
      
      // 3. タスク一覧が表示されることを確認
      expect(
        await driver.getText(find.byType('TaskListView')),
        isNotEmpty,
      );
    });
  });
}
```

#### [4.3.2] タスク CRUD テスト

```dart
test('Create, Read, Update, Delete Task', () async {
  // 1. 新規タスク作成画面に遷移
  await driver.tap(find.byType('FloatingActionButton'));
  await driver.waitFor(find.byType('TaskAddEditScreen'));

  // 2. タスク情報を入力
  await driver.enterText(find.byType('TextFormField'), 'New Task');
  await driver.tap(find.byType('ElevatedButton'));

  // 3. ホーム画面でタスク確認
  await driver.waitFor(find.text('New Task'));

  // 4. タスク詳細を編集
  await driver.tap(find.text('New Task'));
  await driver.enterText(
    find.byType('TextFormField'),
    'Updated Task',
  );
  await driver.tap(find.byType('ElevatedButton'));

  // 5. 削除確認
  await driver.tap(find.byType('PopupMenuButton'));
  await driver.tap(find.text('Delete'));
  await driver.waitForAbsent(find.text('Updated Task'));
});
```

#### [4.3.3] グループ管理テスト

```dart
test('Group creation and member invitation', () async {
  // 1. グループ作成画面
  await driver.tap(find.byIcon(Icons.add));
  await driver.enterText(find.byType('TextFormField'), 'Family Tasks');
  await driver.tap(find.text('Create'));

  // 2. メンバー招待
  await driver.tap(find.byIcon(Icons.person_add));
  await driver.enterText(
    find.byType('TextFormField'),
    'family@example.com',
  );
  await driver.tap(find.text('Send Invitation'));

  // 3. 招待確認メッセージ
  await driver.waitFor(find.text('Invitation sent'));
});
```

#### [4.3.4] 購入フロー（テスト）

```dart
test('Paywall and purchase flow', () async {
  // 1. 設定画面でアップグレード
  await driver.tap(find.byIcon(Icons.settings));
  await driver.tap(find.text('Upgrade to Pro'));

  // 2. PaywallScreen 表示確認
  await driver.waitFor(find.byType('PaywallScreen'));

  // 3. 購入ボタンクリック（テスト環境）
  await driver.tap(find.text('\$3.99/month'));

  // 4. 購入完了確認
  await driver.waitFor(find.text('Purchase successful'));
};
```

#### [4.3.5] 通知受信テスト

```dart
test('Push notification handling', () async {
  // 1. 通知許可設定
  await driver.tap(find.byIcon(Icons.notifications));
  await driver.tap(find.text('Enable Notifications'));

  // 2. FCM メッセージをシミュレート
  await driver.requestData('send_notification', {
    'title': 'Task Reminder',
    'body': 'Don\'t forget your task!',
  });

  // 3. 通知ポップアップ確認
  await driver.waitFor(find.text('Task Reminder'));
});
```

### 4.4 E2E テスト 期待結果

```
✅ E2E テスト実行: 全シナリオ合格
✅ ログインフロー: ✓
✅ タスク CRUD: ✓
✅ グループ管理: ✓
✅ 購入フロー: ✓
✅ 通知受信: ✓
```

---

## [5] 実デバイス・機能チェック (45分)

### 5.1 iOS デバイステスト

```bash
# デバイス一覧確認
xcrun xctrace list devices

# 実デバイスで Release ビルド実行
flutter run --release -d <UDID>

# または Simulator で実行
open -a Simulator
flutter run --release -d "iPhone 15 Pro"
```

### 5.2 Android デバイステスト

```bash
# デバイス一覧確認
adb devices

# 実デバイスで実行
flutter run --release -d <device_id>

# または Emulator で実行
emulator -avd Pixel_7_Pro &
flutter run --release
```

### 5.3 機能チェックリスト

実デバイスで以下を確認してください:

#### ユーザー認証
- [ ] Google Sign-In で正常にログイン
- [ ] ユーザープロフィール表示
- [ ] ログアウト機能動作

#### タスク管理
- [ ] タスク一覧表示（正確なデータ）
- [ ] タスク作成機能
- [ ] タスク編集機能
- [ ] タスク削除機能
- [ ] タスク完了マーク・解除
- [ ] タスク検索機能

#### グループ機能
- [ ] グループ作成
- [ ] メンバー招待（メール送信）
- [ ] グループタスク表示
- [ ] グループメンバー管理

#### 購入フロー
- [ ] PaywallScreen 表示（適切なプラン）
- [ ] 購入ボタン動作
- [ ] 購入成功・確認メッセージ
- [ ] サブスクリプション確認

#### 通知
- [ ] 通知許可リクエスト
- [ ] プッシュ通知受信
- [ ] ローカル通知受信
- [ ] 通知タップでアプリ起動

#### 設定・その他
- [ ] 言語切り替え (日本語 ↔ 英語)
- [ ] ダークモード対応
- [ ] オフライン動作（キャッシュ確認）
- [ ] ネットワーク変更時の動作 (WiFi ↔ Cellular)
- [ ] アカウント削除機能
- [ ] バッテリー消費最適化

### 5.4 パフォーマンス確認

```bash
# Flutter DevTools で性能監視
flutter pub global activate devtools
flutter pub global run devtools

# アプリ実行中に DevTools に接続
flutter run --observatory-port=8888
# ブラウザで http://localhost:8888 にアクセス
```

**確認項目:**
- [ ] UI フレームレート: >= 60fps (目標)
- [ ] メモリ使用量: <= 150MB (平常時)
- [ ] CPU 使用率: <= 30% (待機時)
- [ ] クラッシュなし

### 5.5 デバイステスト 結果サマリー

```
✅ iOS デバイス: 全機能正常
✅ Android デバイス: 全機能正常
✅ チェックリスト: 25/25 項目確認済み
✅ パフォーマンス: 基準値クリア
```

---

## 🎯 Week 2 完了チェックリスト

```
✅ [1] コード生成・品質チェック
    ✓ Build Runner コード生成完了
    ✓ flutter analyze: エラー 0
    ✓ dart format: フォーマット完了

✅ [2] ユニットテスト実行
    ✓ 全テスト実行: 26+ テスト合格
    ✓ 成功率: 100%
    ✓ Coverage: 70% 以上

✅ [3] ウィジェットテスト実行
    ✓ 8+ スクリーン テスト完了
    ✓ 20+ テストケース 合格

✅ [4] E2E テスト実行
    ✓ ログインフロー: ✓
    ✓ タスク CRUD: ✓
    ✓ グループ管理: ✓
    ✓ 購入フロー: ✓
    ✓ 通知受信: ✓

✅ [5] 実デバイス機能チェック
    ✓ iOS 実デバイス/Simulator: 全機能正常
    ✓ Android 実デバイス/Emulator: 全機能正常
    ✓ チェックリスト: 25/25 項目確認済み
    ✓ パフォーマンス: 基準値クリア
```

---

## 🚀 次のステップ

Week 2 完了後:

```
[Week 3] ビルド・署名
    ✅ iOS Release ビルド作成
    ✅ Android Release ビルド作成
    ✅ コード署名・検証完了

[Week 4] ストア配信
    ✅ App Store Connect 提出
    ✅ Google Play Console 提出
    ✅ リリース実行
    ✅ ユーザー対応開始
```

---

## ⚠️ トラブルシューティング

### flutter test が失敗する

```bash
# キャッシュをクリア
flutter clean
flutter pub get

# 再実行
flutter test
```

### Firebase Emulator が接続できない

```bash
# Emulator UI で確認
open http://localhost:4000/

# またはポート確認
netstat -an | grep 8080
lsof -i :8080

# Emulator 再起動
firebase emulators:stop
firebase emulators:start --only firestore,functions
```

### E2E テストがタイムアウト

```bash
# タイムアウト時間を延長
flutter drive \
  --target=test_driver/app.dart \
  --driver-timeout 5m
```

### 実デバイスでアプリがクラッシュ

```bash
# ログ確認
flutter run --verbose

# iOS
xcrun simctl launch booted <app_id>

# Android
adb logcat | grep flutter
```

---

## 📊 テスト品質メトリクス

| メトリクス | 目標値 | 現在値 |
|-----------|-------|--------|
| ユニットテスト成功率 | 100% | ? |
| Code Coverage | >= 70% | ? |
| E2E テストパス率 | 100% | ? |
| 実デバイステスト | 25/25 項目 | ? |

---

**最後の確認**: すべてのテストが合格し、実デバイスで全機能が正常に動作したら、Week 2 完成です。  
**次へ進むには**: git でコミット・プッシュして、Week 3 に進みます。
