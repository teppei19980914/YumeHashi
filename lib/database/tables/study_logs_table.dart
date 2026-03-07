/// 学習ログテーブル定義.
library;

import 'package:drift/drift.dart';

/// 学習ログテーブル.
class StudyLogs extends Table {
  /// 一意識別子.
  TextColumn get id => text()();

  /// 紐づくTaskのID.
  TextColumn get taskId => text()();

  /// 学習実施日.
  DateTimeColumn get studyDate => dateTime()();

  /// 学習時間（分単位）.
  IntColumn get durationMinutes => integer()();

  /// メモ.
  TextColumn get memo => text().withDefault(const Constant(''))();

  /// タスク名（記録時に保存、削除後も表示用）.
  TextColumn get taskName => text().withDefault(const Constant(''))();

  /// 作成日時.
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
