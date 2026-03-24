/// クラウド同期マネージャー.
///
/// デバウンス(3秒) + ハッシュ比較 + ライフサイクル同期を組み合わせ、
/// Firestore へのIO回数を最小化する.
library;

import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'data_export_service.dart';
import 'firestore_sync_service.dart';

/// クラウド同期を管理するシングルトン.
class SyncManager {
  /// SyncManagerを作成する.
  factory SyncManager() => _instance;
  SyncManager._();
  static final _instance = SyncManager._();

  DataExportService? _exportService;
  // テスト環境でFirebase未初期化エラーを防ぐため遅延初期化
  FirestoreSyncService? _syncService;
  FirestoreSyncService get _sync => _syncService ??= FirestoreSyncService();

  Timer? _debounceTimer;
  bool _dirty = false;
  String _lastHash = '';

  static const _debounceDuration = Duration(seconds: 3);

  /// 初期化（アプリ起動時に1回呼ぶ）.
  void init(DataExportService exportService) {
    _exportService = exportService;
  }

  /// データ変更を通知する（デバウンス同期をスケジュール）.
  ///
  /// 即座にIOは発生しない。3秒間追加の通知がなければ同期を実行する.
  void requestSync() {
    if (!kIsWeb) return;

    _dirty = true;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, _executeSync);
  }

  /// アプリ離脱時に未同期データがあれば即座に同期する.
  ///
  /// デバウンス待機中のデータを失わないよう、タイマーをキャンセルして即実行.
  Future<void> syncOnExit() async {
    if (!_dirty) return;
    _debounceTimer?.cancel();
    await _executeSync();
  }

  /// 即座に同期を実行する（起動時の初回同期用）.
  Future<void> syncNow() async {
    if (!kIsWeb || !_sync.isSignedIn) return;
    _dirty = true;
    await _executeSync();
  }

  Future<void> _executeSync() async {
    if (!_dirty || _exportService == null) return;
    if (!_sync.isSignedIn) return;

    try {
      final json = await _exportService!.exportData();

      // ハッシュ比較: 前回と同じならアップロードをスキップ
      final hash = sha256.convert(utf8.encode(json)).toString();
      if (hash == _lastHash) {
        _dirty = false;
        return;
      }

      await _sync.uploadData(json);
      _lastHash = hash;
      _dirty = false;
    } on Object {
      // 同期失敗: dirtyフラグは残す（次回リトライ）
    }
  }

  /// テスト用: 状態をリセットする.
  void reset() {
    _debounceTimer?.cancel();
    _dirty = false;
    _lastHash = '';
    _exportService = null;
    _syncService = null;
  }
}
