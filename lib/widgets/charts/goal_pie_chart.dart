/// 目標別時間配分 PieChart.
///
/// 目標間の活動時間配分をドーナツ型 PieChart で可視化する.
/// 各セクションの色は目標に設定されたカラーを使用する.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../theme/catppuccin_colors.dart';
import 'chart_theme.dart';

/// 目標別の表示データ.
class GoalChartEntry {
  /// GoalChartEntryを作成する.
  const GoalChartEntry({
    required this.name,
    required this.minutes,
    required this.color,
  });

  /// 目標名.
  final String name;

  /// 活動時間（分）.
  final int minutes;

  /// 表示色.
  final Color color;
}

/// 目標別時間配分 PieChart ウィジェット.
class GoalPieChart extends StatelessWidget {
  /// GoalPieChartを作成する.
  const GoalPieChart({
    super.key,
    required this.entries,
    required this.colors,
    this.size = 160,
  });

  /// 目標別データ.
  final List<GoalChartEntry> entries;

  /// アプリのカラーセット.
  final AppColors colors;

  /// チャートのサイズ.
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = ChartTheme(colors);

    if (entries.isEmpty || entries.every((e) => e.minutes == 0)) {
      return SizedBox(
        height: size,
        child: Center(
          child: Text(
            'データがありません',
            style: TextStyle(color: colors.textMuted),
          ),
        ),
      );
    }

    final totalMinutes = entries.fold<int>(0, (sum, e) => sum + e.minutes);

    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: PieChart(
            PieChartData(
              sections: [
                for (final entry in entries)
                  if (entry.minutes > 0)
                    PieChartSectionData(
                      value: entry.minutes.toDouble(),
                      color: entry.color,
                      radius: 20,
                      showTitle: false,
                    ),
              ],
              centerSpaceRadius: size / 2 - 28,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(enabled: true),
            ),
            swapAnimationDuration: const Duration(milliseconds: 400),
          ),
        ),
        const SizedBox(height: 12),
        // 凡例
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (final entry in entries)
              if (entry.minutes > 0)
                _LegendItem(
                  color: entry.color,
                  label: entry.name,
                  detail: '${formatMinutesShort(entry.minutes)}'
                      ' (${(entry.minutes / totalMinutes * 100).round()}%)',
                  textStyle: theme.legendLabel,
                ),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.detail,
    required this.textStyle,
  });

  final Color color;
  final String label;
  final String detail;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: textStyle),
        const SizedBox(width: 4),
        Text(
          detail,
          style: textStyle.copyWith(
            color: textStyle.color?.withAlpha(150),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
