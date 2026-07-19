import 'dart:js_interop';
import 'dart:typed_data';

import 'package:cowboydodartinc/core/web_device_preview/png_export_result.dart';
import 'package:web/web.dart' as web;

/// Copies [bytes] (a PNG) straight to the clipboard so it can be pasted into an
/// AI chat. Falls back to a file download if the browser blocks image clipboard
/// writes.
Future<PngExportResult> copyOrDownloadPng(Uint8List bytes) async {
  final blob = web.Blob(
    <JSAny>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'image/png'),
  );
  try {
    final item = web.ClipboardItem(
      <String, JSAny>{'image/png': blob}.jsify()! as JSObject,
    );
    await web.window.navigator.clipboard
        .write(<web.ClipboardItem>[item].toJS)
        .toDart;
    return PngExportResult.copied;
  } catch (_) {
    _downloadBlob(blob);
    return PngExportResult.downloaded;
  }
}

void _downloadBlob(web.Blob blob) {
  final url = web.URL.createObjectURL(blob);
  web.HTMLAnchorElement()
    ..href = url
    ..download = 'preview_${DateTime.now().millisecondsSinceEpoch}.png'
    ..click();
  web.URL.revokeObjectURL(url);
}
