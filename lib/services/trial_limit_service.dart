/// 機能制限管理.
///
/// v3.0.0 で完全無料化。全ユーザーが全機能を制限なく利用できる.
/// 旧体験版/プレミアム分岐は撤廃済み.
/// Stripe / 招待コード関連のセッター関数は休眠コードとして残す（将来の再導入用）.
library;

import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;

import '../l10n/app_labels.dart';
import 'feedback_service.dart';

/// テスト用トライアルモード上書きフラグ（本番では常にfalse）.
bool _testTrialMode = false;

/// テスト用にトライアルモードを強制有効化する.
///
/// テスト環境でのみ使用する。本番コードでは呼び出してはならない.
@visibleForTesting
void setTrialModeForTest({required bool enabled}) {
  _testTrialMode = enabled;
}

/// レベル別の制限値.
///
/// レベル0: 初期, レベル1: FB1回, レベル2: FB2回, レベル3: 基本機能無制限.
/// 目標数は「夢ごと」ではなく「全体」で制限する.
/// プレミアム機能（スケジュール等）はレベルに関わらず体験版では利用不可.
const _levelLimits = <int, _LevelConfig>{
  0: _LevelConfig(dreams: 1, goals: 3, tasksPerGoal: 3, books: 3),
  1: _LevelConfig(dreams: 2, goals: 5, tasksPerGoal: 5, books: 4),
  2: _LevelConfig(dreams: 3, goals: 8, tasksPerGoal: 8, books: 5),
};

class _LevelConfig {
  const _LevelConfig({
    required this.dreams,
    required this.goals,
    required this.tasksPerGoal,
    required this.books,
  });

  final int dreams;
  final int goals;
  final int tasksPerGoal;
  final int books;
}

/// 現在のレベルに応じた制限値を取得する.
_LevelConfig _currentConfig(int level) {
  if (level >= feedbackMaxLevel) {
    // レベル3以上: 基本機能無制限（十分大きな値）
    return const _LevelConfig(
      dreams: 999,
      goals: 999,
      tasksPerGoal: 999,
      books: 999,
    );
  }
  return _levelLimits[level] ??
      const _LevelConfig(dreams: 1, goals: 3, tasksPerGoal: 3, books: 3);
}

/// 体験版の制限値（レベル0のデフォルト値、表示用）.
int get trialMaxDreams => _levelLimits[0]!.dreams;
int get trialMaxGoals => _levelLimits[0]!.goals;
int get trialMaxTasksPerGoal => _levelLimits[0]!.tasksPerGoal;
int get trialMaxBooks => _levelLimits[0]!.books;

/// Web体験版かどうか.
///
/// v3.0.0 で完全無料化したため、実質的には `isPremium` が常に true となり
/// この値が使われることはない. 内部ロジックの互換性維持のために残す.
bool get isTrialMode => kIsWeb || _testTrialMode;

/// 全機能が利用可能かどうか.
///
/// v3.0.0 で完全無料化。常に true を返す.
/// 旧ロジック: `!isTrialMode || _invitePremium || _subscriptionPremium || _trialPremium || _developerMode`
// ignore: avoid_returning_true
bool get isPremium => true;

/// 招待コードによるプレミアム状態（プロバイダから設定される）.
bool _invitePremium = false;

/// 招待コードによるプレミアム状態を設定する.
void setInvitePremium({required bool enabled}) {
  _invitePremium = enabled;
}

/// サブスクリプションによるプレミアム状態.
bool _subscriptionPremium = false;

/// サブスクリプションによるプレミアム状態を設定する.
void setSubscriptionPremium({required bool enabled}) {
  _subscriptionPremium = enabled;
}

/// 無料トライアルによるプレミアム状態.
bool _trialPremium = false;

/// 無料トライアルによるプレミアム状態を設定する.
void setTrialPremium({required bool enabled}) {
  _trialPremium = enabled;
}

/// 開発者モード（認証メールが開発者のもの）.
bool _developerMode = false;

/// 開発者モードかどうか.
bool get isDeveloperMode => _developerMode;

/// 開発者メールアドレスによるプレミアム状態を設定する.
void setDeveloperMode({required bool enabled}) {
  _developerMode = enabled;
}

/// ガントチャート機能が利用可能か（v3.0.0: 常に true）.
bool get canUseGanttChart => true;

/// 高度な統計機能が利用可能か（v3.0.0: 常に true）.
bool get canUseAdvancedStats => true;

/// 夢の追加が可能か判定する.
bool canAddDream({required int currentCount, int unlockLevel = 0}) {
  if (!isTrialMode || isPremium) return true;
  return currentCount < _currentConfig(unlockLevel).dreams;
}

/// 目標の追加が可能か判定する（全体の目標数で判定）.
bool canAddGoal({
  required int currentGoalCount,
  int unlockLevel = 0,
}) {
  if (!isTrialMode || isPremium) return true;
  return currentGoalCount < _currentConfig(unlockLevel).goals;
}

/// タスクの追加が可能か判定する.
bool canAddTask({
  required int currentTaskCountForGoal,
  int unlockLevel = 0,
}) {
  if (!isTrialMode || isPremium) return true;
  return currentTaskCountForGoal <
      _currentConfig(unlockLevel).tasksPerGoal;
}

/// 書籍の追加が可能か判定する.
bool canAddBook({required int currentCount, int unlockLevel = 0}) {
  if (!isTrialMode || isPremium) return true;
  return currentCount < _currentConfig(unlockLevel).books;
}

/// 指定レベルでの夢の上限数.
int maxDreams(int unlockLevel) => _currentConfig(unlockLevel).dreams;

/// 指定レベルでの目標の上限数（全体）.
int maxGoals(int unlockLevel) => _currentConfig(unlockLevel).goals;

/// 指定レベルでのタスクの上限数.
int maxTasksPerGoal(int unlockLevel) =>
    _currentConfig(unlockLevel).tasksPerGoal;

/// 指定レベルでの書籍の上限数.
int maxBooks(int unlockLevel) => _currentConfig(unlockLevel).books;

/// 制限の説明テキストを取得する.
String trialLimitDescription({int unlockLevel = 0}) {
  if (unlockLevel >= feedbackMaxLevel) {
    return AppLabels.limitUnlocked;
  }
  final config = _currentConfig(unlockLevel);
  return AppLabels.limitDescription(
    unlockLevel,
    feedbackMaxLevel,
    config.dreams,
    config.goals,
    config.books,
  );
}
