import 'dart:async';

import 'package:cowboydodartinc/components/kasy_bottom_sheet.dart';
import 'package:cowboydodartinc/components/kasy_menu.dart';
import 'package:cowboydodartinc/components/kasy_popover.dart';
import 'package:cowboydodartinc/core/home_widgets/home_widget_mywidget_service.dart';
import 'package:cowboydodartinc/core/shared_preferences/shared_preferences.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_hover.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/settings/ui/widgets/settings_tile.dart';
import 'package:cowboydodartinc/i18n/app_locale_display.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lets the user pick the app locale using endonym labels ([AppLocale.nativeName]).
/// The selection is persisted in SharedPreferences and applied immediately via Slang.
class LanguageSwitcher extends ConsumerStatefulWidget {
  const LanguageSwitcher({super.key});

  @override
  ConsumerState<LanguageSwitcher> createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends ConsumerState<LanguageSwitcher> {
  // On desktop the menu is anchored to the value via [KasyMenuAnchor]; this
  // holds its `open` callback so the whole row (KasyHover) can trigger it.
  VoidCallback? _openDesktopMenu;

  @override
  Widget build(BuildContext context) {
    final AppLocale current = TranslationProvider.of(context).locale;
    final bool isDesktop =
        MediaQuery.sizeOf(context).width >= DeviceType.large.breakpoint;

    return KasyHover(
      onTap: () => _onTap(current, isDesktop),
      focusable: true,
      // Rectangular highlight (KasyHover default): this row lives inside a card,
      // whose rounded corners clip the ends — a rounded fill here would float.
      semanticLabel: context.t.settings.language_title,
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.md,
        vertical: KasySpacing.smd,
      ),
      child: Row(
        children: <Widget>[
          Icon(
            KasyIcons.language,
            size: KasyIconSize.rowLeading,
            color: context.colors.onSurface,
          ),
          const SizedBox(width: KasySpacing.sm),
          Expanded(
            child: Text(
              context.t.settings.language_title,
              style: context.kasyTextTheme.listRowTitle.copyWith(
                color: context.colors.onSurface,
              ),
            ),
          ),
          _trailing(context, current, isDesktop),
        ],
      ),
    );
  }

  Widget _trailing(BuildContext context, AppLocale current, bool isDesktop) {
    final Widget value = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          current.nativeName,
          style: context.kasyTextTheme.listRowValue.copyWith(
            color: context.colors.muted,
          ),
        ),
        const SizedBox(width: KasySpacing.xs),
        const SettingsListChevron(),
      ],
    );

    if (!isDesktop) return value;

    // Desktop: glue the menu to the value with KasyMenuAnchor (LayerLink, so it
    // survives the web viewport scale) and align its right edge to the value, so
    // it opens inward like a dropdown instead of off the card edge.
    return KasyMenuAnchor(
      width: 180,
      align: KasyPopoverAlign.end,
      sections: _sections(current),
      builder: (context, open) {
        _openDesktopMenu = open;
        return value;
      },
    );
  }

  List<KasyMenuSection> _sections(AppLocale current) {
    return [
      KasyMenuSection(
        selectionMode: KasyMenuSelectionMode.single,
        items: [
          for (final AppLocale locale in AppLocale.values)
            KasyMenuItem(
              title: locale.nativeName,
              selected: locale == current,
              onTap: () => _applyLocale(locale),
            ),
        ],
      ),
    ];
  }

  void _onTap(AppLocale current, bool isDesktop) {
    if (isDesktop) {
      _openDesktopMenu?.call();
      return;
    }

    // Mobile/tablet: bottom sheet of choices (touch).
    showKasyChoiceSheet<void>(
      context: context,
      title: context.t.settings.language_title,
      options: [
        for (final AppLocale locale in AppLocale.values)
          KasyBottomSheetOption(
            label: locale.nativeName,
            selected: locale == current,
            onTap: () => _applyLocale(locale),
          ),
      ],
    );
  }

  // The menu closes itself before this runs (KasyMenuItem pops first), so the
  // awaited setLocale never races the rebuild it triggers. setLocale is awaited
  // so Slang finishes loading the locale bundle before any widget reads its
  // translations — otherwise a parallel updateForLocale sees an unloaded map and
  // silently falls back to English (the old "first tap doesn't update" bug).
  Future<void> _applyLocale(AppLocale locale) async {
    await LocaleSettings.setLocale(locale);
    unawaited(
      ref.read(sharedPreferencesProvider).setAppLocale(locale.languageCode),
    );
    unawaited(
      ref.read(myWidgetHomeWidgetProvider.notifier).updateForLocale(locale),
    );
  }
}
