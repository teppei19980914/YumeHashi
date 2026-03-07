/// 星座定義データ.
///
/// 12星座の星の位置と接続線を定義する.
/// 座標は0.0〜1.0の正規化座標で、描画時にウィジェットサイズにスケーリングする.
library;

import '../models/constellation.dart';

/// 1つの星を点灯するのに必要な学習時間（分）.
const minutesPerStar = 300; // 5時間

/// 利用可能な星座一覧.
const constellations = <ConstellationDef>[
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
];

/// Dreamインデックスに応じた星座を取得する.
ConstellationDef getConstellationForIndex(int index) {
  return constellations[index % constellations.length];
}
