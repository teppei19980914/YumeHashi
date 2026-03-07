import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_planner/pages/settings_page.dart';

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

    expect(find.text('Study Planner'), findsOneWidget);
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
}
