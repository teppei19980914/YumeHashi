/// データベースのProvider定義.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'database_provider_native.dart'
    if (dart.library.js_interop) 'database_provider_web.dart' as platform;

/// AppDatabaseのProvider.
///
/// アプリ起動時に一度だけ作成され、アプリ終了まで生存する.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(platform.openConnection());
  ref.onDispose(() => db.close());
  return db;
});
