/// 実施率ドーナツチャート.
///
/// 全体実施率を中央に % 表示するドーナツ型 PieChart.
/// 実施済みセクションにアクセントカラー、未実施にボーダーカラーを使用.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../theme/catppuccin_colors.dart';

/// 実施率ドーナツチャートウィジェット.
class ConsistencyDonutChart extends StatelessWidget {
  /// ConsistencyDonutChartを作成する.
  const ConsistencyDonutChart({
    super.key,
    required this.rate,
    required this.colors,
    this.size = 120,
  });

  /// 実施率（0.0〜1.0）.
  final double rate;

  /// アプリのカラーセット.
  final AppColors colors;

  /// チャートのサイズ（幅 = 高さ）.
  final double size;

  @override
  Widget build(BuildContext context) {
    final percentage = (rate * 100).round();
    final theme = Theme.of(context);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: rate.clamp(0, 1),
                  color: colors.accent,
                  radius: 14,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: (1 - rate).clamp(0, 1),
                  color: colors.border.withAlpha(60),
                  radius: 12,
                  showTitle: false,
                ),
              ],
              centerSpaceRadius: size / 2 - 20,
              sectionsSpace: 2,
              startDegreeOffset: -90,
            ),
            swapAnimationDuration: const Duration(milliseconds: 400),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percentage%',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                '実施率',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
