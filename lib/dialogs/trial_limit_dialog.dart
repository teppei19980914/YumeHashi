/// 体験版の制限到達ダイアログ.
///
/// 制限に達した際にデスクトップ版への導線を表示する.
library;

import 'package:flutter/material.dart';

import '../services/trial_limit_service.dart';

/// 体験版の制限到達ダイアログを表示する.
///
/// [itemName] は制限に達した項目名（例: '夢', '目標', 'タスク', '書籍'）.
/// [currentCount] は現在の登録数.
/// [maxCount] は制限数.
Future<void> showTrialLimitDialog(
  BuildContext context, {
  required String itemName,
  required int currentCount,
  required int maxCount,
}) async {
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.lock_outline,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text('$itemNameの上限に達しました'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UsageBar(current: currentCount, max: maxCount, itemName: itemName),
          const SizedBox(height: 16),
          Text(
            'Web体験版では$itemNameを$maxCount件まで登録できます。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withAlpha(40),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'デスクトップ版なら無制限',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 4),
                const Text('デスクトップ版をインストールすると、'
                    '全ての機能を制限なくご利用いただけます。'),
                const SizedBox(height: 8),
                Text(
                  '設定画面のエクスポート機能で現在のデータを'
                  'デスクトップ版に移行できます。',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            trialLimitDescription,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
      ],
    ),
  );
}

/// 使用量バー.
class _UsageBar extends StatelessWidget {
  const _UsageBar({
    required this.current,
    required this.max,
    required this.itemName,
  });

  final int current;
  final int max;
  final String itemName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = (current / max).clamp(0.0, 1.0);
    final isAtLimit = current >= max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(itemName, style: theme.textTheme.labelMedium),
            Text(
              '$current / $max',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isAtLimit ? theme.colorScheme.error : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(
              isAtLimit
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
