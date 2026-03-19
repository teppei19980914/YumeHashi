/// AppBar に配置するお問い合わせ/フィードバックボタン.
///
/// メールアイコンをタップすると、フィードバックまたはお問い合わせを
/// 選択するポップアップメニューを表示する.
/// 制限解除とは無関係の純粋な意見送信・問い合わせ用.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dialogs/feedback_dialog.dart';
import '../../dialogs/inquiry_dialog.dart';
import '../../providers/service_providers.dart';
import '../../services/inquiry_service.dart';

/// AppBar用のお問い合わせボタン.
class ContactButton extends ConsumerWidget {
  const ContactButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.mail_outline),
      tooltip: 'ご意見・お問い合わせ',
      onPressed: () => _showContactMenu(context, ref),
    );
  }

  void _showContactMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'ご意見・お問い合わせ',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.rate_review_outlined),
                title: const Text('フィードバックを送る'),
                subtitle: const Text('アプリへのご意見・改善要望'),
                onTap: () {
                  Navigator.pop(context);
                  _openFeedback(context, ref);
                },
              ),
              ListTile(
                leading: const Icon(Icons.mail_outline),
                title: const Text('お問い合わせ'),
                subtitle: const Text('追加開発・案件のご相談など'),
                onTap: () {
                  Navigator.pop(context);
                  _openInquiry(context, ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openFeedback(BuildContext context, WidgetRef ref) async {
    final feedbackService = ref.read(feedbackServiceProvider);
    final userConfig = ref.read(remoteConfigProvider);
    final userKey = userConfig.name.isNotEmpty ? userConfig.name : null;

    await showFeedbackDialog(
      context,
      feedbackService,
      userKey: userKey,
    );
  }

  Future<void> _openInquiry(BuildContext context, WidgetRef ref) async {
    final userConfig = ref.read(remoteConfigProvider);
    final userKey = userConfig.name.isNotEmpty ? userConfig.name : null;

    await showInquiryDialog(
      context,
      InquiryService(),
      userKey: userKey,
    );
  }
}
