/// Stripe決済連携サービス.
///
/// Google Apps Script 経由で Stripe Checkout Session を作成し、
/// サブスクリプションの状態を管理する.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Stripe Checkout Session 作成用の Apps Script URL.
const stripeEndpointUrl =
    'https://script.google.com/macros/s/AKfycbzwtQ0hmI3aUeZPz95fJV7l4amSaXxRH87NTLAdk0sp1IQRQsSZ7sKjVAm3W1NuVEnq/exec';

const _subscriptionActiveKey = 'stripe_subscription_active';
const _subscriptionActivatedAtKey = 'stripe_subscription_activated_at';
const _trialStartedAtKey = 'premium_trial_started_at';

/// 無料トライアル期間（日数）.
const trialDurationDays = 7;

/// Stripe連携サービス.
class StripeService {
  /// StripeServiceを作成する.
  StripeService(this._prefs, {http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final SharedPreferences _prefs;
  final http.Client _httpClient;

  /// サブスクリプションが有効かどうか.
  bool get isSubscriptionActive =>
      _prefs.getBool(_subscriptionActiveKey) ?? false;

  /// サブスクリプション開始日.
  DateTime? get activatedAt {
    final ms = _prefs.getInt(_subscriptionActivatedAtKey);
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  /// Stripe Checkout Session のURLを取得する.
  ///
  /// Apps Script 経由で Stripe Checkout Session を作成し、
  /// 決済ページのURLを返す.
  Future<String?> createCheckoutUrl({String? userKey}) async {
    try {
      final response = await _httpClient.post(
        Uri.parse(stripeEndpointUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userKey': userKey ?? '',
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json['url'] as String?;
    } on Exception {
      return null;
    }
  }

  /// サブスクリプション成功時にローカル状態を更新する.
  ///
  /// `?subscription=success` パラメータ検出時に呼ばれる.
  Future<void> activateSubscription() async {
    await _prefs.setBool(_subscriptionActiveKey, true);
    await _prefs.setInt(
      _subscriptionActivatedAtKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// サブスクリプション状態をクリアする.
  Future<void> clearSubscription() async {
    await _prefs.remove(_subscriptionActiveKey);
    await _prefs.remove(_subscriptionActivatedAtKey);
  }

  // ── 無料トライアル ──

  /// 無料トライアルが開始済みかどうか.
  bool get isTrialStarted => _prefs.getInt(_trialStartedAtKey) != null;

  /// 無料トライアル開始日.
  DateTime? get trialStartedAt {
    final ms = _prefs.getInt(_trialStartedAtKey);
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  /// 無料トライアルが有効（期間内）かどうか.
  bool get isTrialActive {
    final start = trialStartedAt;
    if (start == null) return false;
    final remaining = _trialRemainingDays(start);
    return remaining > 0;
  }

  /// 無料トライアルの残り日数.
  int get trialRemainingDays {
    final start = trialStartedAt;
    if (start == null) return 0;
    return _trialRemainingDays(start);
  }

  int _trialRemainingDays(DateTime start) {
    final elapsed = DateTime.now().difference(start).inDays;
    final remaining = trialDurationDays - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  /// 無料トライアルを開始する.
  Future<void> startTrial() async {
    if (isTrialStarted) return; // 二重開始防止
    await _prefs.setInt(
      _trialStartedAtKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// プレミアム機能が利用可能か（サブスク or トライアル）.
  bool get hasPremiumAccess => isSubscriptionActive || isTrialActive;
}
