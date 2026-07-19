import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/rating/api/rating_api.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

/// Shows the "update available" prompt. Native-only in production: the caller
/// already guards `kIsWeb`.
///
/// Desktop (>= 1024): centered [KasyDialog]. Mobile/tablet: [KasyBottomSheet].
///
/// [forced] makes the surface blocking (no dismiss, no "later" action).
Future<void> showUpdateAvailableSheet(
  BuildContext context, {
  required bool forced,
}) async {
  final bool isDesktop =
      MediaQuery.sizeOf(context).width >= DeviceType.large.breakpoint;
  if (isDesktop) {
    await showKasyBlurDialog<void>(
      context: context,
      barrierDismissible: !forced,
      builder: (_) => _UpdateAvailablePrompt(asDialog: true, forced: forced),
    );
    return;
  }
  await showKasyBottomSheet<void>(
    context: context,
    isDismissible: !forced,
    enableDrag: !forced,
    isScrollControlled: true,
    builder: (_) => _UpdateAvailablePrompt(asDialog: false, forced: forced),
  );
}

class _UpdateAvailablePrompt extends ConsumerWidget {
  final bool asDialog;
  final bool forced;

  const _UpdateAvailablePrompt({required this.asDialog, required this.forced});

  Future<void> _openStore(WidgetRef ref) async {
    try {
      await ref.read(ratingApiProvider).openStoreListing();
    } catch (e) {
      // iOS needs a configured App Store ID; never crash the prompt.
      Logger().e('openStoreListing failed: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = context.t.update_available;
    final String title = forced ? tr.forced_title : tr.title;
    final String message = forced ? tr.forced_description : tr.description;

    final Widget updateButton = KasyButton(
      label: tr.update_button,
      expand: true,
      onPressed: () => _openStore(ref),
    );

    final Widget shell = asDialog
        ? KasyDialog(
            leadingIcon: KasyIcons.download,
            iconTone: KasyDialogIconTone.info,
            title: title,
            message: message,
            showCloseButton: !forced,
            actionsAxis: forced ? Axis.vertical : Axis.horizontal,
            actions: forced
                ? [updateButton]
                : [
                    KasyButton(
                      label: tr.later_button,
                      variant: KasyButtonVariant.outline,
                      expand: true,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    updateButton,
                  ],
          )
        : KasyBottomSheet(
            icon: KasyIcons.download,
            title: title,
            message: message,
            showDragHandle: !forced,
            actions: [
              updateButton,
              if (!forced)
                KasyButton(
                  label: tr.later_button,
                  variant: KasyButtonVariant.soft,
                  expand: true,
                  onPressed: () => Navigator.of(context).pop(),
                ),
            ],
          );

    return PopScope(canPop: !forced, child: shell);
  }
}
