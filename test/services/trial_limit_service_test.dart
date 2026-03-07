import 'package:flutter_test/flutter_test.dart';
import 'package:study_planner/services/trial_limit_service.dart';

void main() {
  // テスト環境では kIsWeb == false なので isTrialMode は常に false
  group('TrialLimitService (非Web環境)', () {
    test('isTrialMode はテスト環境で false', () {
      expect(isTrialMode, isFalse);
    });

    test('非Web環境では夢の追加制限がない', () {
      expect(canAddDream(currentCount: 100), isTrue);
    });

    test('非Web環境では目標の追加制限がない', () {
      expect(canAddGoal(currentGoalCountForDream: 100), isTrue);
    });

    test('非Web環境ではタスクの追加制限がない', () {
      expect(canAddTask(currentTaskCountForGoal: 100), isTrue);
    });

    test('非Web環境では書籍の追加制限がない', () {
      expect(canAddBook(currentCount: 100), isTrue);
    });
  });

  group('制限値の定義', () {
    test('夢の上限は2', () {
      expect(trialMaxDreams, 2);
    });

    test('目標の上限は各夢3', () {
      expect(trialMaxGoalsPerDream, 3);
    });

    test('タスクの上限は各目標5', () {
      expect(trialMaxTasksPerGoal, 5);
    });

    test('書籍の上限は5', () {
      expect(trialMaxBooks, 5);
    });
  });

  group('trialLimitDescription', () {
    test('制限情報が含まれる', () {
      expect(trialLimitDescription, contains('$trialMaxDreams'));
      expect(trialLimitDescription, contains('$trialMaxGoalsPerDream'));
      expect(trialLimitDescription, contains('$trialMaxTasksPerGoal'));
      expect(trialLimitDescription, contains('$trialMaxBooks'));
    });
  });
}
