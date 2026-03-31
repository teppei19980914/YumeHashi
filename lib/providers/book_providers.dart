/// 書籍関連のProvider定義.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/book.dart';
import '../services/sync_manager.dart';
import 'service_providers.dart';

/// 全Book一覧を取得・管理するProvider.
final bookListProvider =
    AsyncNotifierProvider<BookListNotifier, List<Book>>(BookListNotifier.new);

/// BookListのNotifier.
class BookListNotifier extends AsyncNotifier<List<Book>> {
  @override
  Future<List<Book>> build() async {
    final service = ref.watch(bookServiceProvider);
    return service.getAllBooks();
  }

  /// Bookを作成する.
  Future<void> createBook(
    String title, {
    BookCategory category = BookCategory.other,
    String why = '',
    String description = '',
  }) async {
    final service = ref.read(bookServiceProvider);
    final book = await service.createBook(
      title,
      category: category,
      why: why,
      description: description,
    );
    final current = state.valueOrNull ?? [];
    state = AsyncData([...current, book]);
    SyncManager().requestSync();
  }

  /// Bookの基本情報を更新する.
  Future<void> updateBookInfo(
    String bookId, {
    required String title,
    required BookCategory category,
    required String why,
    required String description,
  }) async {
    final service = ref.read(bookServiceProvider);
    final updated = await service.updateBookInfo(
      bookId,
      title: title,
      category: category,
      why: why,
      description: description,
    );
    if (updated != null) {
      final current = state.valueOrNull ?? [];
      state = AsyncData([
        for (final b in current)
          if (b.id == bookId) updated else b,
      ]);
    }
    SyncManager().requestSync();
  }

  /// Bookのステータスを更新する.
  Future<void> updateStatus(String bookId, BookStatus status) async {
    final service = ref.read(bookServiceProvider);
    final updated = await service.updateStatus(bookId, status);
    if (updated != null) {
      final current = state.valueOrNull ?? [];
      state = AsyncData([
        for (final b in current)
          if (b.id == bookId) updated else b,
      ]);
    }
    SyncManager().requestSync();
  }

  /// Bookを読了にする.
  Future<void> completeBook({
    required String bookId,
    required String summary,
    required String impressions,
    DateTime? completedDate,
  }) async {
    final service = ref.read(bookServiceProvider);
    final updated = await service.completeBook(
      bookId: bookId,
      summary: summary,
      impressions: impressions,
      completedDate: completedDate,
    );
    if (updated != null) {
      final current = state.valueOrNull ?? [];
      state = AsyncData([
        for (final b in current)
          if (b.id == bookId) updated else b,
      ]);
    }
    SyncManager().requestSync();
  }

  /// Bookを削除する.
  Future<void> deleteBook(String bookId) async {
    final service = ref.read(bookServiceProvider);
    await service.deleteBook(bookId);
    final current = state.valueOrNull ?? [];
    state = AsyncData([
      for (final b in current)
        if (b.id != bookId) b,
    ]);
    SyncManager().requestSync();
  }
}
