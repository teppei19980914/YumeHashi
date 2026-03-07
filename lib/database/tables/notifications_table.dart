/// 通知テーブル定義.
library;

import 'package:drift/drift.dart';

/// 通知テーブル.
class Notifications extends Table {
  /// 一意識別子.
  TextColumn get id => text()();

  /// 通知種別（system, achievement）.
  TextColumn get notificationType => text()();

  /// 通知タイトル.
  TextColumn get title => text()();

  /// 通知メッセージ.
  TextColumn get message => text()();

  /// 既読フラグ.
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();

  /// 作成日時.
  DateTimeColumn get createdAt => dateTime()();

  /// 重複防止キー.
  TextColumn get dedupKey => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}
