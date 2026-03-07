/// Catppuccin カラーパレット定義.
///
/// Mocha（ダーク）とLatte（ライト）の2つのカラーパレットを提供する.
library;

import 'package:flutter/material.dart';

/// アプリケーションで使用するセマンティックカラーセット.
class AppColors {
  /// カラーセットを作成する.
  const AppColors({
    required this.bgPrimary,
    required this.bgSecondary,
    required this.bgSurface,
    required this.bgHover,
    required this.bgCard,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentHover,
    required this.success,
    required this.warning,
    required this.error,
    required this.border,
    required this.scrollbar,
    required this.scrollbarHover,
  });

  /// メイン背景色.
  final Color bgPrimary;

  /// サブ背景色（サイドバー、ヘッダー等）.
  final Color bgSecondary;

  /// サーフェス背景色（入力フィールド等）.
  final Color bgSurface;

  /// ホバー時の背景色.
  final Color bgHover;

  /// カード背景色.
  final Color bgCard;

  /// メインテキスト色.
  final Color textPrimary;

  /// サブテキスト色.
  final Color textSecondary;

  /// ミュートテキスト色.
  final Color textMuted;

  /// アクセント色.
  final Color accent;

  /// アクセントホバー色.
  final Color accentHover;

  /// 成功色.
  final Color success;

  /// 警告色.
  final Color warning;

  /// エラー色.
  final Color error;

  /// ボーダー色.
  final Color border;

  /// スクロールバー色.
  final Color scrollbar;

  /// スクロールバーホバー色.
  final Color scrollbarHover;
}

/// Catppuccin Mocha（ダークテーマ）のカラーパレット.
const catppuccinMocha = AppColors(
  bgPrimary: Color(0xFF1E1E2E),
  bgSecondary: Color(0xFF181825),
  bgSurface: Color(0xFF313244),
  bgHover: Color(0xFF45475A),
  bgCard: Color(0xFF2A2A3C),
  textPrimary: Color(0xFFCDD6F4),
  textSecondary: Color(0xFFA6ADC8),
  textMuted: Color(0xFF6C7086),
  accent: Color(0xFF89B4FA),
  accentHover: Color(0xFF74C7EC),
  success: Color(0xFFA6E3A1),
  warning: Color(0xFFF9E2AF),
  error: Color(0xFFF38BA8),
  border: Color(0xFF45475A),
  scrollbar: Color(0xFF585B70),
  scrollbarHover: Color(0xFF6C7086),
);

/// Catppuccin Latte（ライトテーマ）のカラーパレット.
const catppuccinLatte = AppColors(
  bgPrimary: Color(0xFFEFF1F5),
  bgSecondary: Color(0xFFE6E9EF),
  bgSurface: Color(0xFFDCE0E8),
  bgHover: Color(0xFFCCD0DA),
  bgCard: Color(0xFFFFFFFF),
  textPrimary: Color(0xFF4C4F69),
  textSecondary: Color(0xFF5C5F77),
  textMuted: Color(0xFF9CA0B0),
  accent: Color(0xFF1E66F5),
  accentHover: Color(0xFF2A7AE4),
  success: Color(0xFF40A02B),
  warning: Color(0xFFDF8E1D),
  error: Color(0xFFD20F39),
  border: Color(0xFFCCD0DA),
  scrollbar: Color(0xFFACB0BE),
  scrollbarHover: Color(0xFF9CA0B0),
);

/// Goalカードに使用するカラーパレット（8色）.
const goalCardColors = [
  Color(0xFF89B4FA), // Blue
  Color(0xFFA6E3A1), // Green
  Color(0xFFF9E2AF), // Yellow
  Color(0xFFF38BA8), // Pink
  Color(0xFFCBA6F7), // Mauve
  Color(0xFF94E2D5), // Teal
  Color(0xFFFAB387), // Peach
  Color(0xFF74C7EC), // Sapphire
];
