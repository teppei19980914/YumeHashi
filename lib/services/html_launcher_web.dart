/// Web版: Blob URL で別タブにHTMLを表示する.
library;

import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// HTMLコンテンツを Blob URL で別タブに表示する.
void openHtmlInNewTabWeb(String html) {
  final blob = web.Blob(
    [html.toJS].toJS,
    web.BlobPropertyBag(type: 'text/html'),
  );
  final url = web.URL.createObjectURL(blob);
  web.window.open(url, '_blank');
}
