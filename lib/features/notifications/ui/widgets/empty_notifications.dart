import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';

/// Empty state for the notifications list: illustration + copy.
///
/// The "enable push" call-to-action lives in [PushPermissionBanner] at the top
/// of the screen now, so it shows whether or not the list is empty (the welcome
/// notification used to hide the empty-state button). Keeping it in one place
/// avoids a duplicate CTA.
class EmptyNotifications extends StatelessWidget {
  const EmptyNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = context.t.notifications;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KasySpacing.xxxl),
      child: KasyEmptyState(
        icon: KasyIcons.notificationOff,
        title: tr.empty_title,
        subtitle: tr.empty_subtitle,
      ),
    );
  }
}
