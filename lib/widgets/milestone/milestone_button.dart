/// マイルストーン（実績）ボタン.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/dashboard_providers.dart';
import 'milestone_popup.dart';

/// AppBarに表示するマイルストーンボタン.
class MilestoneButton extends ConsumerWidget {
  /// MilestoneButtonを作成する.
  const MilestoneButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestoneAsync = ref.watch(milestoneDataProvider);

    return IconButton(
      icon: const Icon(Icons.emoji_events_outlined),
      tooltip: '実績',
      onPressed: () {
        final data = milestoneAsync.valueOrNull;
        if (data == null) return;
        showDialog(
          context: context,
          builder: (_) => MilestonePopup(data: data),
        );
      },
    );
  }
}
