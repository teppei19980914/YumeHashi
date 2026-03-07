/// 夢DAO.
library;

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/dreams_table.dart';

part 'dream_dao.g.dart';

/// DreamのCRUD操作を提供するDAO.
@DriftAccessor(tables: [Dreams])
class DreamDao extends DatabaseAccessor<AppDatabase> with _$DreamDaoMixin {
  /// DreamDaoを作成する.
  DreamDao(super.db);

  /// 全Dreamを取得する.
  Future<List<Dream>> getAll() => select(dreams).get();

  /// IDでDreamを取得する.
  Future<Dream?> getById(String dreamId) =>
      (select(dreams)..where((t) => t.id.equals(dreamId))).getSingleOrNull();

  /// Dreamを追加する.
  Future<void> insertDream(DreamsCompanion dream) =>
      into(dreams).insert(dream);

  /// Dreamを更新する.
  Future<bool> updateDream(DreamsCompanion dream) async {
    final count = await (update(dreams)
          ..where((t) => t.id.equals(dream.id.value)))
        .write(dream);
    return count > 0;
  }

  /// Dreamを削除する.
  Future<bool> deleteById(String dreamId) async {
    final count =
        await (delete(dreams)..where((t) => t.id.equals(dreamId))).go();
    return count > 0;
  }
}
