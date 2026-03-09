/// 星座進捗の計算ロジック.
///
/// 全学習時間の合計から12星座を順番に埋めていく.
library;

import '../data/constellations.dart';
import '../database/daos/study_log_dao.dart';
import '../models/constellation.dart';

/// 総合学習時間ベースの星座進捗を算出するサービス.
class ConstellationService {
  /// ConstellationServiceを作成する.
  ConstellationService({
    required StudyLogDao studyLogDao,
  }) : _studyLogDao = studyLogDao;

  final StudyLogDao _studyLogDao;

  /// 全学習時間を合計し、12星座を順番に埋めた進捗を返す.
  Future<ConstellationOverallProgress> getOverallProgress() async {
    // 全学習ログの合計時間を算出
    final totalMinutes = await _studyLogDao.getTotalMinutes();

    return calculateProgress(totalMinutes);
  }

  /// 合計学習時間（分）から星座進捗を計算する（テスト用に公開）.
  ConstellationOverallProgress calculateProgress(int totalMinutes) {
    var remainingStars = (totalMinutes ~/ minutesPerStar);
    var totalLitStars = 0;
    final totalStars =
        constellations.fold<int>(0, (sum, c) => sum + c.starCount);

    final progressList = <ConstellationProgress>[];
    for (final constellation in constellations) {
      final lit = remainingStars.clamp(0, constellation.starCount);
      remainingStars -= lit;
      totalLitStars += lit;

      progressList.add(ConstellationProgress(
        constellation: constellation,
        litStarCount: lit,
      ));
    }

    return ConstellationOverallProgress(
      constellations: progressList,
      totalMinutes: totalMinutes,
      totalLitStars: totalLitStars,
      totalStars: totalStars,
    );
  }
}
