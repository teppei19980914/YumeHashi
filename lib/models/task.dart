/// ガントチャートタスクのデータモデル.
library;

import 'package:uuid/uuid.dart';

/// タスクのステータス.
enum TaskStatus {
  /// 未着手.
  notStarted('not_started'),

  /// 進行中.
  inProgress('in_progress'),

  /// 完了.
  completed('completed');

  const TaskStatus(this.value);

  /// JSON保存用の値.
  final String value;

  /// 文字列値からTaskStatusを生成する.
  static TaskStatus fromValue(String value) {
    return TaskStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid TaskStatus value: $value'),
    );
  }
}

/// 書籍ガント用の特殊Goal ID.
const String bookGanttGoalId = '__books__';

/// ガントチャートタスクモデル.
class Task {
  /// ガントチャートタスクを作成する.
  ///
  /// [progress]は0-100の範囲、[endDate]は[startDate]以降である必要がある.
  Task({
    required this.goalId,
    required this.title,
    required this.startDate,
    required this.endDate,
    String? id,
    this.status = TaskStatus.notStarted,
    this.progress = 0,
    this.memo = '',
    this.bookId = '',
    this.order = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now() {
    if (progress < 0 || progress > 100) {
      throw ArgumentError('進捗率は0-100の範囲で指定してください: $progress');
    }
    if (endDate.isBefore(startDate)) {
      throw ArgumentError(
        '終了日は開始日以降に設定してください: $startDate > $endDate',
      );
    }
  }

  /// 一意識別子.
  final String id;

  /// 紐づくGoalのID.
  final String goalId;

  /// タスク名.
  final String title;

  /// 開始日.
  final DateTime startDate;

  /// 終了日.
  final DateTime endDate;

  /// ステータス.
  final TaskStatus status;

  /// 進捗率（0-100）.
  final int progress;

  /// メモ.
  final String memo;

  /// 紐づく書籍ID.
  final String bookId;

  /// 表示順序.
  final int order;

  /// 作成日時.
  final DateTime createdAt;

  /// 更新日時.
  final DateTime updatedAt;

  /// タスクの日数（開始日から終了日まで、両端含む）.
  int get durationDays {
    return endDate.difference(startDate).inDays + 1;
  }

  /// フィールドを変更したコピーを返す.
  Task copyWith({
    String? id,
    String? goalId,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    TaskStatus? status,
    int? progress,
    String? memo,
    String? bookId,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      memo: memo ?? this.memo,
      bookId: bookId ?? this.bookId,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Mapに変換する（JSON保存用）.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'title': title,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status.value,
      'progress': progress,
      'memo': memo,
      'book_id': bookId,
      'order': order,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// MapからTaskを生成する.
  factory Task.fromMap(Map<String, dynamic> data) {
    return Task(
      id: data['id'] as String,
      goalId: data['goal_id'] as String,
      title: data['title'] as String,
      startDate: DateTime.parse(data['start_date'] as String),
      endDate: DateTime.parse(data['end_date'] as String),
      status: TaskStatus.fromValue(data['status'] as String),
      progress: data['progress'] as int,
      memo: (data['memo'] as String?) ?? '',
      bookId: (data['book_id'] as String?) ?? '',
      order: (data['order'] as int?) ?? 0,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Task && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Task(id: $id, title: $title)';
}
