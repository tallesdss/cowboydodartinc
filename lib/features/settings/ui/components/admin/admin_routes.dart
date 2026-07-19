import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/premium_page_factory.dart';
import 'package:flutter/material.dart';

/// The four "Ferramentas" sub-screens are real admin SECTIONS: each is its own
/// branch in the console's [StatefulShellRoute] (so the rail persists and it
/// gets the standard header chrome) and is reached from the sidebar's
/// "Ferramentas" submenu, not pushed. These paths are the branch locations —
/// `adminSections()` reads them so the router and the rail can't drift.
///
/// Send push and Paywalls are admin actions (production); Components and Debug
/// are developer-only (their branches register only when [kDebugMode] is true).
const String adminBasePath = '/admin';

/// Kanban section path inside the admin console.
const String adminKanbanPath = '$adminBasePath/kanban';

/// When true (default), debug builds open the admin console on [adminKanbanPath]
/// instead of the Overview. Set to false to mirror release behaviour.
const bool kDebugAdminOpensKanban = true;

const String adminRouteSendPush = '/admin/tools/send-push';
const String adminRoutePaywalls = '/admin/tools/paywalls';
const String adminRouteComponents = '/admin/tools/components';

/// Drill-downs inside the Components admin section (sidebar persists).
const String adminRouteComponentsDesignSystem =
    '$adminRouteComponents/design-system';

String adminRouteComponentsPreview(String componentName) =>
    '$adminRouteComponents/preview/${Uri.encodeComponent(componentName)}';
const String adminRouteDebug = '/admin/tools/debug';

/// Full-screen pushed routes (debug-only), reached from inside the Debug
/// section as drill-downs (they cover the shell and pop back to it).
const String adminRouteHomeWidgets = '/admin/home-widgets';

/// Ads demo (native-only): showcases the four AdMob formats with test ads.
const String adminRouteAdsDemo = '/admin/ads-demo';

String adminRoutePremiumPreview(String variant) => '/admin/premium/$variant';

PaywallFactory? paywallFactoryFromAdminRoute(String? variant) {
  return switch (variant) {
    'solo' || 'minimal' => PaywallFactory.solo,
    'compare' || 'basicRow' => PaywallFactory.unlock,
    'trial' || 'withSwitch' => PaywallFactory.trial,
    'unlock' || 'basic' => PaywallFactory.unlock,
    _ => null,
  };
}

/// Max content width for every admin section body on wide viewports.
const double adminSectionMaxWidth = 1080;

/// Top inset for admin section bodies on phone/tablet (below the section app bar).
///
/// On desktop (≥ [DeviceType.large]) the shell applies [adminDesktopShellTopInset]
/// once below the application bar, so section bodies return 0 here.
double adminSectionTopInset(BuildContext context) {
  if (MediaQuery.sizeOf(context).width >= DeviceType.large.breakpoint) {
    return 0;
  }
  return KasySpacing.pageHorizontalGutter;
}

/// Horizontal and bottom padding shared by every admin section body.
///
/// Gutter sits outside the max-width column (same rhythm as the Components tab).
/// Top on desktop comes from [AdminShell]; on phone/tablet from
/// [adminSectionTopInset].
EdgeInsets adminSectionBodyPadding(BuildContext context) {
  return EdgeInsets.fromLTRB(
    KasySpacing.pageHorizontalGutter,
    adminSectionTopInset(context),
    KasySpacing.pageHorizontalGutter,
    MediaQuery.paddingOf(context).bottom + KasySpacing.xl,
  );
}

/// Whether [AdminShell] should apply the desktop gap below the application bar.
bool adminShellAppliesDesktopTopInset(BuildContext context) {
  return MediaQuery.sizeOf(context).width >= DeviceType.large.breakpoint;
}

/// Desktop inset below the application bar for every admin branch.
///
/// Single value for root tabs and component drill-downs so route transitions
/// do not jump. Matches Settings on desktop ([belowChromeContentGap] + [lg]).
const double adminDesktopShellTopInset =
    KasySpacing.belowChromeContentGap + KasySpacing.lg;
