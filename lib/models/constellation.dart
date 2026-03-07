/// 星座データモデル.
library;

/// 星の位置（正規化座標 0.0〜1.0）.
class StarPosition {
  /// StarPositionを作成する.
  const StarPosition(this.x, this.y);

  /// X座標（0.0〜1.0）.
  final double x;

  /// Y座標（0.0〜1.0）.
  final double y;
}

/// 星同士の接続線.
class StarConnection {
  /// StarConnectionを作成する.
  const StarConnection(this.fromIndex, this.toIndex);

  /// 始点の星インデックス.
  final int fromIndex;

  /// 終点の星インデックス.
  final int toIndex;
}

/// 星座の定義.
class ConstellationDef {
  /// ConstellationDefを作成する.
  const ConstellationDef({
    required this.id,
    required this.name,
    required this.jaName,
    required this.stars,
    required this.connections,
    required this.symbol,
  });

  /// 一意識別子.
  final String id;

  /// 英語名.
  final String name;

  /// 日本語名.
  final String jaName;

  /// シンボル文字.
  final String symbol;

  /// 星の位置一覧.
  final List<StarPosition> stars;

  /// 接続線一覧.
  final List<StarConnection> connections;

  /// 星の総数.
  int get starCount => stars.length;
}

/// Dream別の星座進捗状態.
class ConstellationProgress {
  /// ConstellationProgressを作成する.
  const ConstellationProgress({
    required this.dreamId,
    required this.dreamTitle,
    required this.constellation,
    required this.totalMinutes,
    required this.litStarCount,
  });

  /// 紐づくDreamのID.
  final String dreamId;

  /// Dreamのタイトル.
  final String dreamTitle;

  /// 割り当てられた星座.
  final ConstellationDef constellation;

  /// 累計学習時間（分）.
  final int totalMinutes;

  /// 点灯済みの星の数.
  final int litStarCount;

  /// 合計学習時間（時間）.
  double get totalHours => totalMinutes / 60.0;

  /// 完成率（0.0〜1.0）.
  double get completionRate =>
      constellation.starCount == 0
          ? 0.0
          : (litStarCount / constellation.starCount).clamp(0.0, 1.0);

  /// 星座が完成しているか.
  bool get isComplete => litStarCount >= constellation.starCount;
}
