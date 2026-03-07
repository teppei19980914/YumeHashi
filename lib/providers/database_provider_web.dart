/// Web プラットフォーム用データベース接続.
library;

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
// ignore: experimental_member_use
import 'package:sqlite3/wasm.dart';

/// Web環境でのデータベース接続を作成する.
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final sqlite3 = await WasmSqlite3.loadFromUrl(
      Uri.parse('sqlite3.wasm'),
    );
    sqlite3.registerVirtualFileSystem(
      InMemoryFileSystem(),
      makeDefault: true,
    );
    return WasmDatabase(sqlite3: sqlite3, path: 'study_planner.db');
  });
}
