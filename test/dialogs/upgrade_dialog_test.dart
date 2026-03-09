import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yume_log/dialogs/upgrade_dialog.dart';

void main() {
  Widget buildApp() {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => showUpgradeDialog(context),
            child: const Text('Open'),
          ),
        ),
      ),
    );
  }

  testWidgets('タイトルが表示される', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('無制限プランのご案内'), findsOneWidget);
  });

  testWidgets('ネイティブアプリ購入オプションが表示される', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('ネイティブアプリを購入'), findsOneWidget);
  });

  testWidgets('Web版無制限化オプションが表示される', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Web版を無制限化'), findsOneWidget);
  });

  testWidgets('相互独立の注意書きが表示される', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('ネイティブアプリとWeb版は別々のサービスです'),
      findsOneWidget,
    );
    expect(
      find.textContaining('それぞれ別途ご購入が必要です'),
      findsOneWidget,
    );
  });

  testWidgets('閉じるボタンでダイアログが閉じる', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('無制限プランのご案内'), findsOneWidget);

    await tester.tap(find.text('閉じる'));
    await tester.pumpAndSettle();

    expect(find.text('無制限プランのご案内'), findsNothing);
  });
}
