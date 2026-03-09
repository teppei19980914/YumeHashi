/// 課金案内ダイアログ.
///
/// フィードバックによる制限解除が上限に達した後、
/// 無制限利用のための課金オプションを案内する.
library;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 課金案内ダイアログを表示する.
Future<void> showUpgradeDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (context) => const _UpgradeDialog(),
  );
}

class _UpgradeDialog extends StatelessWidget {
  const _UpgradeDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.appColors;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.star, size: 24, color: colors.accent),
          const SizedBox(width: 8),
          const Expanded(child: Text('無制限プランのご案内')),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'フィードバックによる制限解除は上限に達しました。\n'
                'すべての機能を無制限でご利用いただくには、以下のプランをご検討ください。',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),

              // オプション1: ネイティブアプリ
              _OptionCard(
                icon: Icons.install_desktop,
                iconColor: colors.accent,
                title: 'ネイティブアプリを購入',
                description:
                    'Windows / macOS / Android / iOS 対応のネイティブアプリ。'
                    'オフラインでも利用可能で、すべての機能が無制限です。',
                theme: theme,
              ),
              const SizedBox(height: 12),

              // オプション2: Web無制限化
              _OptionCard(
                icon: Icons.language,
                iconColor: colors.success,
                title: 'Web版を無制限化',
                description:
                    '現在のWeb体験版のすべての制限を解除します。'
                    'ブラウザからそのまま無制限でご利用いただけます。',
                theme: theme,
              ),
              const SizedBox(height: 16),

              // 注意書き
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.error.withAlpha(60),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 18, color: theme.colorScheme.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ネイティブアプリとWeb版は別々のサービスです。\n'
                        '一方を購入しても、もう一方は無制限になりません。\n'
                        'それぞれ別途ご購入が必要です。',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
      ],
    );
  }
}

/// 課金オプションカード.
class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.theme,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
