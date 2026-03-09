/// 星座定義データ.
///
/// 黄道十二星座 + メジャー星座 + マイナー星座を含む全36星座.
/// 座標は0.0〜1.0の正規化座標で、描画時にウィジェットサイズにスケーリングする.
library;

import '../models/constellation.dart';

/// 1つの星を点灯するのに必要な学習時間（分）.
const minutesPerStar = 300; // 5時間

/// 利用可能な星座一覧.
const constellations = <ConstellationDef>[
  // ========================================
  // 黄道十二星座
  // ========================================

  // おひつじ座 (Aries)
  ConstellationDef(
    id: 'aries',
    name: 'Aries',
    jaName: 'おひつじ座',
    symbol: '\u2648',
    stars: [
      StarPosition(0.20, 0.40),
      StarPosition(0.30, 0.35),
      StarPosition(0.45, 0.30),
      StarPosition(0.55, 0.35),
      StarPosition(0.65, 0.45),
      StarPosition(0.75, 0.40),
      StarPosition(0.60, 0.55),
      StarPosition(0.50, 0.60),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(2, 3),
      StarConnection(3, 4),
      StarConnection(4, 5),
      StarConnection(3, 6),
      StarConnection(6, 7),
    ],
  ),

  // おうし座 (Taurus)
  ConstellationDef(
    id: 'taurus',
    name: 'Taurus',
    jaName: 'おうし座',
    symbol: '\u2649',
    stars: [
      StarPosition(0.15, 0.55),
      StarPosition(0.25, 0.45),
      StarPosition(0.35, 0.40),
      StarPosition(0.50, 0.35),
      StarPosition(0.60, 0.25),
      StarPosition(0.70, 0.30),
      StarPosition(0.55, 0.45),
      StarPosition(0.45, 0.55),
      StarPosition(0.65, 0.50),
      StarPosition(0.75, 0.45),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(2, 3),
      StarConnection(3, 4),
      StarConnection(4, 5),
      StarConnection(3, 6),
      StarConnection(6, 7),
      StarConnection(6, 8),
      StarConnection(8, 9),
    ],
  ),

  // ふたご座 (Gemini)
  ConstellationDef(
    id: 'gemini',
    name: 'Gemini',
    jaName: 'ふたご座',
    symbol: '\u264A',
    stars: [
      StarPosition(0.30, 0.20),
      StarPosition(0.35, 0.35),
      StarPosition(0.30, 0.50),
      StarPosition(0.25, 0.65),
      StarPosition(0.60, 0.20),
      StarPosition(0.55, 0.35),
      StarPosition(0.60, 0.50),
      StarPosition(0.65, 0.65),
      StarPosition(0.45, 0.30),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(2, 3),
      StarConnection(4, 5),
      StarConnection(5, 6),
      StarConnection(6, 7),
      StarConnection(1, 8),
      StarConnection(8, 5),
    ],
  ),

  // かに座 (Cancer)
  ConstellationDef(
    id: 'cancer',
    name: 'Cancer',
    jaName: 'かに座',
    symbol: '\u264B',
    stars: [
      StarPosition(0.30, 0.35),
      StarPosition(0.40, 0.45),
      StarPosition(0.55, 0.45),
      StarPosition(0.65, 0.35),
      StarPosition(0.35, 0.55),
      StarPosition(0.60, 0.55),
      StarPosition(0.45, 0.30),
      StarPosition(0.50, 0.60),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(2, 3),
      StarConnection(1, 4),
      StarConnection(2, 5),
      StarConnection(1, 6),
      StarConnection(2, 7),
    ],
  ),

  // しし座 (Leo)
  ConstellationDef(
    id: 'leo',
    name: 'Leo',
    jaName: 'しし座',
    symbol: '\u264C',
    stars: [
      StarPosition(0.20, 0.35),
      StarPosition(0.30, 0.25),
      StarPosition(0.40, 0.20),
      StarPosition(0.50, 0.30),
      StarPosition(0.45, 0.45),
      StarPosition(0.55, 0.50),
      StarPosition(0.65, 0.45),
      StarPosition(0.70, 0.55),
      StarPosition(0.75, 0.65),
      StarPosition(0.60, 0.60),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(2, 3),
      StarConnection(3, 4),
      StarConnection(4, 5),
      StarConnection(5, 6),
      StarConnection(6, 7),
      StarConnection(7, 8),
      StarConnection(8, 9),
      StarConnection(9, 5),
    ],
  ),

  // おとめ座 (Virgo)
  ConstellationDef(
    id: 'virgo',
    name: 'Virgo',
    jaName: 'おとめ座',
    symbol: '\u264D',
    stars: [
      StarPosition(0.25, 0.30),
      StarPosition(0.35, 0.35),
      StarPosition(0.45, 0.40),
      StarPosition(0.55, 0.35),
      StarPosition(0.65, 0.30),
      StarPosition(0.50, 0.50),
      StarPosition(0.40, 0.60),
      StarPosition(0.55, 0.65),
      StarPosition(0.70, 0.50),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(2, 3),
      StarConnection(3, 4),
      StarConnection(2, 5),
      StarConnection(5, 6),
      StarConnection(5, 7),
      StarConnection(3, 8),
    ],
  ),

  // てんびん座 (Libra)
  ConstellationDef(
    id: 'libra',
    name: 'Libra',
    jaName: 'てんびん座',
    symbol: '\u264E',
    stars: [
      StarPosition(0.30, 0.30),
      StarPosition(0.50, 0.25),
      StarPosition(0.70, 0.30),
      StarPosition(0.40, 0.50),
      StarPosition(0.50, 0.45),
      StarPosition(0.60, 0.50),
      StarPosition(0.50, 0.65),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(0, 3),
      StarConnection(3, 4),
      StarConnection(4, 5),
      StarConnection(5, 2),
      StarConnection(4, 6),
    ],
  ),

  // さそり座 (Scorpius)
  ConstellationDef(
    id: 'scorpius',
    name: 'Scorpius',
    jaName: 'さそり座',
    symbol: '\u264F',
    stars: [
      StarPosition(0.15, 0.30),
      StarPosition(0.25, 0.35),
      StarPosition(0.35, 0.40),
      StarPosition(0.45, 0.45),
      StarPosition(0.55, 0.50),
      StarPosition(0.60, 0.55),
      StarPosition(0.65, 0.60),
      StarPosition(0.70, 0.55),
      StarPosition(0.75, 0.45),
      StarPosition(0.80, 0.40),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(2, 3),
      StarConnection(3, 4),
      StarConnection(4, 5),
      StarConnection(5, 6),
      StarConnection(6, 7),
      StarConnection(7, 8),
      StarConnection(8, 9),
    ],
  ),

  // いて座 (Sagittarius)
  ConstellationDef(
    id: 'sagittarius',
    name: 'Sagittarius',
    jaName: 'いて座',
    symbol: '\u2650',
    stars: [
      StarPosition(0.30, 0.25),
      StarPosition(0.40, 0.35),
      StarPosition(0.50, 0.30),
      StarPosition(0.55, 0.40),
      StarPosition(0.45, 0.50),
      StarPosition(0.60, 0.55),
      StarPosition(0.50, 0.65),
      StarPosition(0.65, 0.45),
      StarPosition(0.70, 0.35),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(2, 3),
      StarConnection(3, 4),
      StarConnection(4, 5),
      StarConnection(5, 6),
      StarConnection(3, 7),
      StarConnection(7, 8),
    ],
  ),

  // やぎ座 (Capricornus)
  ConstellationDef(
    id: 'capricornus',
    name: 'Capricornus',
    jaName: 'やぎ座',
    symbol: '\u2651',
    stars: [
      StarPosition(0.25, 0.35),
      StarPosition(0.35, 0.30),
      StarPosition(0.50, 0.25),
      StarPosition(0.65, 0.30),
      StarPosition(0.70, 0.40),
      StarPosition(0.60, 0.55),
      StarPosition(0.45, 0.60),
      StarPosition(0.30, 0.50),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(2, 3),
      StarConnection(3, 4),
      StarConnection(4, 5),
      StarConnection(5, 6),
      StarConnection(6, 7),
      StarConnection(7, 0),
    ],
  ),

  // みずがめ座 (Aquarius)
  ConstellationDef(
    id: 'aquarius',
    name: 'Aquarius',
    jaName: 'みずがめ座',
    symbol: '\u2652',
    stars: [
      StarPosition(0.20, 0.30),
      StarPosition(0.30, 0.25),
      StarPosition(0.40, 0.30),
      StarPosition(0.50, 0.25),
      StarPosition(0.55, 0.35),
      StarPosition(0.50, 0.50),
      StarPosition(0.60, 0.55),
      StarPosition(0.70, 0.60),
      StarPosition(0.65, 0.45),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(2, 3),
      StarConnection(3, 4),
      StarConnection(4, 5),
      StarConnection(5, 6),
      StarConnection(6, 7),
      StarConnection(4, 8),
    ],
  ),

  // うお座 (Pisces)
  ConstellationDef(
    id: 'pisces',
    name: 'Pisces',
    jaName: 'うお座',
    symbol: '\u2653',
    stars: [
      StarPosition(0.20, 0.40),
      StarPosition(0.25, 0.30),
      StarPosition(0.35, 0.25),
      StarPosition(0.45, 0.30),
      StarPosition(0.50, 0.40),
      StarPosition(0.55, 0.50),
      StarPosition(0.65, 0.45),
      StarPosition(0.75, 0.40),
      StarPosition(0.70, 0.55),
      StarPosition(0.60, 0.60),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(2, 3),
      StarConnection(3, 4),
      StarConnection(4, 5),
      StarConnection(5, 6),
      StarConnection(6, 7),
      StarConnection(6, 8),
      StarConnection(8, 9),
      StarConnection(9, 5),
    ],
  ),

  // ========================================
  // メジャー星座
  // ========================================

  // オリオン座 (Orion) - 冬の代表的な星座
  ConstellationDef(
    id: 'orion',
    name: 'Orion',
    jaName: 'オリオン座',
    symbol: '\u2694', // crossed swords
    stars: [
      StarPosition(0.35, 0.15), // ベテルギウス
      StarPosition(0.65, 0.15), // ベラトリックス
      StarPosition(0.40, 0.40), // 三つ星左
      StarPosition(0.50, 0.42), // 三つ星中
      StarPosition(0.60, 0.40), // 三つ星右
      StarPosition(0.35, 0.70), // サイフ
      StarPosition(0.65, 0.70), // リゲル
      StarPosition(0.50, 0.55), // 小三つ星中
      StarPosition(0.30, 0.45), // 左腕
      StarPosition(0.70, 0.30), // 右腕
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(0, 2),
      StarConnection(1, 4),
      StarConnection(2, 3),
      StarConnection(3, 4),
      StarConnection(2, 5),
      StarConnection(4, 6),
      StarConnection(3, 7),
      StarConnection(0, 8),
      StarConnection(1, 9),
    ],
  ),

  // おおぐま座 (Ursa Major) - 北斗七星を含む
  ConstellationDef(
    id: 'ursa_major',
    name: 'Ursa Major',
    jaName: 'おおぐま座',
    symbol: '\u{1F43B}', // bear
    stars: [
      StarPosition(0.20, 0.40), // 柄の先端
      StarPosition(0.30, 0.35), // 柄2
      StarPosition(0.40, 0.38), // 柄3
      StarPosition(0.50, 0.35), // 器の角1
      StarPosition(0.65, 0.32), // 器の角2
      StarPosition(0.65, 0.50), // 器の角3
      StarPosition(0.50, 0.50), // 器の角4
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(2, 3),
      StarConnection(3, 4),
      StarConnection(4, 5),
      StarConnection(5, 6),
      StarConnection(6, 3),
    ],
  ),

  // カシオペヤ座 (Cassiopeia) - W字型
  ConstellationDef(
    id: 'cassiopeia',
    name: 'Cassiopeia',
    jaName: 'カシオペヤ座',
    symbol: '\u{1F451}', // crown
    stars: [
      StarPosition(0.15, 0.45),
      StarPosition(0.30, 0.30),
      StarPosition(0.45, 0.50),
      StarPosition(0.60, 0.25),
      StarPosition(0.75, 0.40),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(2, 3),
      StarConnection(3, 4),
    ],
  ),

  // はくちょう座 (Cygnus) - 北十字
  ConstellationDef(
    id: 'cygnus',
    name: 'Cygnus',
    jaName: 'はくちょう座',
    symbol: '\u{1F9A2}', // swan
    stars: [
      StarPosition(0.50, 0.15), // デネブ（尾）
      StarPosition(0.50, 0.35),
      StarPosition(0.50, 0.55),
      StarPosition(0.50, 0.75), // アルビレオ（くちばし）
      StarPosition(0.30, 0.40), // 左翼
      StarPosition(0.70, 0.40), // 右翼
      StarPosition(0.20, 0.50), // 左翼先
      StarPosition(0.80, 0.50), // 右翼先
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(2, 3),
      StarConnection(1, 4),
      StarConnection(1, 5),
      StarConnection(4, 6),
      StarConnection(5, 7),
    ],
  ),

  // わし座 (Aquila) - アルタイルを含む
  ConstellationDef(
    id: 'aquila',
    name: 'Aquila',
    jaName: 'わし座',
    symbol: '\u{1F985}', // eagle
    stars: [
      StarPosition(0.50, 0.25), // アルタイル
      StarPosition(0.35, 0.35),
      StarPosition(0.65, 0.35),
      StarPosition(0.45, 0.50),
      StarPosition(0.55, 0.50),
      StarPosition(0.40, 0.65),
      StarPosition(0.60, 0.65),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(0, 2),
      StarConnection(1, 3),
      StarConnection(2, 4),
      StarConnection(3, 5),
      StarConnection(4, 6),
    ],
  ),

  // こと座 (Lyra) - ベガを含む
  ConstellationDef(
    id: 'lyra',
    name: 'Lyra',
    jaName: 'こと座',
    symbol: '\u{1F3B5}', // music note
    stars: [
      StarPosition(0.50, 0.20), // ベガ
      StarPosition(0.40, 0.40),
      StarPosition(0.60, 0.40),
      StarPosition(0.35, 0.60),
      StarPosition(0.65, 0.60),
      StarPosition(0.50, 0.70),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(0, 2),
      StarConnection(1, 3),
      StarConnection(2, 4),
      StarConnection(3, 5),
      StarConnection(4, 5),
    ],
  ),

  // おおいぬ座 (Canis Major) - シリウスを含む
  ConstellationDef(
    id: 'canis_major',
    name: 'Canis Major',
    jaName: 'おおいぬ座',
    symbol: '\u{1F415}', // dog
    stars: [
      StarPosition(0.45, 0.15), // シリウス
      StarPosition(0.35, 0.30),
      StarPosition(0.55, 0.30),
      StarPosition(0.30, 0.45),
      StarPosition(0.60, 0.45),
      StarPosition(0.25, 0.60),
      StarPosition(0.50, 0.60),
      StarPosition(0.65, 0.55),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(0, 2),
      StarConnection(1, 3),
      StarConnection(2, 4),
      StarConnection(3, 5),
      StarConnection(3, 6),
      StarConnection(4, 7),
    ],
  ),

  // ペルセウス座 (Perseus) - 英雄の星座
  ConstellationDef(
    id: 'perseus',
    name: 'Perseus',
    jaName: 'ペルセウス座',
    symbol: '\u{1F5E1}', // dagger
    stars: [
      StarPosition(0.50, 0.15),
      StarPosition(0.45, 0.30),
      StarPosition(0.40, 0.45),
      StarPosition(0.35, 0.55),
      StarPosition(0.30, 0.70),
      StarPosition(0.55, 0.45),
      StarPosition(0.65, 0.55),
      StarPosition(0.60, 0.35),
      StarPosition(0.25, 0.40),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(2, 3),
      StarConnection(3, 4),
      StarConnection(2, 5),
      StarConnection(5, 6),
      StarConnection(1, 7),
      StarConnection(2, 8),
    ],
  ),

  // アンドロメダ座 (Andromeda)
  ConstellationDef(
    id: 'andromeda',
    name: 'Andromeda',
    jaName: 'アンドロメダ座',
    symbol: '\u{1F30C}', // milky way
    stars: [
      StarPosition(0.15, 0.45),
      StarPosition(0.30, 0.40),
      StarPosition(0.45, 0.38),
      StarPosition(0.60, 0.35),
      StarPosition(0.75, 0.30),
      StarPosition(0.35, 0.25),
      StarPosition(0.55, 0.50),
      StarPosition(0.70, 0.55),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(2, 3),
      StarConnection(3, 4),
      StarConnection(1, 5),
      StarConnection(3, 6),
      StarConnection(6, 7),
    ],
  ),

  // ペガスス座 (Pegasus) - 秋の四辺形
  ConstellationDef(
    id: 'pegasus',
    name: 'Pegasus',
    jaName: 'ペガスス座',
    symbol: '\u{1F40E}', // horse
    stars: [
      StarPosition(0.30, 0.25), // 四辺形の角
      StarPosition(0.65, 0.25),
      StarPosition(0.65, 0.55),
      StarPosition(0.30, 0.55),
      StarPosition(0.15, 0.40), // 首
      StarPosition(0.20, 0.60), // 前脚
      StarPosition(0.80, 0.40), // 後ろ
      StarPosition(0.75, 0.65), // 後脚
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(2, 3),
      StarConnection(3, 0),
      StarConnection(3, 4),
      StarConnection(3, 5),
      StarConnection(1, 6),
      StarConnection(2, 7),
    ],
  ),

  // りゅう座 (Draco) - 北極星の近く
  ConstellationDef(
    id: 'draco',
    name: 'Draco',
    jaName: 'りゅう座',
    symbol: '\u{1F409}', // dragon
    stars: [
      StarPosition(0.25, 0.25), // 頭
      StarPosition(0.35, 0.20),
      StarPosition(0.30, 0.35),
      StarPosition(0.40, 0.40),
      StarPosition(0.55, 0.35),
      StarPosition(0.65, 0.40),
      StarPosition(0.70, 0.50),
      StarPosition(0.60, 0.60),
      StarPosition(0.50, 0.55),
      StarPosition(0.45, 0.65),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(0, 2),
      StarConnection(2, 3),
      StarConnection(3, 4),
      StarConnection(4, 5),
      StarConnection(5, 6),
      StarConnection(6, 7),
      StarConnection(7, 8),
      StarConnection(8, 9),
    ],
  ),

  // みなみじゅうじ座 (Crux) - 南十字星
  ConstellationDef(
    id: 'crux',
    name: 'Crux',
    jaName: 'みなみじゅうじ座',
    symbol: '\u271A', // cross
    stars: [
      StarPosition(0.50, 0.15), // 上
      StarPosition(0.50, 0.70), // 下
      StarPosition(0.25, 0.42), // 左
      StarPosition(0.75, 0.42), // 右
      StarPosition(0.55, 0.50), // 中心近く
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(2, 3),
      StarConnection(0, 4),
      StarConnection(4, 1),
    ],
  ),

  // ========================================
  // マイナー星座
  // ========================================

  // からす座 (Corvus) - 春の小さな四辺形
  ConstellationDef(
    id: 'corvus',
    name: 'Corvus',
    jaName: 'からす座',
    symbol: '\u{1F426}', // bird
    stars: [
      StarPosition(0.30, 0.30),
      StarPosition(0.60, 0.25),
      StarPosition(0.70, 0.50),
      StarPosition(0.35, 0.55),
      StarPosition(0.50, 0.70),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(2, 3),
      StarConnection(3, 0),
      StarConnection(3, 4),
    ],
  ),

  // コップ座 (Crater) - 杯の星座
  ConstellationDef(
    id: 'crater',
    name: 'Crater',
    jaName: 'コップ座',
    symbol: '\u{1F378}', // cocktail glass
    stars: [
      StarPosition(0.35, 0.25),
      StarPosition(0.65, 0.25),
      StarPosition(0.70, 0.45),
      StarPosition(0.30, 0.45),
      StarPosition(0.45, 0.60),
      StarPosition(0.55, 0.60),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(2, 5),
      StarConnection(0, 3),
      StarConnection(3, 4),
      StarConnection(4, 5),
    ],
  ),

  // や座 (Sagitta) - 最小の星座の一つ
  ConstellationDef(
    id: 'sagitta',
    name: 'Sagitta',
    jaName: 'や座',
    symbol: '\u{1F3F9}', // bow and arrow
    stars: [
      StarPosition(0.20, 0.45),
      StarPosition(0.45, 0.45),
      StarPosition(0.65, 0.45),
      StarPosition(0.80, 0.45),
      StarPosition(0.60, 0.30),
      StarPosition(0.60, 0.60),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(2, 3),
      StarConnection(2, 4),
      StarConnection(2, 5),
    ],
  ),

  // たて座 (Scutum) - 盾の星座
  ConstellationDef(
    id: 'scutum',
    name: 'Scutum',
    jaName: 'たて座',
    symbol: '\u{1F6E1}', // shield
    stars: [
      StarPosition(0.40, 0.25),
      StarPosition(0.65, 0.30),
      StarPosition(0.70, 0.55),
      StarPosition(0.45, 0.65),
      StarPosition(0.30, 0.45),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(2, 3),
      StarConnection(3, 4),
      StarConnection(4, 0),
    ],
  ),

  // こぎつね座 (Vulpecula) - 小さなきつね
  ConstellationDef(
    id: 'vulpecula',
    name: 'Vulpecula',
    jaName: 'こぎつね座',
    symbol: '\u{1F98A}', // fox
    stars: [
      StarPosition(0.20, 0.40),
      StarPosition(0.35, 0.45),
      StarPosition(0.50, 0.40),
      StarPosition(0.65, 0.45),
      StarPosition(0.80, 0.42),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(2, 3),
      StarConnection(3, 4),
    ],
  ),

  // ほうおう座 (Phoenix) - 不死鳥
  ConstellationDef(
    id: 'phoenix',
    name: 'Phoenix',
    jaName: 'ほうおう座',
    symbol: '\u{1F525}', // fire
    stars: [
      StarPosition(0.50, 0.15), // 頭
      StarPosition(0.40, 0.30),
      StarPosition(0.60, 0.30),
      StarPosition(0.30, 0.50), // 左翼
      StarPosition(0.70, 0.50), // 右翼
      StarPosition(0.45, 0.65),
      StarPosition(0.55, 0.65),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(0, 2),
      StarConnection(1, 3),
      StarConnection(2, 4),
      StarConnection(1, 5),
      StarConnection(2, 6),
    ],
  ),

  // とけい座 (Horologium) - 時計の星座
  ConstellationDef(
    id: 'horologium',
    name: 'Horologium',
    jaName: 'とけい座',
    symbol: '\u{1F570}', // clock
    stars: [
      StarPosition(0.50, 0.15),
      StarPosition(0.55, 0.30),
      StarPosition(0.50, 0.45),
      StarPosition(0.45, 0.60),
      StarPosition(0.50, 0.80),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(2, 3),
      StarConnection(3, 4),
    ],
  ),

  // ろ座 (Fornax) - 化学炉の星座
  ConstellationDef(
    id: 'fornax',
    name: 'Fornax',
    jaName: 'ろ座',
    symbol: '\u{1F52C}', // microscope (closest)
    stars: [
      StarPosition(0.30, 0.30),
      StarPosition(0.50, 0.50),
      StarPosition(0.70, 0.30),
      StarPosition(0.40, 0.65),
      StarPosition(0.60, 0.65),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(1, 3),
      StarConnection(1, 4),
    ],
  ),

  // ちょうこくしつ座 (Sculptor) - 彫刻室
  ConstellationDef(
    id: 'sculptor',
    name: 'Sculptor',
    jaName: 'ちょうこくしつ座',
    symbol: '\u{1F3A8}', // palette
    stars: [
      StarPosition(0.25, 0.35),
      StarPosition(0.40, 0.40),
      StarPosition(0.55, 0.35),
      StarPosition(0.70, 0.40),
      StarPosition(0.50, 0.55),
      StarPosition(0.35, 0.60),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(2, 3),
      StarConnection(2, 4),
      StarConnection(4, 5),
      StarConnection(5, 1),
    ],
  ),

  // レチクル座 (Reticulum) - 十字線の星座
  ConstellationDef(
    id: 'reticulum',
    name: 'Reticulum',
    jaName: 'レチクル座',
    symbol: '\u{1F52D}', // telescope
    stars: [
      StarPosition(0.35, 0.30),
      StarPosition(0.65, 0.30),
      StarPosition(0.65, 0.60),
      StarPosition(0.35, 0.60),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(2, 3),
      StarConnection(3, 0),
    ],
  ),

  // きょしちょう座 (Tucana) - 南天のオオハシ
  ConstellationDef(
    id: 'tucana',
    name: 'Tucana',
    jaName: 'きょしちょう座',
    symbol: '\u{1F99C}', // parrot (closest)
    stars: [
      StarPosition(0.40, 0.25),
      StarPosition(0.55, 0.30),
      StarPosition(0.65, 0.40),
      StarPosition(0.55, 0.55),
      StarPosition(0.40, 0.55),
      StarPosition(0.30, 0.40),
    ],
    connections: [
      StarConnection(0, 1),
      StarConnection(1, 2),
      StarConnection(2, 3),
      StarConnection(3, 4),
      StarConnection(4, 5),
      StarConnection(5, 0),
    ],
  ),
];

/// インデックスに応じた星座を取得する.
ConstellationDef getConstellationForIndex(int index) {
  return constellations[index % constellations.length];
}
