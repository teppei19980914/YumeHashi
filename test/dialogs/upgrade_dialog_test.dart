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

    expect(find.text('プレミアムプランのご案内'), findsOneWidget);
  });

  testWidgets('サブスクプラン情報が表示される', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('サブスクプラン'), findsOneWidget);
    expect(find.text('¥480/月'), findsOneWidget);
  });

  testWidgets('申し込みボタンが表示される', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('サブスクプランに申し込む'), findsOneWidget);
  });

  testWidgets('プレミアム機能一覧が表示される', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('ガントチャート'), findsOneWidget);
    expect(find.text('Excel出力'), findsOneWidget);
    expect(find.text('目標別統計'), findsOneWidget);
  });

  testWidgets('閉じるボタンでダイアログが閉じる', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('プレミアムプランのご案内'), findsOneWidget);

    await tester.tap(find.text('閉じる'));
    await tester.pumpAndSettle();

    expect(find.text('プレミアムプランのご案内'), findsNothing);
  });
}
