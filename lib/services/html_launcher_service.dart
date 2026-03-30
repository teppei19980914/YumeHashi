/// HTMLコンテンツを別タブで開くサービス.
library;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'html_launcher_stub.dart'
    if (dart.library.js_interop) 'html_launcher_web.dart' as platform;

/// HTMLコンテンツを別タブで開く.
Future<void> openHtmlInNewTab(String html) async {
  if (kIsWeb) {
    platform.openHtmlInNewTabWeb(html);
  }
  // ネイティブ版は将来対応（一時ファイル経由）
}
