import 'package:cowboydodartinc/components/kasy_card.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/page_background.dart';
import 'package:flutter/material.dart';

/// Canonical screen scaffold. A new page that uses it inherits the internal
/// screen contract for free: the page background, a centred content column
/// capped at [maxContentWidth], the page gutter, scroll handling, and
/// (optionally) a [KasyCard] wrapper — all from design-system tokens.
///
/// Opt-in by design: it is a thin convenience over [Scaffold] (it forwards the
/// same `appBar`, `floatingActionButton`, `bottomNavigationBar` slots), not a
/// cage. Screens that need bespoke chrome can keep using [Scaffold] directly —
/// nothing here is forced, and any value is overridable.
///
/// ```dart
/// KasyScreen(
///   appBar: KasyAppBar.root(title: 'Settings'),
///   card: true,
///   child: Column(children: [...]),
/// )
/// ```
class KasyScreen extends StatelessWidget {
  const KasyScreen({
    super.key,
    required this.child,
    this.appBar,
    this.scrollable = true,
    this.maxContentWidth = 600,
    this.padding,
    this.card = false,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  /// Page content.
  final Widget child;

  /// Optional top bar. Same slot as [Scaffold.appBar]; pass any
  /// [PreferredSizeWidget].
  final PreferredSizeWidget? appBar;

  /// Wrap the content in a scroll view (default true). Set false for screens
  /// that manage their own scrolling (e.g. a full-bleed list).
  final bool scrollable;

  /// Max width of the content column on wide screens. The internal-screen
  /// contract is ~600; content is centred within the available width so it does
  /// not stretch edge-to-edge on web/desktop.
  final double maxContentWidth;

  /// Padding around the content. Defaults to the horizontal page gutter plus
  /// vertical breathing room.
  final EdgeInsetsGeometry? padding;

  /// Wrap the content in an elevated [KasyCard] (radius 16), matching the Home
  /// reference look.
  final bool card;

  /// Page background. Defaults to the theme background token.
  final Color? backgroundColor;

  /// Forwarded to [Scaffold.resizeToAvoidBottomInset].
  final bool? resizeToAvoidBottomInset;

  /// Forwarded to [Scaffold.floatingActionButton].
  final Widget? floatingActionButton;

  /// Forwarded to [Scaffold.bottomNavigationBar].
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry resolvedPadding = padding ??
        const EdgeInsets.symmetric(
          horizontal: KasySpacing.pageHorizontalGutter,
          vertical: KasySpacing.lg,
        );

    Widget content = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxContentWidth),
      child: card ? KasyCard(child: child) : child,
    );

    content = Align(
      alignment: Alignment.topCenter,
      child: Padding(padding: resolvedPadding, child: content),
    );

    if (scrollable) {
      content = SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? context.colors.background,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Background(
        bgColor: backgroundColor,
        // top:false when an app bar is present — Scaffold already insets the
        // body below it, so SafeArea only needs to guard the bottom/sides.
        child: SafeArea(top: appBar == null, child: content),
      ),
    );
  }
}
