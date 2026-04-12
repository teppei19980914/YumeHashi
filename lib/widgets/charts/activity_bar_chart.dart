/// アクティビティ棒グラフ（fl_chart BarChart ラッパー）.
///
/// 統計画面とダッシュボードで共用する.
/// [ActivityChartData] を受け取り、期間別の活動時間を棒グラフで可視化する.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../services/study_stats_types.dart';
import '../../theme/catppuccin_colors.dart';
import 'chart_theme.dart';

/// アクティビティ棒グラフウィジェット.
class ActivityBarChart extends StatelessWidget {
  /// ActivityBarChartを作成する.
  const ActivityBarChart({
    super.key,
    required this.data,
    required this.colors,
    this.height = 200,
    this.showLabels = true,
  });

  /// アクティビティチャートデータ.
  final ActivityChartData data;

  /// アプリのカラーセット.
  final AppColors colors;

  /// チャートの高さ.
  final double height;

  /// X軸ラベルを表示するか.
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    if (data.buckets.isEmpty || data.maxMinutes == 0) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'データがありません',
            style: TextStyle(color: colors.textMuted),
          ),
        ),
      );
    }

    final theme = ChartTheme(colors);

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: data.maxMinutes.toDouble() * 1.15,
          barGroups: _buildGroups(),
          titlesData: _buildTitles(theme),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _gridInterval(),
            getDrawingHorizontalLine: (_) => theme.gridLine,
          ),
          borderData: theme.noBorder,
          barTouchData: BarTouchData(
            touchTooltipData: theme.barTooltip(
              getLabel: (group, rod) {
                final bucket = data.buckets[group.x];
                return '${bucket.label}: ${formatMinutesShort(bucket.totalMinutes)}';
              },
            ),
          ),
        ),
        swapAnimationDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  List<BarChartGroupData> _buildGroups() {
    return [
      for (var i = 0; i < data.buckets.length; i++)
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: data.buckets[i].totalMinutes.toDouble(),
              color: data.buckets[i].totalMinutes > 0
                  ? colors.accent
                  : colors.border.withAlpha(30),
              width: _barWidth(),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(3),
              ),
            ),
          ],
        ),
    ];
  }

  double _barWidth() {
    final count = data.buckets.length;
    if (count <= 7) return 20;
    if (count <= 12) return 14;
    return 8;
  }

  double _gridInterval() {
    final max = data.maxMinutes.toDouble();
    if (max <= 30) return 10;
    if (max <= 60) return 15;
    if (max <= 120) return 30;
    if (max <= 300) return 60;
    return 120;
  }

  FlTitlesData _buildTitles(ChartTheme theme) {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 36,
          interval: _gridInterval(),
          getTitlesWidget: (value, meta) {
            if (value == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                formatMinutesShort(value.toInt()),
                style: theme.axisLabel,
                textAlign: TextAlign.right,
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: showLabels,
          reservedSize: 22,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= data.buckets.length) {
              return const SizedBox.shrink();
            }
            if (!_shouldShowLabel(index)) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                data.buckets[index].label,
                style: theme.axisLabel,
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ),
    );
  }

  bool _shouldShowLabel(int index) {
    final total = data.buckets.length;
    if (total <= 12) return true;
    return index % 5 == 0 || index == total - 1;
  }
}
