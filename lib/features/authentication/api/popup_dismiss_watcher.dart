import 'dart:async';

/// Watches for the user dismissing a provider auth popup.
///
/// Native/non-web stub: there is no browser popup window to watch, so
/// [PopupDismissWatch.dismissed] never completes and [PopupDismissWatch.cancel]
/// is a no-op. The real implementation lives in `popup_dismiss_watcher_web.dart`
/// and is selected via conditional import on web.
typedef PopupDismissWatch = ({Future<void> dismissed, void Function() cancel});

PopupDismissWatch watchAuthPopupDismiss() =>
    (dismissed: Completer<void>().future, cancel: () {});
