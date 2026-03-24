/// ガントチャートウィジェット.
///
/// 左に固定の目標ラベル列、右にスクロール可能なタイムラインを表示する.
/// タスクは目標ごとにグルーピングされ、グループ帯で視覚的に分類される.
/// 目標列は横スクロールに関わらず常時表示され、縦スクロールは両列で同期される.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../models/task.dart';
import '../../services/gantt_calculator.dart';
import '../../services/study_stats_types.dart';
import '../../theme/app_theme.dart';

/// タスクバーがタップされた時のコールバック.
typedef OnTaskTap = void Function(Task task);

/// 目標グループ情報（内部計算用）.
class _GoalGroup {
  _GoalGroup({
    required this.goalId,
    required this.name,
    required this.color,
    required this.startRow,
    required this.taskCount,
  });

  final String goalId;
  final String name;
  final Color color;
  final int startRow;
  final int taskCount;
  int get endRow => startRow + taskCount - 1;
}

/// ガントチャートウィジェット.
class GanttChart extends StatefulWidget {
  /// GanttChartを作成する.
  const GanttChart({
    required this.tasks,
    required this.goalColors,
    this.goalNames = const {},
    this.milestones = const [],
    this.onTaskTap,
    super.key,
  });

  /// 表示するタスク一覧（目標別にソート済みであること）.
  final List<Task> tasks;

  /// GoalID→カラーのマップ.
  final Map<String, Color> goalColors;

  /// GoalID→表示名のマップ.
  final Map<String, String> goalNames;

  /// マイルストーン一覧（夢・目標の期限）.
  final List<GanttMilestone> milestones;

  /// タスクタップ時のコールバック.
  final OnTaskTap? onTaskTap;

  @override
  State<GanttChart> createState() => _GanttChartState();
}

class _GanttChartState extends State<GanttChart> {
  final _calculator = GanttCalculator();
  late TimelineRange _timeline;
  late List<_GoalGroup> _groups;
  int? _hoveredRow;

  // 縦スクロール同期用
  final _labelVController = ScrollController();
  final _timelineVController = ScrollController();
  bool _syncingScroll = false;

  static const double _labelColumnWidth = 140;

  @override
  void initState() {
    super.initState();
    _rebuild();
    _labelVController.addListener(_onLabelVScroll);
    _timelineVController.addListener(_onTimelineVScroll);
    _timelineHController.addListener(_syncHScroll);
  }

  @override
  void dispose() {
    _labelVController.removeListener(_onLabelVScroll);
    _timelineVController.removeListener(_onTimelineVScroll);
    _timelineHController.removeListener(_syncHScroll);
    _labelVController.dispose();
    _timelineVController.dispose();
    _timelineHController.dispose();
    _headerHController.dispose();
    super.dispose();
  }

  void _onLabelVScroll() {
    if (_syncingScroll) return;
    _syncingScroll = true;
    _timelineVController.jumpTo(_labelVController.offset);
    _syncingScroll = false;
  }

  void _onTimelineVScroll() {
    if (_syncingScroll) return;
    _syncingScroll = true;
    _labelVController.jumpTo(_timelineVController.offset);
    _syncingScroll = false;
  }

  @override
  void didUpdateWidget(GanttChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tasks != widget.tasks ||
        oldWidget.milestones != widget.milestones ||
        oldWidget.goalNames != widget.goalNames) {
      _rebuild();
    }
  }

  void _rebuild() {
    final dates = widget.tasks
        .map((t) => (t.startDate, t.endDate))
        .toList();
    for (final m in widget.milestones) {
      dates.add((m.date, m.date));
    }
    _timeline = _calculator.calculateTimeline(dates);
    _groups = _buildGroups();
  }

  List<_GoalGroup> _buildGroups() {
    final groups = <_GoalGroup>[];
    if (widget.tasks.isEmpty) return groups;

    var currentGoalId = widget.tasks.first.goalId;
    var startRow = 0;
    var count = 0;

    for (var i = 0; i < widget.tasks.length; i++) {
      if (widget.tasks[i].goalId != currentGoalId) {
        groups.add(_GoalGroup(
          goalId: currentGoalId,
          name: _goalName(currentGoalId),
          color: widget.goalColors[currentGoalId] ??
              const Color(0xFF89B4FA),
          startRow: startRow,
          taskCount: count,
        ));
        currentGoalId = widget.tasks[i].goalId;
        startRow = i;
        count = 0;
      }
      count++;
    }
    groups.add(_GoalGroup(
      goalId: currentGoalId,
      name: _goalName(currentGoalId),
      color: widget.goalColors[currentGoalId] ??
          const Color(0xFF89B4FA),
      startRow: startRow,
      taskCount: count,
    ));
    return groups;
  }

  String _goalName(String goalId) {
    if (widget.goalNames.containsKey(goalId)) {
      return widget.goalNames[goalId]!;
    }
    if (goalId.isEmpty) return '独立タスク';
    return goalId;
  }

  int? _hitTestRow(Offset localPosition) {
    // ボディ内ではヘッダーオフセット不要（Y=0がボディの先頭）
    final y = localPosition.dy;
    if (y < 0) return null;
    final row = y ~/ _calculator.rowHeight;
    if (row >= widget.tasks.length) return null;
    return row;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.appColors;
    final sceneWidth = _calculator.calculateSceneWidth(_timeline);
    final bodyHeight = _calculator.calculateSceneHeight(widget.tasks.length) -
        _calculator.headerHeight;
    final headerH = _calculator.headerHeight.toDouble();

    return Column(
      children: [
        // ── ヘッダー行（固定） ──
        SizedBox(
          height: headerH,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 左上: 「目標」ヘッダー
              SizedBox(
                width: _labelColumnWidth,
                child: CustomPaint(
                  painter: _LabelHeaderPainter(
                    bgColor: colors.bgPrimary,
                    gridColor: colors.border,
                    textColor: colors.textPrimary,
                  ),
                ),
              ),
              // 右上: タイムラインヘッダー（横スクロール連動）
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (_) => true, // ヘッダーの独自スクロール防止
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _headerHController,
                    physics: const NeverScrollableScrollPhysics(),
                    child: CustomPaint(
                      size: Size(sceneWidth, headerH),
                      painter: _TimelineHeaderPainter(
                        calculator: _calculator,
                        timeline: _timeline,
                        milestones: widget.milestones,
                        bgColor: colors.bgPrimary,
                        gridColor: colors.border,
                        textColor: colors.textPrimary,
                        mutedColor: colors.textMuted,
                        todayColor: colors.error,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── ボディ行（縦スクロール同期、右は横スクロール可能） ──
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左列: 目標ラベル（縦スクロール）
              SizedBox(
                width: _labelColumnWidth,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    controller: _labelVController,
                    child: CustomPaint(
                      size: Size(_labelColumnWidth, bodyHeight),
                      painter: _LabelBodyPainter(
                        groups: _groups,
                        calculator: _calculator,
                        taskCount: widget.tasks.length,
                        bgColor: colors.bgPrimary,
                        gridColor: colors.border,
                        textColor: colors.textPrimary,
                        hoveredRow: _hoveredRow,
                        hoverColor: colors.bgHover,
                      ),
                    ),
                  ),
                ),
              ),

              // 右列: タイムライン（縦+横スクロール）
              Expanded(
                child: SingleChildScrollView(
                  controller: _timelineVController,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _timelineHController,
                    child: MouseRegion(
                      onHover: (event) {
                        final row = _hitTestRow(event.localPosition);
                        if (row != _hoveredRow) {
                          setState(() => _hoveredRow = row);
                        }
                      },
                      onExit: (_) {
                        if (_hoveredRow != null) {
                          setState(() => _hoveredRow = null);
                        }
                      },
                      child: GestureDetector(
                        onTapUp: (details) {
                          final row = _hitTestRow(details.localPosition);
                          if (row != null && widget.onTaskTap != null) {
                            widget.onTaskTap!(widget.tasks[row]);
                          }
                        },
                        child: CustomPaint(
                          size: Size(sceneWidth, bodyHeight),
                          painter: _TimelineBodyPainter(
                            tasks: widget.tasks,
                            groups: _groups,
                            goalColors: widget.goalColors,
                            milestones: widget.milestones,
                            calculator: _calculator,
                            timeline: _timeline,
                            hoveredRow: _hoveredRow,
                            gridColor: colors.border,
                            textColor: colors.textPrimary,
                            todayColor: colors.error,
                            hoverColor: colors.bgHover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 横スクロール同期: ヘッダーとボディ
  final _timelineHController = ScrollController();
  final _headerHController = ScrollController();

  void _syncHScroll() {
    if (_headerHController.hasClients) {
      _headerHController.jumpTo(_timelineHController.offset);
    }
  }
}

// ── 左上: 「目標」ヘッダー ──────────────────────────────────────

class _LabelHeaderPainter extends CustomPainter {
  _LabelHeaderPainter({
    required this.bgColor,
    required this.gridColor,
    required this.textColor,
  });

  final Color bgColor;
  final Color gridColor;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = bgColor,
    );
    _drawText(canvas, '目標', Offset(8, size.height / 2 - 7), textColor, 12,
        fontWeight: FontWeight.w600);
    // 下線
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      Paint()
        ..color = gridColor
        ..strokeWidth = 1,
    );
    // 右線
    canvas.drawLine(
      Offset(size.width - 1, 0),
      Offset(size.width - 1, size.height),
      Paint()
        ..color = gridColor
        ..strokeWidth = 1,
    );
  }

  void _drawText(Canvas canvas, String text, Offset offset, Color color,
      double fontSize,
      {FontWeight fontWeight = FontWeight.normal}) {
    TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              color: color, fontSize: fontSize, fontWeight: fontWeight)),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── 左列ボディ: 目標ラベル ────────────────────────────────────

class _LabelBodyPainter extends CustomPainter {
  _LabelBodyPainter({
    required this.groups,
    required this.calculator,
    required this.taskCount,
    required this.bgColor,
    required this.gridColor,
    required this.textColor,
    required this.hoveredRow,
    required this.hoverColor,
  });

  final List<_GoalGroup> groups;
  final GanttCalculator calculator;
  final int taskCount;
  final Color bgColor;
  final Color gridColor;
  final Color textColor;
  final int? hoveredRow;
  final Color hoverColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rowH = calculator.rowHeight.toDouble();

    for (final group in groups) {
      final topY = group.startRow * rowH;
      final groupHeight = group.taskCount * rowH;

      // グループ背景帯
      canvas.drawRect(
        Rect.fromLTWH(0, topY, size.width, groupHeight),
        Paint()..color = group.color.withAlpha(12),
      );

      // 左カラーバー
      canvas.drawRect(
        Rect.fromLTWH(0, topY, 4, groupHeight),
        Paint()..color = group.color,
      );

      // グループ上境界線
      canvas.drawLine(
        Offset(0, topY),
        Offset(size.width, topY),
        Paint()
          ..color = group.color.withAlpha(60)
          ..strokeWidth = 1,
      );

      // 目標名
      final labelY = topY + groupHeight / 2 -
          (group.taskCount > 1 ? 7 : 7);
      _drawText(
        canvas,
        group.name,
        Offset(10, labelY),
        group.color,
        11,
        fontWeight: FontWeight.w600,
        maxWidth: size.width - 16,
      );

      // ホバーハイライト
      if (hoveredRow != null &&
          hoveredRow! >= group.startRow &&
          hoveredRow! <= group.endRow) {
        final hoverY = hoveredRow! * rowH;
        canvas.drawRect(
          Rect.fromLTWH(0, hoverY, size.width, rowH),
          Paint()..color = hoverColor.withAlpha(60),
        );
      }
    }

    // 最終下線
    if (groups.isNotEmpty) {
      final lastGroup = groups.last;
      final bottomY = (lastGroup.endRow + 1) * rowH;
      canvas.drawLine(
        Offset(0, bottomY),
        Offset(size.width, bottomY),
        Paint()
          ..color = gridColor.withAlpha(60)
          ..strokeWidth = 1,
      );
    }

    // 右区切り線
    canvas.drawLine(
      Offset(size.width - 1, 0),
      Offset(size.width - 1, size.height),
      Paint()
        ..color = gridColor
        ..strokeWidth = 1,
    );
  }

  void _drawText(Canvas canvas, String text, Offset offset, Color color,
      double fontSize,
      {FontWeight fontWeight = FontWeight.normal, double? maxWidth}) {
    TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              color: color, fontSize: fontSize, fontWeight: fontWeight)),
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '...',
    )
      ..layout(maxWidth: maxWidth ?? double.infinity)
      ..paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_LabelBodyPainter oldDelegate) {
    return oldDelegate.groups != groups ||
        oldDelegate.hoveredRow != hoveredRow;
  }
}

// ── 右上: タイムラインヘッダー ──────────────────────────────────

class _TimelineHeaderPainter extends CustomPainter {
  _TimelineHeaderPainter({
    required this.calculator,
    required this.timeline,
    required this.milestones,
    required this.bgColor,
    required this.gridColor,
    required this.textColor,
    required this.mutedColor,
    required this.todayColor,
  });

  final GanttCalculator calculator;
  final TimelineRange timeline;
  final Color bgColor;
  final Color gridColor;
  final Color textColor;
  final Color mutedColor;
  final Color todayColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = bgColor,
    );

    // 月ラベル
    final monthBoundaries = calculator.getMonthBoundaries(timeline);
    final monthFormat = DateFormat('yyyy/MM');
    for (final (date, x) in monthBoundaries) {
      _drawText(canvas, monthFormat.format(date), Offset(x + 4, 8),
          textColor, 12,
          fontWeight: FontWeight.w600);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        Paint()
          ..color = gridColor
          ..strokeWidth = 1,
      );
    }

    // 日付・曜日
    final dayPositions = calculator.getDayPositions(timeline);
    for (final (date, x) in dayPositions) {
      _drawText(
        canvas,
        '${date.day}',
        Offset(x + calculator.pixelsPerDay / 2 - 6, 32),
        mutedColor,
        10,
      );
      const weekDays = ['月', '火', '水', '木', '金', '土', '日'];
      final weekDay = weekDays[date.weekday - 1];
      final isWeekend = date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday;
      _drawText(
        canvas,
        weekDay,
        Offset(x + calculator.pixelsPerDay / 2 - 5, 48),
        isWeekend ? todayColor.withAlpha(150) : mutedColor,
        9,
      );
    }

    // 下線
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      Paint()
        ..color = gridColor
        ..strokeWidth = 1,
    );

    // 今日線（ヘッダー部分）
    final todayX = calculator.calculateTodayX(timeline);
    canvas.drawLine(
      Offset(todayX, 0),
      Offset(todayX, size.height),
      Paint()
        ..color = todayColor
        ..strokeWidth = 2,
    );

    // マイルストーンマーカー
    for (final milestone in milestones) {
      final mx = calculator.dateToX(milestone.date, timeline) +
          calculator.pixelsPerDay / 2;
      final colorHex = milestone.color.replaceFirst('#', '');
      final color = Color(int.parse('FF$colorHex', radix: 16));
      const diamondSize = 8.0;
      final markerY = size.height - diamondSize - 4;
      final path = Path()
        ..moveTo(mx, markerY - diamondSize)
        ..lineTo(mx + diamondSize, markerY)
        ..lineTo(mx, markerY + diamondSize)
        ..lineTo(mx - diamondSize, markerY)
        ..close();
      canvas.drawPath(path, Paint()..color = color);
      _drawText(canvas, milestone.label,
          Offset(mx + diamondSize + 2, markerY - 6), color, 9,
          fontWeight: FontWeight.w600);
    }
  }

  final List<GanttMilestone> milestones;

  void _drawText(Canvas canvas, String text, Offset offset, Color color,
      double fontSize,
      {FontWeight fontWeight = FontWeight.normal}) {
    TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              color: color, fontSize: fontSize, fontWeight: fontWeight)),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_TimelineHeaderPainter oldDelegate) {
    return oldDelegate.timeline != timeline ||
        oldDelegate.milestones != milestones;
  }
}

// ── 右列ボディ: タイムライン ──────────────────────────────────

class _TimelineBodyPainter extends CustomPainter {
  _TimelineBodyPainter({
    required this.tasks,
    required this.groups,
    required this.goalColors,
    required this.milestones,
    required this.calculator,
    required this.timeline,
    required this.hoveredRow,
    required this.gridColor,
    required this.textColor,
    required this.todayColor,
    required this.hoverColor,
  });

  final List<Task> tasks;
  final List<_GoalGroup> groups;
  final Map<String, Color> goalColors;
  final List<GanttMilestone> milestones;
  final GanttCalculator calculator;
  final TimelineRange timeline;
  final int? hoveredRow;
  final Color gridColor;
  final Color textColor;
  final Color todayColor;
  final Color hoverColor;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGroupBackgrounds(canvas, size);
    _drawGrid(canvas, size);
    _drawMilestoneLines(canvas, size);
    _drawTodayLine(canvas, size);
    _drawBars(canvas);
  }

  void _drawGroupBackgrounds(Canvas canvas, Size size) {
    final rowH = calculator.rowHeight.toDouble();
    for (final group in groups) {
      final topY = group.startRow * rowH;
      final groupHeight = group.taskCount * rowH;

      canvas.drawRect(
        Rect.fromLTWH(0, topY, size.width, groupHeight),
        Paint()..color = group.color.withAlpha(8),
      );
      canvas.drawLine(
        Offset(0, topY),
        Offset(size.width, topY),
        Paint()
          ..color = group.color.withAlpha(40)
          ..strokeWidth = 0.5,
      );

      if (hoveredRow != null &&
          hoveredRow! >= group.startRow &&
          hoveredRow! <= group.endRow) {
        final hoverY = hoveredRow! * rowH;
        canvas.drawRect(
          Rect.fromLTWH(0, hoverY, size.width, rowH),
          Paint()..color = hoverColor.withAlpha(60),
        );
      }
    }
    if (groups.isNotEmpty) {
      final lastGroup = groups.last;
      final bottomY = (lastGroup.endRow + 1) * rowH;
      canvas.drawLine(
        Offset(0, bottomY),
        Offset(size.width, bottomY),
        Paint()
          ..color = gridColor.withAlpha(60)
          ..strokeWidth = 0.5,
      );
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor.withAlpha(30)
      ..strokeWidth = 0.5;
    final rowH = calculator.rowHeight.toDouble();

    for (var i = 0; i <= tasks.length; i++) {
      final y = i * rowH;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final dayPositions = calculator.getDayPositions(timeline);
    for (final (date, x) in dayPositions) {
      final isWeekend = date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday;
      if (isWeekend) {
        canvas.drawRect(
          Rect.fromLTWH(x, 0, calculator.pixelsPerDay, size.height),
          Paint()..color = gridColor.withAlpha(15),
        );
      }
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  void _drawTodayLine(Canvas canvas, Size size) {
    final todayX = calculator.calculateTodayX(timeline);
    canvas.drawLine(
      Offset(todayX, 0),
      Offset(todayX, size.height),
      Paint()
        ..color = todayColor
        ..strokeWidth = 2,
    );
  }

  void _drawBars(Canvas canvas) {
    for (var i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      final geo = calculator.calculateBarGeometry(
        task.startDate, task.endDate, task.progress, timeline);
      // ボディ内ではヘッダー分のオフセット不要（Y=0がボディの先頭）
      final y = i * calculator.rowHeight.toDouble() +
          calculator.barMargin.toDouble();
      final barColor =
          goalColors[task.goalId] ?? const Color(0xFF89B4FA);

      final bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(geo.x, y, geo.width, calculator.barHeight.toDouble()),
        const Radius.circular(4),
      );
      canvas.drawRRect(bgRect, Paint()..color = barColor.withAlpha(60));

      if (geo.progressWidth > 0) {
        final progressRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
              geo.x, y, geo.progressWidth, calculator.barHeight.toDouble()),
          const Radius.circular(4),
        );
        canvas.drawRRect(progressRect, Paint()..color = barColor);
      }

      _drawText(
        canvas,
        '${task.title} (${task.progress}%)',
        Offset(geo.x + 6, y + 5),
        textColor,
        11,
      );
    }
  }

  void _drawMilestoneLines(Canvas canvas, Size size) {
    for (final milestone in milestones) {
      final x = calculator.dateToX(milestone.date, timeline) +
          calculator.pixelsPerDay / 2;
      final colorHex = milestone.color.replaceFirst('#', '');
      final color = Color(int.parse('FF$colorHex', radix: 16));

      final linePaint = Paint()
        ..color = color.withAlpha(100)
        ..strokeWidth = 1.5;
      const dashH = 6.0;
      const gapH = 4.0;
      var y = 0.0;
      while (y < size.height) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x, math.min(y + dashH, size.height)),
          linePaint,
        );
        y += dashH + gapH;
      }
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, Color color,
      double fontSize,
      {FontWeight fontWeight = FontWeight.normal}) {
    TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              color: color, fontSize: fontSize, fontWeight: fontWeight)),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_TimelineBodyPainter oldDelegate) {
    return oldDelegate.tasks != tasks ||
        oldDelegate.groups != groups ||
        oldDelegate.milestones != milestones ||
        oldDelegate.hoveredRow != hoveredRow ||
        oldDelegate.timeline != timeline;
  }
}
