/// Web体験版の注意バナー.
///
/// Web版アプリでのみ表示し、データの取り扱いに関する注意事項を表示する.
library;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _webBannerDismissedKey = 'web_trial_banner_dismissed';
const _webDialogShownKey = 'web_trial_dialog_shown';

/// Web体験版バナー（ダッシュボード上部に表示）.
class WebTrialBanner extends StatefulWidget {
  /// WebTrialBannerを作成する.
  const WebTrialBanner({required this.prefs, super.key});

  /// SharedPreferences.
  final SharedPreferences prefs;

  @override
  State<WebTrialBanner> createState() => _WebTrialBannerState();
}

class _WebTrialBannerState extends State<WebTrialBanner> {
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _dismissed = widget.prefs.getBool(_webBannerDismissedKey) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || _dismissed) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2A2A40)
            : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? const Color(0xFF4A4A6A)
              : const Color(0xFFFFE082),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: isDark
                ? const Color(0xFFFFD54F)
                : const Color(0xFFF9A825),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Web体験版をご利用中です',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ブラウザのデータを削除すると学習記録が消えます。'
                  '別端末・別ブラウザとのデータ共有はできません。',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: _dismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: '閉じる',
          ),
        ],
      ),
    );
  }

  void _dismiss() {
    setState(() => _dismissed = true);
    widget.prefs.setBool(_webBannerDismissedKey, true);
  }
}

/// Web体験版の初回ダイアログを表示する.
///
/// 初回のみ表示し、以降はSharedPreferencesで制御する.
Future<void> showWebTrialDialogIfNeeded(
  BuildContext context,
  SharedPreferences prefs,
) async {
  if (!kIsWeb) return;
  if (prefs.getBool(_webDialogShownKey) ?? false) return;

  await prefs.setBool(_webDialogShownKey, true);

  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.language, size: 24),
          SizedBox(width: 8),
          Text('Web体験版について'),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'このアプリはWeb体験版です。デスクトップ版のインストール前に'
            '機能をお試しいただけます。',
          ),
          SizedBox(height: 16),
          _NoticeItem(
            icon: Icons.warning_amber_outlined,
            text: 'ブラウザのキャッシュ/データを削除すると、'
                '全ての学習記録が消えます。',
          ),
          SizedBox(height: 8),
          _NoticeItem(
            icon: Icons.devices_outlined,
            text: '別の端末や別のブラウザからアクセスすると、'
                'データは引き継がれません。\n'
                '(設定画面のエクスポート/インポート機能で移行可能)',
          ),
          SizedBox(height: 16),
          Text(
            '安定してご利用いただくには、デスクトップ版のインストールを'
            'おすすめします。',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('理解しました'),
        ),
      ],
    ),
  );
}

/// 注意事項の項目表示.
class _NoticeItem extends StatelessWidget {
  const _NoticeItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFFF9A825)),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
