/// fl_chart 共通スタイル定義.
///
/// Catppuccin テーマに合わせたグリッド・ツールチップ・フォントの
/// 共通設定を提供する. 各チャートウィジェットがこのテーマを参照して
/// 統一感のある見た目にする.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../theme/catppuccin_colors.dart';

/// チャート共通のスタイル設定.
class ChartTheme {
  /// AppColors からチャートスタイルを生成する.
  const ChartTheme(this.colors);

  /// アプリのカラーセット.
  final AppColors colors;

  /// グリッドライン（横線）のスタイル.
  FlLine get gridLine => FlLine(
        color: colors.border.withAlpha(60),
        strokeWidth: 0.8,
      );

  /// チャートの枠線スタイル（表示しない）.
  FlBorderData get noBorder => FlBorderData(show: false);

  /// BarChart の標準ツールチップスタイル.
  BarTouchTooltipData barTooltip({
    required String Function(BarChartGroupData, BarChartRodData) getLabel,
  }) {
    return BarTouchTooltipData(
      tooltipRoundedRadius: 8,
      tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      getTooltipItem: (group, groupIndex, rod, rodIndex) {
        return BarTooltipItem(
          getLabel(group, rod),
          TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        );
      },
    );
  }

  /// X 軸ラベルのテキストスタイル.
  TextStyle get axisLabel => TextStyle(
        color: colors.textMuted,
        fontSize: 9,
        fontWeight: FontWeight.w400,
      );

  /// 凡例のテキストスタイル.
  TextStyle get legendLabel => TextStyle(
        color: colors.textSecondary,
        fontSize: 12,
      );
}

/// 分を「Xh Ym」形式にフォーマットする（チャート共通ユーティリティ）.
String formatMinutesShort(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h > 0 && m > 0) return '${h}h${m}m';
  if (h > 0) return '${h}h';
  return '${m}m';
}
