/// テスト用インメモリデータベース.
library;

import 'package:drift/native.dart';
import 'package:study_planner/database/app_database.dart';

/// テスト用のインメモリAppDatabaseを作成する.
AppDatabase createTestDatabase() {
  return AppDatabase(NativeDatabase.memory());
}
