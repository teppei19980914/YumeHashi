/// 星座進捗の計算ロジック.
library;

import '../data/constellations.dart';
import '../database/daos/goal_dao.dart';
import '../database/daos/study_log_dao.dart';
import '../database/daos/task_dao.dart';
import '../models/constellation.dart';
import '../models/dream.dart';

/// Dream別の星座進捗を算出するサービス.
class ConstellationService {
  /// ConstellationServiceを作成する.
  ConstellationService({
    required GoalDao goalDao,
    required TaskDao taskDao,
    required StudyLogDao studyLogDao,
  })  : _goalDao = goalDao,
        _taskDao = taskDao,
        _studyLogDao = studyLogDao;

  final GoalDao _goalDao;
  final TaskDao _taskDao;
  final StudyLogDao _studyLogDao;

  /// 全Dreamの星座進捗を取得する.
  Future<List<ConstellationProgress>> getAllProgress(
    List<Dream> dreams,
  ) async {
    if (dreams.isEmpty) return [];

    final allGoals = await _goalDao.getAll();
    final allTasks = await _taskDao.getAll();

    // goalId → dreamId マップ
    final goalDreamMap = <String, String>{
      for (final g in allGoals) g.id: g.dreamId,
    };

    // dreamId → 集計用taskIds
    final dreamTaskIds = <String, List<String>>{};
    for (final task in allTasks) {
      final dreamId = goalDreamMap[task.goalId];
      if (dreamId != null && dreamId.isNotEmpty) {
        dreamTaskIds.putIfAbsent(dreamId, () => []).add(task.id);
      }
    }

    // 全ログを一括取得してdreamId別に集計
    final allTaskIds =
        dreamTaskIds.values.expand((ids) => ids).toList();
    final allLogs = allTaskIds.isEmpty
        ? <dynamic>[]
        : await _studyLogDao.getByTaskIds(allTaskIds);

    // taskId → durationMinutesの合計
    final taskMinutes = <String, int>{};
    for (final log in allLogs) {
      taskMinutes[log.taskId] =
          (taskMinutes[log.taskId] ?? 0) + (log.durationMinutes as int);
    }

    // dreamId → 合計分
    final dreamMinutes = <String, int>{};
    for (final entry in dreamTaskIds.entries) {
      var total = 0;
      for (final taskId in entry.value) {
        total += taskMinutes[taskId] ?? 0;
      }
      dreamMinutes[entry.key] = total;
    }

    // Dream ごとに ConstellationProgress を生成
    final results = <ConstellationProgress>[];
    for (var i = 0; i < dreams.length; i++) {
      final dream = dreams[i];
      final totalMin = dreamMinutes[dream.id] ?? 0;
      final constellation = getConstellationForIndex(i);
      final litCount =
          (totalMin ~/ minutesPerStar).clamp(0, constellation.starCount);

      results.add(ConstellationProgress(
        dreamId: dream.id,
        dreamTitle: dream.title,
        constellation: constellation,
        totalMinutes: totalMin,
        litStarCount: litCount,
      ));
    }
    return results;
  }
}
