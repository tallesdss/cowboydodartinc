import 'package:cowboydodartinc/components/kasy_app_bar.dart';
import 'package:cowboydodartinc/components/kasy_bottom_sheet.dart';
import 'package:cowboydodartinc/components/kasy_button.dart';
import 'package:cowboydodartinc/components/kasy_card.dart';
import 'package:cowboydodartinc/components/kasy_dialog.dart';
import 'package:cowboydodartinc/components/kasy_empty_state.dart';
import 'package:cowboydodartinc/components/kasy_sidebar.dart';
import 'package:cowboydodartinc/components/kasy_skeleton.dart';
import 'package:cowboydodartinc/components/kasy_status_tag.dart';
import 'package:cowboydodartinc/components/kasy_switch.dart';
import 'package:cowboydodartinc/components/kasy_text_field.dart';
import 'package:cowboydodartinc/core/app_update/update_available_sheet.dart';
import 'package:cowboydodartinc/core/bottom_menu/sidebar_focus.dart';
import 'package:cowboydodartinc/core/bottom_menu/web_content_wrapper.dart';
import 'package:cowboydodartinc/core/chrome/sidebar_expansion_scope.dart';
import 'package:cowboydodartinc/core/config/features.dart';
import 'package:cowboydodartinc/core/data/models/user.dart';
import 'package:cowboydodartinc/core/dev_inspector/dev_inspector.dart';
import 'package:cowboydodartinc/core/rating/widgets/review_popup.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/toast/toast_service.dart';
import 'package:cowboydodartinc/core/web_device_preview/web_device_preview.dart';
import 'package:cowboydodartinc/core/widgets/kasy_brand_logo.dart';
import 'package:cowboydodartinc/core/widgets/kasy_hover.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/core/widgets/update_bottom_sheet.dart';
import 'package:cowboydodartinc/features/feedbacks/api/entities/feature_request_entity.dart';
import 'package:cowboydodartinc/features/feedbacks/api/feature_request_api.dart';
import 'package:cowboydodartinc/features/home/components_navigation.dart';
import 'package:cowboydodartinc/features/home/home_components_page.dart';
import 'package:cowboydodartinc/features/kanban/ui/kanban_page.dart';
import 'package:cowboydodartinc/features/library/providers/library_stats_provider.dart';
import 'package:cowboydodartinc/features/notifications/api/local_notifier.dart';
import 'package:cowboydodartinc/features/notifications/providers/models/notification.dart'
    as kasy_kit;
import 'package:cowboydodartinc/features/settings/ui/components/admin/admin_categories_tab.dart';
import 'package:cowboydodartinc/features/settings/ui/components/admin/admin_routes.dart';
import 'package:cowboydodartinc/features/settings/ui/components/admin/admin_users_tab.dart';
import 'package:cowboydodartinc/features/settings/ui/components/admin/send_push_notification_page.dart';
import 'package:cowboydodartinc/features/settings/ui/widgets/kasy_user_avatar.dart';
import 'package:cowboydodartinc/features/settings/ui/widgets/settings_tile.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/premium_page_factory.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:cowboydodartinc/router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Admin sections — single source of truth shared by the router (URL branches)
// and the sidebar (nav items), so the two can never drift out of sync.
// ─────────────────────────────────────────────────────────────────────────────
/// A navigable admin section. Each maps to a real URL branch in the router.
///
/// The first three are top-level rows under the "ADMIN" label; the rest live
/// inside the sidebar's expandable "Ferramentas" submenu
/// ([AdminSectionDef.inToolsGroup]). All sections ship in production (admins
/// reach them in release); only [debug]'s home-widgets-panel tile is hidden
/// outside [kDebugMode] and on web (home widgets are native-only).
enum AdminSection {
  overview,
  users,
  requests,
  kanban,
  sendPush,
  categories,
  paywalls,
  components,
  debug,
}

/// Descriptor for one admin section: its real URL [path], sidebar [icon] and the
/// [build]er for its (body-only) view. [inToolsGroup] places the row inside the
/// sidebar's "Ferramentas" submenu instead of the top-level list.
class AdminSectionDef {
  final AdminSection id;
  final String path;
  final IconData icon;
  final Widget Function() build;
  final bool inToolsGroup;
  const AdminSectionDef({
    required this.id,
    required this.path,
    required this.icon,
    required this.build,
    this.inToolsGroup = false,
  });
}

/// The admin sections, in sidebar/URL order. The four "Ferramentas" sub-screens
/// are real sections too (own branch, own URL, persistent rail) and all ship in
/// production — only Debug's home-widgets-panel tile is hidden outside debug
/// builds and on web (native-only). The router (branches) and the sidebar (nav
/// rows) both read this single list, so they can never drift.
List<AdminSectionDef> adminSections() => [
  AdminSectionDef(
    id: AdminSection.overview,
    path: adminBasePath,
    icon: KasyIcons.dashboard,
    build: () => const _OverviewTab(),
  ),
  AdminSectionDef(
    id: AdminSection.users,
    path: '$adminBasePath/users',
    icon: KasyIcons.users,
    build: () => const _UsersTab(),
  ),
  AdminSectionDef(
    id: AdminSection.requests,
    path: '$adminBasePath/requests',
    icon: KasyIcons.idea,
    build: () => const _RequestsTab(),
  ),
  if (withKanban)
    AdminSectionDef(
      id: AdminSection.kanban,
      path: adminKanbanPath,
      icon: KasyIcons.checkCircle,
      build: () => const _KanbanTab(),
    ),
  // ── "Ferramentas" submenu ───────────────────────────────────────────────
  AdminSectionDef(
    id: AdminSection.sendPush,
    path: adminRouteSendPush,
    icon: KasyIcons.notificationActive,
    build: () => const SendPushNotificationPage(),
    inToolsGroup: true,
  ),
  AdminSectionDef(
    id: AdminSection.categories,
    path: adminRouteCategories,
    icon: KasyIcons.folder,
    build: () => const AdminCategoriesTab(),
    inToolsGroup: true,
  ),
  AdminSectionDef(
    id: AdminSection.paywalls,
    path: adminRoutePaywalls,
    icon: KasyIcons.payment,
    build: () => const _PaywallsTab(),
    inToolsGroup: true,
  ),
  // Components and Debug ship in production too (admins reach them in release).
  // Debug's body hides its one developer-only tile (the home-widgets panel,
  // native + kDebugMode only; its drill-down route matches that gate).
  AdminSectionDef(
    id: AdminSection.components,
    path: adminRouteComponents,
    icon: KasyIcons.widgets,
    build: () => const _ComponentsTab(),
    inToolsGroup: true,
  ),
  AdminSectionDef(
    id: AdminSection.debug,
    path: adminRouteDebug,
    icon: KasyIcons.note,
    build: () => const _DebugTab(),
    inToolsGroup: true,
  ),
];

/// Resolves where opening the admin console should land. Release always opens the
/// Overview ([adminBasePath]). Debug opens [adminKanbanPath] when
/// [kDebugAdminOpensKanban] is true and the Kanban module is enabled.
String resolveAdminEntryLocation() {
  if (!kDebugMode || !kDebugAdminOpensKanban || !withKanban) {
    return adminBasePath;
  }
  return adminKanbanPath;
}

/// Localized sidebar / app-bar label for a section.
String adminSectionLabel(AdminSection id) {
  final tabs = t.admin_console.tabs;
  return switch (id) {
    AdminSection.overview => tabs.overview,
    AdminSection.users => tabs.users,
    AdminSection.requests => tabs.requests,
    AdminSection.kanban => t.kanban.title,
    AdminSection.sendPush => t.home.features_page.send_push_title,
    AdminSection.categories => tabs.categories,
    AdminSection.paywalls => t.settings.admin.paywalls,
    AdminSection.components => t.home.dashboard.components_title,
    AdminSection.debug => tabs.debug,
  };
}

/// Persistent chrome for the admin console: the navigation rail (sidebar on
/// desktop, drawer on mobile) wrapping the routed section content. Each section
/// is a real, URL-addressable screen ([adminSections]); the rail reflects and
/// drives [StatefulNavigationShell.currentIndex] so the browser URL, the back
/// button and web state-restoration all behave like the rest of the app.
///
/// Reached from Settings via `context.go` (see `_openAdminConsole`): the console
/// is a full-screen shell that owns its URL, so each section is addressable and a
/// reload resumes it. "Back to app" returns to Settings (see [_backToApp]). Built
/// from the same design system as the real [KasySidebar]/[KasyAppBar] so it reads
/// as native product chrome.
///
/// Access: the router redirects non-admins away from `/admin*` in production
/// (see the guard in `router.dart`) — the real lock is at the routing layer, not
/// just hidden UI. In debug anyone reaches it; server-backed sections still gate
/// their data by role internally.
class AdminShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;
  const AdminShell({super.key, required this.navigationShell});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// `true` while the admin sidebar is wide. Drives one-brand-at-a-time on the
  /// tablet page app bar (logo in bar when rail; logo in sidebar when wide).
  late final ValueNotifier<bool> _sidebarExpanded = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _sidebarExpanded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = ref.watch(userStateNotifierProvider).user.isAdmin;
    final ac = t.admin_console;

    // Defense in depth: the router already redirects non-admins away from
    // /admin* in production, so this only ever renders in the unexpected case
    // the shell is reached without the role (never in a release build).
    if (!isAdmin && !kDebugMode) {
      return Scaffold(
        backgroundColor: context.colors.background,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KasyAppBar(title: 'Admin'),
            Expanded(
              child: _EmptyState(
                icon: KasyIcons.security,
                title: ac.tabs.overview,
                message: ac.requires_admin,
              ),
            ),
          ],
        ),
      );
    }

    final List<AdminSectionDef> sections = adminSections();
    final int index = widget.navigationShell.currentIndex;
    final double width = MediaQuery.sizeOf(context).width;
    // Same breakpoints as the app shell (bottom_menu.dart +
    // web_content_wrapper.dart): the sidebar shows from tablet up (collapsing to
    // the icon rail on tablet), and the web header replaces the app bar only on
    // desktop.
    final bool hasSidebar = width >= DeviceType.medium.breakpoint;

    void selectEntry(int i) {
      // Re-tapping the active section resets its branch to the root, the
      // standard StatefulShellRoute / tab-bar behaviour.
      widget.navigationShell.goBranch(
        i,
        initialLocation: i == widget.navigationShell.currentIndex,
      );
      if (!hasSidebar) _scaffoldKey.currentState?.closeDrawer();
    }

    // Profile block in the rail, populated exactly like the app sidebar
    // (bottom_menu.dart): the real name/email + the signed-in user's avatar.
    final User user = ref.watch(userStateNotifierProvider).user;
    final (String profileName, String profileEmail) = switch (user) {
      final AuthenticatedUserData u => (
        (u.name?.isNotEmpty ?? false) ? u.name! : u.email.split('@').first,
        u.email,
      ),
      _ => (t.settings.my_account, ''),
    };

    // The app's real KasySidebar, driven by the admin sections (same component,
    // same logo/dividers/collapse/tooltips/profile — no bespoke copy). The
    // top-level sections are flat rows; the four Tools sub-screens live inside an
    // expandable "Ferramentas" submenu (the same dropdown recipe as the app's
    // Income menu), so each keeps the rail and its own URL.
    KasySidebar buildRail({required bool isDrawer}) {
      final List<KasySidebarItem> items = [
        for (int i = 0; i < sections.length; i++)
          if (!sections[i].inToolsGroup)
            KasySidebarItem(
              icon: sections[i].icon,
              label: adminSectionLabel(sections[i].id),
              selected: i == index,
              onTap: () => selectEntry(i),
            ),
      ];
      final List<KasySidebarSubItem> toolsChildren = [
        for (int i = 0; i < sections.length; i++)
          if (sections[i].inToolsGroup)
            KasySidebarSubItem(
              label: adminSectionLabel(sections[i].id),
              selected: i == index,
              onTap: () => selectEntry(i),
            ),
      ];
      if (toolsChildren.isNotEmpty) {
        items.add(
          KasySidebarItem(
            icon: KasyIcons.briefcase,
            label: t.admin_console.tabs.tools,
            children: toolsChildren,
          ),
        );
      }
      return KasySidebar(
        isDrawer: isDrawer,
        items: items,
        sectionLabel: 'ADMIN',
        footerItems: [
          KasySidebarItem(
            icon: KasyIcons.arrowBackIos,
            label: ac.back_to_app,
            onTap: () {
              if (!hasSidebar) _scaffoldKey.currentState?.closeDrawer();
              _backToApp(context);
            },
          ),
        ],
        profileName: profileName,
        profileEmail: profileEmail,
        profileAvatar: const KasyUserAvatar(),
        expansionListenable: isDrawer ? null : _sidebarExpanded,
      );
    }

    final Widget content = widget.navigationShell;

    Widget buildSectionAppBar({
      required bool phoneDrawer,
      required bool sidebarWide,
    }) {
      final ComponentsDrillDown? drillDown =
          ComponentsNavigation.componentsDrillDown(context);
      final bool desktopShell =
          !phoneDrawer &&
          MediaQuery.sizeOf(context).width >= DeviceType.large.breakpoint;
      final bool tabletShell =
          !phoneDrawer &&
          MediaQuery.sizeOf(context).width >= DeviceType.medium.breakpoint &&
          !desktopShell;
      final Widget? tabletBrandLogo = (!phoneDrawer && !sidebarWide)
          ? KasyBrandLogo(
              height: kasyBrandLogoAppBarHeight(context),
              semanticLabel: t.home.dashboard.brand,
            )
          : null;
      // Drill-down title + back live ONLY in [AdminComponentsDrillDownLayout]
      // ("< Componentes"). Never put a second back on the tablet app bar —
      // default [KasyAppBar] style is subpage and would show a dead arrow.
      if (drillDown != null && desktopShell) {
        return const SizedBox.shrink();
      }
      if (drillDown != null && tabletShell) {
        return KasyAppBar(
          title: '',
          titleWidget: tabletBrandLogo,
          style: KasyAppBarStyle.rootTab,
          onThemeToggle: () => ThemeProvider.of(context).toggle(),
        );
      }
      if (drillDown != null) {
        return KasyAppBar(
          title: drillDown.title,
          onBack: () => ComponentsNavigation.popToCatalog(context),
        );
      }
      if (phoneDrawer) {
        return KasyAppBar(
          title: adminSectionLabel(sections[index].id),
          leading: Builder(
            builder: (ctx) => KasyChromeOrbIconButton(
              icon: KasyIcons.menu,
              iconSize: KasyIconSize.md,
              foregroundColor: context.colors.onSurface,
              onPressed: () => Scaffold.of(ctx).openDrawer(),
              tooltip: MaterialLocalizations.of(ctx).openAppDrawerTooltip,
            ),
          ),
        );
      }
      // Tablet: one brand mark — logo in the bar when the rail is collapsed,
      // section title when the sidebar is wide (logo already in the rail).
      return KasyAppBar(
        title: sidebarWide ? adminSectionLabel(sections[index].id) : '',
        titleWidget: tabletBrandLogo,
        style: KasyAppBarStyle.rootTab,
        onThemeToggle: () => ThemeProvider.of(context).toggle(),
      );
    }

    // Tablet + desktop: the real KasySidebar persists and EVERY section gets the
    // same chrome as the rest of the app (bottom_menu.dart): the web header on
    // desktop / the rootTab app bar on tablet, both supplied here so the section
    // bodies stay chrome-free. Keyboard order matches the app shell:
    // OrderedTraversalPolicy flows Tab sidebar -> header -> content;
    // KasyFocusableSidebar anchors the initial focus to the rail and hosts the
    // skip-to-content link; WebContentWrapper carries the desktop web header +
    // the content focus target (orders 2 and 3) exactly like every app page.
    if (hasSidebar) {
      final Widget branchHost = adminShellAppliesDesktopTopInset(context)
          ? Padding(
              padding: const EdgeInsets.only(
                top: adminDesktopShellTopInset,
              ),
              child: content,
            )
          : content;
      final Widget right = ValueListenableBuilder<bool>(
        valueListenable: _sidebarExpanded,
        builder: (BuildContext context, bool sidebarWide, Widget? _) {
          return WebContentWrapper(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildSectionAppBar(
                  phoneDrawer: false,
                  sidebarWide: sidebarWide,
                ),
                Expanded(child: branchHost),
              ],
            ),
          );
        },
      );
      return KasySidebarExpansionScope(
        notifier: _sidebarExpanded,
        child: Scaffold(
          backgroundColor: context.colors.background,
          body: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FocusTraversalOrder(
                  order: const NumericFocusOrder(1),
                  child: KasyFocusableSidebar(
                    child: buildRail(isDrawer: false),
                  ),
                ),
                Expanded(child: right),
              ],
            ),
          ),
        ),
      );
    }

    // Phone: the page app bar (with a menu orb) over a drawer holding the same
    // KasySidebar — the standard mobile pattern.
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: context.colors.background,
      // Square edge / flat / surface fill all come from the global DrawerThemeData
      // (core/theme/universal_theme.dart); here we only size it to the rail.
      drawer: Drawer(width: kasySidebarWidth, child: buildRail(isDrawer: true)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildSectionAppBar(phoneDrawer: true, sidebarWide: false),
          Expanded(child: content),
        ],
      ),
    );
  }
}

/// Live feature requests (active + hidden), highest-voted first — real data for
/// the Requests tab and the Overview count. Invalidate to refresh after a change.
final _adminRequestsProvider =
    FutureProvider.autoDispose<List<FeatureRequestEntity>>((ref) {
      return ref.read(featureRequestApiProvider).getAll();
    });

// Removed unused provider

// ─────────────────────────────────────────────────────────────────────────────
// Layout primitives
// ─────────────────────────────────────────────────────────────────────────────

// Was a hand-picked 18 with no token behind it — every admin card now shares
// the same radius as `AdminPanelCard` (lib/features/settings/ui/widgets/admin_card.dart).
const double _cardRadius = KasyRadius.lg;

/// Centres content and caps its width so the console looks deliberate on wide
/// web/desktop viewports (mobile fills the screen normally).
class _MaxWidth extends StatelessWidget {
  final Widget child;
  const _MaxWidth({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: adminSectionMaxWidth),
        child: child,
      ),
    );
  }
}

/// Gutter outside the max-width column — the Components tab rhythm for every
/// admin section on desktop.
class _AdminSectionFrame extends StatelessWidget {
  final Widget child;
  final bool scrollable;

  const _AdminSectionFrame({
    required this.child,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget framed = Padding(
      padding: adminSectionBodyPadding(context),
      child: _MaxWidth(child: child),
    );
    if (!scrollable) return framed;
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: framed,
    );
  }
}

/// Scrollable body shared by overview, paywalls, debug, and similar tabs.
class _TabScroll extends StatelessWidget {
  final List<Widget> children;
  const _TabScroll({required this.children});

  @override
  Widget build(BuildContext context) {
    return _AdminSectionFrame(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// Small uppercase label that opens a group (Vercel-style section head).
class _GroupLabel extends StatelessWidget {
  final String label;
  const _GroupLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: KasySpacing.xs,
        // Topic sits close to its container (xs), matching the Settings screen's
        // section-label → card gap — not a wide smd gap that floats the label.
        bottom: KasySpacing.xs,
      ),
      child: Text(
        label.toUpperCase(),
        style: context.kasyTextTheme.sectionLabel.copyWith(
          color: context.colors.muted,
        ),
      ),
    );
  }
}

/// Rounded surface card with a hairline border and the design-system shadow.
class _CardShell extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _CardShell({
    required this.child,
    this.padding = const EdgeInsets.all(KasySpacing.md),
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(
          color: context.colors.outline.withValues(
            alpha: context.isDark ? 0.45 : 0.6,
          ),
        ),
        boxShadow: [KasyShadows.component(context)],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Metric card: a discreet icon, a big value and a muted label on a neutral
/// surface. Monochrome on purpose — the number is the focus, not the colour, so
/// the four sit quietly side by side instead of turning into a carnival.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: context.colors.muted),
          const SizedBox(height: KasySpacing.smd),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.headlineSmall?.copyWith(
              color: context.colors.onSurface,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Lays children out in as many equal columns as fit [minItemWidth], capped at
/// four. Collapses to a single full-width column on narrow screens.
class _ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double minItemWidth;
  const _ResponsiveGrid({required this.children, this.minItemWidth = 240});

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    const double gap = KasySpacing.md;
    const int maxCols = 4;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxW = constraints.maxWidth;
        int cols = ((maxW + gap) / (minItemWidth + gap)).floor();
        cols = cols.clamp(1, maxCols);
        if (cols > children.length) cols = children.length;
        final double itemW = cols <= 1
            ? maxW
            : (maxW - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children) SizedBox(width: itemW, child: child),
          ],
        );
      },
    );
  }
}

/// Leaves the admin console entirely, back to the app. Pops the ROOT navigator
/// so the whole admin shell is removed at once — even when a detail screen is
/// open in a section's nested navigator (a plain pop would only close the
/// detail). Falls back to going home when it can't pop (e.g. a web reload / deep
/// link that landed directly on an /admin URL).
void _backToApp(BuildContext context) {
  final NavigatorState root = Navigator.of(context, rootNavigator: true);
  if (root.canPop()) {
    root.pop();
  } else {
    // No back stack to pop (e.g. after a hot restart, or when the console was
    // entered with `go`): the console is always reached from Settings, so land
    // there rather than on Home.
    context.go('/settings');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Overview — real project + session data (no vanity metrics)
// ─────────────────────────────────────────────────────────────────────────────

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateNotifierProvider);
    final user = userState.user;
    final bool isAuth = user is AuthenticatedUserData;
    final bool isAdmin = user.isAdmin;
    final ov = t.admin_console.overview;
    final admin = t.settings.admin;
    final groups = t.admin_console.groups;
    final String account = isAuth ? user.email : ov.guest;
    final String uid = userState.user.idOrNull ?? '—';

    return _TabScroll(
      children: [
        // Admin-only data panel: live KPIs, the sign-up chart and the plan
        // split. Non-admins (debug builds only) skip straight to the session
        // card — the metrics need the server function, which gates by role.
        if (isAdmin) ...[
          const _LibraryOverviewMetricsPanel(),
          const SizedBox(height: KasySpacing.lg),
        ],
        _GroupLabel(ov.session_title),
        _CardShell(
          padding: const EdgeInsets.symmetric(
            horizontal: KasySpacing.md,
            vertical: KasySpacing.xs,
          ),
          child: Column(
            children: [
              _InfoRow(label: ov.backend, value: 'Firebase'),
              const SettingsDivider(),
              _InfoRow(
                label: ov.account,
                value: account,
                valueColor: isAuth ? null : context.colors.muted,
              ),
              const SettingsDivider(),
              _InfoRow(
                label: ov.user_id,
                value: uid,
                trailing: _CopyButton(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: uid));
                    ref
                        .read(toastProvider)
                        .alert(
                          title: t.common.copied,
                          text: t.settings.admin.user_id_copied,
                        );
                  },
                ),
              ),
              const SettingsDivider(),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snap) => _InfoRow(
                  label: ov.build,
                  value: snap.hasData
                      ? 'v${snap.data!.version} (${snap.data!.buildNumber})'
                      : '…',
                ),
              ),
            ],
          ),
        ),
        // Dev preview tools are toggled by keyboard shortcut (no buttons). Shown
        // only in debug — never in production.
        if (kDebugMode) ...[
          const SizedBox(height: KasySpacing.lg),
          _GroupLabel(groups.preview),
          _CardShell(
            padding: const EdgeInsets.symmetric(
              horizontal: KasySpacing.md,
              vertical: KasySpacing.xs,
            ),
            child: Column(
              children: [
                _ShortcutRow(
                  label: admin.inspector_fab_title,
                  keys: devInspectorShortcutLabel(),
                ),
                if (kIsWeb) ...[
                  const SettingsDivider(),
                  _ShortcutRow(
                    label: admin.device_preview_title,
                    keys: webDevicePreviewShortcutLabel(),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: KasySpacing.md),
        Text(
          ov.users_hint,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.muted,
          ),
        ),
      ],
    );
  }
}

class _LibraryOverviewMetricsPanel extends ConsumerWidget {
  const _LibraryOverviewMetricsPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(libraryStatsProvider);
    final ov = t.admin_console.overview;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GroupLabel(ov.summary),
        _ResponsiveGrid(
          minItemWidth: 168,
          children: [
            _StatCard(
              icon: KasyIcons.book,
              value: _compactCount(stats.totalPdfs),
              label: 'Total de PDFs',
            ),
            _StatCard(
              icon: KasyIcons.eye,
              value: _compactCount(stats.totalViews),
              label: 'Acessos',
            ),
            _StatCard(
              icon: KasyIcons.download,
              value: _compactCount(stats.totalDownloads),
              label: 'Downloads',
            ),
          ],
        ),
        const SizedBox(height: KasySpacing.lg),
        const _GroupLabel('Top Uploaders'),
        _CardShell(
          padding: EdgeInsets.zero,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.uploaderRanking.length,
            separatorBuilder: (context, index) => const SettingsDivider(),
            itemBuilder: (context, index) {
              final rank = stats.uploaderRanking[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: context.colors.primary,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(color: context.colors.onPrimary),
                  ),
                ),
                title: Text(rank.author),
                trailing: Text(
                  '${rank.pdfCount} PDFs',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Abbreviates large counts (1240 → 1.2k) so KPI values never overflow.
String _compactCount(int n) {
  if (n < 1000) return '$n';
  if (n < 1000000) {
    final double v = n / 1000;
    return '${v.toStringAsFixed(v >= 100 ? 0 : 1).replaceAll('.0', '')}k';
  }
  final double v = n / 1000000;
  return '${v.toStringAsFixed(1).replaceAll('.0', '')}M';
}


class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? trailing;
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KasySpacing.smd),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.muted,
              ),
            ),
          ),
          const SizedBox(width: KasySpacing.sm),
          Expanded(
            child: Text(
              value,
              style: context.kasyTextTheme.rowValue.copyWith(
                color: valueColor ?? context.colors.onSurface,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// A dev-tool name with its global keyboard shortcut on the right (read-only).
class _ShortcutRow extends StatelessWidget {
  final String label;
  final String keys;
  const _ShortcutRow({required this.label, required this.keys});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KasySpacing.smd),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurface,
              ),
            ),
          ),
          const SizedBox(width: KasySpacing.sm),
          Text(
            keys,
            style: context.kasyTextTheme.rowValue.copyWith(
              color: context.colors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _CopyButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CopyButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return KasyHover(
      onTap: onTap,
      focusable: true,
      borderRadius: BorderRadius.circular(KasyRadius.sm),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(KasyIcons.copy, size: 16, color: context.colors.primary),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty-state tabs (real content lands next: Users via a server function,
// Requests reads the live feature_requests collection)
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return _TabScroll(
      children: [
        _CardShell(
          padding: const EdgeInsets.symmetric(
            horizontal: KasySpacing.lg,
            vertical: KasySpacing.xxl,
          ),
          child: KasyEmptyState(
            icon: icon,
            title: title,
            subtitle: message,
          ),
        ),
      ],
    );
  }
}

class _UsersTab extends ConsumerWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isAdmin = ref.watch(userStateNotifierProvider).user.isAdmin;
    final u = t.admin_console.users;
    if (!isAdmin) {
      return _EmptyState(
        icon: KasyIcons.security,
        title: u.title,
        message: t.admin_console.requires_admin,
      );
    }
    return const AdminUsersTab();
  }
}

class _KanbanTab extends ConsumerWidget {
  const _KanbanTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isAdmin = ref.watch(userStateNotifierProvider).user.isAdmin;
    if (!isAdmin) {
      return _EmptyState(
        icon: KasyIcons.security,
        title: t.kanban.title,
        message: t.admin_console.requires_admin,
      );
    }
    return const KanbanPage();
  }
}

class _RequestsTab extends ConsumerWidget {
  const _RequestsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isAdmin = ref.watch(userStateNotifierProvider).user.isAdmin;
    final r = t.admin_console.requests;
    if (!isAdmin) {
      return _EmptyState(
        icon: KasyIcons.security,
        title: r.title,
        message: t.admin_console.requires_admin,
      );
    }
    final AsyncValue<List<FeatureRequestEntity>> async = ref.watch(
      _adminRequestsProvider,
    );
    return async.when(
      loading: () => _TabScroll(
        children: [
          _GroupLabel(t.admin_console.tabs.requests),
          Padding(
            padding: const EdgeInsets.only(
              left: KasySpacing.xs,
              bottom: KasySpacing.md,
            ),
            child: Text(
              r.subtitle,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.muted,
                height: 1.35,
              ),
            ),
          ),
          for (int i = 0; i < 4; i++) ...[
            const _RequestCardSkeleton(),
            const SizedBox(height: KasySpacing.sm),
          ],
        ],
      ),
      error: (_, _) => _EmptyState(
        icon: KasyIcons.message,
        title: r.title,
        message: r.error,
      ),
      data: (list) {
        if (list.isEmpty) {
          return _EmptyState(
            icon: KasyIcons.idea,
            title: r.empty,
            message: r.empty_hint,
          );
        }
        // Newest first — the most recently submitted request leads the list.
        final sorted = [...list]
          ..sort((a, b) => b.creationDate.compareTo(a.creationDate));
        return _TabScroll(
          children: [
            _GroupLabel(t.admin_console.tabs.requests),
            Padding(
              padding: const EdgeInsets.only(
                left: KasySpacing.xs,
                bottom: KasySpacing.md,
              ),
              child: Text(
                r.subtitle,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.muted,
                  height: 1.35,
                ),
              ),
            ),
            for (final req in sorted) ...[
              _RequestCard(req),
              const SizedBox(height: KasySpacing.sm),
            ],
          ],
        );
      },
    );
  }
}

/// Picks the value for [lang], falling back to English then anything present.
String _pickLocale(Map<String, String> m, String lang) =>
    m[lang] ?? m['en'] ?? (m.isNotEmpty ? m.values.first : '');

class _RequestCardSkeleton extends StatelessWidget {
  const _RequestCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _CardShell(
      child: KasySkeletonGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KasySkeleton(
                  width: 48,
                  height: 56,
                  borderRadius: BorderRadius.all(Radius.circular(KasyRadius.sm)),
                ),
                SizedBox(width: KasySpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KasySkeleton(width: double.infinity, height: 14),
                      SizedBox(height: 6),
                      KasySkeleton(width: double.infinity, height: 12),
                      SizedBox(height: 4),
                      KasySkeleton(width: 200, height: 12),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: KasySpacing.smd),
            Divider(height: 1),
            SizedBox(height: KasySpacing.sm),
            Row(
              children: [
                KasySkeleton(width: 64, height: 24),
                SizedBox(width: KasySpacing.sm),
                KasySkeleton(width: 40, height: 24),
                Spacer(),
                KasySkeleton(width: 72, height: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends ConsumerStatefulWidget {
  final FeatureRequestEntity req;
  const _RequestCard(this.req);

  @override
  ConsumerState<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends ConsumerState<_RequestCard> {
  bool? _optimisticActive;
  int _toggleGeneration = 0;

  bool get _active => _optimisticActive ?? widget.req.active;

  @override
  void didUpdateWidget(covariant _RequestCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.req.active != widget.req.active &&
        (_optimisticActive == null || widget.req.active == _optimisticActive)) {
      _optimisticActive = null;
    }
  }

  Future<void> _setActive(bool active) async {
    final int generation = ++_toggleGeneration;
    setState(() => _optimisticActive = active);
    final r = t.admin_console.requests;
    try {
      await ref
          .read(featureRequestApiProvider)
          .setActive(widget.req.id!, active);
      if (!mounted || generation != _toggleGeneration) return;
      ref.invalidate(_adminRequestsProvider);
      ref.read(toastProvider).alert(title: t.common.saved, text: r.saved);
    } catch (_) {
      if (!mounted || generation != _toggleGeneration) return;
      setState(() => _optimisticActive = widget.req.active);
      ref.read(toastProvider).alert(title: t.common.error, text: r.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = t.admin_console.requests;
    final String lang = Localizations.localeOf(context).languageCode;
    final String title = _pickLocale(widget.req.title, lang);
    final String desc = _pickLocale(widget.req.description, lang);
    final bool active = _active;

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _VotesChip(widget.req.votes),
              const SizedBox(width: KasySpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.kasyTextTheme.listRowTitle.copyWith(
                        color: context.colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.muted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: KasySpacing.smd),
          Divider(
            height: 1,
            color: context.colors.outline.withValues(alpha: 0.35),
          ),
          const SizedBox(height: KasySpacing.smd),
          Row(
            children: [
              KasyStatusTag(
                label: active ? r.visible : r.hidden,
                tone: active
                    ? KasyStatusTagTone.success
                    : KasyStatusTagTone.neutral,
              ),
              const SizedBox(width: KasySpacing.sm),
              KasySwitch(
                value: active,
                onChanged: _setActive,
              ),
              const Spacer(),
              KasyButton(
                label: r.edit,
                variant: KasyButtonVariant.link,
                size: KasyButtonSize.small,
                icon: KasyIcons.language,
                onPressed: () => _openRequestEditor(context, widget.req),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VotesChip extends StatelessWidget {
  final int votes;
  const _VotesChip(this.votes);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(vertical: KasySpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(
          alpha: context.isDark ? 0.16 : 0.08,
        ),
        borderRadius: BorderRadius.circular(KasyRadius.sm),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(KasyIcons.voteUp, size: 18, color: context.colors.primary),
          const SizedBox(height: 2),
          Text(
            '$votes',
            style: context.textTheme.labelLarge?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _openRequestEditor(
  BuildContext context,
  FeatureRequestEntity req,
) {
  final bool isDesktop =
      MediaQuery.sizeOf(context).width >= DeviceType.large.breakpoint;
  if (isDesktop) {
    return showKasyBlurDialog<void>(
      context: context,
      builder: (_) => _RequestEditorForm(asDialog: true, req: req),
    );
  }
  return showKasyBlurBottomSheet<void>(
    context: context,
    builder: (_) => _RequestEditorForm(asDialog: false, req: req),
  );
}

class _RequestEditorForm extends ConsumerStatefulWidget {
  final bool asDialog;
  final FeatureRequestEntity req;

  const _RequestEditorForm({required this.asDialog, required this.req});

  @override
  ConsumerState<_RequestEditorForm> createState() => _RequestEditorFormState();
}

class _RequestEditorFormState extends ConsumerState<_RequestEditorForm> {
  static const List<String> _langs = ['en', 'pt', 'es'];
  late final Map<String, TextEditingController> _title;
  late final Map<String, TextEditingController> _desc;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = {
      for (final l in _langs)
        l: TextEditingController(text: widget.req.title[l] ?? ''),
    };
    _desc = {
      for (final l in _langs)
        l: TextEditingController(text: widget.req.description[l] ?? ''),
    };
  }

  @override
  void dispose() {
    for (final c in _title.values) {
      c.dispose();
    }
    for (final c in _desc.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _langLabel(String l) {
    final r = t.admin_console.requests;
    return switch (l) {
      'en' => r.lang_en,
      'pt' => r.lang_pt,
      _ => r.lang_es,
    };
  }

  Future<void> _save() async {
    final r = t.admin_console.requests;
    setState(() => _saving = true);
    try {
      await ref
          .read(featureRequestApiProvider)
          .updateTexts(
            id: widget.req.id!,
            title: {for (final l in _langs) l: _title[l]!.text.trim()},
            description: {for (final l in _langs) l: _desc[l]!.text.trim()},
          );
      ref.invalidate(_adminRequestsProvider);
      if (!mounted) return;
      context.pop();
      ref.read(toastProvider).alert(title: t.common.saved, text: r.saved);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ref.read(toastProvider).alert(title: t.common.error, text: r.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = t.admin_console.requests;
    final Widget fields = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final l in _langs) ...[
          _GroupLabel(_langLabel(l)),
          KasyTextField(
            controller: _title[l],
            label: r.field_title,
            maxLength: 60,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: KasySpacing.sm),
          KasyTextField(
            controller: _desc[l],
            label: r.field_description,
            minLines: 2,
            maxLines: 4,
            maxLength: 1000,
          ),
          const SizedBox(height: KasySpacing.md),
        ],
      ],
    );

    final List<Widget> actions = [
      KasyButton(
        label: t.common.close,
        variant: KasyButtonVariant.outline,
        expand: true,
        onPressed: _saving ? null : () => Navigator.of(context).pop(),
      ),
      KasyButton(
        label: r.save,
        expand: true,
        isLoading: _saving,
        onPressed: _saving ? null : _save,
      ),
    ];

    if (widget.asDialog) {
      return KasyDialog(
        title: r.editor_title,
        showCloseButton: false,
        body: KasyDialogScrollableBody(
          maxHeight: 420,
          child: fields,
        ),
        actionsAxis: Axis.horizontal,
        actions: actions,
      );
    }

    return KasyBottomSheet(
      title: r.editor_title,
      addKeyboardInset: true,
      body: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.5,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: fields,
        ),
      ),
      actions: [
        KasyButton(
          label: r.save,
          expand: true,
          isLoading: _saving,
          onPressed: _saving ? null : _save,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tools sub-screens — each is a real console section (body only; the admin
// shell supplies the chrome), reached from the sidebar's "Ferramentas" submenu.
// ─────────────────────────────────────────────────────────────────────────────

/// Settings-style card: rows separated by hairline dividers — the exact clean
/// list pattern of the Settings screen. Mirrors `SettingsContainer`: the
/// design-system [KasyCard] at the settings-density radius with NO inner
/// padding, so each tile's press/hover highlight spans the full card width and
/// is clipped to the rounded corners (instead of a pill floating inside a white
/// margin). Shared by the Tools sections.
Widget _groupCard(List<Widget> rows) => KasyCard(
  borderRadius: BorderRadius.circular(KasyRadius.lg),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (int i = 0; i < rows.length; i++) ...[
        if (i > 0) const SettingsDivider(),
        rows[i],
      ],
    ],
  ),
);

/// Paywalls panel — every variant as a rich card: a friendly name, a short
/// description and its code (the id you hand the assistant to pick one), with a
/// copy button. Tapping a card opens the live preview. Production section; the
/// preview route is debug-only, so it only opens a screen in debug builds.
class _PaywallsTab extends StatelessWidget {
  const _PaywallsTab();

  // Ordered simplest → richest so the gallery reads as a deliberate sequence.
  static const List<String> _order = [
    'solo',
    'compare',
    'trial',
    'unlock',
  ];

  @override
  Widget build(BuildContext context) {
    final admin = t.settings.admin;
    final pw = t.admin_console.paywalls;
    return _TabScroll(
      children: [
        _GroupLabel(admin.paywalls),
        Padding(
          padding: const EdgeInsets.only(
            left: KasySpacing.xs,
            bottom: KasySpacing.md,
          ),
          child: Text(
            pw.subtitle,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.muted,
              height: 1.35,
            ),
          ),
        ),
        for (final id in _order) ...[
          _PaywallCard(
            paywall: PaywallFactory.values.firstWhere((p) => p.name == id),
          ),
          const SizedBox(height: KasySpacing.sm),
        ],
      ],
    );
  }
}

/// Localized friendly title + description for a paywall id.
({String title, String desc}) _paywallMeta(String id) {
  final pw = t.admin_console.paywalls;
  return switch (id) {
    'trial' || 'withSwitch' => (title: pw.trial_title, desc: pw.trial_desc),
    'compare' || 'basicRow' => (title: pw.compare_title, desc: pw.compare_desc),
    'unlock' || 'basic' => (title: pw.unlock_title, desc: pw.unlock_desc),
    _ => (title: pw.solo_title, desc: pw.solo_desc),
  };
}

class _PaywallCard extends ConsumerWidget {
  final PaywallFactory paywall;
  const _PaywallCard({required this.paywall});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pw = t.admin_console.paywalls;
    final meta = _paywallMeta(paywall.name);
    return KasyHover(
      onTap: () => context.push(adminRoutePremiumPreview(paywall.name)),
      borderRadius: BorderRadius.circular(_cardRadius),
      semanticLabel: meta.title,
      child: _CardShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    meta.title,
                    style: context.kasyTextTheme.listRowTitle.copyWith(
                      color: context.colors.onSurface,
                      // Content card title: 16 / w600 — same standard as the
                      // Requests / notifications / feedback cards.
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: KasySpacing.sm),
                Icon(
                  KasyIcons.chevronRight,
                  size: 18,
                  color: context.colors.muted,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              meta.desc,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.muted,
                height: 1.35,
              ),
            ),
            const SizedBox(height: KasySpacing.smd),
            _CodeChip(
              code: paywall.name,
              onCopy: () {
                Clipboard.setData(ClipboardData(text: paywall.name));
                ref
                    .read(toastProvider)
                    .alert(title: t.common.copied, text: pw.code_copied);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Monospace code pill (the paywall id) with a copy icon — tap to copy and hand
/// it to the assistant. Its own tap target, so it never triggers the card.
class _CodeChip extends StatelessWidget {
  final String code;
  final VoidCallback onCopy;
  const _CodeChip({required this.code, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return KasyHover(
      onTap: onCopy,
      borderRadius: BorderRadius.circular(KasyRadius.sm),
      semanticLabel: t.admin_console.paywalls.copy_code,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: context.colors.surfaceNeutralSoft,
          borderRadius: BorderRadius.circular(KasyRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              code,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.muted,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Icon(KasyIcons.copy, size: 13, color: context.colors.primary),
          ],
        ),
      ),
    );
  }
}

/// The UI-kit catalog as a console section.
class _ComponentsTab extends StatelessWidget {
  const _ComponentsTab();

  @override
  Widget build(BuildContext context) {
    return const _AdminSectionFrame(
      child: HomeComponentsCatalog(omitOuterPadding: true),
    );
  }
}

/// Developer tooling (debug only): identity helpers, debug actions and a
/// local-notification test — the leftovers that aren't worth a screen of their
/// own, grouped as clean Settings-style lists.
class _DebugTab extends ConsumerWidget {
  const _DebugTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = t.home.features_page;
    final admin = t.settings.admin;
    final groups = t.admin_console.groups;
    final userState = ref.watch(userStateNotifierProvider);

    return _TabScroll(
      children: [
        // ── Identity ────────────────────────────────────────────────────────
        _GroupLabel(groups.identity),
        _groupCard([
          SettingsTile(
            icon: KasyIcons.person,
            title: admin.copy_user_id,
            onTap: () {
              Clipboard.setData(
                ClipboardData(text: userState.user.idOrNull ?? 'no-id (guest)'),
              );
              ref
                  .read(toastProvider)
                  .alert(title: t.common.copied, text: admin.user_id_copied);
            },
          ),
          SettingsTile(
            icon: KasyIcons.notification,
            title: admin.copy_fcm_token,
            onTap: () async {
              if (kIsWeb) {
                ref
                    .read(toastProvider)
                    .alert(
                      title: t.common.native_only_title,
                      text: admin.native_only,
                    );
                return;
              }
              final token = await FirebaseMessaging.instance.getToken();
              if (token == null) {
                ref
                    .read(toastProvider)
                    .alert(
                      title: t.common.unavailable,
                      text: admin.fcm_token_unavailable,
                    );
                return;
              }
              await Clipboard.setData(ClipboardData(text: token));
              ref
                  .read(toastProvider)
                  .alert(title: t.common.copied, text: admin.fcm_token_copied);
            },
          ),
          SettingsTile(
            icon: KasyIcons.notification,
            title: admin.ask_notification,
            onTap: () {
              if (kIsWeb) {
                ref
                    .read(toastProvider)
                    .alert(
                      title: t.common.native_only_title,
                      text: admin.native_only,
                    );
                return;
              }
              ref.read(notificationsSettingsProvider).askPermission();
            },
          ),
        ]),

        const SizedBox(height: KasySpacing.lg),

        // ── Debug actions ───────────────────────────────────────────────────
        _GroupLabel(groups.debug_actions),
        _groupCard([
          SettingsTile(
            icon: KasyIcons.note,
            title: admin.update_bottom_sheet,
            // Preview the sheet over the current screen; dismissing just closes
            // it and returns here, without navigating away.
            onTap: () => showUpdateBottomSheet(
              context: navigatorKey.currentContext!,
              version: '0.0.0',
            ),
          ),
          SettingsTile(
            icon: KasyIcons.download,
            title: admin.preview_update_available,
            // Previews the optional (dismissible) sheet. The forced variant is
            // the same layout, blocking — test it via app_min_version.
            onTap: () => showUpdateAvailableSheet(
              navigatorKey.currentContext!,
              forced: false,
            ),
          ),
          SettingsTile(
            icon: KasyIcons.check,
            title: admin.test_onboarding,
            // Preview mode: walks the onboarding screens with every real side
            // effect suppressed (no guest account, no profile writes, no
            // permission prompts) and returns here when done.
            onTap: () =>
                ref.read(goRouterProvider).go('/onboarding?preview=true'),
          ),
          SettingsTile(
            icon: KasyIcons.star,
            title: admin.ask_review,
            // Has a design (the review dialog), previewable on web too — only
            // the store action no-ops there.
            onTap: () => showReviewDialog(context, ref, force: true),
          ),
          // Native-only + debug: home widgets don't exist on web. Match the
          // ads_demo_panel gate so web debug doesn't surface a useless tile.
          if (kDebugMode && !kIsWeb)
            SettingsTile(
              icon: KasyIcons.message,
              title: admin.home_widgets_panel,
              // Pushed full-screen (its own back button), a drill-down from here.
              onTap: () => context.push(adminRouteHomeWidgets),
            ),
          // Ads demo: native-only (AdMob does not run on web). Shown whenever the
          // ads module is present; the demo only serves test ads.
          if (withAds && !kIsWeb)
            SettingsTile(
              icon: KasyIcons.monitor,
              title: admin.ads_demo_panel,
              onTap: () => context.push(adminRouteAdsDemo),
            ),
        ]),

        const SizedBox(height: KasySpacing.lg),

        // ── Notification test ───────────────────────────────────────────────
        _GroupLabel(groups.notification_test),
        _groupCard([
          SettingsTile(
            icon: KasyIcons.notification,
            title: page.notification_title,
            onTap: () {
              // Local notifications don't fire on web — tell the user instead
              // of doing nothing when tapped.
              if (kIsWeb) {
                ref
                    .read(toastProvider)
                    .alert(
                      title: t.common.native_only_title,
                      text: admin.native_only,
                    );
                return;
              }
              final settings = ref.read(notificationsSettingsProvider);
              final localNotifier = ref.read(localNotifierProvider);
              kasy_kit.Notification.withData(
                id: 'fake-id',
                title: page.notification_demo_title,
                body: page.notification_demo_body,
                createdAt: DateTime.now(),
                notifier: localNotifier,
                notifierSettings: settings,
              ).show();
            },
          ),
        ]),
      ],
    );
  }
}
