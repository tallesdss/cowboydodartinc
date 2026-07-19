import 'package:cowboydodartinc/components/kasy_switch.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_hover.dart';
import 'package:flutter/material.dart';

typedef SettingsTileOnTap = void Function();

/// Rounded-square icon container used in settings rows.
/// Uses a soft tinted background (12 % opacity) with a colored icon —
/// keeping the hue recognizable without being visually heavy.
class SettingsIconBadge extends StatelessWidget {
  const SettingsIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 32,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(KasyRadius.sm),
      ),
      child: Icon(
        icon,
        size: size * 0.56,
        color: color,
      ),
    );
  }
}

/// Trailing chevron for tappable settings rows: slightly larger and higher
/// contrast in light mode, slightly lighter in dark mode.
class SettingsListChevron extends StatelessWidget {
  const SettingsListChevron({super.key});

  static const double _iconSize = KasyIconSize.rowTrailing;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color onSurface = context.colors.onSurface;
    final Color color = brightness == Brightness.light
        ? onSurface.withValues(alpha: 0.57)
        : Color.lerp(onSurface, Colors.white, 0.14) ?? onSurface;
    return Icon(
      KasyIcons.arrowForwardIos,
      size: _iconSize,
      color: color,
    );
  }
}

/// This widget is used to show a divider between settings tiles
class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    // Inset to align with the rows' content (which now carry the horizontal
    // padding the card used to have), so the hairline doesn't touch the edges.
    return Divider(
      // Hairline only — no extra height — so rows sit close together (iOS-style
      // contiguous list) instead of floating apart with a 16px gap.
      height: 1,
      thickness: 1,
      color: context.colors.onBackground.withValues(alpha: .06),
      indent: KasySpacing.md,
      endIndent: KasySpacing.md,
    );
  }
}

/// Same row layout as [SettingsTile], with a trailing switch instead of the chevron.
class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.iconBackgroundColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.md,
        vertical: KasySpacing.smd,
      ),
      child: Row(
        children: <Widget>[
          if (iconBackgroundColor != null)
            SettingsIconBadge(icon: icon, color: iconBackgroundColor!)
          else
            Icon(
              icon,
              size: KasyIconSize.rowLeading,
              color: context.colors.onSurface,
            ),
          const SizedBox(width: KasySpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: context.kasyTextTheme.listRowTitle.copyWith(
                    color: context.colors.onSurface,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ],
            ),
          ),
          KasySwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// This widget is used to show a settings tile with an icon and a title.
/// Optionally shows a [trailingLabel] value before the chevron — mirrors the
/// pattern of [LanguageSwitcher] where the current value appears on the right.
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final SettingsTileOnTap onTap;
  final Color? iconBackgroundColor;
  final String? trailingLabel;
  final Widget? trailingWidget;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconBackgroundColor,
    this.trailingLabel,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return KasyHover(
      onTap: onTap,
      focusable: true,
      // Rectangular highlight (default): the card clips the rounded ends, so
      // middle rows stay square instead of showing a floating rounded pill.
      semanticLabel: title,
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.md,
        vertical: KasySpacing.smd,
      ),
      child: Row(
        children: [
          if (iconBackgroundColor != null)
            SettingsIconBadge(icon: icon, color: iconBackgroundColor!)
          else
            Icon(
              icon,
              size: KasyIconSize.rowLeading,
              color: context.colors.onSurface,
            ),
          const SizedBox(width: KasySpacing.sm),
          Expanded(
            child: Text(
              title,
              style: context.kasyTextTheme.listRowTitle.copyWith(
                color: context.colors.onSurface,
              ),
            ),
          ),
          if (trailingLabel != null) ...[
            Text(
              trailingLabel!,
              style: context.kasyTextTheme.listRowValue.copyWith(
                color: context.colors.muted,
              ),
            ),
            const SizedBox(width: KasySpacing.xs),
          ],
          trailingWidget ?? const SettingsListChevron(),
        ],
      ),
    );
  }
}
