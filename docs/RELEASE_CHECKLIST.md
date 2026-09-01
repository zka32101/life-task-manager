# LifeTask Manager — リリース準備完全チェックリスト

**最終更新**: 2026-09-01  
**対象バージョン**: 1.0.0+1  
**ステータス**: Phase 2 進行中 ✅

---

## 📋 全体進捗

### ✅ Phase 1: コード品質改善 (完了・マージ済み)

| # | フェーズ | タイトル | ステータス |
|----|---------|---------|---------|
| 1-1 | ルータ | ナビゲーション リダイレクト基盤 | ✅ マージ |
| 1-2 | エラーUI | 統一エラーハンドリング (8画面) | ✅ マージ |
| 1-3 | Firebase | 例外詳細処理・リトライ判定 | ✅ マージ |
| 1-4 | Provider | メモ化・パフォーマンス最適化 | ✅ マージ |
| 1-5 | ナビゲーション | パラメータ安全検証 | ✅ マージ |
| 1-6 | データ層 | Firestore キャッシング・バッチ操作 | ✅ マージ |

**統計**: 6 commits, +~700行, -~100行 | **PR #5 マージ完了** ✅

---

### 🔄 Phase 2: デプロイメント準備 (進行中)

| # | フェーズ | タイトル | ステータス | ドキュメント |
|----|---------|---------|---------|---------|
| 2-1 | Firebase | 設定ファイル・Firestore規則 | ✅ 完了 | `DEPLOYMENT.md` |
| 2-2 | RevenueCat | API キー・ストア設定 | ✅ 完了 | `REVENUE_CAT_SETUP.md` |
| 2-3 | Cloud Functions | Functions デプロイ・設定 | 📝 計画中 | - |
| 2-4 | Build Runner | コード生成・Freezed | 📝 計画中 | - |
| 2-5 | Sentry | エラー トラッキング | 📝 計画中 | - |
| 2-6 | E2E テスト | テスト スイート実装 | 📝 計画中 | - |
| 2-7 | 本番ビルド | Android/iOS ビルド署名 | 📝 計画中 | - |
| 2-8 | ストア配信 | App Store/Play Store 提出 | 📝 計画中 | - |

---

## 📝 実装済みドキュメント

### 必読

1. **DEPLOYMENT.md** ⭐⭐⭐
   - 全 Phase 2-1 〜 2-8 の概要
   - Firebase セットアップ
   - ストア設定の基本

2. **REVENUE_CAT_SETUP.md** ⭐⭐⭐
   - RevenueCat アカウント作成
   - Product ID マッピング
   - テスト手順
   - トラブルシューティング

3. **firebase_options.dart** ⭐⭐
   - テンプレート ファイル
   - プラットフォーム別設定構造
   - [FlutterFire CLI で自動生成可能]

---

## 🚀 リリース前 チェックリスト

### 段階 1: 開発環境設定 (現在地)

```
✅ Phase 1 品質改善 完了
✅ Firebase options テンプレート 用意
✅ RevenueCat 統合ガイド 完成
⬜ Cloud Functions セットアップ (次)
⬜ E2E テスト実装 (計画中)
⬜ ビルド署名設定 (計画中)
```

### 段階 2: 環境設定準備

**Firebaseプロジェクト:**
- [ ] Firebase Console でプロジェクト作成
- [ ] firebase_options.dart に認証情報入力
- [ ] Firestore ルール デプロイ
- [ ] Cloud Messaging 設定

**RevenueCat:**
- [ ] RevenueCat アカウント作成
- [ ] App Store Connect で In-App Purchase 設定
- [ ] Google Play Console で In-App Product 設定
- [ ] API キー を AppConstants に設定

**ビルド署名:**
- [ ] Android Keystore ファイル生成
- [ ] iOS 証明書・プロビジョニング プロファイル取得
- [ ] Xcode signing 設定

### 段階 3: テスト実行

```
Unit Tests:
- [ ] flutter test (全テスト合格)
- [ ] 成功率 100%

Widget Tests:
- [ ] PaywallScreen テスト
- [ ] LoginScreen テスト
- [ ] TaskDetailScreen テスト

Integration/E2E Tests:
- [ ] ログイン フロー
- [ ] タスク作成・編集・削除
- [ ] 購入フロー
- [ ] グループ管理
```

### 段階 4: ビルド作成

```
Android:
- [ ] flutter build appbundle --release
- [ ] ファイルサイズ確認
- [ ] 署名確認

iOS:
- [ ] flutter build ios --release
- [ ] App Store 配信用ビルド
- [ ] ファイルサイズ確認
```

### 段階 5: ストア設定

```
App Store Connect:
- [ ] アプリ基本情報入力
- [ ] スクリーンショット アップロード
- [ ] 説明・キーワード入力
- [ ] 価格設定
- [ ] プライバシー ポリシー入力
- [ ] 利用規約 入力

Google Play Console:
- [ ] ストア情報 入力
- [ ] アプリ スクリーンショット
- [ ] 説明テキスト
- [ ] カテゴリ・コンテンツレーティング
- [ ] プライバシー ポリシー
```

### 段階 6: リリース前 確認

```
品質確認:
- [ ] 全ユニットテスト合格
- [ ] Lint チェック: 0 エラー
- [ ] Format チェック: 通過
- [ ] ビルド警告: 0 件

機能確認:
- [ ] ログイン/登録
- [ ] タスク管理 (CRUD)
- [ ] グループ機能
- [ ] 購入フロー
- [ ] 通知機能
- [ ] 設定画面

デバイス確認:
- [ ] iPhone (最新 2 機種)
- [ ] Android (最新 2 機種)
- [ ] タブレット (オプション)
```

---

## 📅 推奨タイムライン

### Week 1: 開発環境準備
- [ ] Firebase プロジェクト作成
- [ ] RevenueCat アカウント設定
- [ ] ビルド署名準備
- [ ] ローカル テスト環境構築

### Week 2: テスト・検証
- [ ] ユニット/ウィジェット テスト実行
- [ ] E2E テスト実装・実行
- [ ] ストア テスト環境でテスト購入
- [ ] 不具合修正

### Week 3: ストア提出準備
- [ ] スクリーンショット・説明文 完成
- [ ] プライバシー ポリシー・利用規約 完成
- [ ] App Store Connect にビルド アップロード
- [ ] Google Play Console にビルド アップロード

### Week 4: リリース
- [ ] Apple 審査対応
- [ ] Google Play 自動承認確認
- [ ] リリース実行
- [ ] ユーザー対応体制 準備

---

## 🔗 関連ドキュメント

```
lib/firebase_options.dart          ← Firebase 認証情報テンプレート
DEPLOYMENT.md                      ← 全体デプロイメント ガイド
docs/REVENUE_CAT_SETUP.md          ← RevenueCat 統合詳細ガイド
```

---

## ⚠️ 注意事項

1. **Firebase Options**
   - 絶対に .gitignore を外さない (本番環境)
   - テンプレートに実際の認証情報を入力すること

2. **API Keys**
   - RevenueCat キー を絶対に公開しない
   - `.env` ファイルは `.gitignore` に含めること

3. **ビルド署名**
   - Android Keystore ファイルを安全に保管
   - iOS 証明書の有効期限を監視

4. **テスト環境**
   - Sandbox 環境で充分にテスト
   - 本番環境では最小限の変更のみ

---

## 🆘 トラブルシューティング

**Q: Firebase 接続エラー?**  
A: `firebase_options.dart` の API キーと projectId を確認

**Q: 購入画面が表示されない?**  
A: Product IDs が RevenueCat・ストアと一致しているか確認

**Q: ビルド失敗?**  
A: `flutter pub get` → `flutter clean` → 再ビルド

**Q: テスト購入ができない?**  
A: テストアカウントが正しく登録・ログインされているか確認

---

## ✅ 最終確認

**リリース前にこれを実行:**

```bash
# コード品質確認
flutter analyze

# フォーマット確認
dart format . --set-exit-if-changed

# テスト実行
flutter test

# 本番ビルド作成
flutter build appbundle --release     # Android
flutter build ios --release           # iOS
```

**リリース準備ができたら:**
1. App Store に提出
2. Google Play に提出
3. 承認待機
4. リリース実行
5. ユーザー サポート開始

---

**最後の確認**: すべてのチェックボックスが完了したら、本番リリースの準備完了です! 🎉
