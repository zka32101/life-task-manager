/**
 * LifeTask Manager - 最小アセット画像生成用プロンプト生成
 * 28枚（アイコン・UI要素） Leonardo.ai 用
 *
 * 出力形式: seed_data.json に各画像のプロンプト/negativePrompt を記載
 */

const fs = require('fs');
const path = require('path');

// 出力ディレクトリ
const OUTPUT_DIR = path.join(__dirname, 'generated');
const SEED_DATA_FILE = path.join(__dirname, 'seed_data.json');

// ===== アセット定義 =====

// 1. 法定期限アイコン（8種） - 512×512、透明背景、等線画スタイル
const DEADLINE_ICONS = [
  {
    id: 'icon_inheritance',
    name: '相続期限',
    prompt: 'Icon of family inheritance, legal document with family tree symbol, minimalist line art, transparent background, flat design, business style, 512x512',
    negativePrompt: 'realistic, photo, person, text, watermark, low quality'
  },
  {
    id: 'icon_tax',
    name: '税務期限',
    prompt: 'Icon of tax deadline, calculator and money symbol combined, minimalist line art, transparent background, flat design, accounting style, 512x512',
    negativePrompt: 'realistic, photo, person, text, watermark, low quality'
  },
  {
    id: 'icon_insurance',
    name: '保険期限',
    prompt: 'Icon of insurance renewal, shield with checkmark, minimalist line art, transparent background, flat design, protection style, 512x512',
    negativePrompt: 'realistic, photo, person, text, watermark, low quality'
  },
  {
    id: 'icon_license',
    name: '免許期限',
    prompt: 'Icon of driver license or certificate, ID card symbol, minimalist line art, transparent background, flat design, identification style, 512x512',
    negativePrompt: 'realistic, photo, person, text, watermark, low quality'
  },
  {
    id: 'icon_divorce',
    name: '離婚期限',
    prompt: 'Icon of legal agreement or contract, documents with seal symbol, minimalist line art, transparent background, flat design, legal style, 512x512',
    negativePrompt: 'realistic, photo, person, text, watermark, low quality'
  },
  {
    id: 'icon_contract',
    name: '契約期限',
    prompt: 'Icon of contract signature, pen on document, minimalist line art, transparent background, flat design, business style, 512x512',
    negativePrompt: 'realistic, photo, person, text, watermark, low quality'
  },
  {
    id: 'icon_renewal',
    name: '更新期限',
    prompt: 'Icon of renewal or refresh, circular arrow symbol, minimalist line art, transparent background, flat design, modern style, 512x512',
    negativePrompt: 'realistic, photo, person, text, watermark, low quality'
  },
  {
    id: 'icon_application',
    name: '申請期限',
    prompt: 'Icon of application or registration, form with checkmark, minimalist line art, transparent background, flat design, administrative style, 512x512',
    negativePrompt: 'realistic, photo, person, text, watermark, low quality'
  }
];

// 2. 期限ステータスバッジ（3種） - 512×512、円形
const STATUS_BADGES = [
  {
    id: 'badge_warning',
    name: '⚠️ 要注意',
    prompt: 'Round badge icon, yellow and orange warning symbol, alert sign with exclamation mark, minimalist design, transparent background, 512x512, flat UI style',
    negativePrompt: 'realistic, photo, text, watermark, low quality'
  },
  {
    id: 'badge_overdue',
    name: '🔴 期限超過',
    prompt: 'Round badge icon, red urgent/overdue symbol, alert indicator, minimalist design, transparent background, 512x512, flat UI style',
    negativePrompt: 'realistic, photo, text, watermark, low quality'
  },
  {
    id: 'badge_completed',
    name: '✅ 完了',
    prompt: 'Round badge icon, green checkmark symbol, success indicator, minimalist design, transparent background, 512x512, flat UI style',
    negativePrompt: 'realistic, photo, text, watermark, low quality'
  }
];

// 3. 書類カメラ UI（4種）
const DOCUMENT_CAMERA = [
  {
    id: 'camera_frame',
    name: 'カメラフレーム',
    prompt: 'Minimalist camera viewfinder frame, document scanning rectangle border, clean lines, transparent background, UI element, flat design, 512x512',
    negativePrompt: 'realistic, photo, person, text, watermark, low quality'
  },
  {
    id: 'camera_correct',
    name: '正位置ガイド',
    prompt: 'Camera position guide, document aligned correctly, green checkmark overlay, minimalist flat design, transparent background, 512x512, instruction icon',
    negativePrompt: 'realistic, photo, person, text, watermark, low quality'
  },
  {
    id: 'camera_tilt_warning',
    name: '傾き警告',
    prompt: 'Camera tilt warning icon, document tilted at angle with red warning symbol, minimalist flat design, transparent background, 512x512, alert style',
    negativePrompt: 'realistic, photo, person, text, watermark, low quality'
  },
  {
    id: 'camera_extraction',
    name: '抽出結果表示',
    prompt: 'Document text extraction highlight, data fields marked with boxes, clean minimalist design, transparent background, 512x512, flat UI style',
    negativePrompt: 'realistic, photo, person, text, watermark, low quality'
  }
];

// 4. ストリーク関連（6種）
const STREAK_ASSETS = [
  {
    id: 'mascot_silhouette',
    name: 'マスコット基本形',
    prompt: 'Simple mascot character silhouette, friendly abstract figure, flat design, minimalist style, transparent background, 512x512, suitable for app icon, neutral pose',
    negativePrompt: 'realistic, photo, detailed face, text, watermark, low quality'
  },
  {
    id: 'flame_icon',
    name: 'ストリーク炎アイコン',
    prompt: 'Fire flame icon for streak counter, orange and yellow gradient flame shape, flat design, minimalist, transparent background, 512x512, celebratory style',
    negativePrompt: 'realistic, photo, text, watermark, low quality'
  },
  {
    id: 'milestone_7day',
    name: 'ミルストーン 7日',
    prompt: 'Milestone badge for 7-day streak, number 7 with trophy or star, celebratory design, flat UI, transparent background, 512x512, gold accent color',
    negativePrompt: 'realistic, photo, text, watermark, low quality'
  },
  {
    id: 'milestone_30day',
    name: 'ミルストーン 30日',
    prompt: 'Milestone badge for 30-day streak, number 30 with crown or medal, celebratory design, flat UI, transparent background, 512x512, premium gold style',
    negativePrompt: 'realistic, photo, text, watermark, low quality'
  },
  {
    id: 'milestone_100day',
    name: 'ミルストーン 100日',
    prompt: 'Milestone badge for 100-day streak, number 100 with premium trophy or star burst, grand celebratory design, flat UI, transparent background, 512x512, golden shine',
    negativePrompt: 'realistic, photo, text, watermark, low quality'
  }
];

// 5. 共通 UI（7種）
const COMMON_UI = [
  {
    id: 'bg_gradient_1',
    name: 'グラデーション背景 1',
    prompt: 'Subtle gradient background, blue to purple colors, smooth transition, minimalist design, 512x512, flat design, modern aesthetic',
    negativePrompt: 'realistic, photo, texture, text, watermark, low quality'
  },
  {
    id: 'bg_gradient_2',
    name: 'グラデーション背景 2',
    prompt: 'Subtle gradient background, green to teal colors, smooth transition, minimalist design, 512x512, flat design, calm aesthetic',
    negativePrompt: 'realistic, photo, texture, text, watermark, low quality'
  },
  {
    id: 'bg_gradient_3',
    name: 'グラデーション背景 3',
    prompt: 'Subtle gradient background, warm orange to pink colors, smooth transition, minimalist design, 512x512, flat design, energetic aesthetic',
    negativePrompt: 'realistic, photo, texture, text, watermark, low quality'
  },
  {
    id: 'btn_state_default',
    name: 'ボタン状態 - デフォルト',
    prompt: 'Button UI element, default state, rounded corners, subtle shadow, blue color, flat design, 512x512, interactive element',
    negativePrompt: 'realistic, photo, text, watermark, low quality'
  },
  {
    id: 'btn_state_hover',
    name: 'ボタン状態 - ホバー',
    prompt: 'Button UI element, hover state, rounded corners, enhanced shadow, blue darker shade, flat design, 512x512, interactive element',
    negativePrompt: 'realistic, photo, text, watermark, low quality'
  },
  {
    id: 'btn_state_active',
    name: 'ボタン状態 - アクティブ',
    prompt: 'Button UI element, active/pressed state, rounded corners, inset shadow, blue darkest shade, flat design, 512x512, interactive element',
    negativePrompt: 'realistic, photo, text, watermark, low quality'
  },
  {
    id: 'btn_state_disabled',
    name: 'ボタン状態 - ディセーブル',
    prompt: 'Button UI element, disabled state, rounded corners, gray color, subtle appearance, flat design, 512x512, inactive element',
    negativePrompt: 'realistic, photo, text, watermark, low quality'
  }
];

// ===== データ統合 =====

const allAssets = [
  ...DEADLINE_ICONS,
  ...STATUS_BADGES,
  ...DOCUMENT_CAMERA,
  ...STREAK_ASSETS,
  ...COMMON_UI
];

console.log(`📊 LifeTask Manager 最小アセット生成セット`);
console.log(`✅ 合計: ${allAssets.length} 枚`);
console.log(`  - 法定期限アイコン: ${DEADLINE_ICONS.length} 枚`);
console.log(`  - ステータスバッジ: ${STATUS_BADGES.length} 枚`);
console.log(`  - 書類カメラ UI: ${DOCUMENT_CAMERA.length} 枚`);
console.log(`  - ストリーク資産: ${STREAK_ASSETS.length} 枚`);
console.log(`  - 共通 UI: ${COMMON_UI.length} 枚`);
console.log(`\n💾 出力ファイル: ${SEED_DATA_FILE}`);

// seed_data.json を生成
if (!fs.existsSync(OUTPUT_DIR)) {
  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
}

fs.writeFileSync(SEED_DATA_FILE, JSON.stringify(allAssets, null, 2), 'utf-8');

console.log(`✅ seed_data.json 生成完了`);
console.log(`\n📝 次のステップ:`);
console.log(`1. node generate_leonardo.js --sample     # サンプル 2 枚生成して品質確認`);
console.log(`2. node generate_leonardo.js --all        # 全 28 枚生成`);
