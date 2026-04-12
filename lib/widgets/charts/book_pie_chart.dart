/// 書籍ステータス PieChart.
///
/// 読了 / 読書中 / 未読 の構成比をドーナツ型 PieChart で可視化する.
/// 中央に合計冊数を表示する.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../theme/catppuccin_colors.dart';
import 'chart_theme.dart';

/// 書籍ステータスの表示データ.
class BookStatusEntry {
  /// BookStatusEntryを作成する.
  const BookStatusEntry({
    required this.label,
    required this.count,
    required this.color,
  });

  /// ステータスラベル（読了・読書中・未読）.
  final String label;

  /// 冊数.
  final int count;

  /// 表示色.
  final Color color;
}

/// 書籍ステータス PieChart ウィジェット.
class BookPieChart extends StatelessWidget {
  /// BookPieChartを作成する.
  const BookPieChart({
    super.key,
    required this.entries,
    required this.colors,
    this.size = 140,
  });

  /// ステータス別データ.
  final List<BookStatusEntry> entries;

  /// アプリのカラーセット.
  final AppColors colors;

  /// チャートのサイズ.
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = ChartTheme(colors);
    final textTheme = Theme.of(context).textTheme;
    final total = entries.fold<int>(0, (sum, e) => sum + e.count);

    if (total == 0) {
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

    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: [
                    for (final entry in entries)
                      if (entry.count > 0)
                        PieChartSectionData(
                          value: entry.count.toDouble(),
                          color: entry.color,
                          radius: 18,
                          showTitle: false,
                        ),
                  ],
                  centerSpaceRadius: size / 2 - 24,
                  sectionsSpace: 2,
                  startDegreeOffset: -90,
                ),
                swapAnimationDuration: const Duration(milliseconds: 400),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$total',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    '冊',
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
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
              if (entry.count > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: entry.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.label}: ${entry.count}冊',
                      style: theme.legendLabel,
                    ),
                  ],
                ),
          ],
        ),
      ],
    );
  }
}
