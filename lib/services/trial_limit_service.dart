/// Web体験版の制限管理.
///
/// Web版アプリでのみデータ追加数を制限する.
/// ネイティブデスクトップ版では全て無制限.
library;

import 'package:flutter/foundation.dart' show kIsWeb;

/// 体験版の制限値.
const trialMaxDreams = 2;
const trialMaxGoalsPerDream = 3;
const trialMaxTasksPerGoal = 5;
const trialMaxBooks = 5;

/// Web体験版かどうか.
bool get isTrialMode => kIsWeb;

/// 夢の追加が可能か判定する.
bool canAddDream({required int currentCount}) {
  if (!isTrialMode) return true;
  return currentCount < trialMaxDreams;
}

/// 目標の追加が可能か判定する.
bool canAddGoal({required int currentGoalCountForDream}) {
  if (!isTrialMode) return true;
  return currentGoalCountForDream < trialMaxGoalsPerDream;
}

/// タスクの追加が可能か判定する.
bool canAddTask({required int currentTaskCountForGoal}) {
  if (!isTrialMode) return true;
  return currentTaskCountForGoal < trialMaxTasksPerGoal;
}

/// 書籍の追加が可能か判定する.
bool canAddBook({required int currentCount}) {
  if (!isTrialMode) return true;
  return currentCount < trialMaxBooks;
}

/// 制限の説明テキストを取得する.
String get trialLimitDescription => '体験版では以下の制限があります:\n'
    '- 夢: $trialMaxDreams個まで\n'
    '- 目標: 各夢$trialMaxGoalsPerDream個まで\n'
    '- タスク: 各目標$trialMaxTasksPerGoal個まで\n'
    '- 書籍: $trialMaxBooks冊まで';
