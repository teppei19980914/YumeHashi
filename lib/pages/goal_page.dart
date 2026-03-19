/// 目標ページ.
///
/// 目標一覧をカードリストで表示し、追加・編集・削除を提供する.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../dialogs/goal_dialog.dart';
import '../dialogs/trial_limit_dialog.dart';
import '../models/dream.dart';
import '../models/goal.dart';
import '../providers/dream_providers.dart';
import '../providers/goal_providers.dart';
import '../providers/service_providers.dart';
import '../services/trial_limit_service.dart';
import '../services/tutorial_service.dart';
import '../theme/app_theme.dart';
import '../widgets/tutorial/tutorial_banner.dart';
import '../widgets/tutorial/tutorial_target_keys.dart';

/// 目標ページ.
class GoalPage extends ConsumerWidget {
  /// GoalPageを作成する.
  const GoalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalListProvider);
    final dreamsAsync = ref.watch(dreamListProvider);
    final theme = Theme.of(context);
    final colors = theme.appColors;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Row(
            children: [
              Expanded(
                child: Text(
                  'やりたいことに向けた目標を管理します。',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                key: TutorialTargetKeys.addGoalButton,
                onPressed: () => _addGoal(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('目標を追加'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 目標リスト
          Expanded(
            child: goalsAsync.when(
              data: (goals) => dreamsAsync.when(
                data: (dreams) {
                  if (goals.isEmpty) {
                    return _buildEmptyState(theme, colors);
                  }
                  final dreamMap = {for (final d in dreams) d.id: d};
                  return ListView.separated(
                    itemCount: goals.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final goal = goals[index];
                      final dreamTitle = goal.dreamId.isEmpty
                          ? null
                          : dreamMap[goal.dreamId]?.title ?? '(未設定)';
                      return _GoalCard(
                        goal: goal,
                        dreamTitle: dreamTitle,
                        onTap: () => _editGoal(context, ref, goal),
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text('エラーが発生しました: $error'),
                ),
              ),
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
          Icon(Icons.flag_outlined, size: 64, color: colors.textMuted),
          const SizedBox(height: 16),
          Text(
            '最初の目標を設定しよう',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '「目標を追加」ボタンから始められます',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  List<Dream> _getDreams(WidgetRef ref) {
    return ref.read(dreamListProvider).valueOrNull ?? [];
  }

  Future<void> _addGoal(BuildContext context, WidgetRef ref) async {
    final dreams = _getDreams(ref);

    final tutorialState = ref.read(tutorialStateProvider);
    final isTutorial = tutorialState.isActive &&
        tutorialState.step == TutorialStep.addGoal;

    // チュートリアル中は制限をバイパス
    if (!isTutorial) {
      final goals = await ref.read(goalListProvider.future);
      final level = ref.read(unlockLevelProvider);
      final totalMax = maxDreams(level) * maxGoalsPerDream(level);
      if (goals.length >= totalMax) {
        if (!context.mounted) return;
        await showTrialLimitDialog(
          context,
          itemName: '目標',
          currentCount: goals.length,
          maxCount: totalMax,
          feedbackService: ref.read(feedbackServiceProvider),
        );
        ref.invalidate(feedbackServiceProvider);
        return;
      }
    }

    if (!context.mounted) return;
    final result = await showGoalDialog(context, dreams: dreams);
    if (result == null) return;

    final goalId = await ref.read(goalListProvider.notifier).createGoal(
          dreamId: result.dreamId,
          whenTarget: result.whenTarget,
          whenType: result.whenType,
          what: result.what,
          how: result.how,
        );

    // チュートリアル中: 目標IDを記録してステップを進める
    if (isTutorial) {
      final tutorialService = ref.read(tutorialServiceProvider);
      await tutorialService.setTutorialGoalId(goalId);
      await ref.read(tutorialStateProvider.notifier).advanceStep();
    }
  }

  Future<void> _editGoal(
    BuildContext context,
    WidgetRef ref,
    Goal goal,
  ) async {
    final dreams = _getDreams(ref);
    final result = await showGoalDialog(context, goal: goal, dreams: dreams);
    if (result == null) return;

    if (result.deleteRequested) {
      await ref.read(goalListProvider.notifier).deleteGoal(goal.id);
      return;
    }

    await ref.read(goalListProvider.notifier).updateGoal(
          goalId: goal.id,
          dreamId: result.dreamId,
          whenTarget: result.whenTarget,
          whenType: result.whenType,
          what: result.what,
          how: result.how,
        );
  }
}

/// 目標カードウィジェット.
class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.dreamTitle,
    required this.onTap,
  });

  final Goal goal;
  final String? dreamTitle;
  final VoidCallback onTap;

  Color _parseColor(String hex) {
    final code = hex.replaceFirst('#', '');
    return Color(int.parse('FF$code', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.appColors;
    final goalColor = _parseColor(goal.color);

    return GestureDetector(
      onTap: onTap,
      child: Card(
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            // カラーバー
            Container(width: 6, color: goalColor),

            // コンテンツ
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // タイトル行
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            goal.what,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _WhenBadge(goal: goal),
                        Icon(Icons.chevron_right,
                            size: 18, color: colors.textMuted),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // 夢情報（紐づく夢がある場合のみ表示）
                    if (dreamTitle != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 13,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dreamTitle!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),

                    // 目標情報
                    _InfoRow(
                      icon: Icons.build_outlined,
                      label: 'How',
                      value: goal.how,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

/// When情報のバッジ.
class _WhenBadge extends StatelessWidget {
  const _WhenBadge({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDate = goal.whenType == WhenType.date;
    final targetDate = goal.getTargetDate();

    String label;
    Color? badgeColor;

    if (isDate && targetDate != null) {
      final remaining = targetDate.difference(DateTime.now()).inDays;
      label = DateFormat('yyyy/MM/dd').format(targetDate);
      if (remaining < 0) {
        badgeColor = theme.colorScheme.error;
      } else if (remaining <= 30) {
        badgeColor = theme.appColors.warning;
      }
    } else {
      label = goal.whenTarget;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor?.withAlpha(30) ??
            theme.colorScheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: badgeColor?.withAlpha(80) ??
              theme.colorScheme.primary.withAlpha(50),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDate ? Icons.calendar_today : Icons.schedule,
            size: 12,
            color: badgeColor ?? theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: badgeColor ?? theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 情報行.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ),
      ],
    );
  }
}
