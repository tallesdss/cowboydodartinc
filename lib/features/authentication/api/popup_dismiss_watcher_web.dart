import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

typedef PopupDismissWatch = ({Future<void> dismissed, void Function() cancel});

/// Web implementation: Firebase's `signInWithPopup` / `linkWithPopup` never
/// reject when the user closes the popup window manually, leaving the sign-in
/// future pending forever. We detect that dismissal indirectly: when the popup
/// closes, the main window regains focus.
///
/// [dismissed] completes ~1.2s after the main window refocuses (a debounce so a
/// successful sign-in — which resolves its own future first — wins the race).
/// Always call [cancel] once the sign-in settles to remove the listener.
PopupDismissWatch watchAuthPopupDismiss() {
  final completer = Completer<void>();
  Timer? settle;

  final handler = ((web.Event _) {
    settle?.cancel();
    settle = Timer(const Duration(milliseconds: 1200), () {
      if (!completer.isCompleted) completer.complete();
    });
  }).toJS;

  web.window.addEventListener('focus', handler);

  void cancel() {
    settle?.cancel();
    web.window.removeEventListener('focus', handler);
  }

  return (dismissed: completer.future, cancel: cancel);
}
