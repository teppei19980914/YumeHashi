/// ガントチャートタスクのビジネスロジック.
library;

import 'package:drift/drift.dart';

import '../database/app_database.dart' as db;
import '../database/daos/task_dao.dart';
import '../models/task.dart';

/// TaskのCRUD操作とビジネスロジックを提供するサービス.
class TaskService {
  /// TaskServiceを作成する.
  TaskService({required TaskDao taskDao}) : _taskDao = taskDao;

  final TaskDao _taskDao;

  /// Goal IDに紐づくTaskを取得する.
  Future<List<Task>> getTasksForGoal(String goalId) async {
    final rows = await _taskDao.getByGoalId(goalId);
    return rows.map(_rowToTask).toList();
  }

  /// Book IDに紐づくTaskを取得する.
  Future<List<Task>> getTasksForBook(String bookId) async {
    final rows = await _taskDao.getByBookId(bookId);
    return rows.map(_rowToTask).toList();
  }

  /// 全Taskを取得する.
  Future<List<Task>> getAllTasks() async {
    final rows = await _taskDao.getAll();
    return rows.map(_rowToTask).toList();
  }

  /// Taskを作成する.
  Future<Task> createTask({
    required String goalId,
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    String memo = '',
    String bookId = '',
  }) async {
    if (title.trim().isEmpty) {
      throw ArgumentError('タスク名は必須です');
    }
    final existing = await _taskDao.getByGoalId(goalId);
    final task = Task(
      goalId: goalId,
      title: title,
      startDate: startDate,
      endDate: endDate,
      memo: memo,
      bookId: bookId,
      order: existing.length,
    );
    await _taskDao.insertTask(_taskToCompanion(task));
    return task;
  }

  /// Taskを更新する.
  Future<Task?> updateTask({
    required String taskId,
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required int progress,
    String memo = '',
    String bookId = '',
    String? goalId,
  }) async {
    if (title.trim().isEmpty) throw ArgumentError('タイトルは必須です');
    if (progress < 0 || progress > 100) {
      throw ArgumentError('進捗率は0-100の範囲で指定してください');
    }
    if (endDate.isBefore(startDate)) {
      throw ArgumentError('終了日は開始日以降に設定してください');
    }

    final existing = await _taskDao.getById(taskId);
    if (existing == null) return null;

    final updated = _rowToTask(existing).copyWith(
      title: title,
      startDate: startDate,
      endDate: endDate,
      progress: progress,
      status: _statusFromProgress(progress),
      memo: memo,
      bookId: bookId,
      goalId: goalId ?? existing.goalId,
      updatedAt: DateTime.now(),
    );
    await _taskDao.updateTask(_taskToCompanion(updated));
    return updated;
  }

  /// Taskを削除する.
  Future<bool> deleteTask(String taskId) => _taskDao.deleteById(taskId);

  /// タスクの進捗を更新する.
  Future<Task?> updateProgress(String taskId, int progress) async {
    if (progress < 0 || progress > 100) {
      throw ArgumentError('進捗率は0-100の範囲で指定してください');
    }
    final existing = await _taskDao.getById(taskId);
    if (existing == null) return null;

    final updated = _rowToTask(existing).copyWith(
      progress: progress,
      status: _statusFromProgress(progress),
      updatedAt: DateTime.now(),
    );
    await _taskDao.updateTask(_taskToCompanion(updated));
    return updated;
  }

  /// 進捗率からステータスを判定する.
  static TaskStatus _statusFromProgress(int progress) {
    if (progress == 0) return TaskStatus.notStarted;
    if (progress >= 100) return TaskStatus.completed;
    return TaskStatus.inProgress;
  }

  Task _rowToTask(db.Task row) {
    return Task(
      id: row.id,
      goalId: row.goalId,
      title: row.title,
      startDate: row.startDate,
      endDate: row.endDate,
      status: TaskStatus.fromValue(row.status),
      progress: row.progress,
      memo: row.memo,
      bookId: row.bookId,
      order: row.order,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  db.TasksCompanion _taskToCompanion(Task task) {
    return db.TasksCompanion(
      id: Value(task.id),
      goalId: Value(task.goalId),
      title: Value(task.title),
      startDate: Value(task.startDate),
      endDate: Value(task.endDate),
      status: Value(task.status.value),
      progress: Value(task.progress),
      memo: Value(task.memo),
      bookId: Value(task.bookId),
      order: Value(task.order),
      createdAt: Value(task.createdAt),
      updatedAt: Value(task.updatedAt),
    );
  }
}
