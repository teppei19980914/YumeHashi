import 'package:flutter_test/flutter_test.dart';
import 'package:yume_hashi/services/trial_limit_service.dart';

void main() {
  group('TrialLimitService (v3.0.0 完全無料化)', () {
    test('isPremium は常に true', () {
      expect(isPremium, isTrue);
    });

    test('canUseGanttChart は常に true', () {
      expect(canUseGanttChart, isTrue);
    });

    test('canUseAdvancedStats は常に true', () {
      expect(canUseAdvancedStats, isTrue);
    });

    test('夢の追加制限がない', () {
      expect(canAddDream(currentCount: 100), isTrue);
    });

    test('目標の追加制限がない', () {
      expect(canAddGoal(currentGoalCount: 100), isTrue);
    });

    test('タスクの追加制限がない', () {
      expect(canAddTask(currentTaskCountForGoal: 100), isTrue);
    });

    test('書籍の追加制限がない', () {
      expect(canAddBook(currentCount: 100), isTrue);
    });

    test('トライアルモードを有効化しても isPremium は true（完全無料化）', () {
      setTrialModeForTest(enabled: true);
      expect(isPremium, isTrue);
      setTrialModeForTest(enabled: false);
    });
  });
}
