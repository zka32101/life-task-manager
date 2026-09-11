# Week 3: ビルド・署名完全ガイド

> **対象**: LifeTask Manager 1.0.0+1  
> **実行環境**: ローカル開発マシン（Xcode, Android Studio）  
> **推定時間**: 4-5時間  
> **前提条件**: Week 1-2 完了

---

## 📋 Week 3 全体スケジュール

```
[1] iOS リリースビルド・署名       (90分)
[2] Android リリースビルド・署名   (60分)
[3] ビルドサイズ最適化             (30分)
[4] ビルド検証・品質確認           (45分)
```

---

## [1] iOS リリースビルド・署名 (90分)

### 1.1 前提条件確認

```bash
# Xcode インストール確認
xcode-select --install

# Xcode パス確認
xcode-select -p
# 出力例: /Applications/Xcode.app/Contents/Developer

# CocoaPods インストール確認
pod --version
# 出力例: 1.12.1
```

### 1.2 Apple Developer Account 準備

#### 1.2.1 Team ID 確認

1. [Apple Developer](https://developer.apple.com/) にサインイン
2. **Membership** → **Team ID** をコピー
3. 例: `ABC123XY4Z`

#### 1.2.2 App ID 登録（初回のみ）

1. **Certificates, IDs & Profiles** → **Identifiers**
2. **+** ボタンをクリック
3. **App ID** を選択
4. **Bundle ID**: `com.petitworks.apps.lifetaskmanager`
5. **Capabilities**: Push Notifications を有効化
6. **Register** をクリック

#### 1.2.3 署名証明書の取得

**方法 A: Xcode 自動管理（推奨）**
```bash
# ios/Runner.xcworkspace を開く
open ios/Runner.xcworkspace

# Xcode で自動署名を有効化
# Runner → Signing & Capabilities
# ☑️ Automatically manage signing
# Team: 自分のチーム選択
```

**方法 B: 手動署名**

1. Keychain Access アプリを開く
2. **Keychain Access** → **Certificate Assistant** → **Request a Certificate from a Certificate Authority**
3. CSR ファイルを保存
4. Apple Developer サイトで証明書作成
5. Keychain に追加

### 1.3 プロビジョニングプロファイル作成

1. **Apple Developer** → **Profiles**
2. **+** ボタン
3. **App Store** を選択
4. **App ID**: `com.petitworks.apps.lifetaskmanager`
5. **Certificates**: 作成した証明書を選択
6. **Devices**: すべて（App Store は無制限）
7. **Download** → Xcode に追加

### 1.4 Xcode 署名設定

```bash
cd ios/
open Runner.xcworkspace
```

**Xcode での設定:**

1. Runner プロジェクト → Runner (Target)
2. **Signing & Capabilities** タブ
3. 以下を確認:
   - ☑️ Automatically manage signing
   - **Team**: 自分のチーム
   - **Bundle Identifier**: `com.petitworks.apps.lifetaskmanager`

### 1.5 Release ビルド作成

```bash
cd /path/to/life-task-manager

# Flutter iOS Release ビルド
flutter build ios --release

# ビルド確認（10-15分）
ls -la build/ios/iphoneos/

# 出力例:
# -rw-r--r-- Runner.app/
```

### 1.6 Archive 作成

```bash
cd ios/

# xcodebuild で Archive 作成
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -archivePath ~/Desktop/Runner.xcarchive \
  archive

# Archive 確認
ls -la ~/Desktop/Runner.xcarchive/
```

### 1.7 ExportOptions.plist 作成

**ファイル**: `ios/ExportOptions.plist`

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

**YOUR_TEAM_ID を置き換える:**
```bash
# Apple Developer から Team ID をコピー
# 例: ABC123XY4Z
```

### 1.8 IPA ファイル出力

```bash
cd ios/

# IPA ファイルを生成
xcodebuild -exportArchive \
  -archivePath ~/Desktop/Runner.xcarchive \
  -exportOptionsPlist ios/ExportOptions.plist \
  -exportPath ~/Desktop/ipa_export/

# IPA 確認
ls -lh ~/Desktop/ipa_export/
# 出力例: Runner.ipa (45.2M)

# IPA をメインディレクトリにコピー
cp ~/Desktop/ipa_export/Runner.ipa build/ipa/
```

### 1.9 署名検証

```bash
# IPA の署名を確認
codesign -vv build/ipa/Runner.ipa

# 出力例:
# Signing Certificate information
# Authority=Apple Distribution: ... (TEAM ID)
```

### 1.10 iOS ビルド チェックリスト

```
✅ Xcode インストール: 確認
✅ Apple Developer Account: 準備完了
✅ Bundle ID: com.petitworks.apps.lifetaskmanager
✅ 署名証明書: 取得完了
✅ プロビジョニングプロファイル: 作成完了
✅ Xcode 署名設定: 完了
✅ Release ビルド: 成功 (flutter build ios --release)
✅ Archive 作成: 成功
✅ ExportOptions.plist: 作成
✅ IPA ファイル: 出力完了 (~45MB)
✅ 署名検証: 成功
```

---

## [2] Android リリースビルド・署名 (60分)

### 2.1 キーストア作成（初回のみ）

```bash
# キーストア生成（自宅ディレクトリ）
keytool -genkey -v -keystore ~/lifetask-release.keystore \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10950 \
  -alias lifetask-key

# プロンプト:
# Enter keystore password: [設定するパスワード]
# Re-enter new password: [再入力]
# What is your first and last name? Petitworks App
# What is the name of your organizational unit? Development
# What is the name of your organization? Petitworks
# What is the name of your City or Locality? Tokyo
# What is the name of your State or Province? Tokyo
# What is the two-letter country code? JP
# Is CN=..., OU=...? yes
# Enter key password for <lifetask-key>: [同じパスワード]
```

**重要:** パスワードを安全に保管してください！

### 2.2 キーストア確認

```bash
# キーストア情報を確認
keytool -list -v -keystore ~/lifetask-release.keystore

# 出力例:
# Keystore type: PKCS12
# Keystore provider: SunJSSE
# ...
# Alias name: lifetask-key
# Creation date: Sep 11, 2026
# ...
```

### 2.3 android/key.properties 作成

**ファイル**: `android/key.properties`

```properties
storeFile=~/lifetask-release.keystore
storePassword=YOUR_STORE_PASSWORD
keyAlias=lifetask-key
keyPassword=YOUR_KEY_PASSWORD
```

**セキュリティ設定:**
```bash
# .gitignore に追加
echo "android/key.properties" >> .gitignore

# ファイルパーミッション
chmod 600 android/key.properties

# git で追跡しない確認
git check-ignore android/key.properties
# 出力: android/key.properties
```

### 2.4 build.gradle 署名設定

**ファイル**: `android/app/build.gradle`

既に設定されているか確認:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    compileSdkVersion 34

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
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
```

### 2.5 Release ビルド作成

```bash
cd /path/to/life-task-manager

# App Bundle 生成（Google Play 推奨）
flutter build appbundle --release

# ビルド確認（10-15分）
ls -lh build/app/outputs/bundle/release/

# 出力例:
# app-release.aab (28.5M)
```

### 2.6 APK 生成（テスト用）

```bash
# テスト用 APK 生成
flutter build apk --release

# ファイル確認
ls -lh build/app/outputs/flutter-apk/

# 出力例:
# app-release.apk (45.2M)
```

### 2.7 署名検証

```bash
# AAB ファイルの署名を確認
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab

# または APK
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk

# 出力例:
# jar verified. This jar contains entries whose certificate chain is not validated.
```

### 2.8 AndroidManifest 確認

```bash
# APK の内容を確認
aapt dump badging build/app/outputs/flutter-apk/app-release.apk | head -20

# 出力例:
# package: name='com.petitworks.apps.lifetaskmanager' versionCode='1' versionName='1.0.0'
# sdkVersion:'21'
# maxSdkVersion:'33'
```

### 2.9 Android ビルド チェックリスト

```
✅ keytool インストール: 確認
✅ キーストア作成: 完了
✅ キーストア確認: 成功
✅ android/key.properties: 作成
✅ .gitignore 追加: 完了
✅ build.gradle 署名設定: 確認
✅ Release ビルド: 成功 (flutter build appbundle)
✅ App Bundle: 出力完了 (~28MB)
✅ APK 生成: 完了 (~45MB)
✅ 署名検証: 成功
✅ AndroidManifest: 確認済み
```

---

## [3] ビルドサイズ最適化 (30分)

### 3.1 iOS ビルドサイズ削減

```bash
# Bitcode を無効化
flutter build ios --release --no-bitcode

# ARM64 アーキテクチャのみ
flutter build ios --release --ios-arch=arm64

# サイズ確認
du -sh build/ios/iphoneos/Runner.app
```

### 3.2 Android ビルドサイズ削減

**ProGuard ルール**: `android/app/proguard-rules.pro`

```pro
# Firebase
-keep class com.firebase.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn com.firebase.**
-dontwarn com.google.firebase.**

# Riverpod
-keepclasseswithmembernames class * {
    native <methods>;
}

# JSON Serialization
-keepclasseswithmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Flutter
-keep class io.flutter.** { *; }
-keep class com.google.flutter.** { *; }

# 混淆パッケージ除外
-keep class com.android.** { *; }
```

**build.gradle での設定:**

```gradle
buildTypes {
    release {
        signingConfig signingConfigs.release
        shrinkResources true
        minifyEnabled true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        
        // 追加最適化
        debuggable false
        ndk {
            debugSymbolLevel 'full'
        }
    }
}
```

### 3.3 ビルドサイズ確認

```bash
# iOS サイズ
ls -lh build/ios/iphoneos/Runner.app/
# 推定: 45-55MB

# Android サイズ
ls -lh build/app/outputs/bundle/release/app-release.aab
# 推定: 25-35MB

# APK サイズ
ls -lh build/app/outputs/flutter-apk/app-release.apk
# 推定: 40-50MB
```

**目標:**
- iOS: < 60MB
- Android: < 40MB

---

## [4] ビルド検証・品質確認 (45分)

### 4.1 バージョン確認

```bash
# pubspec.yaml からバージョン確認
grep version pubspec.yaml
# 出力例: version: 1.0.0+1

# iOS のバージョン・ビルド番号
grep MARKETING_VERSION ios/Runner.xcodeproj/project.pbxproj
# 出力例: MARKETING_VERSION = 1.0.0
# CURRENT_PROJECT_VERSION = 1
```

### 4.2 ビルド署名確認（iOS）

```bash
# IPA の署名を詳細確認
codesign -dvv build/ipa/Runner.ipa

# 出力例:
# Authority=Apple Distribution: Petitworks Inc (ABC123XY4Z)
# Team ID: ABC123XY4Z
# Signing Certificate: Apple Distribution
```

### 4.3 ビルド署名確認（Android）

```bash
# APK の署名情報
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk

# または zipalign で確認
zipalign -c -v 4 build/app/outputs/flutter-apk/app-release.apk

# 出力例:
# Verification successful
# Aligned at 4-byte boundaries
```

### 4.4 ローカルテストビルド

```bash
# iOS: 実デバイスに直接インストール
ios-deploy --bundle build/ios/iphoneos/Runner.app

# または Xcode 経由
xcodebuild -allowProvisioningUpdates -scheme Runner -workspace ios/Runner.xcworkspace -configuration Release

# Android: 実デバイスに APK インストール
adb install -r build/app/outputs/flutter-apk/app-release.apk

# アプリ起動確認
adb shell am start -n com.petitworks.apps.lifetaskmanager/.MainActivity
```

### 4.5 リリース前最終チェック

```
✅ コード品質
   ☑️ flutter analyze: エラー 0
   ☑️ dart format: フォーマット確認
   ☑️ flutter test: 全テスト合格

✅ ビルド設定
   ☑️ firebase_options.dart: 本番設定
   ☑️ .env: API キー設定
   ☑️ iOS Bundle ID: com.petitworks.apps.lifetaskmanager
   ☑️ Android Package Name: com.petitworks.apps.lifetaskmanager

✅ ビルドファイル
   ☑️ iOS IPA: build/ipa/Runner.ipa (~45-55MB)
   ☑️ Android AAB: build/app/outputs/bundle/release/app-release.aab (~25-35MB)
   ☑️ Android APK: build/app/outputs/flutter-apk/app-release.apk (~40-50MB)

✅ 署名検証
   ☑️ iOS IPA: 署名確認済み（Apple Distribution）
   ☑️ Android APK: 署名確認済み（Release キーストア）

✅ バージョン確認
   ☑️ App Version: 1.0.0
   ☑️ Build Number: 1
   ☑️ iOS: Version 1.0.0, Build 1
   ☑️ Android: versionCode 1, versionName 1.0.0

✅ 実デバイステスト
   ☑️ iOS: アプリ起動・基本機能確認
   ☑️ Android: アプリ起動・基本機能確認
   ☑️ クラッシュなし
```

---

## 🎯 Week 3 完了チェックリスト

```
✅ [1] iOS リリースビルド・署名
    ✓ Apple Developer Account: 準備完了
    ✓ 署名証明書・プロビジョニングプロファイル: 取得
    ✓ IPA ファイル生成: 成功
    ✓ 署名検証: 成功

✅ [2] Android リリースビルド・署名
    ✓ キーストア作成: 完了
    ✓ key.properties 設定: 完了
    ✓ App Bundle 生成: 成功
    ✓ APK 生成: 成功
    ✓ 署名検証: 成功

✅ [3] ビルドサイズ最適化
    ✓ iOS: < 60MB
    ✓ Android: < 40MB

✅ [4] ビルド検証・品質確認
    ✓ バージョン確認: 1.0.0+1
    ✓ 署名検証: 完了
    ✓ ローカルテスト: 成功
    ✓ リリース前最終チェック: 完了
```

---

## 🚀 次のステップ

Week 3 完了後:

```
[Week 4] ストア配信
    ✅ App Store Connect アップロード
    ✅ TestFlight ベータテスト
    ✅ Google Play Console アップロード
    ✅ リリース実行
    ✅ ユーザー対応開始
```

---

## ⚠️ トラブルシューティング

### iOS ビルド失敗

```bash
# Pod キャッシュクリア
cd ios/
rm -rf Pods/ Podfile.lock
pod install
cd ..

# Flutter クリーン
flutter clean
flutter pub get

# 再ビルド
flutter build ios --release
```

### 署名エラー

```
error: provisioning profile was not found
```

**解決:**
```bash
# Xcode でプロビジョニングプロファイルをリセット
xcode-select --reset

# または Xcode を再起動
killall Xcode
open -a Xcode
```

### Android キーストア パスワード忘却

```
⚠️ キーストアは再生成不可

新しいキーストアを作成する必要があります
（新しいバージョンリリース時のみ）

バックアップ:
cp ~/lifetask-release.keystore ~/lifetask-release-backup.keystore
```

### ビルドサイズが大きい

```bash
# サイズ分析
flutter pub run devtools

# 不要なアセット削除
grep -r "assets" pubspec.yaml

# ProGuard ルール確認
cat android/app/proguard-rules.pro
```

---

**最後の確認**: iOS IPA と Android AAB が生成され、すべての署名検証が成功したら、Week 3 完成です。  
**次へ進むには**: git でコミット・プッシュして、Week 4 ストア配信に進みます。
