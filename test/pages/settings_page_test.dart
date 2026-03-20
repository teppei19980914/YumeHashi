import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yume_log/pages/settings_page.dart';

import '../helpers/test_helpers.dart';

void main() {
  final setup = TestSetup();

  setUp(() => setup.setUp());
  tearDown(() => setup.tearDown());

  Future<SharedPreferences> getPrefs() async =>
      SharedPreferences.getInstance();

  testWidgets('設定ページが正常にレンダリングされる', (tester) async {
    final prefs = await getPrefs();
    await tester.pumpWidget(
      wrapWithProviders(const SettingsPage(), prefs: prefs, db: setup.db),
    );
    await tester.pumpAndSettle();

    expect(find.text('外観'), findsOneWidget);
    expect(find.text('通知'), findsOneWidget);
    expect(find.text('データ管理'), findsOneWidget);

    // スクロールして下部のセクションを確認
    await tester.scrollUntilVisible(
      find.text('アプリ情報'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('アプリ情報'), findsOneWidget);
  });

  testWidgets('ダークモードスイッチが表示される', (tester) async {
    final prefs = await getPrefs();
    await tester.pumpWidget(
      wrapWithProviders(const SettingsPage(), prefs: prefs, db: setup.db),
    );
    await tester.pumpAndSettle();

    expect(find.text('ダークモード'), findsOneWidget);
    expect(find.text('Catppuccin Mocha'), findsOneWidget);
  });

  testWidgets('通知設定スイッチが表示される', (tester) async {
    final prefs = await getPrefs();
    await tester.pumpWidget(
      wrapWithProviders(const SettingsPage(), prefs: prefs, db: setup.db),
    );
    await tester.pumpAndSettle();

    expect(find.text('実績通知'), findsOneWidget);
  });

  testWidgets('データ管理メニューが表示される', (tester) async {
    final prefs = await getPrefs();
    await tester.pumpWidget(
      wrapWithProviders(const SettingsPage(), prefs: prefs, db: setup.db),
    );
    await tester.pumpAndSettle();

    expect(find.text('データをエクスポート'), findsOneWidget);
    expect(find.text('データをインポート'), findsOneWidget);
    expect(find.text('全データを削除'), findsOneWidget);
  });

  testWidgets('バージョン情報が表示される', (tester) async {
    final prefs = await getPrefs();
    await tester.pumpWidget(
      wrapWithProviders(const SettingsPage(), prefs: prefs, db: setup.db),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('ユメログ'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('ユメログ'), findsOneWidget);
    expect(find.text('1.0.0'), findsOneWidget);
  });

  testWidgets('全削除をタップすると確認ダイアログが表示される', (tester) async {
    final prefs = await getPrefs();
    await tester.pumpWidget(
      wrapWithProviders(const SettingsPage(), prefs: prefs, db: setup.db),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('全データを削除'));
    await tester.pumpAndSettle();

    expect(find.textContaining('すべてのデータを削除します'), findsOneWidget);
    expect(find.text('削除する'), findsOneWidget);
  });

  testWidgets('インポートメニューが表示される（非体験版）', (tester) async {
    // テスト環境では kIsWeb=false のため isTrialMode=false
    // ファイルピッカーはプラットフォームAPIのためタップ動作はテストしない
    final prefs = await getPrefs();
    await tester.pumpWidget(
      wrapWithProviders(const SettingsPage(), prefs: prefs, db: setup.db),
    );
    await tester.pumpAndSettle();

    expect(find.text('データをインポート'), findsOneWidget);
    expect(find.text('バックアップから復元'), findsOneWidget);
  });

  testWidgets('非体験版ではフィードバックセクションが非表示', (tester) async {
    final prefs = await getPrefs();
    await tester.pumpWidget(
      wrapWithProviders(const SettingsPage(), prefs: prefs, db: setup.db),
    );
    await tester.pumpAndSettle();

    // 非体験版（テスト環境）ではフィードバックセクションは非表示
    expect(find.text('フィードバックを送信'), findsNothing);
  });
}
