# LifeTask Manager - Leonardo.ai 画像自動生成

**28枚の最小アセット（アイコン・UI要素）を Leonardo.ai で自動生成するツール**

---

## 📊 生成アセット内訳

| カテゴリ | 枚数 | 内容 |
|---------|------|------|
| **法定期限アイコン** | 8 | 相続/税務/保険/免許/離婚/契約/更新/申請 |
| **ステータスバッジ** | 3 | 要注意/期限超過/完了 |
| **書類カメラ UI** | 4 | フレーム/正位置/傾き警告/抽出結果 |
| **ストリーク資産** | 6 | マスコット/炎アイコン/ミルストーン(3種) |
| **共通 UI** | 7 | グラデーション背景(3)/ボタン状態(4) |
| **合計** | **28** | |

---

## ⚙️ 事前セットアップ

### 1. Leonardo.ai API キー取得

```
https://cloud.leonardo.ai/
→ Platform > API Access
→ API Key をコピー
```

### 2. 環境変数設定（Windows PowerShell）

```powershell
# 永続的に設定（このマシンで 1 回だけ）
[Environment]::SetEnvironmentVariable("LEONARDO_API_KEY", "your-api-key-here", "User")

# 設定確認
$k = [Environment]::GetEnvironmentVariable("LEONARDO_API_KEY", "User")
if ($k) { "✅ 設定済み" } else { "❌ 未設定" }
```

### 3. Node.js インストール確認

```bash
node --version   # v18以上推奨
npm --version
```

---

## 🚀 実行手順

### Step 1: seed_data.json を生成

```bash
cd H:/マイドライブ/apps/life-task-manager/tools/life_task_manager_image_gen
node prompt_builder.js
```

✅ 出力: `seed_data.json` （28個のプロンプト定義）

---

### Step 2: サンプル 2 枚生成（品質確認）

```bash
node generate_leonardo.js --sample
```

**期待時間**: 3-5 分

✅ 出力:
- `generated/icon_inheritance.png`
- `generated/badge_warning.png`

**品質チェック:**
- 背景は透明か？
- アイコンは判別可能か？
- リサイズ時に劣化していないか？

---

### Step 3: 全 28 枚生成

品質が OK なら全量生成：

```bash
node generate_leonardo.js --all
```

**期待時間**: 30-45 分

✅ 出力: `generated/` フォルダに 28個の PNG ファイル

---

## 📁 ファイル構成

```
life_task_manager_image_gen/
├── prompt_builder.js       # プロンプト生成
├── generate_leonardo.js    # API 呼び出し・ダウンロード
├── package.json
├── seed_data.json          # ← 自動生成される
└── generated/              # ← ここに出力される
    ├── icon_inheritance.png
    ├── badge_warning.png
    ├── camera_frame.png
    └── ... (全 28 枚)
```

---

## 🔧 オプション

```bash
# サンプル 2 枚のみ
node generate_leonardo.js --sample

# 全 28 枚（既存ファイルはスキップ）
node generate_leonardo.js --all

# 既存ファイルを上書き
node generate_leonardo.js --all --force
```

---

## 💾 生成済み画像の配置

生成が完了したら、アプリに組み込みます：

```bash
# 1. assets/images フォルダに コピー
cp generated/*.png ../../../assets/images/

# 2. pubspec.yaml に登録
# flutter:
#   assets:
#     - assets/images/icon_inheritance.png
#     - assets/images/badge_warning.png
#     - ... (全 28 枚)

# 3. Dart コードで参照
Image.asset('assets/images/icon_inheritance.png')
```

---

## 🐛 トラブルシューティング

### `LEONARDO_API_KEY が設定されていません`

```powershell
$env:LEONARDO_API_KEY = [Environment]::GetEnvironmentVariable("LEONARDO_API_KEY", "User")
node generate_leonardo.js --sample
```

### `ECONNREFUSED` または `ETIMEDOUT`

- ネットワーク接続を確認
- Leonardo.ai の API ステータス確認: https://status.leonardo.ai/
- API キーが無効になっていないか確認

### 生成が異常に遅い

- Leonardo API の負荷が高い可能性
- `waitForGeneration` の `maxWait` を 120000ms に変更

```javascript
const imageUrl = await waitForGeneration(generationId, 120000); // 2分に延長
```

---

## 💰 コスト目安

| モデル | 設定 | 1枚のコスト | 28枚合計 |
|--------|------|-----------|---------|
| Leonardo Phoenix 1.0 | alchemy:false, photoReal:false | 約 0.03 credits | 約 0.84 credits |

Leonardo.ai の無料枠: 月 150 credits / 計画

---

## 📝 次のステップ

1. ✅ seed_data.json 生成完了
2. ⏳ サンプル 2 枚生成実行 → 品質確認
3. ⏳ 全 28 枚生成実行
4. 📦 assets/images/ に配置
5. 🎨 Dart UI にアセットを組み込み

---

**作成日**: 2026-08-02  
**参考**: [leonardo-ai-image-gen スキル](../../skills/leonardo-ai-image-gen)
