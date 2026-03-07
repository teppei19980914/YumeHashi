/// 目標DAO.
library;

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/goals_table.dart';

part 'goal_dao.g.dart';

/// GoalのCRUD操作を提供するDAO.
@DriftAccessor(tables: [Goals])
class GoalDao extends DatabaseAccessor<AppDatabase> with _$GoalDaoMixin {
  /// GoalDaoを作成する.
  GoalDao(super.db);

  /// 全Goalを取得する.
  Future<List<Goal>> getAll() => select(goals).get();

  /// IDでGoalを取得する.
  Future<Goal?> getById(String goalId) =>
      (select(goals)..where((t) => t.id.equals(goalId))).getSingleOrNull();

  /// Goalを追加する.
  Future<void> insertGoal(GoalsCompanion goal) => into(goals).insert(goal);

  /// Goalを更新する.
  Future<bool> updateGoal(GoalsCompanion goal) async {
    final count = await (update(goals)
          ..where((t) => t.id.equals(goal.id.value)))
        .write(goal);
    return count > 0;
  }

  /// Goalを削除する.
  Future<bool> deleteById(String goalId) async {
    final count =
        await (delete(goals)..where((t) => t.id.equals(goalId))).go();
    return count > 0;
  }
}
