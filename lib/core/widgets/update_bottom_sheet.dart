import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';

/// Shows the "what's new" prompt, built on [KasyBottomSheet] or [KasyDialog].
///
/// Desktop (>= 1024): centered dialog. Mobile/tablet: bottom sheet.
///
/// Dismissing it simply closes the surface and returns the user to the screen
/// they were on; it never navigates anywhere. The version is already recorded
/// as seen before this is shown (see `MaybeShowUpdateBottomSheet`), so it won't
/// pop up again for the same version.
Future<void> showUpdateBottomSheet({
  required BuildContext context,
  required String version,
}) async {
  final bool isDesktop =
      MediaQuery.sizeOf(context).width >= DeviceType.large.breakpoint;
  if (isDesktop) {
    await showKasyBlurDialog<void>(
      context: context,
      builder: (_) => _UpdatePrompt(asDialog: true, version: version),
    );
    return;
  }
  await showKasyBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext ctx) =>
        _UpdatePrompt(asDialog: false, version: version),
  );
}

class _UpdatePrompt extends StatelessWidget {
  final bool asDialog;
  final String version;

  const _UpdatePrompt({required this.asDialog, required this.version});

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context).update_bottom_sheet;
    final Widget highlights = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < translations.highlights.length; i++) ...[
          if (i > 0) const SizedBox(height: KasySpacing.sm),
          _UpdateHighlightTile(highlight: translations.highlights[i]),
        ],
      ],
    );

    final Widget body = asDialog
        ? KasyDialogScrollableBody(maxHeight: 320, child: highlights)
        : ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.5,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemBuilder: (BuildContext context, int index) =>
                  _UpdateHighlightTile(highlight: translations.highlights[index]),
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: KasySpacing.sm),
              itemCount: translations.highlights.length,
            ),
          );

    final Widget continueButton = KasyButton(
      label: translations.continue_button,
      expand: true,
      onPressed: () => Navigator.of(context).pop(),
    );

    if (asDialog) {
      return KasyDialog(
        leadingIcon: KasyIcons.star,
        iconTone: KasyDialogIconTone.info,
        title: translations.title,
        message: 'Version $version',
        showCloseButton: false,
        body: body,
        actions: [continueButton],
      );
    }

    return KasyBottomSheet(
      icon: KasyIcons.star,
      title: translations.title,
      message: 'Version $version',
      body: body,
      actions: [continueButton],
    );
  }
}

class _UpdateHighlightTile extends StatelessWidget {
  final String highlight;

  const _UpdateHighlightTile({required this.highlight});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: KasySpacing.xs + 2,
          height: KasySpacing.xs + 2,
          margin: const EdgeInsets.only(top: KasySpacing.sm),
          decoration: BoxDecoration(
            color: context.colors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: KasySpacing.md),
        Expanded(
          child: Text(
            highlight,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
