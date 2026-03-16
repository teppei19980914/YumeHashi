/// 課金案内ダイアログ.
///
/// フィードバックによる制限解除が上限に達した後、
/// プレミアム機能へのアップグレードを案内する.
/// Stripe Checkout 経由でサブスクリプション契約を行う.
library;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/remote_config_service.dart';
import '../services/stripe_service.dart';
import '../theme/app_theme.dart';

/// プレミアム機能の一覧.
const _premiumFeatures = [
  (Icons.view_timeline_outlined, 'ガントチャート', 'タスクの日程をタイムラインでビジュアル管理'),
  (Icons.file_download_outlined, 'Excel出力', 'ガントチャートをExcelエクスポートして共有'),
  (Icons.bar_chart, '目標別統計', '目標・タスクごとの活動時間を詳細分析'),
  (Icons.show_chart, 'アクティビティチャート', '日・週・月・年単位の活動推移をグラフ表示'),
  (Icons.menu_book, '読書スケジュール', '書籍の読書計画をガントチャートで管理'),
  (Icons.add_circle_outline, '今後の新機能すべて', '追加される最新機能を最優先で利用可能'),
];

/// 課金案内ダイアログを表示する.
Future<void> showUpgradeDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (context) => const _UpgradeDialog(),
  );
}

class _UpgradeDialog extends StatefulWidget {
  const _UpgradeDialog();

  @override
  State<_UpgradeDialog> createState() => _UpgradeDialogState();
}

class _UpgradeDialogState extends State<_UpgradeDialog> {
  bool _isLoading = false;

  Future<void> _subscribe() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final stripeService = StripeService(prefs);
      final userKey = RemoteConfigService(prefs).savedUserKey;
      final checkoutUrl = await stripeService.createCheckoutUrl(
        userKey: userKey,
      );

      if (!mounted) return;

      if (checkoutUrl != null) {
        final uri = Uri.parse(checkoutUrl);
        if (kIsWeb) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        } else {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        if (mounted) Navigator.of(context).pop();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('決済ページの取得に失敗しました。しばらく後にお試しください。')),
          );
        }
      }
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('エラーが発生しました。しばらく後にお試しください。')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.appColors;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.star, size: 24, color: colors.accent),
          const SizedBox(width: 8),
          const Expanded(child: Text('プレミアムプランのご案内')),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'プレミアムプランでは以下の機能が全てご利用いただけます。',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),

              // プレミアム機能一覧
              ...(_premiumFeatures.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(f.$1, size: 20, color: colors.accent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              f.$2,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              f.$3,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // プラン情報
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.accent.withAlpha(80)),
                  borderRadius: BorderRadius.circular(12),
                  color: colors.accent.withAlpha(10),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.language, size: 28, color: colors.accent),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'サブスクプラン',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'ブラウザからそのまま全機能を利用可能',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.accent.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '¥480/月',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isLoading ? null : _subscribe,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.payment),
                        label: Text(
                          _isLoading ? '処理中...' : 'サブスクプランに申し込む',
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
