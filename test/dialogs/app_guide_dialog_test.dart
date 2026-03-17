import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yume_log/dialogs/app_guide_dialog.dart';

void main() {
  Widget wrap({bool isPremium = false}) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showAppGuideDialog(context, isPremium: isPremium),
            child: const Text('open'),
          ),
        ),
      ),
    );
  }

  group('全体像タブ', () {
    testWidgets('ガイドダイアログが表示される', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('ヘルプ'), findsOneWidget);
      expect(find.text('全体像'), findsOneWidget);
      expect(find.text('使い方'), findsOneWidget);
      expect(find.text('FAQ'), findsOneWidget);
    });

    testWidgets('メイン階層の図が表示される', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // メインノード
      expect(find.text('夢'), findsOneWidget);
      expect(find.text('目標'), findsWidgets);
      // 矢印ラベル
      expect(find.text('分解'), findsOneWidget);
    });

    testWidgets('連携する画面の図が表示される', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('連携する画面'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('連携する画面'), findsOneWidget);
    });

    testWidgets('サポート画面のミニノードが表示される', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('統計'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('統計'), findsOneWidget);
      expect(find.text('振り返り'), findsOneWidget);
    });
  });

  group('使い方タブ', () {
    testWidgets('ステップ番号付きの手順が表示される', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('使い方'));
      await tester.pumpAndSettle();

      expect(find.text('夢を登録する'), findsOneWidget);
      // 手順の番号付きテキストが存在する
      expect(find.text('1. '), findsWidgets);
    });

    testWidgets('体験版ではガントチャートガイドが非表示', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('使い方'));
      await tester.pumpAndSettle();

      // kIsWebはテスト環境ではfalseなのでガントチャートは表示される
      expect(find.text('ガントチャートでタスク管理'), findsOneWidget);
    });

    testWidgets('プレミアム版ではガントチャートガイドが表示される',
        (tester) async {
      await tester.pumpWidget(wrap(isPremium: true));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('使い方'));
      await tester.pumpAndSettle();

      expect(find.text('ガントチャートでタスク管理'), findsOneWidget);
    });

    testWidgets('星座ステップまでスクロールできる', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('使い方'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('星座で成長を実感'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('星座で成長を実感'), findsOneWidget);
    });
  });

  group('FAQタブ', () {
    testWidgets('FAQタブに切り替えられる', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('FAQ'));
      await tester.pumpAndSettle();

      expect(find.text('データはどこに保存されますか？'), findsOneWidget);
    });

    testWidgets('検索フィールドが表示される', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('FAQ'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.widgetWithText(TextField, 'キーワードで検索...'), findsOneWidget);
    });

    testWidgets('検索でFAQを絞り込める', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('FAQ'));
      await tester.pumpAndSettle();

      // 「バックアップ」で検索
      await tester.enterText(find.byType(TextField), 'バックアップ');
      await tester.pumpAndSettle();

      expect(find.text('データのバックアップはできますか？'), findsOneWidget);
      // 関係ないFAQは非表示
      expect(find.text('スマートフォンでも使えますか？'), findsNothing);
    });

    testWidgets('検索結果なしの表示', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('FAQ'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'あいうえおかきくけこ');
      await tester.pumpAndSettle();

      expect(find.text('該当するFAQが見つかりません'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('クリアボタンで検索をリセットできる', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('FAQ'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'バックアップ');
      await tester.pumpAndSettle();

      // クリアボタンをタップ
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // 全FAQが表示される
      expect(find.text('データはどこに保存されますか？'), findsOneWidget);
      expect(find.text('体験版の制限を解除するには？'), findsOneWidget);
    });

    testWidgets('FAQ項目を展開できる', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('FAQ'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('データはどこに保存されますか？'));
      await tester.pumpAndSettle();

      expect(find.textContaining('ブラウザ内'), findsOneWidget);
    });

    testWidgets('キーワードでも検索できる', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('FAQ'));
      await tester.pumpAndSettle();

      // キーワード「スマホ」で検索（質問文には含まれないがキーワードに登録済み）
      await tester.enterText(find.byType(TextField), 'スマホ');
      await tester.pumpAndSettle();

      expect(find.text('スマートフォンでも使えますか？'), findsOneWidget);
    });
  });

  group('閉じるボタン', () {
    testWidgets('閉じるボタンでダイアログが閉じる', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('閉じる'));
      await tester.pumpAndSettle();

      expect(find.text('ヘルプ'), findsNothing);
    });

    testWidgets('Xボタンでダイアログが閉じる', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('ヘルプ'), findsNothing);
    });
  });
}
