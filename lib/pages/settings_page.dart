/// 設定ページ.
///
/// テーマ切替、通知設定、データエクスポート/インポート/全削除、
/// バージョン情報を提供する.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../app_version.dart';
import '../providers/book_providers.dart';
import '../providers/dream_providers.dart';
import '../providers/goal_providers.dart';
import '../services/data_export_service.dart' show buildBackupFileName;
import '../services/file_save_service.dart' as file_io;
import '../providers/service_providers.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_labels.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snackbar.dart';

/// 通知有効/無効Provider.
final _notificationsEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  return service.notificationsEnabled;
});

/// 設定ページ.
class SettingsPage extends ConsumerWidget {
  /// SettingsPageを作成する.
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeType = ref.watch(themeProvider);
    final notifAsync = ref.watch(_notificationsEnabledProvider);
    final theme = Theme.of(context);
    final colors = theme.appColors;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // テーマ設定
        _SectionHeader(title: AppLabels.settingsAppearance, icon: Icons.palette_outlined),
        Card(
          child: SwitchListTile(
            title: const Text(AppLabels.settingsDarkMode),
            subtitle: Text(
              themeType == ThemeType.dark
                  ? 'Catppuccin Mocha'
                  : 'Catppuccin Latte',
            ),
            value: themeType == ThemeType.dark,
            onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
            secondary: Icon(
              themeType == ThemeType.dark ? Icons.dark_mode : Icons.light_mode,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 通知設定
        _SectionHeader(title: AppLabels.settingsNotifications, icon: Icons.notifications_outlined),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text(AppLabels.settingsAchievementNotif),
                subtitle: const Text(AppLabels.settingsAchievementNotifDesc),
                value: notifAsync.valueOrNull ?? true,
                onChanged: (value) async {
                  final service = ref.read(notificationServiceProvider);
                  await service.setNotificationsEnabled(value);
                  ref.invalidate(_notificationsEnabledProvider);
                },
                secondary: const Icon(Icons.emoji_events_outlined),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text(AppLabels.settingsReleaseNotes),
                subtitle: const Text(AppLabels.settingsReleaseNotesDesc),
                value: ref.watch(sharedPreferencesProvider).getBool('release_notes_enabled') ?? true,
                onChanged: (value) async {
                  await ref.read(sharedPreferencesProvider).setBool('release_notes_enabled', value);
                  (context as Element).markNeedsBuild();
                },
                secondary: const Icon(Icons.new_releases_outlined),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // データ管理
        _SectionHeader(title: AppLabels.settingsDataManagement, icon: Icons.storage_outlined),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.file_upload_outlined,
                  color: colors.accent,
                ),
                title: const Text(AppLabels.settingsExportData),
                subtitle: const Text(
                  AppLabels.settingsExportDesc,
                ),
                onTap: () => _exportData(context, ref),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  Icons.file_download_outlined,
                  color: colors.success,
                ),
                title: const Text(AppLabels.settingsImportData),
                subtitle: const Text(AppLabels.settingsImportRestoreDesc),
                onTap: () => _importData(context, ref),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.delete_forever_outlined,
                    color: colors.error),
                title: Text(
                  AppLabels.settingsDeleteAll,
                  style: TextStyle(color: colors.error),
                ),
                subtitle: const Text(AppLabels.settingsDeleteWarning),
                onTap: () => _clearAllData(context, ref),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ご利用プラン（v3.1.0 で全機能無料・認証なし）
        if (kIsWeb) ...[
          _SectionHeader(title: AppLabels.settingsPlan, icon: Icons.workspace_premium),
          Card(
            child: ListTile(
              leading: Icon(Icons.workspace_premium, color: colors.success),
              title: const Text(AppLabels.settingsFreePlan),
              subtitle: const Text(AppLabels.settingsFreePlanDesc),
            ),
          ),
          const SizedBox(height: 24),
        ],


        // バージョン情報
        _SectionHeader(title: AppLabels.settingsAppInfo, icon: Icons.info_outlined),
        Card(
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.code),
                title: Text(AppLabels.settingsVersion),
                subtitle: Text(appVersion),
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.update),
                title: Text(AppLabels.settingsLastDeploy),
                subtitle: Text(deployedAt),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.flutter_dash),
                title: const Text('Flutter'),
                subtitle: const Text(AppLabels.settingsPlatform),
                trailing: Icon(
                  Icons.check_circle,
                  color: colors.success,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }



  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      final service = ref.read(dataExportServiceProvider);
      final jsonString = await service.exportData();
      final bytes = Uint8List.fromList(utf8.encode(jsonString));
      final fileName = buildBackupFileName(DateTime.now());

      final saved = await file_io.saveFile(
        bytes: bytes,
        fileName: fileName,
        mimeType: 'application/json',
        allowedExtensions: ['json'],
      );

      if (!context.mounted) return;
      if (saved) {
        showSuccessSnackBar(context, AppLabels.settingsExportSuccess(fileName));
      }
    } on Exception catch (e) {
      if (!context.mounted) return;
      showErrorSnackBar(context, AppLabels.settingsExportError('$e'));
    }
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    final bytes = await file_io.pickFile(allowedExtensions: ['json']);
    if (bytes == null) return;

    final jsonString = utf8.decode(bytes);
    final service = ref.read(dataExportServiceProvider);
    final validation = service.validateJson(jsonString);

    if (!validation.valid) {
      if (!context.mounted) return;
      showErrorSnackBar(context, AppLabels.importError(validation.errorMessage ?? ''));
      return;
    }

    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppLabels.importConfirmTitle),
        content: Text(
          '${AppLabels.importConfirmMsg}\n'
          '${AppLabels.settingsImportOverwriteWarning}\n\n'
          '${AppLabels.settingsImportCounts(
            dreams: validation.counts['dreams'] ?? 0,
            goals: validation.counts['goals'] ?? 0,
            tasks: validation.counts['tasks'] ?? 0,
            books: validation.counts['books'] ?? 0,
            studyLogs: validation.counts['study_logs'] ?? 0,
            notifications: validation.counts['notifications'] ?? 0,
          )}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppLabels.btnCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppLabels.importButton),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final result = await service.importData(jsonString);

      // 全Providerを再読み込みしてUIに反映
      ref.invalidate(dreamListProvider);
      ref.invalidate(goalListProvider);
      ref.invalidate(bookListProvider);

      if (!context.mounted) return;
      showSuccessSnackBar(context, AppLabels.settingsImportResult(
              dreams: result.dreamCount,
              goals: result.goalCount,
              tasks: result.taskCount,
              books: result.bookCount,
              logs: result.studyLogCount,
            ));
    } on Exception catch (e) {
      if (!context.mounted) return;
      showErrorSnackBar(context, AppLabels.importError('$e'));
    }
  }

  Future<void> _clearAllData(BuildContext context, WidgetRef ref) async {
    final colors = Theme.of(context).appColors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppLabels.settingsDeleteAll),
        content: const Text(
          AppLabels.settingsDeleteConfirmMsg,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppLabels.btnCancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppLabels.btnDelete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final service = ref.read(dataExportServiceProvider);
      await service.clearAllData();

      // 全Providerを再読み込みしてUIに反映
      ref.invalidate(dreamListProvider);
      ref.invalidate(goalListProvider);
      ref.invalidate(bookListProvider);

      if (!context.mounted) return;
      showSuccessSnackBar(context, AppLabels.settingsDeleteSuccess);
    } on Exception catch (e) {
      if (!context.mounted) return;
      showErrorSnackBar(context, AppLabels.settingsDeleteError('$e'));
    }
  }
}

/// セクションヘッダー.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.appColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
