import 'package:cowboydodartinc/components/kasy_app_bar.dart';
import 'package:cowboydodartinc/core/home_widgets/home_widget_mywidget_service.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_scroll_behavior.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/settings/ui/widgets/admin_card.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdminHomeWidgets extends ConsumerWidget {
  const AdminHomeWidgets({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScrollConfiguration(
      behavior: const KasyKitScrollBehavior(),
      child: KasyOverlayScaffold(
        title: t.settings.admin.home_widgets_title,
        onBack: () => context.pop(),
        // Contain + center the single utility card on desktop so it never
        // stretches edge-to-edge, matching Notifications / Reminders.
        maxContentWidth: kKasyContentMaxWidth,
        slivers: [
          SliverList.list(
            children: [
              AdminPanelCard(
                title: t.settings.admin.update_mywidget_title,
                description: t.settings.admin.update_mywidget_desc,
                onTap: () => ref
                    .watch(myWidgetHomeWidgetProvider.notifier)
                    .update(),
              ),
              const SizedBox(height: KasySpacing.md),
            ],
          ),
        ],
      ),
    );
  }
}
