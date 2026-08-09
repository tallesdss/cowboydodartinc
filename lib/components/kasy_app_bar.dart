/// Frosted toolbar (title + orbs, backdrop blur). **Placement is up to the parent**
/// — [KasyAppBar] does not force one layout.
///
/// **1 — Underlap (content behind the frost)**
/// Use [KasyOverlayScaffold] or a [Stack]: scroll view fills the screen; first sliver
/// uses [kasyAppBarBodyTopOverlap]; bar in a [Positioned] at `top: 0`. Best for
/// home, long lists, previews.
///
/// **2 — No underlap (bar sits above content)**
/// `[Column]` → `[KasyAppBar]` → `[Expanded]` → your scroll/list, with
/// [KasySpacing.belowChromeContentGap] above the scroll child. Nothing scrolls under
/// the bar (e.g. catalog with an inset list).
///
/// **3 — Bar scrolls away with content**
/// Put [KasyAppBar] *inside* the same scroll view (e.g. first `SliverToBoxAdapter`
/// or top of a [ListView]). Bar and body move together.
///
/// **Styles:** [KasyAppBarStyle.subpage] (back + theme), [KasyAppBarStyle.rootTab],
/// [KasyAppBarStyle.subpageSimple] (back only), [KasyAppBarStyle.subpageActions]
/// (custom [trailing]).
///
/// **Desktop:** [KasyAppBar.application] renders the application chrome (search,
/// quick-create, notifications, profile) for viewports ≥ 1024px — the responsive
/// other half of the same component (formerly a separate web header). The shell
/// places it above content; the page bar then hides on desktop.
///
/// Barrel: [components.dart].

library;

import 'package:cowboydodartinc/components/kasy_avatar_presets.dart';
import 'package:cowboydodartinc/components/kasy_button.dart';
import 'package:cowboydodartinc/components/kasy_tooltip.dart';
import 'package:cowboydodartinc/core/chrome/app_bar_config.dart';
import 'package:cowboydodartinc/core/chrome/app_bar_scope.dart';
import 'package:cowboydodartinc/core/chrome/chrome_visibility.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_brand_logo.dart';
import 'package:cowboydodartinc/core/widgets/kasy_focus_ring.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;

/// Inner toolbar band height (orbit hit targets, title baseline).
const double kasyAppBarToolbarRowHeight = 44;

/// Effective toolbar band height. The page chrome serves phone and tablet — on
/// desktop [KasyAppBar.application] takes over — so the band keeps a single
/// compact height across every viewport where the page bar appears.
double kasyAppBarToolbarRowHeightOf(BuildContext context) =>
    kasyAppBarToolbarRowHeight;

const double kasyAppBarTitleFontScale = 0.92;

/// Height of the desktop application bar band ([KasyAppBar.application]): 36px
/// content + 16px top/bottom. minHeight, not fixed, so the search field never
/// overflows the row.
const double kasyAppBarApplicationHeight = 68;

/// Fixed width of the search field in the desktop application bar.
const double kasyAppBarApplicationSearchWidth = 220;

/// Tight vertical padding inside the frost, above/below [kasyAppBarToolbarRowHeight].
const double kasyAppBarChromePaddingTop = KasySpacing.xs;
const double kasyAppBarChromePaddingBottom = KasySpacing.sm;

/// How [KasyAppBar] interacts with vertically scrolling siblings.
///
/// - [overlay]: put the bar in a [Stack] on top of the scrolling body and pad
///   the body's top with [kasyAppBarBodyTopOverlap].
/// - [intrinsicScroll]: bar is above an [Expanded] list / scroll (e.g.
///   [Column])—no blur underlap below the frost.
enum KasyAppBarScrollTreatment { overlay, intrinsicScroll }

/// Vertical inset for scroll/viewport when using [KasyAppBarScrollTreatment.overlay].
double kasyAppBarBodyTopOverlap(BuildContext context) {
  // On desktop the page bar hides only inside the application-bar scope (the
  // shell), so no overlap there. Outside it (a full-screen pushed route) the bar
  // is visible, so reserve its height like on phone/tablet.
  if (MediaQuery.sizeOf(context).width >= DeviceType.large.breakpoint &&
      KasyAppBarScope.of(context)) {
    return 0;
  }
  return MediaQuery.paddingOf(context).top +
      kasyAppBarChromePaddingTop +
      kasyAppBarToolbarRowHeightOf(context) +
      kasyAppBarChromePaddingBottom;
}

/// Overlap spacer + padded sliver group for overlay chrome.
///
/// Use inside a [CustomScrollView] under a pinned [KasyAppBar] in a [Stack], or use
/// [KasyOverlayScaffold] which applies this for you.
List<Widget> kasyOverlayPaddedSlivers(
  BuildContext context, {
  required List<Widget> slivers,
  EdgeInsetsGeometry? contentPadding,
  double? maxContentWidth,
  bool omitTopPadding = false,
  /// When the page app bar is **intrinsic** (sits above the scroll in a
  /// [Column], e.g. admin shell on phone/tablet), skip the overlay overlap
  /// spacer reserved for a floating [KasyAppBar] in a [Stack].
  bool omitAppBarOverlap = false,
}) {
  final double topPad =
      omitTopPadding ? 0 : KasySpacing.belowChromeContentGap;
  final double bottomPad =
      MediaQuery.paddingOf(context).bottom + KasySpacing.pageVerticalGutter;
  const double gutter = KasySpacing.pageHorizontalGutter;

  final Widget body = SliverMainAxisGroup(slivers: slivers);

  // An explicit [contentPadding] takes full control; otherwise use the page
  // gutters, optionally centering content within [maxContentWidth] on wide
  // viewports (so lists never stretch edge-to-edge on desktop). Centering is
  // computed from the real content width (SliverLayoutBuilder) so it stays
  // correct inside the desktop shell where the sidebar already took space.
  final Widget paddedGroup;
  if (contentPadding != null) {
    paddedGroup = SliverPadding(padding: contentPadding, sliver: body);
  } else if (maxContentWidth == null) {
    paddedGroup = SliverPadding(
      padding: EdgeInsets.fromLTRB(gutter, topPad, gutter, bottomPad),
      sliver: body,
    );
  } else {
    paddedGroup = SliverLayoutBuilder(
      builder: (context, constraints) {
        final double available = constraints.crossAxisExtent;
        final double horizontal = kasyOverlayHorizontalInset(
          availableWidth: available,
          maxContentWidth: maxContentWidth,
        );
        return SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontal,
            topPad,
            horizontal,
            bottomPad,
          ),
          sliver: body,
        );
      },
    );
  }
  final List<Widget> result = <Widget>[];
  if (!omitAppBarOverlap) {
    result.add(
      SliverToBoxAdapter(
        child: SizedBox(height: kasyAppBarBodyTopOverlap(context)),
      ),
    );
  }
  result.add(paddedGroup);
  return result;
}

/// Horizontal inset that centres a [maxContentWidth] column inside [availableWidth]
/// (same math as [kasyOverlayPaddedSlivers]).
double kasyOverlayHorizontalInset({
  required double availableWidth,
  required double maxContentWidth,
}) {
  const double gutter = KasySpacing.pageHorizontalGutter;
  return availableWidth - 2 * gutter > maxContentWidth
      ? (availableWidth - maxContentWidth) / 2
      : gutter;
}

/// Wraps [child] in the same centred column as [kasyOverlayPaddedSlivers].
class KasyOverlayWidthAligned extends StatelessWidget {
  final double? maxContentWidth;
  final Widget child;

  const KasyOverlayWidthAligned({
    super.key,
    required this.child,
    this.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (maxContentWidth == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KasySpacing.pageHorizontalGutter,
        ),
        child: child,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final double horizontal = kasyOverlayHorizontalInset(
          availableWidth: constraints.maxWidth,
          maxContentWidth: maxContentWidth!,
        );
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontal),
          child: child,
        );
      },
    );
  }
}

/// Orbs vs canvas: slightly lifted in dark so they read off [KasyColors.background];
/// soft chip in light, close to frost.
Color kasyChromeOrbFillColor(BuildContext context) {
  final KasyColors colors = context.colors;
  if (Theme.of(context).brightness == Brightness.dark) {
    return Color.lerp(colors.background, colors.surface, 0.32)!;
  }
  return Color.lerp(colors.surface, colors.background, 0.05)!;
}

/// Same frosted/backdrop tint and blur as [KasyAppBar] for custom pinned chrome
/// when a full bar is not used.
class KasyFrostedChromeBackground extends StatelessWidget {
  final Widget child;

  /// Insets content below the notch but keeps the solid fill covering the
  /// status-bar strip so scroll never shows cards behind clock/battery icons.
  final bool padForStatusBar;

  const KasyFrostedChromeBackground({
    super.key,
    required this.child,
    this.padForStatusBar = true,
  });

  /// Solid bar fill from the global `surface` token; follows light/dark.
  Color _tint(BuildContext context) {
    return context.colors.surface;
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = padForStatusBar
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top),
              child,
            ],
          )
        : child;

    final Color tint = _tint(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final BoxShadow baseShadow = KasyShadows.component(context);
    // Stronger shadow multiplier in light mode so the white bar reads off the grey canvas.
    final double shadowAlphaFactor = dark ? 0.4 : 0.58;
    final List<BoxShadow> chromeShadow = <BoxShadow>[
      baseShadow.copyWith(
        color: baseShadow.color.withValues(
          alpha: baseShadow.color.a * shadowAlphaFactor,
        ),
        blurRadius: baseShadow.blurRadius + 0.15,
        spreadRadius: baseShadow.spreadRadius - 0.1,
        offset: Offset(baseShadow.offset.dx, baseShadow.offset.dy + 0.18),
      ),
    ];
    final SystemUiOverlayStyle overlayStyle = dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
          );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: DecoratedBox(
        decoration: BoxDecoration(color: tint, boxShadow: chromeShadow),
        child: content,
      ),
    );
  }
}

/// A soft top wash — the page [KasyColors.background] fading to transparent —
/// sized to the app bar's height. Place it behind the [KasyAppBar] in overlay
/// layouts: when the bar hides on scroll, content melts into the background at
/// the top instead of hard-cutting under the status bar. Mirrors the wash under
/// the bottom navigation bar.
///
/// It is invisible while the bar is shown (it sits directly behind it) and a
/// no-op on desktop (there is no app bar there), so it is always safe to add.
class KasyTopScrollFade extends StatelessWidget {
  const KasyTopScrollFade({super.key});

  /// Total wash height: status-bar strip + a fade zone below it.
  static const double _contentFade = 40.0;

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;
    // On web topInset = 0; enforce a 6 px minimum so the strip still exists.
    final double solidHeight = topInset < 6 ? 6.0 : topInset;
    final double totalHeight = solidHeight + _contentFade;
    // The page background (NOT the bar's `surface`): when the bar hides on
    // scroll, content must melt into the page color, not into a floating sliver
    // of the bar's tint at the top.
    final Color base = context.colors.background;

    // Same gradient the grid cards use for their caption scrim — strong at the
    // top, melting gradually to fully transparent at the bottom.
    return IgnorePointer(
      child: SizedBox(
        height: totalHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                base.withValues(alpha: 0.96),
                base.withValues(alpha: 0.96),
                base.withValues(alpha: 0.68),
                base.withValues(alpha: 0.0),
              ],
              stops: const <double>[0.0, 0.20, 0.55, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

/// Layout preset for [KasyAppBar] (pick one; avoids composing many public pieces).
enum KasyAppBarStyle {
  /// Back + centred title + light/dark theme toggle (dashboard sub-routes).
  subpage,

  /// Back + centred title only (balanced spacer on the right).
  subpageSimple,

  /// Back + centred title + custom [trailing] (no theme toggle).
  subpageActions,

  /// Tab root: centred title + theme orb; no back ([SizedBox] placeholder left).
  rootTab,
}

/// Internal: which chrome a [KasyAppBar] renders — the phone/tablet page bar or
/// the desktop application bar ([KasyAppBar.application]).
enum _KasyAppBarVariant { page, application }

/// Implements the frosted toolbar; usage patterns described in this file header.
class KasyAppBar extends StatelessWidget {
  final String title;

  /// When set, replaces the centred [title] text (e.g. a brand logo on Home).
  final Widget? titleWidget;

  final KasyAppBarStyle style;
  final VoidCallback? onBack;

  /// Only for [KasyAppBarStyle.subpageActions]. Prefer [KasyChromeOrbIconButton]
  /// or wrap a custom 44×44 chrome control with [KasyAppBarChromeTap] for the
  /// same tap target semantics as the built-in orbs.
  final Widget? trailing;

  /// Replaces the default leading control (back button / spacer) — e.g. a menu
  /// orb that opens a [KasySidebar] drawer. Use [KasyChromeOrbIconButton] so it
  /// matches the trailing orbs' size and tap target.
  final Widget? leading;

  final bool useSafeArea;

  /// When set, called instead of [ThemeProvider.toggle] for the theme orb
  /// ([KasyAppBarStyle.subpage], [KasyAppBarStyle.rootTab]).
  final VoidCallback? onThemeToggle;

  /// Overrides [kasyAppBarToolbarRowHeight] for contexts that need a taller bar
  /// (e.g. page-sheet modals). Defaults to [kasyAppBarToolbarRowHeight].
  final double? toolbarHeight;

  /// Extra top padding inserted inside the frosted chrome, above the toolbar
  /// row. Only useful when [useSafeArea] is false (e.g. page-sheet modals)
  /// where there is no status-bar inset to provide natural breathing room.
  final double? topInset;

  /// When true, the bar slides up and fades out as the user scrolls down and
  /// returns on scroll up / at the top, in lock-step with the bottom menu (see
  /// [KasyChromeVisibility]). Opt-in: only safe for pages that lay the bar over
  /// full-height scroll content (the overlay pattern), so an empty gap never
  /// appears where the bar was.
  final bool hideOnScroll;

  // --- Application chrome (desktop, via [KasyAppBar.application]) ---
  // These carry the desktop header (search, quick-create, notifications,
  // profile). They are inert in the default (page) constructor.

  /// Controller for the search field. Optional — omit for a display-only header.
  final TextEditingController? searchController;

  /// Placeholder shown in the search field.
  final String searchHint;

  /// Called as the user types in the search field.
  final ValueChanged<String>? onSearchChanged;

  /// Called when the search field is submitted (Enter).
  final ValueChanged<String>? onSearchSubmitted;

  /// Notifications (bell) action. Ignored when [notifications] is provided.
  final VoidCallback? onNotifications;

  /// Shows the unread dot on the bell. Ignored when [notifications] is provided.
  final bool showNotificationBadge;

  /// Custom notifications control — replaces the built-in bell with a data-aware
  /// widget so the bar itself stays presentational.
  final Widget? notifications;

  /// Primary quick-create action. When null the button is disabled.
  final VoidCallback? onCreate;

  /// Label for the create button.
  final String createLabel;

  /// Gradient for the profile avatar fallback (when [avatar] is null).
  final KasyAvatarGradientData avatarGradient;

  /// Custom avatar widget (e.g. the signed-in user's photo). When null and
  /// [showAvatar] is true, a gradient-fill avatar is shown.
  final Widget? avatar;

  /// Whether the profile avatar is shown (false when the sidebar owns it).
  final bool showAvatar;

  /// Profile avatar tap (open menu / profile).
  final VoidCallback? onAvatarTap;

  /// Theme toggle for the application bar (sun/moon ghost button before the bell).
  final VoidCallback? onToggleTheme;

  /// Whether the search field is shown (application bar).
  final bool showSearch;

  /// Whether the notifications control is shown (application bar).
  final bool showNotifications;

  /// Whether the quick-create button is shown (application bar).
  final bool showCreate;

  final _KasyAppBarVariant _variant;

  const KasyAppBar({
    super.key,
    required this.title,
    this.titleWidget,
    this.style = KasyAppBarStyle.subpage,
    this.onBack,
    this.trailing,
    this.leading,
    this.useSafeArea = true,
    this.onThemeToggle,
    this.toolbarHeight,
    this.topInset,
    this.hideOnScroll = false,
  }) : _variant = _KasyAppBarVariant.page,
       searchController = null,
       searchHint = 'Search...',
       onSearchChanged = null,
       onSearchSubmitted = null,
       onNotifications = null,
       showNotificationBadge = false,
       notifications = null,
       onCreate = null,
       createLabel = 'Create',
       avatarGradient = KasyAvatarGradients.orange,
       avatar = null,
       showAvatar = true,
       onAvatarTap = null,
       onToggleTheme = null,
       showSearch = true,
       showNotifications = true,
       showCreate = true;

  /// Desktop application chrome (viewport ≥ 1024px): global search, quick-create,
  /// notifications and profile, sitting to the right of the sidebar. The
  /// responsive counterpart of the phone/tablet page chrome (the default
  /// constructor) — same component, the other half. The shell places this above
  /// content inside a [KasyAppBarScope]; the page bar then hides on desktop.
  const KasyAppBar.application({
    super.key,
    this.searchController,
    this.searchHint = 'Search...',
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onNotifications,
    this.showNotificationBadge = false,
    this.notifications,
    this.onCreate,
    this.createLabel = 'Create',
    this.avatarGradient = KasyAvatarGradients.orange,
    this.avatar,
    this.showAvatar = true,
    this.onAvatarTap,
    this.onToggleTheme,
    this.showSearch = true,
    this.showNotifications = true,
    this.showCreate = true,
  }) : _variant = _KasyAppBarVariant.application,
       title = '',
       titleWidget = null,
       style = KasyAppBarStyle.rootTab,
       onBack = null,
       trailing = null,
       leading = null,
       useSafeArea = true,
       onThemeToggle = null,
       toolbarHeight = null,
       topInset = null,
       hideOnScroll = false;

  /// Builds the desktop application bar from a [KasyAppBarConfig] — the bridge
  /// the shell uses to render whatever a screen published. Theme/search/create/
  /// notifications appear per the config's `showX` flags.
  factory KasyAppBar.fromConfig(KasyAppBarConfig config, {Key? key}) {
    return KasyAppBar.application(
      key: key,
      showSearch: config.showSearch,
      searchController: config.searchController,
      searchHint: config.searchHint,
      onSearchChanged: config.onSearchChanged,
      onSearchSubmitted: config.onSearchSubmitted,
      onToggleTheme: config.showThemeToggle ? config.onToggleTheme : null,
      showNotifications: config.showNotifications,
      notifications: config.notifications,
      onNotifications: config.onNotifications,
      showNotificationBadge: config.showNotificationBadge,
      showCreate: config.showCreate,
      createLabel: config.createLabel,
      onCreate: config.onCreate,
      showAvatar: config.showAvatar,
      avatar: config.avatar,
      avatarGradient: config.avatarGradient ?? KasyAvatarGradients.orange,
      onAvatarTap: config.onAvatarTap,
    );
  }

  /// True for the desktop application bar ([KasyAppBar.application]); false for
  /// the phone/tablet page bar. Lets tests assert which chrome is mounted without
  /// reaching for a private type.
  bool get isApplication => _variant == _KasyAppBarVariant.application;

  @override
  Widget build(BuildContext context) {
    return switch (_variant) {
      _KasyAppBarVariant.application => _buildApplicationChrome(context),
      _KasyAppBarVariant.page => _buildPageChrome(context),
    };
  }

  Widget _buildPageChrome(BuildContext context) {
    // On desktop the application bar owns the top chrome, so the page bar hides —
    // but ONLY when there actually is one above (i.e. inside the shell's
    // KasyAppBarScope). A full-screen route pushed over the shell has none, so
    // the bar stays visible and its back button is never lost.
    if (MediaQuery.sizeOf(context).width >= DeviceType.large.breakpoint &&
        KasyAppBarScope.of(context)) {
      return const SizedBox.shrink();
    }
    final Color orbFg = context.colors.onSurface;
    final Color orbFill = kasyChromeOrbFillColor(context);
    final VoidCallback handleBack = onBack ?? () => Navigator.maybePop(context);

    final double rowHeight =
        toolbarHeight ?? kasyAppBarToolbarRowHeightOf(context);
    final Widget leadingWidget =
        leading ??
        switch (style) {
          KasyAppBarStyle.rootTab => SizedBox(width: 44, height: rowHeight),
          _ => KasyChromeOrbIconButton(
            icon: KasyIcons.arrowBackIos,
            iconSize: KasyIconSize.md,
            foregroundColor: orbFg,
            fillColor: orbFill,
            onPressed: handleBack,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
        };

    final TextStyle? titleRef =
        context.textTheme.headlineSmall ?? context.textTheme.titleLarge;
    final TextStyle? titleStyle = titleRef?.copyWith(
      fontSize: (titleRef.fontSize ?? 24) * kasyAppBarTitleFontScale,
      // w700 (not w900): a clean page-title weight that matches the Home /
      // sidebar scale. w900 read as a heavy "black" that fought the rest of
      // the chrome.
      fontWeight: FontWeight.w700,
      letterSpacing: -0.35,
      color: context.colors.onBackground,
    );

    final Widget bar = Padding(
      padding: const EdgeInsets.fromLTRB(
        KasySpacing.pageHorizontalGutter,
        kasyAppBarChromePaddingTop,
        KasySpacing.pageHorizontalGutter,
        kasyAppBarChromePaddingBottom,
      ),
      child: SizedBox(
        height: rowHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                leadingWidget,
                const Spacer(),
                _buildTrailing(context, orbFg, orbFill),
              ],
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: titleWidget ??
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle,
                  ),
            ),
          ],
        ),
      ),
    );
    final double inset = topInset ?? 0;
    final Widget barContent = (!useSafeArea && inset > 0)
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: inset),
              bar,
            ],
          )
        : bar;
    final Widget chrome = KasyFrostedChromeBackground(
      padForStatusBar: useSafeArea,
      child: barContent,
    );

    Widget animatedChrome = chrome;
    if (hideOnScroll) {
      // Slide up + fade as the chrome collapses; the same notifier drives the
      // bottom bar, so the two move together.
      final double barHeight = kasyAppBarBodyTopOverlap(context);
      animatedChrome = ValueListenableBuilder<double>(
        valueListenable: KasyChromeVisibility.instance.reveal,
        builder: (BuildContext context, double reveal, Widget? child) {
          final double hidden = 1 - reveal;
          return Transform.translate(
            offset: Offset(0, -barHeight * hidden),
            child: Opacity(opacity: reveal, child: child),
          );
        },
        child: chrome,
      );
    }

    // A top wash sits BEHIND the bar (and stays put even when the bar hides) so
    // content melts into the background at the top — mobile only (tablet/desktop
    // use the sidebar/web header instead). Skipped for modal / page-sheet bars.
    final bool isMobile =
        MediaQuery.sizeOf(context).width < DeviceType.medium.breakpoint;
    final bool standardBar =
        useSafeArea && topInset == null && toolbarHeight == null;
    if (!standardBar || !isMobile) return animatedChrome;
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        const Positioned(top: 0, left: 0, right: 0, child: KasyTopScrollFade()),
        animatedChrome,
      ],
    );
  }

  Widget _buildTrailing(BuildContext context, Color iconFg, Color orbFill) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    switch (style) {
      case KasyAppBarStyle.subpageActions:
        return trailing ?? const SizedBox(width: 44);
      case KasyAppBarStyle.subpageSimple:
        return const SizedBox(width: 44);
      case KasyAppBarStyle.subpage:
        return KasyChromeOrbIconButton(
          icon: isDark ? KasyIcons.lightMode : KasyIcons.darkMode,
          iconSize: KasyIconSize.lg,
          foregroundColor: iconFg,
          fillColor: orbFill,
          onPressed: () {
            final VoidCallback? custom = onThemeToggle;
            if (custom != null) {
              custom();
            } else {
              ThemeProvider.of(context).toggle();
            }
          },
          tooltip: isDark ? 'Light mode' : 'Dark mode',
        );
      case KasyAppBarStyle.rootTab:
        if (trailing != null) return trailing!;
        return KasyChromeOrbIconButton(
          icon: isDark ? KasyIcons.lightMode : KasyIcons.darkMode,
          iconSize: KasyIconSize.lg,
          foregroundColor: iconFg,
          fillColor: orbFill,
          onPressed: () {
            final VoidCallback? custom = onThemeToggle;
            if (custom != null) {
              custom();
            } else {
              ThemeProvider.of(context).toggle();
            }
          },
          tooltip: isDark ? 'Light mode' : 'Dark mode',
        );
    }
  }

  /// Desktop application chrome: search + theme + notifications + create + avatar,
  /// matching [KasySidebar]'s surface fill and hairline border so the two read as
  /// one continuous chrome across the top of the shell.
  Widget _buildApplicationChrome(BuildContext context) {
    final KasyColors c = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(bottom: BorderSide(color: c.border, width: 0.5)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: kasyAppBarApplicationHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              const KasyBrandLogo(
                height: 24,
                semanticLabel: 'Logo',
              ),
              const Spacer(),
              _buildApplicationThemeToggle(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApplicationThemeToggle(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return KasyButton.iconOnly(
      icon: isDark ? KasyIcons.lightMode : KasyIcons.darkMode,
      variant: KasyButtonVariant.ghost,
      size: KasyButtonSize.small,
      iconOnlyLayoutExtent: 36,
      iconGlyphSize: KasyIconSize.md,
      onPressed: onToggleTheme ?? () => ThemeProvider.of(context).toggle(),
      semanticLabel: isDark ? 'Light mode' : 'Dark mode',
    );
  }
}

/// Full-screen scaffold: frosted [KasyAppBar] pinned over scroll content.
class KasyOverlayScaffold extends StatelessWidget {
  final String title;
  final KasyAppBarStyle appBarStyle;
  final VoidCallback? onBack;
  final VoidCallback? onThemeToggle;
  final Widget? trailing;
  final List<Widget> slivers;
  final EdgeInsetsGeometry? contentPadding;

  /// When set, content is centered within this max width on wide viewports
  /// (desktop) instead of stretching edge-to-edge. Use [kKasyContentMaxWidth]
  /// for the standard single-column internal page. Ignored when
  /// [contentPadding] is provided (that takes full control of the insets).
  final double? maxContentWidth;

  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  final Color? backgroundColor;
  final Future<void> Function()? onRefresh;
  final double refreshIndicatorDisplacement;

  /// Forwarded to [KasyAppBar.hideOnScroll]. Safe here because this scaffold is
  /// the overlay pattern (bar floats over full-height scroll content).
  final bool hideAppBarOnScroll;

  /// Desktop only: adapt the shell's application bar for this screen. Receives the
  /// shell default; return e.g. `bar.only(search: true)`. No-op on phone/tablet
  /// (there the page chrome above is what shows). Shortcut for wrapping the body
  /// in a [KasyAppBarConfigurator].
  final KasyAppBarConfigure? applicationBar;

  /// Parent label for the desktop in-shell breadcrumb (e.g. "Settings").
  ///
  /// A sub-page opened inside the desktop shell (sidebar persists, the page bar
  /// hides — see [_buildPageChrome]) would otherwise lose its title and its way
  /// back. When set together with [onBack], the content gets a Stripe-style
  /// header on desktop: a clickable "‹ {backLabel}" link over the page title
  /// (plus any [trailing] actions). On phone/tablet it's ignored — the floating
  /// page bar already carries the back button and title there.
  final String? backLabel;

  const KasyOverlayScaffold({
    super.key,
    required this.title,
    this.appBarStyle = KasyAppBarStyle.subpage,
    this.onBack,
    this.onThemeToggle,
    this.trailing,
    required this.slivers,
    this.contentPadding,
    this.maxContentWidth,
    this.scrollController,
    this.physics,
    this.backgroundColor,
    this.onRefresh,
    this.refreshIndicatorDisplacement = 48,
    this.hideAppBarOnScroll = false,
    this.applicationBar,
    this.backLabel,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = backgroundColor ?? context.colors.background;
    final ScrollPhysics? effectivePhysics =
        physics ??
        (onRefresh != null ? const AlwaysScrollableScrollPhysics() : null);
    // On desktop the page bar hides inside the shell's [KasyAppBarScope], so a
    // sub-page would lose its title and back button. Re-add them as an in-content
    // breadcrumb header (Stripe pattern) — only there, and only when the page
    // declares a back action and a parent label.
    final bool desktopInShell =
        MediaQuery.sizeOf(context).width >= DeviceType.large.breakpoint &&
        KasyAppBarScope.of(context);
    final bool pinDesktopSubpageHeader =
        desktopInShell && onBack != null && backLabel != null;

    Widget scrollView = CustomScrollView(
      controller: scrollController,
      physics: effectivePhysics,
      // Dragging the form means the user is done with the focused field and
      // wants to see what's below, so dismiss the keyboard. Chat views opt out
      // of this wrapper on purpose (there scrolling means reading, not typing).
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: kasyOverlayPaddedSlivers(
        context,
        contentPadding: contentPadding,
        maxContentWidth: maxContentWidth,
        omitTopPadding: pinDesktopSubpageHeader,
        slivers: slivers,
      ),
    );
    final Future<void> Function()? refresh = onRefresh;
    if (refresh != null) {
      scrollView = RefreshIndicator.adaptive(
        displacement: refreshIndicatorDisplacement,
        onRefresh: refresh,
        child: scrollView,
      );
    }

    final Widget pageBody = pinDesktopSubpageHeader
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KasyOverlayWidthAligned(
                maxContentWidth: maxContentWidth,
                child: _KasyDesktopSubpageHeader(
                  title: title,
                  backLabel: backLabel!,
                  onBack: onBack!,
                  trailing: trailing,
                ),
              ),
              Expanded(child: scrollView),
            ],
          )
        : Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(child: scrollView),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: KasyAppBar(
                  title: title,
                  style: appBarStyle,
                  onBack: onBack,
                  onThemeToggle: onThemeToggle,
                  trailing: trailing,
                  hideOnScroll: hideAppBarOnScroll,
                ),
              ),
            ],
          );

    final Widget scaffold = Scaffold(
      backgroundColor: bg,
      body: pageBody,
    );
    final KasyAppBarConfigure? configure = applicationBar;
    if (configure == null) return scaffold;
    return KasyAppBarConfigurator(configure: configure, child: scaffold);
  }
}

/// Stripe-style in-content header for a sub-page opened inside the desktop shell
/// (where the floating page bar hides). A clickable "‹ {backLabel}" link sits
/// over the page title, with optional [trailing] actions on the right. Rendered
/// only by [KasyOverlayScaffold] on desktop; phone/tablet keep the page bar.
class _KasyDesktopSubpageHeader extends StatelessWidget {
  final String title;
  final String backLabel;
  final VoidCallback onBack;
  final Widget? trailing;

  const _KasyDesktopSubpageHeader({
    required this.title,
    required this.backLabel,
    required this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle? titleRef =
        context.textTheme.headlineSmall ?? context.textTheme.titleLarge;
    final TextStyle? titleStyle = titleRef?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.35,
      color: context.colors.onBackground,
    );

    Widget backLink = Semantics(
      button: true,
      label: backLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onBack,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              KasyIcons.arrowBackIos,
              size: KasyIconSize.sm,
              color: context.colors.primary,
            ),
            const SizedBox(width: KasySpacing.xs),
            Text(
              backLabel,
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
    if (kIsWeb) {
      backLink = MouseRegion(cursor: SystemMouseCursors.click, child: backLink);
    }

    // Match the top breathing room of root tabs (Notifications, Settings): the
    // overlay scaffold already applies [belowChromeContentGap]; sub-pages used
    // to add the same gap again in their form padding before the desktop
    // breadcrumb landed here, so restore it once at the header level.
    return Padding(
      padding: const EdgeInsets.only(
        top: KasySpacing.belowChromeContentGap,
        bottom: KasySpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          backLink,
          const SizedBox(height: KasySpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: KasySpacing.md),
                trailing!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// 44×44 tap target for toolbar chrome; optional [tooltip].
///
/// Calls [onPressed] on tap with no animation or delay.
class KasyAppBarChromeTap extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final String? tooltip;

  /// [Semantics.label]; defaults to `'Button'` or non-empty [tooltip].
  final String? semanticsLabel;

  const KasyAppBarChromeTap({
    super.key,
    required this.child,
    required this.onPressed,
    this.tooltip,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final String tip = tooltip ?? '';
    final String label = semanticsLabel ?? (tip.isNotEmpty ? tip : 'Button');

    Widget body = Semantics(
      button: true,
      enabled: true,
      label: label,
      child: KasyFocusRing(
        onActivate: onPressed,
        // Circular icon button, so a large radius keeps the focus ring round.
        borderRadius: BorderRadius.circular(999),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            child: Center(child: child),
          ),
        ),
      ),
    );

    if (tip.isNotEmpty) {
      body = KasyTooltip(message: tip, child: body);
    }
    if (kIsWeb) {
      return MouseRegion(cursor: SystemMouseCursors.click, child: body);
    }
    return body;
  }
}

/// Circular control on the frosted toolbar (back, theme, etc.).
///
/// Wraps the orb with [KasyAppBarChromeTap] (immediate tap, no scale animation).
class KasyChromeOrbIconButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final Color foregroundColor;
  final VoidCallback onPressed;
  final String? tooltip;

  /// Default: [kasyChromeOrbFillColor].
  final Color? fillColor;

  const KasyChromeOrbIconButton({
    super.key,
    required this.icon,
    required this.iconSize,
    required this.foregroundColor,
    required this.onPressed,
    this.tooltip,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color fill = fillColor ?? kasyChromeOrbFillColor(context);
    final BoxShadow baseShadow = KasyShadows.component(context);

    final Widget orb = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill,
        border: Border.all(color: context.colors.borderOrb),
        boxShadow: <BoxShadow>[
          baseShadow.copyWith(
            color: baseShadow.color.withValues(
              alpha: baseShadow.color.a * 0.42,
            ),
            blurRadius: baseShadow.blurRadius - 1.6,
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, size: iconSize, color: foregroundColor),
      ),
    );

    return KasyAppBarChromeTap(
      tooltip: tooltip,
      semanticsLabel: tooltip,
      onPressed: onPressed,
      child: orb,
    );
  }
}
