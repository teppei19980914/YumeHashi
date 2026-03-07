/// ガントチャートの座標計算ロジック.
library;

import 'study_stats_types.dart';

/// ガントチャートの座標計算を提供するクラス.
class GanttCalculator {
  /// GanttCalculatorを作成する.
  GanttCalculator({
    this.pixelsPerDay = 30.0,
    this.rowHeight = 40,
    this.headerHeight = 70,
    this.barHeight = 24,
    this.barMargin = 8,
  });

  /// 1日あたりのピクセル数.
  final double pixelsPerDay;

  /// 行の高さ.
  final int rowHeight;

  /// ヘッダーの高さ.
  final int headerHeight;

  /// バーの高さ.
  final int barHeight;

  /// バーのマージン.
  final int barMargin;

  /// タスク日付リストからタイムラインの範囲を計算する.
  TimelineRange calculateTimeline(
    List<(DateTime, DateTime)> taskDates, {
    int paddingDays = 7,
  }) {
    if (taskDates.isEmpty) {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      return TimelineRange(
        startDate: todayDate.subtract(Duration(days: paddingDays)),
        endDate: todayDate.add(Duration(days: paddingDays + 30)),
      );
    }

    var earliest = taskDates[0].$1;
    var latest = taskDates[0].$2;
    for (final (start, end) in taskDates) {
      if (start.isBefore(earliest)) earliest = start;
      if (end.isAfter(latest)) latest = end;
    }

    return TimelineRange(
      startDate: earliest.subtract(Duration(days: paddingDays)),
      endDate: latest.add(Duration(days: paddingDays)),
    );
  }

  /// タスクのバー座標を計算する.
  BarGeometry calculateBarGeometry(
    DateTime taskStart,
    DateTime taskEnd,
    int progress,
    TimelineRange timeline,
  ) {
    final daysFromStart =
        taskStart.difference(timeline.startDate).inDays.toDouble();
    final duration = taskEnd.difference(taskStart).inDays + 1;
    final x = daysFromStart * pixelsPerDay;
    final width = duration * pixelsPerDay;
    final progressWidth = width * (progress / 100.0);
    return BarGeometry(x: x, width: width, progressWidth: progressWidth);
  }

  /// 行のY座標を計算する.
  double calculateBarY(int rowIndex) {
    return headerHeight + rowIndex * rowHeight + barMargin.toDouble();
  }

  /// 今日のX座標を計算する.
  double calculateTodayX(TimelineRange timeline) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return dateToX(todayDate, timeline);
  }

  /// 日付をX座標に変換する.
  double dateToX(DateTime targetDate, TimelineRange timeline) {
    return targetDate.difference(timeline.startDate).inDays * pixelsPerDay;
  }

  /// 月の境界位置リストを取得する.
  List<(DateTime, double)> getMonthBoundaries(TimelineRange timeline) {
    final boundaries = <(DateTime, double)>[];
    var current = DateTime(
      timeline.startDate.year,
      timeline.startDate.month,
    );
    if (current.isBefore(timeline.startDate)) {
      current =
          current.month == 12
              ? DateTime(current.year + 1, 1)
              : DateTime(current.year, current.month + 1);
    }
    while (!current.isAfter(timeline.endDate)) {
      final x = dateToX(current, timeline);
      boundaries.add((current, x));
      current =
          current.month == 12
              ? DateTime(current.year + 1, 1)
              : DateTime(current.year, current.month + 1);
    }
    return boundaries;
  }

  /// 日付位置リストを取得する.
  List<(DateTime, double)> getDayPositions(TimelineRange timeline) {
    final positions = <(DateTime, double)>[];
    var current = timeline.startDate;
    while (!current.isAfter(timeline.endDate)) {
      positions.add((current, dateToX(current, timeline)));
      current = current.add(const Duration(days: 1));
    }
    return positions;
  }

  /// シーンの幅を計算する.
  double calculateSceneWidth(TimelineRange timeline) {
    return timeline.totalDays * pixelsPerDay;
  }

  /// シーンの高さを計算する.
  double calculateSceneHeight(int taskCount) {
    final effectiveCount = taskCount < 1 ? 1 : taskCount;
    return headerHeight + effectiveCount * rowHeight.toDouble();
  }
}
