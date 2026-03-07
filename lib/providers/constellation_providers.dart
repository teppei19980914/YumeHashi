/// 星座関連のProvider定義.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/constellation.dart';
import '../services/constellation_service.dart';
import 'database_provider.dart';
import 'dream_providers.dart';

/// ConstellationServiceのProvider.
final constellationServiceProvider = Provider<ConstellationService>((ref) {
  final db = ref.watch(databaseProvider);
  return ConstellationService(
    goalDao: db.goalDao,
    taskDao: db.taskDao,
    studyLogDao: db.studyLogDao,
  );
});

/// 全Dreamの星座進捗を取得するProvider.
final constellationProgressProvider =
    FutureProvider<List<ConstellationProgress>>((ref) async {
  final service = ref.watch(constellationServiceProvider);
  final dreamsAsync = ref.watch(dreamListProvider);
  final dreams = dreamsAsync.valueOrNull ?? [];
  return service.getAllProgress(dreams);
});
