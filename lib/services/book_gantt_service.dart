/// 書籍ガントチャートのビジネスロジック.
library;

import '../models/book.dart';
import '../models/task.dart';
import 'book_service.dart';
import 'task_service.dart';

/// 書籍ガント用カラー.
const bookGanttColor = '#F9E2AF';

const _statusMap = {
  BookStatus.unread: TaskStatus.notStarted,
  BookStatus.reading: TaskStatus.inProgress,
  BookStatus.completed: TaskStatus.completed,
};

const _reverseStatusMap = {
  TaskStatus.notStarted: BookStatus.unread,
  TaskStatus.inProgress: BookStatus.reading,
  TaskStatus.completed: BookStatus.completed,
};

/// 書籍ガントチャートのビジネスロジックサービス.
class BookGanttService {
  /// BookGanttServiceを作成する.
  BookGanttService({
    required BookService bookService,
    TaskService? taskService,
  })  : _bookService = bookService,
       _taskService = taskService;

  final BookService _bookService;
  final TaskService? _taskService;

  /// スケジュール設定済み書籍を取得する.
  Future<List<Book>> getScheduledBooks() async {
    final books = await _bookService.getAllBooks();
    return books.where((b) => b.hasSchedule).toList();
  }

  /// スケジュール未設定書籍を取得する.
  /// スケジュール未設定かつ読了でない書籍を取得する.
  Future<List<Book>> getUnscheduledBooks() async {
    final books = await _bookService.getAllBooks();
    return books
        .where((b) => !b.hasSchedule && b.status != BookStatus.completed)
        .toList();
  }

  /// BookリストからTaskリストへ変換する.
  List<Task> booksToTasks(List<Book> books) {
    return books.where((b) => b.hasSchedule).map((book) {
      return Task(
        id: book.id,
        goalId: bookGanttGoalId,
        title: '\u{1F4D6} ${book.title}',
        startDate: book.startDate!,
        endDate: book.endDate!,
        status: _statusMap[book.status] ?? TaskStatus.notStarted,
        progress: book.progress,
        bookId: book.id,
      );
    }).toList();
  }

  /// スケジュール付き書籍を作成する.
  Future<Book> createBookWithSchedule({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (endDate.isBefore(startDate)) {
      throw ArgumentError('終了日は開始日以降に設定してください');
    }
    final book = await _bookService.createBook(title);
    final updated = book.copyWith(
      startDate: startDate,
      endDate: endDate,
      status: BookStatus.reading,
      updatedAt: DateTime.now(),
    );
    await _bookService.updateBook(updated);
    return updated;
  }

  /// 書籍のスケジュールを更新する.
  Future<Book?> updateBookSchedule({
    required String bookId,
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required int progress,
  }) async {
    if (title.trim().isEmpty) throw ArgumentError('書籍名は必須です');
    if (progress < 0 || progress > 100) {
      throw ArgumentError('進捗率は0-100の範囲で指定してください');
    }
    if (endDate.isBefore(startDate)) {
      throw ArgumentError('終了日は開始日以降に設定してください');
    }

    final book = await _bookService.getBook(bookId);
    if (book == null) return null;

    final updated = book.copyWith(
      title: title,
      startDate: startDate,
      endDate: endDate,
      progress: progress,
      status: _bookStatusFromProgress(progress),
      updatedAt: DateTime.now(),
    );
    await _bookService.updateBook(updated);
    return updated;
  }

  /// 既存書籍にスケジュールを設定する.
  Future<Book?> setBookSchedule({
    required String bookId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (endDate.isBefore(startDate)) {
      throw ArgumentError('終了日は開始日以降に設定してください');
    }
    final book = await _bookService.getBook(bookId);
    if (book == null) return null;
    final updated = book.copyWith(
      startDate: startDate,
      endDate: endDate,
      updatedAt: DateTime.now(),
    );
    await _bookService.updateBook(updated);
    return updated;
  }

  /// 書籍のスケジュールをクリアする.
  Future<Book?> clearBookSchedule(String bookId) async {
    final book = await _bookService.getBook(bookId);
    if (book == null) return null;
    final updated = book.copyWith(
      clearStartDate: true,
      clearEndDate: true,
      progress: 0,
      updatedAt: DateTime.now(),
    );
    await _bookService.updateBook(updated);
    return updated;
  }

  /// タスクの進捗平均を書籍に同期する.
  Future<void> syncBookProgress(String bookId) async {
    if (_taskService == null) return;
    final book = await _bookService.getBook(bookId);
    if (book == null) return;
    final tasks = await _taskService.getTasksForBook(bookId);

    Book updated;
    if (tasks.isEmpty) {
      updated = book.copyWith(
        progress: 0,
        status: _bookStatusFromProgress(0),
        clearStartDate: true,
        clearEndDate: true,
        updatedAt: DateTime.now(),
      );
    } else {
      final avgProgress =
          (tasks.fold<int>(0, (sum, t) => sum + t.progress) / tasks.length)
              .round();
      final minStart = tasks
          .map((t) => t.startDate)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      final maxEnd = tasks
          .map((t) => t.endDate)
          .reduce((a, b) => a.isAfter(b) ? a : b);
      updated = book.copyWith(
        progress: avgProgress,
        status: _bookStatusFromProgress(avgProgress),
        startDate: minStart,
        endDate: maxEnd,
        updatedAt: DateTime.now(),
      );
    }
    await _bookService.updateBook(updated);
  }

  /// 全書籍タスクを取得する.
  Future<List<Task>> getAllBookTasks() async {
    if (_taskService == null) return [];
    return _taskService.getTasksForGoal(bookGanttGoalId);
  }

  /// BookStatusからTaskStatusへ変換する.
  static TaskStatus bookStatusToTaskStatus(BookStatus bookStatus) {
    return _statusMap[bookStatus] ?? TaskStatus.notStarted;
  }

  /// TaskStatusからBookStatusへ変換する.
  static BookStatus taskStatusToBookStatus(TaskStatus taskStatus) {
    return _reverseStatusMap[taskStatus] ?? BookStatus.unread;
  }

  static BookStatus _bookStatusFromProgress(int progress) {
    if (progress == 0) return BookStatus.unread;
    if (progress >= 100) return BookStatus.completed;
    return BookStatus.reading;
  }
}
