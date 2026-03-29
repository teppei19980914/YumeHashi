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

      test('再同期で既存のシステム通知が上書きされる', () async {
        const jsonStr1 =
            '[{"dedup_key":"sys:v1","title":"旧お知らせ","message":"旧"}]';
        await service.syncSystemNotificationsFromJson(jsonStr1);

        const jsonStr2 =
            '[{"dedup_key":"sys:v2","title":"新お知らせ","message":"新"}]';
        await service.syncSystemNotificationsFromJson(jsonStr2);

        final all = await service.getAllNotifications();
        final systemNotifs =
            all.where((n) => n.notificationType == NotificationType.system);
        expect(systemNotifs.length, 1);
        expect(systemNotifs.first.title, '新お知らせ');
      });

      test('空JSONで既存のシステム通知が全削除される', () async {
        const jsonStr =
            '[{"dedup_key":"sys:v1","title":"A","message":"B"}]';
        await service.syncSystemNotificationsFromJson(jsonStr);

        await service.syncSystemNotificationsFromJson('[]');

        final all = await service.getAllNotifications();
        final systemNotifs =
            all.where((n) => n.notificationType == NotificationType.system);
        expect(systemNotifs, isEmpty);
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
            '"date":"2026-04-01"}'
            ']';
        final result =
            await service.syncSystemNotificationsFromJson(jsonStr);
        expect(result.notifications.length, 1);
        final all = await service.getAllNotifications();
        expect(all.first.createdAt.year, 2026);
        expect(all.first.createdAt.month, 4);
        expect(all.first.createdAt.day, 1);
      });
    });
  });
}
