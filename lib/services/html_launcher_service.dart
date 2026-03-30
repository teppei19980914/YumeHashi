/// HTMLコンテンツを別タブで開くサービス.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

/// HTMLコンテンツを別タブで開く.
///
/// Web版: data URI で別タブを開く.
/// ネイティブ版: デフォルトブラウザで data URI を開く.
Future<void> openHtmlInNewTab(String html) async {
  final encoded = base64Encode(utf8.encode(html));
  final dataUri = Uri.parse('data:text/html;charset=utf-8;base64,$encoded');

  await launchUrl(
    dataUri,
    mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
  );
}
