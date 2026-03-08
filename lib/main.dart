/// ユメログ アプリケーションのエントリポイント.
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
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // リモートユーザー設定を取得
  final userConfig = await _initRemoteConfig(prefs);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        remoteConfigProvider.overrideWithValue(userConfig),
      ],
      child: const YumeLogApp(),
    ),
  );
}

/// リモート設定の初期化.
///
/// URLパラメータからキーを取得し、Gistから設定を取得する.
/// resetOnAccessが有効な場合はSharedPreferencesをクリアする.
Future<UserConfig> _initRemoteConfig(SharedPreferences prefs) async {
  if (!kIsWeb) return UserConfig.defaultConfig;

  final service = RemoteConfigService(prefs);

  // URLパラメータからキーを取得（Web限定）
  final urlKey = _getUrlKey();
  if (urlKey != null && urlKey.isNotEmpty) {
    await service.saveUserKey(urlKey);
  }

  // 保存済みキーがなければデフォルト
  if (service.savedUserKey == null) return UserConfig.defaultConfig;

  // Gistから設定を取得
  final config = await service.fetchAndApply();

  // resetOnAccess: アクセス時にデータをリセット
  if (config.resetOnAccess) {
    await service.clearPreferencesExceptKey();
    // データベースリセットのフラグを設定（アプリ起動後に実行）
    await prefs.setBool(resetPendingKey, true);
  }

  return config;
}

/// URLのクエリパラメータからキーを取得する.
String? _getUrlKey() {
  try {
    // Uri.base はFlutter Webで現在のURLを返す
    return Uri.base.queryParameters['key'];
  } on Exception {
    return null;
  }
}
