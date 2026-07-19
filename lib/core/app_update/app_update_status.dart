/// Result of comparing the installed app version against the remote config
/// (`app_latest_version` / `app_min_version`).
enum AppUpdateStatus {
  /// Installed version is current — nothing to show.
  upToDate,

  /// A newer version exists; the update sheet is dismissible ("update now"
  /// vs "not now").
  optional,

  /// Installed version is below the minimum allowed; the sheet blocks the app
  /// until the user updates.
  forced,
}
