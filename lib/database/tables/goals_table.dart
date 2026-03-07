/// 目標テーブル定義.
library;

import 'package:drift/drift.dart';

/// 3W1H学習目標テーブル.
class Goals extends Table {
  /// 一意識別子.
  TextColumn get id => text()();

  /// 紐づく夢のID.
  TextColumn get dreamId => text().withDefault(const Constant(''))();

  /// なぜ学習するのか（動機・理由）.
  TextColumn get why => text()();

  /// いつまでに（目標日付または期間の説明）.
  TextColumn get whenTarget => text()();

  /// When指定タイプ（date or period）.
  TextColumn get whenType => text()();

  /// 何を学習するのか.
  TextColumn get what => text()();

  /// どうやって学習するのか.
  TextColumn get how => text()();

  /// 表示色（ガントチャート用）.
  TextColumn get color => text().withDefault(const Constant('#4A9EFF'))();

  /// 作成日時.
  DateTimeColumn get createdAt => dateTime()();

  /// 更新日時.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
