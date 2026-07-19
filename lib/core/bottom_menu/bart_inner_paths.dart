/// Bart resolves the bottom tab from the **first** path segment (`/home/...` → `home`).
///
/// Inner routes must use `/$tabId/segment`. A lone `/$segment` breaks the tab bar
/// (`currentIndex == -1`).
String bartInnerPath(String tabId, String segment) => '/$tabId/$segment';
