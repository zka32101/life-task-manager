# Build Runner & コード生成セットアップガイド

> **最終確認日**: 2026-09-01  
> **LifeTask Manager バージョン**: 1.0.0
> **Phase**: 2-4 デプロイメント準備

## 概要

Build Runner は Flutter/Dart プロジェクトのコード生成を自動化するツールです。LifeTask Manager では以下の用途で使用します：

- **Freezed**: 不変データクラスの自動生成（fromJson, copyWith等）
- **json_serializable**: JSON シリアライゼーション
- **Riverpod Generator**: 状態管理プロバイダーの最適化

---

## 1. セットアップ

### 1.1 前提条件

```bash
# Dart SDK確認
dart --version  # 3.0+

# Flutter確認
flutter --version
```

### 1.2 依存パッケージ確認

`pubspec.yaml` に以下が含まれていることを確認:

```yaml
dev_dependencies:
  build_runner: ^2.4.0
  freezed_annotation: ^2.4.0
  freezed: ^2.4.0
  json_annotation: ^4.8.0
  json_serializable: ^6.7.0
  riverpod_annotation: ^2.3.0
  riverpod_generator: ^2.3.0
```

### 1.3 インストール

```bash
flutter pub get
```

---

## 2. コード生成の種類

### 2.1 Freezed データクラス

**対象ファイル**: `*_model.dart`, `*_entity.dart`

#### 例: TaskModel

```dart
// lib/features/tasks/data/models/task_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

@freezed
class TaskModel with _$TaskModel {
  const factory TaskModel({
    required String id,
    required String title,
    required String categoryId,
    @Default(false) bool isCompleted,
    DateTime? dueAt,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  factory TaskModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return TaskModel.fromJson({...data, 'id': doc.id});
  }

  Map<String, dynamic> toFirestore() => toJson()..remove('id');
  Map<String, dynamic> toJson() => _$TaskModelToJson(this);
}
```

#### 生成されるファイル

```
task_model.freezed.dart
  - _$TaskModel (内部実装)
  - copyWith() メソッド
  - toString(), hashCode, == 等

task_model.g.dart
  - _$TaskModelFromJson()
  - _$TaskModelToJson()
```

### 2.2 JSON シリアライゼーション

**対象ファイル**: すべてのモデルクラス

```dart
@JsonSerializable()
class UserProfile {
  final String uid;
  final String email;
  final bool isPaid;
  final DateTime trialStartAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.isPaid,
    required this.trialStartAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
```

### 2.3 Riverpod Generator (オプション)

**対象ファイル**: `*_provider.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'example_provider.g.dart';

@riverpod
Future<List<Task>> userTasks(UserTasksRef ref) async {
  final uid = ref.watch(authProvider).maybeWhen(
    data: (user) => user?.uid,
    orElse: () => null,
  );
  
  if (uid == null) return [];
  
  final db = FirebaseFirestore.instance;
  final snapshot = await db
      .collection('users')
      .doc(uid)
      .collection('tasks')
      .where('isArchived', isEqualTo: false)
      .get();
  
  return snapshot.docs
      .map((doc) => TaskModel.fromFirestore(doc).toEntity())
      .toList();
}
```

---

## 3. コード生成実行

### 3.1 1回限りのビルド

```bash
# すべてのコード生成
flutter pub run build_runner build --delete-conflicting-outputs

# または短縮形
dart run build_runner build --delete-conflicting-outputs
```

**フラグ解説:**
- `--delete-conflicting-outputs`: 既存ファイルを削除してから生成
- `--verbose`: 詳細ログ表示

### 3.2 Watch モード（開発中）

```bash
# ファイル変更を監視してリアルタイムコード生成
flutter pub run build_runner watch

# キーボード[q]で終了
```

### 3.3 キャッシュクリア

```bash
# キャッシュを削除してクリーンビルド
flutter pub run build_runner clean

# その後、ビルド
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 4. トラブルシューティング

### 4.1 "Could not find package"エラー

```bash
# 依存関係を再取得
flutter pub get

# キャッシュ削除
rm -rf .dart_tool
flutter pub get
```

### 4.2 "Conflicting outputs"エラー

```bash
# オプション付きで再生成
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4.3 メモリ不足（Out of Memory）

```bash
# より小さなバッチサイズでビルド
dart run build_runner build --verbose
```

### 4.4 "This file must be generated using build_runner"エラー

`.freezed.dart` ファイルが生成されていない場合：

```bash
# 確認: part ディレクティブがあるか
grep "part '.*\.freezed\.dart'" lib/features/**/models/*.dart

# 再生成
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 5. ベストプラクティス

### 5.1 ファイル命名規則

```
✅ task_model.dart         (モデルクラス)
✅ user_entity.dart        (エンティティクラス)
❌ TaskModel.dart          (大文字は避ける - 自動生成で問題になる可能性)
```

### 5.2 Part ディレクティブ

**必須**: 以下の2行はすべてのコード生成対象ファイルに必要

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_model.freezed.dart';  // Freezed生成ファイル
part 'task_model.g.dart';         // JSON生成ファイル
```

### 5.3 モデル ← → エンティティ変換

```dart
// lib/features/tasks/data/models/task_model.dart
@freezed
class TaskModel with _$TaskModel {
  // ...
  
  // エンティティへの変換
  TaskEntity toEntity() => TaskEntity(
    id: id,
    title: title,
    categoryId: categoryId,
    isCompleted: isCompleted,
    dueAt: dueAt,
  );
}
```

### 5.4 JSON フィールドマッピング

```dart
@JsonSerializable()
class UserProfile {
  final String uid;
  
  // Firebase の "createdAt" フィールドを DateTime に変換
  @JsonKey(name: 'createdAt', fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAtDate;

  static DateTime _timestampFromJson(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return DateTime.parse(value.toString());
  }

  static dynamic _timestampToJson(DateTime date) {
    return Timestamp.fromDate(date);
  }
}
```

---

## 6. ビルド プロセス全体

### 6.1 推奨フロー

```bash
# 1. 依存関係更新
flutter pub get

# 2. キャッシュクリア (必要に応じて)
flutter pub run build_runner clean

# 3. コード生成
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Lint チェック
flutter analyze

# 5. Format チェック
dart format . --set-exit-if-changed

# 6. テスト実行
flutter test
```

### 6.2 CI/CD パイプラインでのコード生成

```yaml
# .github/workflows/tests.yml
name: Tests

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Generate code
        run: flutter pub run build_runner build --delete-conflicting-outputs
      
      - name: Analyze
        run: flutter analyze
      
      - name: Format check
        run: dart format . --set-exit-if-changed
      
      - name: Run tests
        run: flutter test
```

---

## 7. 生成ファイルの .gitignore 設定

以下のファイルはバージョン管理から除外 **してはいけません** - 実装の一部です:

```
# ❌ 以下は.gitignoreに追加しないこと
*.freezed.dart
*.g.dart
```

以下は除外してもよい:

```
# ✅ 以下は.gitignoreに追加してよい
.dart_tool/
build/
.packages
```

---

## 8. コード生成の検証

### 8.1 生成ファイルの確認

```bash
# 生成ファイル一覧
find lib -name "*.freezed.dart" | wc -l
find lib -name "*.g.dart" | wc -l

# 例: 18個のモデルファイル
18 freezed files
18 g.dart files (JSON serialization)
```

### 8.2 IDE での確認

- **VS Code**: 拡張機能「Dart」で自動補完が有効か確認
- **Android Studio**: File → Invalidate Caches / Restart

### 8.3 ビルド確認

```bash
# Dart Analyzer で検証
dart analyze lib/

# エラーなし: OK ✅
# エラーあり: エラー修正後に再生成
```

---

## 9. チェックリスト

### Pre-Generation

- [ ] `pubspec.yaml` に build_runner, freezed, json_serializable がある
- [ ] `flutter pub get` 実行完了
- [ ] Part ディレクティブが全モデルに存在
- [ ] @freezed / @JsonSerializable アノテーションが付与されている

### Generation

- [ ] `flutter pub run build_runner build --delete-conflicting-outputs` 実行
- [ ] エラーメッセージなし
- [ ] `.freezed.dart` と `.g.dart` ファイル生成確認
- [ ] Lint/Format チェック合格
- [ ] テスト実行完了（全テスト合格）

### Post-Generation

- [ ] IDE でコード補完が動作
- [ ] Git 差分で自動生成ファイルが含まれている
- [ ] CI/CD パイプラインで自動生成設定完了

---

## 10. リリース前チェック

```
リリース前に必ず実行:

✅ flutter pub get
✅ flutter pub run build_runner build --delete-conflicting-outputs
✅ flutter analyze (エラー: 0)
✅ dart format . --set-exit-if-changed (フォーマット一致)
✅ flutter test (全テスト合格)
✅ Git状態確認 (生成ファイル含まれている)
```

---

## 参考資料

- [build_runner official](https://pub.dev/packages/build_runner)
- [Freezed documentation](https://pub.dev/packages/freezed)
- [json_serializable guide](https://pub.dev/packages/json_serializable)
- [Riverpod Generator](https://pub.dev/packages/riverpod_generator)

---

**最後の確認**: コード生成が成功したら、Phase 2-5 Sentry エラートラッキング設定に進みます。
