import 'package:cowboydodartinc/components/kasy_link.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// One level in a [KasyBreadcrumbs] trail.
class KasyBreadcrumbItem {
  const KasyBreadcrumbItem(this.label, {this.onTap});

  final String label;

  /// Tapped when the item is navigable. The last item (the current page) is
  /// always rendered as non-interactive, so its [onTap] is ignored.
  final VoidCallback? onTap;
}

/// Contextual navigation showing the user's location in a hierarchy (HeroUI
/// "Breadcrumbs"). Items are laid out in a single horizontal row separated by
/// chevrons; every item except the last is a navigable [KasyLink], and the last
/// item is the visually distinct, non-interactive current page.
///
/// ```dart
/// KasyBreadcrumbs(items: [
///   KasyBreadcrumbItem('Home', onTap: () => context.go('/')),
///   KasyBreadcrumbItem('Components', onTap: () => context.go('/components')),
///   KasyBreadcrumbItem('Breadcrumbs'), // current page
/// ])
/// ```
class KasyBreadcrumbs extends StatelessWidget {
  const KasyBreadcrumbs({super.key, required this.items});

  final List<KasyBreadcrumbItem> items;

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    final List<Widget> row = <Widget>[];

    for (int i = 0; i < items.length; i++) {
      if (i > 0) {
        // Separator chevron between items — 12px, muted (Figma).
        row.add(const SizedBox(width: 4));
        row.add(Icon(KasyIcons.chevronRight, size: 12, color: c.muted));
        row.add(const SizedBox(width: 4));
      }

      final KasyBreadcrumbItem item = items[i];
      final bool isCurrent = i == items.length - 1;

      final Widget content;
      if (isCurrent) {
        // Current page: darker (onSurface), non-interactive.
        content = Text(item.label, style: _itemStyle(context, c.onSurface));
      } else if (item.onTap != null) {
        // Navigable level with a handler: muted link with hover underline.
        content = KasyLink(
          label: item.label,
          onPressed: item.onTap,
          color: c.muted,
        );
      } else {
        // Navigable level without a wired handler: still a full-opacity muted
        // label (NOT KasyLink, whose null onPressed would dim it to 50%).
        content = Text(item.label, style: _itemStyle(context, c.muted));
      }

      // Figma "Link" padding: 2px each side.
      row.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: content,
      ));
    }

    return Row(mainAxisSize: MainAxisSize.min, children: row);
  }

  /// Breadcrumb label style — Link sm: Nunito Medium 14 / 20.
  TextStyle _itemStyle(BuildContext context, Color color) =>
      (context.textTheme.bodyMedium ?? const TextStyle()).copyWith(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w500,
        color: color,
      );
}
