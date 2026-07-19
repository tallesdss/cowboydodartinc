/// Native / VM stub — no synchronous local storage exists off the web, and the
/// device preview never runs there anyway. Reads return null and writes are
/// no-ops, so callers keep their defaults. See [boot_prefs.dart] for why this is
/// split out.
library;

String? readPreviewChrome() => null;

void writePreviewChrome(String value) {}

int? bootPrefInt(String key) => null;
