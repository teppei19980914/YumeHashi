/// ユメハシ アプリケーションのエントリポイント.
library;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'providers/service_providers.dart';
import 'providers/theme_provider.dart';
import 'services/firestore_sync_service.dart';
import 'services/remote_config_service.dart';

/// アプリケーションのエントリポイント.
///
/// v3.0.0: 完全無料化に伴い、Stripe 検証・招待コード処理・プレミアム状態
/// キャッシュ適用を削除. 起動時の外部通信は匿名認証とリモート設定のみ.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
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

  // 初回フレーム描画が完了した後に外部通信・データクリーンアップを開始する.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initRemoteConfigAsync(prefs, container);
    _initAnonymousAuth();
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

/// Web起動時にFirebase匿名認証を自動実行する.
///
/// ユーザー操作なしでUIDが発行され、以降のデータ同期の基盤となる.
/// 既にサインイン済み（匿名・メール問わず）の場合は何もしない.
Future<void> _initAnonymousAuth() async {
  if (!kIsWeb) return;
  try {
    await FirestoreSyncService().ensureSignedIn();
  } on Exception {
    // 認証失敗時はローカルのみで動作（次回起動時にリトライ）
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
