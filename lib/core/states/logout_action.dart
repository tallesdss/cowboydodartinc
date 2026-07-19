import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:cowboydodartinc/router.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Standardized logout flow — the single source of truth for signing out.
///
/// Every entry point (settings app bar, sidebar, …) calls this so the confirm
/// dialog's look (blurred [KasyDialog] with a logout icon), copy and behavior
/// stay identical everywhere. Feature/host code owns the *when*; the design
/// system owns the *how*.
Future<void> confirmLogout(BuildContext context, WidgetRef ref) {
  final tr = context.t.settings;
  return showKasyConfirmDialog(
    context,
    leadingIcon: KasyIcons.logout,
    title: tr.disconnect_confirm_title,
    message: tr.disconnect_confirm_message,
    cancelLabel: tr.disconnect_cancel,
    confirmLabel: tr.disconnect,
    // Async so the confirm button shows a spinner while signing out, then the
    // router redirect lands the user on the sign-in screen. (Don't fire-and-
    // forget: that closed the dialog instantly and left the old screen frozen.)
    onConfirmAsync: () =>
        ref.read(userStateNotifierProvider.notifier).onLogout(),
  ).whenComplete(() {
    // The confirm dialog is a pageless route on the ROOT navigator, so the
    // redirect that fires when onLogout flips the state to anonymous runs while
    // the dialog still sits on top — go_router keeps the current page (Settings)
    // mounted underneath and the move to /signin never lands. Now that the
    // dialog has popped, re-run the redirect so the (now unauthenticated) user
    // is sent to sign-in. Harmless on cancel: the redirect keeps an
    // authenticated user exactly where they are.
    if (context.mounted) ref.read(goRouterProvider).refresh();
  });
}
