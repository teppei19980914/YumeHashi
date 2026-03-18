import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yume_log/services/stripe_service.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('createCheckoutUrl', () {
    test('成功時にURLを返す', () async {
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['userKey'], 'test-user');
        return http.Response(
          jsonEncode({'url': 'https://checkout.stripe.com/test'}),
          200,
        );
      });

      final service = StripeService(prefs, httpClient: mockClient);
      final url = await service.createCheckoutUrl(userKey: 'test-user');
      expect(url, 'https://checkout.stripe.com/test');
    });

    test('エラー時にnullを返す', () async {
      final mockClient = MockClient((_) async {
        return http.Response('error', 500);
      });

      final service = StripeService(prefs, httpClient: mockClient);
      final url = await service.createCheckoutUrl(userKey: 'test-user');
      expect(url, isNull);
    });

    test('userKeyなしでも送信できる', () async {
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['userKey'], '');
        return http.Response(
          jsonEncode({'url': 'https://checkout.stripe.com/test'}),
          200,
        );
      });

      final service = StripeService(prefs, httpClient: mockClient);
      final url = await service.createCheckoutUrl();
      expect(url, 'https://checkout.stripe.com/test');
    });
  });

  group('isSubscriptionActive', () {
    test('初期状態はfalse', () {
      final service = StripeService(prefs);
      expect(service.isSubscriptionActive, isFalse);
    });

    test('activateSubscription後はtrue', () async {
      final service = StripeService(prefs);
      await service.activateSubscription();
      expect(service.isSubscriptionActive, isTrue);
    });

    test('activatedAtが設定される', () async {
      final service = StripeService(prefs);
      expect(service.activatedAt, isNull);
      await service.activateSubscription();
      expect(service.activatedAt, isNotNull);
    });

    test('clearSubscriptionでリセットされる', () async {
      final service = StripeService(prefs);
      await service.activateSubscription();
      expect(service.isSubscriptionActive, isTrue);

      await service.clearSubscription();
      expect(service.isSubscriptionActive, isFalse);
      expect(service.activatedAt, isNull);
    });
  });

  group('無料トライアル', () {
    test('初期状態はトライアル未開始', () {
      final service = StripeService(prefs);
      expect(service.isTrialStarted, isFalse);
      expect(service.isTrialActive, isFalse);
      expect(service.trialRemainingDays, 0);
    });

    test('startTrialでトライアルが開始される', () async {
      final service = StripeService(prefs);
      await service.startTrial();
      expect(service.isTrialStarted, isTrue);
      expect(service.isTrialActive, isTrue);
      expect(service.trialRemainingDays, trialDurationDays);
    });

    test('二重開始は無視される', () async {
      final service = StripeService(prefs);
      await service.startTrial();
      final firstStart = service.trialStartedAt;
      await service.startTrial(); // 二重呼び出し
      expect(service.trialStartedAt, firstStart);
    });

    test('期限切れ後はisTrialActiveがfalse', () async {
      SharedPreferences.setMockInitialValues({
        'premium_trial_started_at': DateTime.now()
            .subtract(const Duration(days: 10))
            .millisecondsSinceEpoch,
      });
      prefs = await SharedPreferences.getInstance();

      final service = StripeService(prefs);
      expect(service.isTrialStarted, isTrue);
      expect(service.isTrialActive, isFalse);
      expect(service.trialRemainingDays, 0);
    });

    test('hasPremiumAccessはサブスクまたはトライアルで有効', () async {
      final service = StripeService(prefs);
      expect(service.hasPremiumAccess, isFalse);

      await service.startTrial();
      expect(service.hasPremiumAccess, isTrue);
    });
  });

  test('定数 stripeEndpointUrlが定義されている', () {
    expect(stripeEndpointUrl, isNotEmpty);
    expect(stripeEndpointUrl, contains('script.google.com'));
  });
}
