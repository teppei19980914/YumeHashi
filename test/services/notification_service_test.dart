import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yume_log/database/app_database.dart';
import 'package:yume_log/models/notification.dart';
import 'package:yume_log/services/notification_service.dart';

void main() {
  late AppDatabase db;
  late NotificationService service;

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    service = NotificationService(notificationDao: db.notificationDao);
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() => db.close());

  group('NotificationService', () {
    group('syncSystemNotificationsFromJson', () {
      test('JSON文字列から通知を同期する', () async {
        const jsonStr =
            '[{"dedup_key":"sys:v1","title":"お知らせ","message":"テスト"}]';
        final result =
            await service.syncSystemNotificationsFromJson(jsonStr);
        expect(result.notifications.length, 1);
        expect(result.notifications.first.notificationType,
            NotificationType.system);
        expect(result.notifications.first.title, 'お知らせ');
      });

      test('再同期で既存の通知は保持され新規のみ追加される', () async {
        const jsonStr1 =
            '[{"dedup_key":"sys:v1","title":"旧お知らせ","message":"旧"}]';
        await service.syncSystemNotificationsFromJson(jsonStr1);

        const jsonStr2 =
            '[{"dedup_key":"sys:v1","title":"旧お知らせ","message":"旧"},'
            '{"dedup_key":"sys:v2","title":"新お知らせ","message":"新"}]';
        final result =
            await service.syncSystemNotificationsFromJson(jsonStr2);

        // 新規のsys:v2のみ追加される
        expect(result.notifications.length, 1);
        expect(result.notifications.first.title, '新お知らせ');

        final all = await service.getAllNotifications();
        final systemNotifs =
            all.where((n) => n.notificationType == NotificationType.system);
        expect(systemNotifs.length, 2);
      });

      test('空JSONで再同期しても既存の通知は保持される', () async {
        const jsonStr =
            '[{"dedup_key":"sys:v1","title":"A","message":"B"}]';
        await service.syncSystemNotificationsFromJson(jsonStr);

        await service.syncSystemNotificationsFromJson('[]');

        final all = await service.getAllNotifications();
        final systemNotifs =
            all.where((n) => n.notificationType == NotificationType.system);
        expect(systemNotifs.length, 1);
      });

      test('リマインダー通知はシステム同期で削除されない', () async {
        // リマインダーを手動追加
        await db.notificationDao.insertNotification(
          NotificationsCompanion(
            id: const Value('reminder-1'),
            notificationType: const Value('reminder'),
            title: const Value('期限通知'),
            message: const Value('テスト'),
            isRead: const Value(false),
            createdAt: Value(DateTime.now()),
            dedupKey: const Value('reminder:task:t1:due_7days'),
          ),
        );

        // システム通知を同期（空）
        await service.syncSystemNotificationsFromJson('[]');

        final all = await service.getAllNotifications();
        expect(all.length, 1);
        expect(all.first.notificationType, NotificationType.reminder);
      });

      test('空のdedup_keyはスキップする', () async {
        const jsonStr =
            '[{"dedup_key":"","title":"A","message":"B"}]';
        final result =
            await service.syncSystemNotificationsFromJson(jsonStr);
        expect(result.notifications, isEmpty);
      });

      test('不正なJSONで空リスト', () async {
        final result =
            await service.syncSystemNotificationsFromJson('invalid');
        expect(result.notifications, isEmpty);
      });

      test('dateを指定するとcreatedAtに反映される', () async {
        const jsonStr = '['
            '{"dedup_key":"sys:dated","title":"日付指定","message":"テスト",'
            '"date":"2025-01-01"}'
            ']';
        final result =
            await service.syncSystemNotificationsFromJson(jsonStr);
        expect(result.notifications.length, 1);
        final all = await service.getAllNotifications();
        expect(all.first.createdAt.year, 2025);
        expect(all.first.createdAt.month, 1);
        expect(all.first.createdAt.day, 1);
      });

      test('未来の日付の通知はスキップされる（予約通知）', () async {
        const jsonStr = '['
            '{"dedup_key":"sys:future","title":"未来の通知","message":"テスト",'
            '"date":"2099-12-31"}'
            ']';
        final result =
            await service.syncSystemNotificationsFromJson(jsonStr);
        expect(result.notifications, isEmpty);

        final all = await service.getAllNotifications();
        expect(all, isEmpty);
      });

      test('過去の通知は表示され未来の通知はスキップされる', () async {
        const jsonStr = '['
            '{"dedup_key":"sys:past","title":"過去の通知","message":"A",'
            '"date":"2025-01-01"},'
            '{"dedup_key":"sys:future","title":"未来の通知","message":"B",'
            '"date":"2099-12-31"}'
            ']';
        final result =
            await service.syncSystemNotificationsFromJson(jsonStr);
        expect(result.notifications.length, 1);
        expect(result.notifications.first.title, '過去の通知');
      });
    });
  });
}
