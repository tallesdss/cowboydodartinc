/// Loads raw image bytes from a remote URL, choosing a platform-specific
/// strategy so social-profile photos (e.g. Google) import reliably:
///   - native: a direct HTTP download (see `image_bytes_loader_io.dart`),
///   - web: an `<img>` + canvas read that avoids the CDN throttling that hits
///     programmatic `fetch()`/XHR (see `image_bytes_loader_web.dart`).
///
/// Both implementations expose the same `loadImageBytes(url)` entry point and
/// return null (or rethrow) on failure so the caller can keep its fallback.
library;

export 'image_bytes_loader_io.dart'
    if (dart.library.js_interop) 'image_bytes_loader_web.dart';
