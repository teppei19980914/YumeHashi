/// Firestore データ同期サービス.
///
/// Firebase匿名認証で自動ログインし、Firestoreにデータを同期する.
/// ユーザーは任意のタイミングでメール/パスワードにアカウント昇格できる.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firestoreデータ同期サービス.
class FirestoreSyncService {
  /// FirestoreSyncServiceを作成する.
  FirestoreSyncService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// 現在のFirebaseユーザー.
  User? get currentUser => _auth.currentUser;

  /// ログイン済みかどうか（匿名含む）.
  bool get isSignedIn => _auth.currentUser != null;

  /// 匿名ユーザーかどうか.
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;

  /// メール連携済みかどうか.
  bool get isLinked => isSignedIn && !isAnonymous;

  /// 連携済みメールアドレス.
  String? get email => _auth.currentUser?.email;

  /// ユーザーのドキュメント参照.
  DocumentReference? get _userDoc {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid);
  }

  // ── 認証 ──────────────────────────────────────────────────

  /// 匿名認証でサインイン（初回アクセス時に自動実行）.
  ///
  /// 既にサインイン済みの場合は何もしない.
  Future<User?> ensureSignedIn() async {
    if (_auth.currentUser != null) return _auth.currentUser;
    final credential = await _auth.signInAnonymously();
    return credential.user;
  }

  /// 匿名アカウントをメール/パスワードに昇格する.
  ///
  /// 匿名ユーザーのUIDとデータはそのまま引き継がれる.
  /// 既にメール連携済みの場合は例外を投げる.
  Future<UserCredential> linkWithEmail({
    required String email,
    required String password,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('サインインされていません');
    }
    if (!user.isAnonymous) {
      throw StateError('既にアカウント連携済みです');
    }
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    return user.linkWithCredential(credential);
  }

  /// メール+パスワードでサインイン（別端末からのログイン用）.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// サインアウト.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── データ同期 ────────────────────────────────────────────

  /// ローカルデータをFirestoreにアップロード（全データ同期）.
  Future<void> uploadData(String exportedJson) async {
    final doc = _userDoc;
    if (doc == null) return;

    await doc.set({
      'data': exportedJson,
      'updatedAt': FieldValue.serverTimestamp(),
      'email': _auth.currentUser?.email,
      'isAnonymous': _auth.currentUser?.isAnonymous ?? true,
    }, SetOptions(merge: true));
  }

  /// Firestoreからデータをダウンロード.
  Future<String?> downloadData() async {
    final doc = _userDoc;
    if (doc == null) return null;

    final snapshot = await doc.get();
    if (!snapshot.exists) return null;

    final data = snapshot.data() as Map<String, dynamic>?;
    return data?['data'] as String?;
  }

  /// 最終同期日時を取得する.
  Future<DateTime?> getLastSyncTime() async {
    final doc = _userDoc;
    if (doc == null) return null;

    final snapshot = await doc.get();
    if (!snapshot.exists) return null;

    final data = snapshot.data() as Map<String, dynamic>?;
    final timestamp = data?['updatedAt'] as Timestamp?;
    return timestamp?.toDate();
  }

  /// ユーザーアカウントを削除する.
  Future<void> deleteAccount() async {
    final doc = _userDoc;
    if (doc != null) {
      await doc.delete();
    }
    await _auth.currentUser?.delete();
  }
}
