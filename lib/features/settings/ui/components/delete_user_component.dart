import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:cowboydodartinc/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeleteUserButton extends ConsumerWidget {
  const DeleteUserButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KasyButton(
      label: t.settings.delete_account.button,
      variant: KasyButtonVariant.ghost,
      foregroundColor: context.colors.muted,
      onPressed: () {
        // Only warn about losing the subscription when the user actually has an
        // active one — otherwise the generic permanent-deletion warning.
        final bool isSubscriber =
            ref.read(userStateNotifierProvider).subscription?.isActive ?? false;
        final account = t.settings.delete_account;
        showKasyConfirmDialog(
        context,
        title: account.title,
        message: isSubscriber ? account.content_subscriber : account.content,
        cancelLabel: account.cancel,
        confirmLabel: account.confirm,
        destructive: true,
        onConfirmAsync: () async {
          try {
            await ref.read(userStateNotifierProvider.notifier).deleteAccount();
          } catch (_) {
            if (context.mounted) {
              showKasyToast(
                context,
                title: t.settings.delete_account.error,
                tone: KasyToastTone.danger,
              );
            }
          }
        },
        ).whenComplete(() {
          // Same pageless-dialog issue as logout: on success deleteAccount flips
          // the state to anonymous while this confirm dialog still sits on the
          // root navigator, so the redirect to /signin can't land. Re-run it
          // once the dialog has popped. Harmless when the user cancels or the
          // deletion failed (still authenticated → redirect keeps them here).
          if (context.mounted) ref.read(goRouterProvider).refresh();
        });
      },
    );
  }
}
