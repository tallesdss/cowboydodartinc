import 'package:flutter/widgets.dart';

/// Publishes whether the shell [KasySidebar] is currently wide (expanded) or a
/// thin icon rail (collapsed). Owned by the tablet/desktop shell above both the
/// sidebar and the routed pages, so the page app bar can hide the brand logo
/// when the sidebar already shows it (one brand mark at a time).
///
/// [notifier] value is `true` when the sidebar is wide.
class KasySidebarExpansionScope extends InheritedNotifier<ValueNotifier<bool>> {
  const KasySidebarExpansionScope({
    super.key,
    required ValueNotifier<bool> notifier,
    required super.child,
  }) : super(notifier: notifier);

  /// Whether the shell sidebar is wide. Rebuilds when the toggle flips.
  /// Outside the tablet/desktop shell (phone bottom-bar layout) returns `false`.
  static bool isExpandedOf(BuildContext context) {
    final ValueNotifier<bool>? notifier =
        context.dependOnInheritedWidgetOfExactType<KasySidebarExpansionScope>()
            ?.notifier;
    return notifier?.value ?? false;
  }

  /// Same as [isExpandedOf] without establishing a dependency (no rebuild).
  static bool maybeExpandedOf(BuildContext context) {
    final ValueNotifier<bool>? notifier =
        context.getInheritedWidgetOfExactType<KasySidebarExpansionScope>()
            ?.notifier;
    return notifier?.value ?? false;
  }
}
