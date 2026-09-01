# 本番ビルド・署名設定ガイド

> **最終確認日**: 2026-09-01  
> **LifeTask Manager バージョン**: 1.0.0+1  
> **Phase**: 2-7 デプロイメント準備

## 概要

本番ビルドは、アプリを App Store と Google Play に配布するための最終成果物です。このガイドではコード署名、ビルド設定、デバイステストまでを網羅します。

**主要成果物:**
- **iOS**: `.ipa` ファイル（App Store Connect アップロード用）
- **Android**: `.aab` ファイル（Google Play アップロード用）

---

## 1. iOS 本番ビルド

### 1.1 前提条件

```bash
# Xcode インストール確認
xcode-select --install

# Xcode のパス確認
xcode-select -p

# iOS 関連ファイル確認
ls -la ios/
```

### 1.2 証明書・プロビジョニングプロファイル取得

#### 1.2.1 Apple Developer Account

1. [Apple Developer](https://developer.apple.com/) にサインイン
2. Account → Certificates, IDs & Profiles

#### 1.2.2 App ID 作成

1. **Identifiers** → **+**
2. **App ID** 選択
3. **Bundle ID**: `com.petitworks.apps.lifetaskmanager`
4. **Capabilities**: Push Notifications 有効化
5. **Register**

#### 1.2.3 署名証明書 (CSR から生成)

1. **Certificates** → **+** → **Apple Distribution**
2. CSR ファイルをアップロード（macOS Keychain で生成）
3. ダウンロード → Keychain に追加

**CSR 作成手順（初回）:**

```bash
# キーチェーンアクセス.app → 証明書アシスタント → CSR ファイルを要求
# または openssl で生成:

openssl req -new -keyout server.key -out server.csr \
  -subj "/C=JP/ST=Tokyo/L=Tokyo/O=Petitworks/CN=*.lifetaskmanager.com"
```

#### 1.2.4 プロビジョニングプロファイル作成

1. **Profiles** → **+** → **App Store**
2. **App ID**: `com.petitworks.apps.lifetaskmanager`
3. **Certificates**: 上記で作成した証明書を選択
4. **Devices**: すべて選択（App Store は制限なし）
5. **Download**

### 1.3 Xcode 署名設定

```bash
cd ios/

# Runner プロジェクトを開く
open Runner.xcworkspace
```

**Xcode 設定:**

1. Runner → Runner (プロジェクト) → Target → Runner
2. **Signing & Capabilities** タブ
3. **Team**: 自分のチーム選択
4. **Bundle Identifier**: `com.petitworks.apps.lifetaskmanager`
5. **Signing Certificate**: Automatic を選択
6. **Provisioning Profile**: 上記で作成したプロファイルを自動選択

### 1.4 Release ビルド作成

```bash
# Flutter ビルド（iOS）
flutter build ios --release

# 本番ビルド確認
ls -la build/ios/iphoneos/
```

### 1.5 Archive 作成（xcodebuild）

```bash
cd ios/

# Archive パスを指定
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -archivePath build/Runner.xcarchive \
  archive

# Archive 確認
ls -la build/Runner.xcarchive/
```

### 1.6 IPA 出力

```bash
# xcodebuild で IPA を生成
xcodebuild -exportArchive \
  -archivePath build/Runner.xcarchive \
  -exportOptionsPlist ios/ExportOptions.plist \
  -exportPath build/ipa/

# IPA 確認
ls -la build/ipa/
```

**ExportOptions.plist 作成:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    
    <key>signingStyle</key>
    <string>automatic</string>
    
    <key>stripSwiftSymbols</key>
    <true/>
    
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
```

---

## 2. Android 本番ビルド

### 2.1 キーストア作成（初回のみ）

```bash
# キーストア生成
keytool -genkey -v -keystore ~/lifetask-release.keystore \
  -keyalg RSA -keysize 2048 -validity 10950 \
  -alias lifetask-key

# パスワード設定（重要: 記録しておく）
# 何度も入力されるので同じパスワードを使用

# キーストア確認
keytool -list -v -keystore ~/lifetask-release.keystore
```

**キーストア情報:**
- **File**: `~/lifetask-release.keystore`
- **Store Password**: [安全に保管]
- **Key Alias**: `lifetask-key`
- **Key Password**: [安全に保管]

### 2.2 署名設定ファイル

**ファイル**: `android/key.properties`

```properties
storeFile=../lifetask-release.keystore
storePassword=YOUR_STORE_PASSWORD
keyAlias=lifetask-key
keyPassword=YOUR_KEY_PASSWORD
```

**セキュリティ注意:**

```bash
# .gitignore に追加（認証情報保護）
echo "android/key.properties" >> .gitignore

# ファイルパーミッション設定
chmod 600 android/key.properties
```

### 2.3 build.gradle 設定

**ファイル**: `android/app/build.gradle`

```gradle
android {
    compileSdkVersion 34

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? \
                file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            shrinkResources true
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}

// key.properties を読み込む
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

### 2.4 Release ビルド作成

```bash
# App Bundle 生成（Google Play に推奨）
flutter build appbundle --release

# ファイル確認
ls -la build/app/outputs/bundle/release/
```

**出力ファイル:**
```
build/app/outputs/bundle/release/app-release.aab
```

### 2.5 内部テスト用 APK 生成（オプション）

```bash
# APK 生成（Play Console に直接アップロードはできないが、テスト用）
flutter build apk --release

# ファイル確認
ls -la build/app/outputs/flutter-apk/
```

---

## 3. ビルド最適化

### 3.1 APK サイズ最適化

**ProGuard ルール**: `android/app/proguard-rules.pro`

```
# Firebase
-keep class com.firebase.** { *; }
-keep class com.google.firebase.** { *; }

# Riverpod
-keepclasseswithmembernames class * {
    native <methods>;
}

# JSON Serialization
-keepclasseswithmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
```

### 3.2 iOS ビルドサイズ削減

```bash
# 不要な Bitcode を削除
flutter build ios --release --no-bitcode

# Dynamic Framework を使用
flutter build ios --release --ios-arch=arm64
```

### 3.3 ビルドサイズ確認

```bash
# Android
ls -lh build/app/outputs/bundle/release/app-release.aab
# 推定ダウンロードサイズ: 30-50MB

# iOS
ls -lh build/ios/iphoneos/Runner.app
# 推定ダウンロードサイズ: 40-60MB
```

---

## 4. デバイステスト

### 4.1 Android テストデバイス

```bash
# テストデバイス一覧
adb devices

# デバイスに APK をインストール（テスト用）
adb install build/app/outputs/flutter-apk/app-release.apk

# アプリ起動
adb shell am start -n com.petitworks.apps.lifetaskmanager/.MainActivity

# ログ確認
adb logcat | grep flutter
```

### 4.2 iOS テストデバイス

```bash
# 接続デバイス一覧
xcrun xctrace list devices

# 実デバイスで実行
flutter run --release -d <UDID>

# コンソールログ確認
ios/Runner/Runner.xcworkspace
```

### 4.3 機能チェックリスト

本番デバイスで以下を確認:

```
✅ ログイン・ユーザー登録
✅ タスク作成・編集・削除
✅ グループ管理・招待
✅ プッシュ通知受信
✅ 購入フロー
✅ 言語設定（日本語・英語）
✅ オフライン動作
✅ クラッシュ時の復帰
✅ バッテリー消費
✅ ネットワーク変更（WiFi ↔ モバイル）
```

---

## 5. ビルド検証

### 5.1 iOS ビルド検証

```bash
# Xcode でビルド検証
xcodebuild -scheme Runner \
  -configuration Release \
  -derivedDataPath build/ \
  -sdk iphoneos analyze

# IPA 署名確認
codesign -vv build/ipa/Runner.ipa
```

### 5.2 Android ビルド検証

```bash
# APK/AAB 署名確認
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab

# AndroidManifest 確認
aapt dump badging build/app/outputs/flutter-apk/app-release.apk
```

### 5.3 バージョン・ビルド番号確認

```bash
# pubspec.yaml で確認
grep version: pubspec.yaml

# iOS: version + build
# 例: 1.0.0+1
# → iOS: Version 1.0.0, Build 1

# Android: versionCode + versionName
grep versionCode android/app/build.gradle
grep versionName android/app/build.gradle
```

---

## 6. リリース前チェックリスト

### Pre-Build

```
✅ コード品質チェック
  - flutter analyze (エラー: 0)
  - dart format . --set-exit-if-changed (フォーマット一致)

✅ テスト実行
  - flutter test (全テスト合格)
  - E2E テスト (全テスト合格)

✅ ビルド設定確認
  - firebase_options.dart 設定完了
  - .env / .env.production 設定完了
  - API キー・認証情報検査完了

✅ 依存パッケージ確認
  - flutter pub get
  - Lint/警告なし
```

### Build & Sign

```
✅ iOS ビルド
  - flutter build ios --release 成功
  - Xcode 署名設定完了
  - Archive 作成成功
  - IPA 出力確認

✅ Android ビルド
  - android/key.properties 設定
  - flutter build appbundle --release 成功
  - AAB ファイルサイズ確認（< 100MB）
```

### Testing & Validation

```
✅ デバイステスト
  - 実デバイスでのインストール成功
  - 主要機能 10 項目確認完了
  - パフォーマンス確認（クラッシュなし）

✅ ビルド検証
  - codesign -vv (iOS 署名確認)
  - jarsigner -verify (Android 署名確認)
  - バージョン・ビルド番号正確
```

---

## 7. トラブルシューティング

### 問題: Xcode ビルド失敗

```bash
# Pod キャッシュクリア
cd ios/
rm -rf Pods/
pod install
cd ..

# Flutter クリーン
flutter clean
flutter pub get

# 再ビルド
flutter build ios --release
```

### 問題: 署名エラー

```
error: provisioning profile was not found
```

**解決:**
```bash
# Xcode でプロビジョニングプロファイルをリセット
xcode-select --reset

# またはマニュアル設定
# Xcode → Preferences → Accounts → Team を確認
```

### 問題: Android キーストア パスワード忘却

```
キーストアは再生成不可のため、新しいキーストアを作成する必要があります
（新バージョンを配布する場合のみ）

キーストアのバックアップ:
cp ~/lifetask-release.keystore ~/lifetask-release-backup.keystore
```

### 問題: ビルドサイズ大きい

```bash
# サイズ分析
flutter pub run devtools -- --vm-service-uri=...

# 不要なアセット削除
grep -r "assets" pubspec.yaml

# ProGuard ルール確認
cat android/app/proguard-rules.pro
```

---

## 8. 環境別ビルド設定

### 8.1 Development ビルド

```bash
# デバッグビルド（自動署名）
flutter build apk --debug

# DEV Firebase を使用（.env から）
ENVIRONMENT=development flutter build apk --release
```

### 8.2 Staging ビルド

```bash
# Staging 設定
ENVIRONMENT=staging flutter build apk --release

# Staging Firebase, RevenueCat を使用
```

### 8.3 Production ビルド

```bash
# 本番設定
ENVIRONMENT=production flutter build appbundle --release

# 本番 Firebase, RevenueCat, Sentry を使用
```

---

## 参考資料

- [Flutter iOS Release Documentation](https://flutter.dev/docs/deployment/ios)
- [Flutter Android Release Documentation](https://flutter.dev/docs/deployment/android)
- [Xcode Signing Guide](https://help.apple.com/xcode/mac/current/#/dev3a05256b8)
- [Google Play App Signing](https://developer.android.com/studio/publish/app-signing)

---

**最後の確認**: 本番ビルドが作成されたら、Phase 2-8 ストア配信準備に進みます。
