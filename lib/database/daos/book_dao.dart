/// 書籍DAO.
library;

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/books_table.dart';

part 'book_dao.g.dart';

/// BookのCRUD操作を提供するDAO.
@DriftAccessor(tables: [Books])
class BookDao extends DatabaseAccessor<AppDatabase> with _$BookDaoMixin {
  /// BookDaoを作成する.
  BookDao(super.db);

  /// 全Bookを取得する.
  Future<List<Book>> getAll() => select(books).get();

  /// IDでBookを取得する.
  Future<Book?> getById(String bookId) =>
      (select(books)..where((t) => t.id.equals(bookId))).getSingleOrNull();

  /// Bookを追加する.
  Future<void> insertBook(BooksCompanion book) => into(books).insert(book);

  /// Bookを更新する.
  Future<bool> updateBook(BooksCompanion book) async {
    final count = await (update(books)
          ..where((t) => t.id.equals(book.id.value)))
        .write(book);
    return count > 0;
  }

  /// Bookを削除する.
  Future<bool> deleteById(String bookId) async {
    final count =
        await (delete(books)..where((t) => t.id.equals(bookId))).go();
    return count > 0;
  }
}
