/// 統計ページ.
///
/// サマリー、自己ベスト、実施率、アクティビティチャート、
/// 最近の活動ログを表示する.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/book.dart';
import '../models/study_log.dart';
import '../providers/book_providers.dart';
import '../providers/dashboard_providers.dart';
import '../services/study_stats_calculator.dart';
import '../services/study_stats_types.dart';
import '../l10n/app_labels.dart';
import '../theme/app_theme.dart';

import '../services/trial_limit_service.dart' show isPremium, isTrialMode;
import '../widgets/premium/premium_gate.dart';
import '../widgets/stats/goal_stats_section.dart';

/// アクティビティ期間Provider.
final activityPeriodProvider =
    StateProvider<ActivityPeriodType>((ref) => ActivityPeriodType.monthly);

/// アクティビティチャートProvider.
final activityChartProvider = FutureProvider<ActivityChartData>((ref) async {
  final period = ref.watch(activityPeriodProvider);
  final logs = await ref.watch(allLogsProvider.future);
  return StudyStatsCalculator.calculateActivity(logs, period);
});

/// 統計ページ.
class StatsPage extends ConsumerWidget {
  /// StatsPageを作成する.
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.appColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // サマリーセクション
          _SummarySection(colors: colors),
          const SizedBox(height: 16),

          // 自己ベスト
          _PersonalRecordSection(colors: colors),
          const SizedBox(height: 16),

          // 実施率
          _ConsistencySection(colors: colors),
          const SizedBox(height: 16),

          // 目標別統計（プレミアム機能）
          const _GoalStatsPremiumSection(),
          const SizedBox(height: 16),

          // 書籍統計
          _BookStatsSection(colors: colors),
          const SizedBox(height: 16),

          // アクティビティチャート（プレミアム機能）
          const _ActivityChartPremiumSection(),
          const SizedBox(height: 16),

          // 最近の活動ログ
          _RecentLogsSection(colors: colors),
        ],
      ),
    );
  }
}

/// サマリーセクション.
class _SummarySection extends ConsumerWidget {
  const _SummarySection({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayStudyProvider);
    final recordAsync = ref.watch(personalRecordProvider);
    final streakAsync = ref.watch(streakProvider);
    final goalCountAsync = ref.watch(goalCountProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLabels.statsSummary, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _SummaryTile(
                  label: AppLabels.statsTotalTime,
                  value: recordAsync.when(
                    data: (d) => '${d.totalHours.toStringAsFixed(1)}h',
                    loading: () => '...',
                    error: (_, _) => '-',
                  ),
                  icon: Icons.timer_outlined,
                  iconColor: colors.accent,
                ),
                _SummaryTile(
                  label: AppLabels.statsStudyDays,
                  value: recordAsync.when(
                    data: (d) => AppLabels.unitDays(d.totalStudyDays),
                    loading: () => '...',
                    error: (_, _) => '-',
                  ),
                  icon: Icons.calendar_today_outlined,
                  iconColor: colors.success,
                ),
                _SummaryTile(
                  label: AppLabels.statsStreak,
                  value: streakAsync.when(
                    data: (d) => AppLabels.unitDays(d.currentStreak),
                    loading: () => '...',
                    error: (_, _) => '-',
                  ),
                  icon: Icons.local_fire_department_outlined,
                  iconColor: colors.error,
                ),
                _SummaryTile(
                  label: AppLabels.statsToday,
                  value: todayAsync.when(
                    data: (d) => _formatMinutes(d.totalMinutes),
                    loading: () => '...',
                    error: (_, _) => '-',
                  ),
                  icon: Icons.today_outlined,
                  iconColor: colors.warning,
                ),
                _SummaryTile(
                  label: AppLabels.statsGoalCount,
                  value: goalCountAsync.when(
                    data: (d) => '$d',
                    loading: () => '...',
                    error: (_, _) => '-',
                  ),
                  icon: Icons.flag_outlined,
                  iconColor: colors.accent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0 && m > 0) return '${h}h${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }
}

/// サマリータイル.
class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 140,
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelSmall),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 自己ベストセクション.
class _PersonalRecordSection extends ConsumerWidget {
  const _PersonalRecordSection({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordAsync = ref.watch(personalRecordProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events_outlined,
                    size: 20, color: colors.warning),
                const SizedBox(width: 8),
                Text(AppLabels.statsPersonalRecord, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            recordAsync.when(
              data: (data) => Column(
                children: [
                  _RecordItem(
                    label: AppLabels.statsBestDay,
                    value: _formatMinutes(data.bestDayMinutes),
                    detail: data.bestDayDate != null
                        ? DateFormat('yyyy/MM/dd').format(data.bestDayDate!)
                        : null,
                  ),
                  const Divider(height: 16),
                  _RecordItem(
                    label: AppLabels.statsBestWeek,
                    value: _formatMinutes(data.bestWeekMinutes),
                    detail: data.bestWeekStart != null
                        ? AppLabels.unitWeekStart(DateFormat('MM/dd').format(data.bestWeekStart!))
                        : null,
                  ),
                  const Divider(height: 16),
                  _RecordItem(
                    label: AppLabels.statsLongestStreak,
                    value: AppLabels.unitDays(data.longestStreak),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Text(AppLabels.errorGeneral),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return AppLabels.unitHoursMinutes(h, m);
  }
}

/// レコードアイテム.
class _RecordItem extends StatelessWidget {
  const _RecordItem({required this.label, required this.value, this.detail});

  final String label;
  final String value;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall),
              if (detail != null)
                Text(
                  detail!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.appColors.textMuted,
                  ),
                ),
            ],
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// 実施率セクション.
class _ConsistencySection extends ConsumerWidget {
  const _ConsistencySection({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consistAsync = ref.watch(consistencyProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart_outlined, size: 20, color: colors.accent),
                const SizedBox(width: 8),
                Text(AppLabels.statsConsistency, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            consistAsync.when(
              data: (data) => Column(
                children: [
                  // 全体実施率
                  Row(
                    children: [
                      Text(AppLabels.statsOverall, style: theme.textTheme.bodyMedium),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: data.overallRate.clamp(0.0, 1.0),
                            minHeight: 10,
                            backgroundColor: colors.border,
                            valueColor:
                                AlwaysStoppedAnimation(colors.accent),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 50,
                        child: Text(
                          '${(data.overallRate * 100).toStringAsFixed(0)}%',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 今週 / 今月
                  Row(
                    children: [
                      Expanded(
                        child: _PeriodCard(
                          label: AppLabels.statsThisWeek,
                          days: data.thisWeekDays,
                          totalDays: data.thisWeekTotal,
                          minutes: data.thisWeekMinutes,
                          color: colors.accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PeriodCard(
                          label: AppLabels.statsThisMonth,
                          days: data.thisMonthDays,
                          totalDays: data.thisMonthTotal,
                          minutes: data.thisMonthMinutes,
                          color: colors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Text(AppLabels.errorGeneral),
            ),
          ],
        ),
      ),
    );
  }
}

/// 期間カード.
class _PeriodCard extends StatelessWidget {
  const _PeriodCard({
    required this.label,
    required this.days,
    required this.totalDays,
    required this.minutes,
    required this.color,
  });

  final String label;
  final int days;
  final int totalDays;
  final int minutes;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final h = minutes ~/ 60;
    final m = minutes % 60;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(
            AppLabels.unitDaysSlash(days, totalDays),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            '${h}h${m}m',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// 目標別統計のプレミアムラッパー.
class _GoalStatsPremiumSection extends ConsumerWidget {
  const _GoalStatsPremiumSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isTrialMode || isPremium) {
      return const GoalStatsSection();
    }
    return const PremiumSectionGate(
      featureName: AppLabels.statsGoalStatsPremiumName,
      featureIcon: Icons.bar_chart,
      premiumPoints: [
        AppLabels.statsGoalStatsPremiumPoint1,
        AppLabels.statsGoalStatsPremiumPoint2,
        AppLabels.statsGoalStatsPremiumPoint3,
      ],
    );
  }
}

/// アクティビティチャートのプレミアムラッパー.
class _ActivityChartPremiumSection extends ConsumerWidget {
  const _ActivityChartPremiumSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.appColors;
    if (!isTrialMode || isPremium) {
      return _ActivityChartSection(colors: colors);
    }
    return const PremiumSectionGate(
      featureName: AppLabels.statsActivityPremiumName,
      featureIcon: Icons.show_chart,
      premiumPoints: [
        AppLabels.statsActivityPremiumPoint1,
        AppLabels.statsActivityPremiumPoint2,
        AppLabels.statsActivityPremiumPoint3,
      ],
    );
  }
}

/// アクティビティチャートセクション.
class _ActivityChartSection extends ConsumerWidget {
  const _ActivityChartSection({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(activityPeriodProvider);
    final chartAsync = ref.watch(activityChartProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.show_chart, size: 20, color: colors.success),
                    const SizedBox(width: 8),
                    Text(AppLabels.statsActivity, style: theme.textTheme.titleMedium),
                  ],
                ),
                // 期間セレクタ
                SegmentedButton<ActivityPeriodType>(
                  segments: const [
                    ButtonSegment(
                      value: ActivityPeriodType.daily,
                      label: Text(AppLabels.statsPeriodDaily),
                    ),
                    ButtonSegment(
                      value: ActivityPeriodType.weekly,
                      label: Text(AppLabels.statsPeriodWeekly),
                    ),
                    ButtonSegment(
                      value: ActivityPeriodType.monthly,
                      label: Text(AppLabels.statsPeriodMonthly),
                    ),
                    ButtonSegment(
                      value: ActivityPeriodType.yearly,
                      label: Text(AppLabels.statsPeriodYearly),
                    ),
                  ],
                  selected: {period},
                  onSelectionChanged: (selected) {
                    ref.read(activityPeriodProvider.notifier).state =
                        selected.first;
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    textStyle: WidgetStatePropertyAll(
                      theme.textTheme.labelSmall,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            chartAsync.when(
              data: (data) => SizedBox(
                height: 160,
                child: _BarChart(data: data, colors: colors),
              ),
              loading: () =>
                  const SizedBox(
                    height: 160,
                    child: Center(child: CircularProgressIndicator()),
                  ),
              error: (_, _) =>
                  const SizedBox(height: 160, child: Center(child: Text(AppLabels.errorGeneral))),
            ),
          ],
        ),
      ),
    );
  }
}

/// バーチャート.
class _BarChart extends StatelessWidget {
  const _BarChart({required this.data, required this.colors});

  final ActivityChartData data;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    if (data.buckets.isEmpty || data.maxMinutes == 0) {
      return Center(
        child: Text(
          AppLabels.statsNoData,
          style: TextStyle(color: colors.textMuted),
        ),
      );
    }

    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final barSpacing = 4.0;
        final labelHeight = 24.0;
        final chartHeight = constraints.maxHeight - labelHeight;
        final barWidth = (constraints.maxWidth -
                (data.buckets.length - 1) * barSpacing) /
            data.buckets.length;

        return Column(
          children: [
            SizedBox(
              height: chartHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < data.buckets.length; i++) ...[
                    if (i > 0) SizedBox(width: barSpacing),
                    SizedBox(
                      width: barWidth,
                      child: Tooltip(
                        message:
                            '${data.buckets[i].label}: ${_formatMinutes(data.buckets[i].totalMinutes)}',
                        child: FractionallySizedBox(
                          heightFactor:
                              (data.buckets[i].totalMinutes / data.maxMinutes)
                                  .clamp(0.0, 1.0),
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            decoration: BoxDecoration(
                              color: data.buckets[i].totalMinutes > 0
                                  ? colors.accent
                                  : colors.border.withAlpha(50),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(
              height: labelHeight,
              child: Row(
                children: [
                  for (var i = 0; i < data.buckets.length; i++) ...[
                    if (i > 0) SizedBox(width: barSpacing),
                    SizedBox(
                      width: barWidth,
                      child: Text(
                        _shouldShowLabel(i, data.buckets.length)
                            ? data.buckets[i].label
                            : '',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 9,
                          color: colors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  bool _shouldShowLabel(int index, int total) {
    if (total <= 12) return true;
    // For 30 buckets, show every 5th label
    return index % 5 == 0 || index == total - 1;
  }

  String _formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0) return '${h}h${m}m';
    return '${m}m';
  }
}

/// 最近の活動ログセクション.
class _RecentLogsSection extends ConsumerWidget {
  const _RecentLogsSection({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(allLogsProvider);
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MM/dd');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, size: 20, color: colors.textSecondary),
                const SizedBox(width: 8),
                Text(AppLabels.statsRecentLogs, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            logsAsync.when(
              data: (logs) {
                if (logs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        AppLabels.statsNoLogs,
                        style: TextStyle(color: colors.textMuted),
                      ),
                    ),
                  );
                }

                // Sort by date descending and take recent 20
                final sorted = List<StudyLog>.from(logs)
                  ..sort((a, b) => b.studyDate.compareTo(a.studyDate));
                final recent = sorted.take(20).toList();

                return Column(
                  children: [
                    for (var i = 0; i < recent.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      _LogItem(
                        log: recent[i],
                        dateFormat: dateFormat,
                        colors: colors,
                      ),
                    ],
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Text(AppLabels.errorGeneral),
            ),
          ],
        ),
      ),
    );
  }
}

/// ログアイテム.
class _LogItem extends StatelessWidget {
  const _LogItem({
    required this.log,
    required this.dateFormat,
    required this.colors,
  });

  final StudyLog log;
  final DateFormat dateFormat;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final h = log.durationMinutes ~/ 60;
    final m = log.durationMinutes % 60;
    final durationStr = h > 0 ? '${h}h${m}m' : '${m}m';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              dateFormat.format(log.studyDate),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              log.taskName.isNotEmpty ? log.taskName : log.taskId,
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            durationStr,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 書籍統計セクション.
class _BookStatsSection extends ConsumerWidget {
  const _BookStatsSection({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(bookListProvider);
    final theme = Theme.of(context);

    return booksAsync.when(
      data: (books) {
        if (books.isEmpty) return const SizedBox.shrink();

        final total = books.length;
        final completed =
            books.where((b) => b.status == BookStatus.completed).length;
        final reading =
            books.where((b) => b.status == BookStatus.reading).length;
        final unread =
            books.where((b) => b.status == BookStatus.unread).length;
        final completionRate =
            total > 0 ? (completed / total * 100).round() : 0;

        // カテゴリ別集計
        final categoryMap = <BookCategory, int>{};
        final categoryCompletedMap = <BookCategory, int>{};
        for (final book in books) {
          categoryMap[book.category] =
              (categoryMap[book.category] ?? 0) + 1;
          if (book.status == BookStatus.completed) {
            categoryCompletedMap[book.category] =
                (categoryCompletedMap[book.category] ?? 0) + 1;
          }
        }
        final sortedCategories = categoryMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.menu_book, size: 20, color: colors.accent),
                    const SizedBox(width: 8),
                    Text(AppLabels.statsBookStats, style: theme.textTheme.titleSmall),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    _BookStatTile(
                        label: AppLabels.statsRegistered, value: AppLabels.unitBooks(total),
                        color: colors.textPrimary),
                    _BookStatTile(
                        label: AppLabels.statsCompleted, value: AppLabels.unitBooks(completed),
                        color: colors.success),
                    _BookStatTile(
                        label: AppLabels.statsReading, value: AppLabels.unitBooks(reading),
                        color: colors.accent),
                    _BookStatTile(
                        label: AppLabels.statsUnread, value: AppLabels.unitBooks(unread),
                        color: colors.textMuted),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(AppLabels.statsCompletionRate, style: theme.textTheme.bodySmall),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: total > 0 ? completed / total : 0,
                          minHeight: 8,
                          backgroundColor: colors.textMuted.withAlpha(30),
                          color: colors.success,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('$completionRate%',
                        style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(AppLabels.statsCategory, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                ...sortedCategories.map((entry) {
                  final cat = entry.key;
                  final count = entry.value;
                  final completedInCat = categoryCompletedMap[cat] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 90,
                          child: Text(cat.label,
                              style: theme.textTheme.bodySmall),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: count / total,
                              minHeight: 6,
                              backgroundColor:
                                  colors.textMuted.withAlpha(30),
                              color: colors.accent.withAlpha(180),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 70,
                          child: Text(AppLabels.unitBooksSlash(completedInCat, count),
                              style: theme.textTheme.labelSmall,
                              textAlign: TextAlign.end),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

/// 書籍統計の個別タイル.
class _BookStatTile extends StatelessWidget {
  const _BookStatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: theme.textTheme.titleMedium?.copyWith(
                  color: color, fontWeight: FontWeight.bold)),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
