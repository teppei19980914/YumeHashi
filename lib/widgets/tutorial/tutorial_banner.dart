/// チュートリアル状態管理.
///
/// チュートリアルの状態を管理するStateNotifierとProvider.
/// UI表示はtutorial_overlay.dartが担当する.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/service_providers.dart';
import '../../services/tutorial_service.dart';

/// チュートリアル状態.
class TutorialState {
  const TutorialState({required this.isActive, required this.step});

  static const inactive =
      TutorialState(isActive: false, step: TutorialStep.goToDreams);

  /// チュートリアル実行中か.
  final bool isActive;

  /// 現在のステップ.
  final TutorialStep step;
}

/// チュートリアル状態のNotifier.
class TutorialStateNotifier extends StateNotifier<TutorialState> {
  /// TutorialStateNotifierを作成する.
  TutorialStateNotifier(this._service)
      : super(TutorialState(
          isActive: _service.isActive,
          step: _service.isActive
              ? _service.currentStep
              : TutorialStep.goToDreams,
        ));

  final TutorialService _service;

  /// チュートリアルを開始する.
  Future<void> start() async {
    await _service.start();
    state = const TutorialState(
      isActive: true,
      step: TutorialStep.goToDreams,
    );
  }

  /// 次のステップに進む.
  Future<void> advanceStep() async {
    if (!state.isActive) return;
    await _service.advanceStep();
    state = TutorialState(
      isActive: true,
      step: _service.currentStep,
    );
  }

  /// チュートリアルをリセットする.
  void reset() {
    state = TutorialState.inactive;
  }
}

/// チュートリアル状態のProvider.
final tutorialStateProvider =
    StateNotifierProvider<TutorialStateNotifier, TutorialState>((ref) {
  final service = ref.watch(tutorialServiceProvider);
  return TutorialStateNotifier(service);
});
