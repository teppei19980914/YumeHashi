/// ユメハシ アプリケーションのエントリポイント.
library;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'providers/service_providers.dart';
import 'providers/theme_provider.dart';
import 'services/remote_config_service.dart';

/// アプリケーションのエントリポイント.
///
/// v3.1.0: 認証機能（Firebase Auth）とクラウド同期（Firestore）を停止.
/// データはブラウザ内 SQLite (WASM) のみで管理する.
/// Firebase 初期化・匿名認証・クラウド同期処理を全て削除.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // URLキーの保存は同期的に実施（軽量なSharedPreferences操作のみ）
  _saveUrlKeyIfPresent(prefs);

  // リモート設定をバックグラウンドで取得
  // デフォルト設定で即座にアプリを起動し、取得完了後にプロバイダを更新する
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      remoteConfigProvider.overrideWithValue(UserConfig.defaultConfig),
    ],
  );

  // アプリを即座に表示
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const YumeHashiApp(),
    ),
  );

  // 初回フレーム描画が完了した後にデータクリーンアップを開始する.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initRemoteConfigAsync(prefs, container);
    _runDataRetentionCleanup(container);
  });
}

/// データ保持期間を超えた古いデータを物理削除する.
///
/// 既読かつ 30 日以上経過した通知、および完了済みかつ 30 日以上更新されて
/// いないタスクを削除する. 起動時に 1 回だけ実行. 失敗してもアプリ本体には
/// 影響しない (例外は DataRetentionService 内で吸収).
Future<void> _runDataRetentionCleanup(ProviderContainer container) async {
  try {
    final service = container.read(dataRetentionServiceProvider);
    await service.cleanup();
  } on Object {
    // クリーンアップの失敗はアプリ動作に影響させない
  }
}

/// URLキーをSharedPreferencesに保存する（同期的）.
void _saveUrlKeyIfPresent(SharedPreferences prefs) {
  if (!kIsWeb) return;
  final urlKey = _getUrlKey();
  if (urlKey != null && urlKey.isNotEmpty) {
    RemoteConfigService(prefs).saveUserKey(urlKey);
  }
}

/// リモート設定を非同期で取得し、プロバイダを更新する.
Future<void> _initRemoteConfigAsync(
  SharedPreferences prefs,
  ProviderContainer container,
) async {
  if (!kIsWeb) return;

  final service = RemoteConfigService(prefs);
  if (service.savedUserKey == null) return;

  try {
    final config = await service.fetchAndApply();

    // プロバイダを更新（UIが自動的に再構築される）
    container.updateOverrides([
      sharedPreferencesProvider.overrideWithValue(prefs),
      remoteConfigProvider.overrideWithValue(config),
    ]);

    // resetOnAccess: アクセス時にデータをリセット
    if (config.resetOnAccess) {
      await service.clearPreferencesExceptKey();
      await prefs.setBool(resetPendingKey, true);
    }
  } on Exception {
    // リモート設定取得失敗時はデフォルト設定のまま動作する
  }
}

/// URLのクエリパラメータを取得する.
String? _getUrlParam(String name) {
  try {
    return Uri.base.queryParameters[name];
  } on Exception {
    return null;
  }
}

/// URLのクエリパラメータからキーを取得する.
String? _getUrlKey() => _getUrlParam('key');
