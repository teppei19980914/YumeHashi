/// 星座関連のProvider定義.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/constellation.dart';
import '../services/constellation_service.dart';
import 'database_provider.dart';

/// ConstellationServiceのProvider.
final constellationServiceProvider = Provider<ConstellationService>((ref) {
  final db = ref.watch(databaseProvider);
  return ConstellationService(
    studyLogDao: db.studyLogDao,
  );
});

/// 全星座の総合進捗を取得するProvider.
final constellationProgressProvider =
    FutureProvider<ConstellationOverallProgress>((ref) async {
  final service = ref.watch(constellationServiceProvider);
  return service.getOverallProgress();
});
