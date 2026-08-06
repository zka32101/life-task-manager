/**
 * Leonardo.ai 画像生成スクリプト
 * seed_data.json から読み込んで Leonardo.ai API で画像生成
 *
 * 使用法:
 *   node generate_leonardo.js --sample    # サンプル 2 枚 (icon_inheritance, badge_warning)
 *   node generate_leonardo.js --all       # 全 28 枚生成（既存ファイルはスキップ）
 *   node generate_leonardo.js --force     # 既存ファイルを上書き
 */

const fs = require('fs');
const path = require('path');
const https = require('https');

// ===== 設定 =====

const API_KEY = process.env.LEONARDO_API_KEY;
const MODEL_ID = 'de7d3faf-762f-48e0-b3b7-9d0ac3a3fcf3'; // Leonardo Phoenix 1.0
const OUTPUT_DIR = path.join(__dirname, 'generated');
const SEED_DATA_FILE = path.join(__dirname, 'seed_data.json');

// オプション解析
const args = process.argv.slice(2);
const isSample = args.includes('--sample');
const isAll = args.includes('--all');
const isForce = args.includes('--force');

// ===== ロジック =====

if (!API_KEY) {
  console.error('❌ エラー: LEONARDO_API_KEY が設定されていません');
  console.error('   PowerShell: $env:LEONARDO_API_KEY = [Environment]::GetEnvironmentVariable("LEONARDO_API_KEY","User")');
  process.exit(1);
}

if (!fs.existsSync(SEED_DATA_FILE)) {
  console.error(`❌ エラー: ${SEED_DATA_FILE} が見つかりません`);
  console.error('   先に node prompt_builder.js を実行してください');
  process.exit(1);
}

if (!fs.existsSync(OUTPUT_DIR)) {
  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
}

const seedData = JSON.parse(fs.readFileSync(SEED_DATA_FILE, 'utf-8'));

console.log(`\n🎨 Leonardo.ai 画像生成開始`);
console.log(`📍 モデル: Phoenix 1.0`);
console.log(`📁 出力先: ${OUTPUT_DIR}`);
console.log(`🔑 API Key: ${API_KEY.substring(0, 8)}...${API_KEY.substring(-4)}`);

// サンプル or 全量の選定
let targetAssets = seedData;
if (isSample) {
  targetAssets = seedData.slice(0, 2); // 最初の 2 枚
  console.log(`\n⚡ サンプルモード: 最初の 2 枚のみ生成\n`);
} else if (isAll) {
  console.log(`\n📦 フル生成モード: ${targetAssets.length} 枚すべて生成\n`);
}

// 既存チェック（フォースオプション無い場合）
if (!isForce) {
  targetAssets = targetAssets.filter(asset => {
    const outputPath = path.join(OUTPUT_DIR, `${asset.id}.png`);
    const exists = fs.existsSync(outputPath);
    if (exists && (isSample || isAll)) {
      console.log(`⏭️  スキップ: ${asset.id} (既に存在)`);
    }
    return !exists;
  });
}

if (targetAssets.length === 0) {
  console.log(`✅ 対象ファイルがすべて存在します。`);
  if (!isForce) {
    console.log(`   再生成する場合: node generate_leonardo.js --force`);
  }
  process.exit(0);
}

console.log(`\n📋 生成対象: ${targetAssets.length} 枚\n`);

// ===== Leonardo API 呼び出し =====

async function generateImage(asset) {
  return new Promise((resolve, reject) => {
    const payload = {
      prompt: asset.prompt,
      negativePrompt: asset.negativePrompt,
      modelId: MODEL_ID,
      width: 512,
      height: 512,
      numImages: 1,
      alchemy: false,
      photoReal: false,
      guidance_scale: 7.5
    };

    const options = {
      hostname: 'api.leonardo.ai',
      port: 443,
      path: '/api/rest/v1/generations',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${API_KEY}`,
        'Content-Length': Buffer.byteLength(JSON.stringify(payload))
      }
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          if (json.generationId) {
            // 生成開始成功 → generationId を返す
            resolve(json.generationId);
          } else {
            reject(new Error(`Leonardo API エラー: ${JSON.stringify(json)}`));
          }
        } catch (e) {
          reject(new Error(`JSON パース失敗: ${data}`));
        }
      });
    });

    req.on('error', reject);
    req.write(JSON.stringify(payload));
    req.end();
  });
}

// ===== 生成結果ポーリング =====

async function waitForGeneration(generationId, maxWait = 60000) {
  const startTime = Date.now();
  const pollInterval = 2000; // 2秒ごとにポーリング

  while (Date.now() - startTime < maxWait) {
    const status = await checkGenerationStatus(generationId);

    if (status.imageUrl) {
      return status.imageUrl; // 完了
    }

    if (status.error) {
      throw new Error(`生成エラー: ${status.error}`);
    }

    // ステータスを待つ
    await new Promise(r => setTimeout(r, pollInterval));
  }

  throw new Error(`タイムアウト: ${generationId}`);
}

async function checkGenerationStatus(generationId) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'api.leonardo.ai',
      port: 443,
      path: `/api/rest/v1/generations/${generationId}`,
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${API_KEY}`
      }
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          if (json.generations && json.generations.length > 0) {
            const gen = json.generations[0];
            resolve({
              imageUrl: gen.imageUrl,
              error: gen.error
            });
          } else {
            resolve({ imageUrl: null, error: null });
          }
        } catch (e) {
          reject(new Error(`JSON パース失敗: ${data}`));
        }
      });
    });

    req.on('error', reject);
    req.end();
  });
}

// ===== 画像ダウンロード =====

async function downloadImage(url, outputPath) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(outputPath);
    https.get(url, (res) => {
      res.pipe(file);
      file.on('finish', () => {
        file.close();
        resolve();
      });
    }).on('error', reject);
  });
}

// ===== メイン処理 =====

(async () => {
  const results = {
    success: [],
    failed: []
  };

  for (let i = 0; i < targetAssets.length; i++) {
    const asset = targetAssets[i];
    const progress = `[${i + 1}/${targetAssets.length}]`;

    try {
      process.stdout.write(`${progress} 🎨 ${asset.name}... `);

      // 生成開始
      const generationId = await generateImage(asset);

      // ポーリング
      process.stdout.write(`(ID: ${generationId.substring(0, 8)}...) `);
      const imageUrl = await waitForGeneration(generationId);

      // ダウンロード
      const outputPath = path.join(OUTPUT_DIR, `${asset.id}.png`);
      await downloadImage(imageUrl, outputPath);

      console.log(`✅ ${outputPath}`);
      results.success.push(asset.id);

      // API レート制限対策（3秒待機）
      await new Promise(r => setTimeout(r, 3000));

    } catch (error) {
      console.log(`❌ エラー: ${error.message}`);
      results.failed.push({ id: asset.id, error: error.message });
    }
  }

  // ===== 結果サマリ =====

  console.log(`\n${'='.repeat(60)}`);
  console.log(`✅ 成功: ${results.success.length} 枚`);
  if (results.failed.length > 0) {
    console.log(`❌ 失敗: ${results.failed.length} 枚`);
    results.failed.forEach(f => {
      console.log(`   - ${f.id}: ${f.error}`);
    });
  }

  console.log(`\n📁 生成済みファイル: ${OUTPUT_DIR}`);
  console.log(`\n📝 次のステップ:`);
  console.log(`1. generated/ フォルダの画像をプレビュー`);
  console.log(`2. assets/images/ にコピー: cp generated/*.png ../../../assets/images/`);
  console.log(`3. pubspec.yaml に登録: assets/images/*.png`);

  process.exit(results.failed.length > 0 ? 1 : 0);
})();
