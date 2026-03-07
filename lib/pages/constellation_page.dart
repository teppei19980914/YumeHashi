/// 星座ページ.
///
/// 夢ごとの星座進捗を一覧表示する.
/// 学習時間が増えると星が灯り、星座が完成していく.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/constellations.dart';
import '../models/constellation.dart';
import '../providers/constellation_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/constellation/constellation_painter.dart';

/// 星座ページ.
class ConstellationPage extends ConsumerWidget {
  /// ConstellationPageを作成する.
  const ConstellationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(constellationProgressProvider);
    final theme = Theme.of(context);
    final colors = theme.appColors;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Text(
            '学習時間に応じて星が灯り、星座が完成します。'
            '${minutesPerStar ~/ 60}時間ごとに1つの星が輝きます。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // 星座リスト
          Expanded(
            child: progressAsync.when(
              data: (progressList) {
                if (progressList.isEmpty) {
                  return _buildEmptyState(theme, colors);
                }
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: progressList.length,
                  itemBuilder: (_, index) =>
                      _ConstellationCard(progress: progressList[index]),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('エラーが発生しました: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, dynamic colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.stars_outlined, size: 64, color: colors.textMuted),
          const SizedBox(height: 16),
          Text(
            '星座がまだありません',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '「夢」を追加すると星座が割り当てられます',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// 個別の星座カード.
class _ConstellationCard extends StatelessWidget {
  const _ConstellationCard({required this.progress});

  final ConstellationProgress progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.appColors;
    final constellation = progress.constellation;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      clipBehavior: Clip.antiAlias,
      color: isDark
          ? const Color(0xFF1A1A2E)
          : const Color(0xFFF0F4F8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タイトル行
            Row(
              children: [
                Text(
                  constellation.symbol,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        progress.dreamTitle,
                        style: theme.textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        constellation.jaName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (progress.isComplete)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '完成',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // 星座描画エリア
            Expanded(
              child: ConstellationWidget(progress: progress),
            ),

            const SizedBox(height: 8),

            // 進捗バー
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.completionRate,
                minHeight: 4,
                backgroundColor: isDark
                    ? Colors.white.withAlpha(15)
                    : Colors.black.withAlpha(10),
                valueColor: AlwaysStoppedAnimation(
                  progress.isComplete
                      ? const Color(0xFFFFD700)
                      : theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 4),

            // 統計行
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${progress.litStarCount}/${constellation.starCount} 星',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
                Text(
                  '${progress.totalHours.toStringAsFixed(1)}h',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
