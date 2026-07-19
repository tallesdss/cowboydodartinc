import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Downloads image bytes on web by loading the URL through an `<img>` element
/// and reading it back from a canvas.
///
/// Browsers serve `<img>` requests reliably, while some CDNs (notably Google's
/// `lh3.googleusercontent.com`) throttle programmatic `fetch()`/XHR with HTTP
/// 429 - which is what an HTTP client like dio uses. The image is requested with
/// CORS (`crossOrigin = 'anonymous'`) so the canvas is not tainted and its
/// pixels can be exported. Returns null on any failure, so the caller keeps its
/// fallback avatar.
Future<List<int>?> loadImageBytes(String url) async {
  final image = web.HTMLImageElement()..crossOrigin = 'anonymous';
  final loaded = Completer<bool>();
  image.addEventListener(
    'load',
    (web.Event _) {
      if (!loaded.isCompleted) loaded.complete(true);
    }.toJS,
  );
  image.addEventListener(
    'error',
    (web.Event _) {
      if (!loaded.isCompleted) loaded.complete(false);
    }.toJS,
  );
  image.src = url;

  final ok = await loaded.future
      .timeout(const Duration(seconds: 10), onTimeout: () => false);
  if (!ok || image.naturalWidth == 0) return null;

  final canvas = web.HTMLCanvasElement()
    ..width = image.naturalWidth
    ..height = image.naturalHeight;
  final context = canvas.getContext('2d') as web.CanvasRenderingContext2D?;
  if (context == null) return null;
  context.drawImage(image, 0, 0);

  final blobReady = Completer<web.Blob?>();
  canvas.toBlob(
    (web.Blob? blob) {
      blobReady.complete(blob);
    }.toJS,
    'image/jpeg',
    0.92.toJS,
  );
  final blob = await blobReady.future;
  if (blob == null) return null;

  final buffer = await blob.arrayBuffer().toDart;
  return buffer.toDart.asUint8List();
}
