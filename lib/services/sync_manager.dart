/// クラウド同期マネージャー.
///
/// デバウンス(3秒) + ハッシュ比較 + ライフサイクル同期を組み合わせ、
/// Firestore へのIO回数を最小化する.
/// 起動時にはタイムスタンプ比較でクラウドが新しければ自動ダウンロードする.
library;

import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:shared_preferences/shared_preferences.dart';

import 'data_export_service.dart';
import 'firestore_sync_service.dart';

/// クラウド同期を管理するシングルトン.
class SyncManager {
  /// SyncManagerを作成する.
  factory SyncManager() => _instance;
  SyncManager._();
  static final _instance = SyncManager._();

  /// テスト用コンストラクタ（kIsWebガードを無効化できる）.
  @visibleForTesting
  SyncManager.forTest({bool webMode = true}) : _webMode = webMode;

  DataExportService? _exportService;
  SharedPreferences? _prefs;
  // テスト環境でFirebase未初期化エラーを防ぐため遅延初期化
  CloudSyncClient? _syncService;
  CloudSyncClient get _sync => _syncService ??= FirestoreSyncService();

  Timer? _debounceTimer;
  bool _dirty = false;
  String _lastHash = '';

  // テスト時にkIsWebを上書きするためのフラグ
  bool? _webMode;
  bool get _isWeb => _webMode ?? kIsWeb;

  static const _debounceDuration = Duration(seconds: 3);
  static const _lastSyncKey = 'cloud_last_sync_ms';

  /// 初期化（アプリ起動時に1回呼ぶ）.
  void init(
    DataExportService exportService, {
    SharedPreferences? prefs,
    CloudSyncClient? syncService,
  }) {
    _exportService = exportService;
    _prefs = prefs;
    if (syncService != null) _syncService = syncService;
  }

  /// データ変更を通知する（デバウンス同期をスケジュール）.
  ///
  /// 即座にIOは発生しない。3秒間追加の通知がなければ同期を実行する.
  void requestSync() {
    if (!_isWeb) return;

    _dirty = true;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, _executeUpload);
  }

  /// アプリ離脱時に未同期データがあれば即座に同期する.
  ///
  /// デバウンス待機中のデータを失わないよう、タイマーをキャンセルして即実行.
  Future<void> syncOnExit() async {
    if (!_dirty) return;
    _debounceTimer?.cancel();
    await _executeUpload();
  }

  /// 起動時の同期: タイムスタンプ比較でダウンロードまたはアップロードを実行する.
  ///
  /// クラウドのデータがローカルより新しい場合は自動ダウンロードし、
  /// そうでなければアップロードする.
  Future<void> syncNow() async {
    if (!_isWeb || !_sync.isSignedIn) return;

    try {
      final cloudTime = await _sync.getLastSyncTime();
      final localTimeMs = _prefs?.getInt(_lastSyncKey) ?? 0;
      final localTime = localTimeMs > 0
          ? DateTime.fromMillisecondsSinceEpoch(localTimeMs, isUtc: true)
          : null;

      if (cloudTime != null &&
          (localTime == null || cloudTime.toUtc().isAfter(localTime))) {
        // クラウドが新しい → ダウンロード
        await _executeDownload();
      } else {
        // ローカルが新しいまたは同じ → アップロード
        _dirty = true;
        await _executeUpload();
      }
    } on Object {
      // 同期失敗: 次回リトライ
    }
  }

  Future<void> _executeUpload() async {
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
      _saveLocalSyncTime();
    } on Object {
      // 同期失敗: dirtyフラグは残す（次回リトライ）
    }
  }

  Future<void> _executeDownload() async {
    if (_exportService == null) return;
    if (!_sync.isSignedIn) return;

    try {
      final json = await _sync.downloadData();
      if (json == null || json.isEmpty) return;

      await _exportService!.importData(json);
      _lastHash = sha256.convert(utf8.encode(json)).toString();
      _dirty = false;
      _saveLocalSyncTime();
    } on Object {
      // ダウンロード失敗: 次回リトライ
    }
  }

  void _saveLocalSyncTime() {
    _prefs?.setInt(_lastSyncKey, DateTime.now().toUtc().millisecondsSinceEpoch);
  }

  /// テスト用: 状態をリセットする.
  void reset() {
    _debounceTimer?.cancel();
    _dirty = false;
    _lastHash = '';
    _exportService = null;
    _syncService = null;
    _prefs = null;
  }
}
