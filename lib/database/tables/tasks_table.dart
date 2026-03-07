/// タスクテーブル定義.
library;

import 'package:drift/drift.dart';

/// ガントチャートタスクテーブル.
class Tasks extends Table {
  /// 一意識別子.
  TextColumn get id => text()();

  /// 紐づくGoalのID.
  TextColumn get goalId => text()();

  /// タスク名.
  TextColumn get title => text()();

  /// 開始日.
  DateTimeColumn get startDate => dateTime()();

  /// 終了日.
  DateTimeColumn get endDate => dateTime()();

  /// ステータス（not_started, in_progress, completed）.
  TextColumn get status => text().withDefault(const Constant('not_started'))();

  /// 進捗率（0-100）.
  IntColumn get progress => integer().withDefault(const Constant(0))();

  /// メモ.
  TextColumn get memo => text().withDefault(const Constant(''))();

  /// 紐づく書籍ID.
  TextColumn get bookId => text().withDefault(const Constant(''))();

  /// 表示順序.
  IntColumn get order => integer().withDefault(const Constant(0))();

  /// 作成日時.
  DateTimeColumn get createdAt => dateTime()();

  /// 更新日時.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
