/// デモデータ投入サービス.
///
/// アプリの画面キャプチャ・説明資料用のサンプルデータを生成する.
/// SharedPreferences の 'demo_data_seeded' フラグで二重投入を防止する.
library;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/book.dart';
import '../models/goal.dart';
import 'book_service.dart';
import 'dream_service.dart';
import 'goal_service.dart';
import 'study_log_service.dart';
import 'task_service.dart';

const _seededKey = 'demo_data_seeded';

/// デモデータが投入済みかどうか.
bool isDemoDataSeeded(SharedPreferences prefs) =>
    prefs.getBool(_seededKey) ?? false;

/// デモデータを投入する.
///
/// 既に投入済みの場合は何もしない.
Future<void> seedDemoData({
  required SharedPreferences prefs,
  required DreamService dreamService,
  required GoalService goalService,
  required TaskService taskService,
  required BookService bookService,
  required StudyLogService studyLogService,
}) async {
  if (isDemoDataSeeded(prefs)) return;

  final now = DateTime.now();

  // ══════════════════════════════════════════════
  // 夢 1: ITエンジニアとして独立する
  // ══════════════════════════════════════════════
  final dream1 = await dreamService.createDream(
    title: 'ITエンジニアとして独立する',
    description: '自分のプロダクトで世の中に価値を届けたい',
    why: '自由な働き方で、好きな技術に没頭したい',
    category: 'career',
  );

  // 目標 1-1: AWS資格を取得する
  final goal1 = await goalService.createGoal(
    dreamId: dream1.id,
    what: 'AWS ソリューションアーキテクト資格を取得する',
    how: '公式教材と模擬試験を毎日1時間進める',
    whenTarget: DateTime(now.year, now.month + 3, 1)
        .toIso8601String()
        .substring(0, 10),
    whenType: WhenType.date,
  );

  final task1a = await taskService.createTask(
    goalId: goal1.id,
    title: '公式教材を1章ずつ進める',
    startDate: DateTime(now.year, now.month - 1, 1),
    endDate: DateTime(now.year, now.month + 1, 15),
    memo: 'AWS Certified Solutions Architect - Associate',
  );
  await taskService.updateProgress(task1a.id, 65);

  final task1b = await taskService.createTask(
    goalId: goal1.id,
    title: '模擬試験を解く（5回分）',
    startDate: DateTime(now.year, now.month, 1),
    endDate: DateTime(now.year, now.month + 2, 28),
  );
  await taskService.updateProgress(task1b.id, 20);

  // 目標 1-2: Flutter アプリをリリースする
  final goal2 = await goalService.createGoal(
    dreamId: dream1.id,
    what: 'Flutter アプリをリリースする',
    how: '毎日2時間コーディングし、月1回リリースする',
    whenTarget: DateTime(now.year, now.month + 2, 1)
        .toIso8601String()
        .substring(0, 10),
    whenType: WhenType.date,
  );

  final task2a = await taskService.createTask(
    goalId: goal2.id,
    title: 'Dart の基礎文法をマスターする',
    startDate: DateTime(now.year, now.month - 2, 1),
    endDate: DateTime(now.year, now.month - 1, 15),
  );
  await taskService.updateProgress(task2a.id, 100);

  final task2b = await taskService.createTask(
    goalId: goal2.id,
    title: 'UI設計とウィジェット実装',
    startDate: DateTime(now.year, now.month - 1, 1),
    endDate: DateTime(now.year, now.month, 20),
  );
  await taskService.updateProgress(task2b.id, 80);

  final task2c = await taskService.createTask(
    goalId: goal2.id,
    title: 'Firebase連携とデプロイ',
    startDate: DateTime(now.year, now.month, 1),
    endDate: DateTime(now.year, now.month + 1, 30),
  );
  await taskService.updateProgress(task2c.id, 30);

  // ══════════════════════════════════════════════
  // 夢 2: 健康的な体を手に入れる
  // ══════════════════════════════════════════════
  final dream2 = await dreamService.createDream(
    title: '健康的な体を手に入れる',
    description: '心身ともに健やかでいられる生活習慣を確立する',
    why: '仕事のパフォーマンスを最大化するため',
    category: 'health',
  );

  final goal3 = await goalService.createGoal(
    dreamId: dream2.id,
    what: 'フルマラソンを完走する',
    how: '週3回のランニングと月1回の長距離走',
    whenTarget: DateTime(now.year, 11, 1)
        .toIso8601String()
        .substring(0, 10),
    whenType: WhenType.date,
  );

  final task3a = await taskService.createTask(
    goalId: goal3.id,
    title: '5km ランニングを週3回',
    startDate: DateTime(now.year, now.month - 1, 1),
    endDate: DateTime(now.year, now.month + 3, 30),
  );
  await taskService.updateProgress(task3a.id, 40);

  final task3b = await taskService.createTask(
    goalId: goal3.id,
    title: 'ハーフマラソンに出場する',
    startDate: DateTime(now.year, now.month + 1, 1),
    endDate: DateTime(now.year, now.month + 4, 30),
  );
  await taskService.updateProgress(task3b.id, 0);

  // ══════════════════════════════════════════════
  // 夢 3: 年間50冊読書する
  // ══════════════════════════════════════════════
  final dream3 = await dreamService.createDream(
    title: '年間50冊の本を読む',
    description: '幅広い分野の知識を吸収し、視野を広げる',
    why: '読書は最高の自己投資だから',
    category: 'learning',
  );

  final goal4 = await goalService.createGoal(
    dreamId: dream3.id,
    what: '毎月4冊以上読了する',
    how: '通勤時間と就寝前の30分を読書に充てる',
    whenTarget: DateTime(now.year, 12, 31)
        .toIso8601String()
        .substring(0, 10),
    whenType: WhenType.date,
  );

  final task4a = await taskService.createTask(
    goalId: goal4.id,
    title: '今月の読書リストを作成する',
    startDate: DateTime(now.year, now.month, 1),
    endDate: DateTime(now.year, now.month, 7),
  );
  await taskService.updateProgress(task4a.id, 100);

  // ══════════════════════════════════════════════
  // 書籍
  // ══════════════════════════════════════════════
  final book1 = await bookService.createBook(
    '7つの習慣',
    category: BookCategory.selfHelp,
    why: '成功の原則を体系的に学びたい',
    description: '主体的であること、終わりを思い描くことから始める',
  );
  await bookService.updateStatus(book1.id, BookStatus.reading);

  await bookService.createBook(
    'Clean Architecture',
    category: BookCategory.it,
    why: 'ソフトウェア設計の原則を深く理解したい',
    description: '依存関係の方向を制御する設計手法',
  );

  final book3 = await bookService.createBook(
    'リーダブルコード',
    category: BookCategory.it,
    why: '読みやすいコードを書く技術を身につけたい',
  );
  await bookService.completeBook(
    bookId: book3.id,
    summary: 'コードは他人が読むものとして書く',
    impressions: '変数名・関数名の付け方が劇的に変わった。チーム開発で即実践できる。',
    completedDate: DateTime(now.year, now.month - 1, 20),
  );

  await bookService.createBook(
    '嫌われる勇気',
    category: BookCategory.selfHelp,
    why: '対人関係の悩みを整理したい',
  );

  final book5 = await bookService.createBook(
    '失敗の科学',
    category: BookCategory.business,
    why: '失敗から学ぶ仕組みを知りたい',
    description: '失敗を検知するためには、失敗を報告できるシステムと人が必要',
  );
  await bookService.updateStatus(book5.id, BookStatus.reading);

  await bookService.createBook(
    'イシューからはじめよ',
    category: BookCategory.business,
    why: '本当に解くべき問題を見極めたい',
  );

  final book7 = await bookService.createBook(
    'FACTFULNESS',
    category: BookCategory.academic,
    why: 'データに基づく正しい世界の見方を学びたい',
  );
  await bookService.completeBook(
    bookId: book7.id,
    summary: '10の思い込みを乗り越えてデータで世界を見る',
    impressions: '自分の先入観に気づけた。メディアの情報を鵜呑みにしない習慣が身についた。',
    completedDate: DateTime(now.year, now.month - 1, 5),
  );

  await bookService.createBook(
    'エッセンシャル思考',
    category: BookCategory.selfHelp,
    why: '本当に大事なことだけに集中したい',
  );

  // ══════════════════════════════════════════════
  // 活動ログ（星座・統計用）
  // ══════════════════════════════════════════════
  // 過去30日分の活動ログを生成（星座を数個光らせるため）
  for (var i = 30; i >= 1; i--) {
    final date = now.subtract(Duration(days: i));
    // 平日は多め、休日は少なめ
    final isWeekday = date.weekday <= 5;
    final minutes = isWeekday ? 90 + (i % 3) * 30 : 30 + (i % 2) * 30;

    // タスクをローテーションで記録
    final tasks = [task1a, task2b, task2c, task3a];
    final task = tasks[i % tasks.length];
    final taskNames = [
      '公式教材を1章ずつ進める',
      'UI設計とウィジェット実装',
      'Firebase連携とデプロイ',
      '5km ランニングを週3回',
    ];

    await studyLogService.addStudyLog(
      taskId: task.id,
      studyDate: date,
      durationMinutes: minutes,
      taskName: taskNames[i % taskNames.length],
    );
  }

  await prefs.setBool(_seededKey, true);
}
