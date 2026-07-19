import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/home/home_components_preview_registry.dart';
import 'package:cowboydodartinc/features/settings/ui/components/admin/admin_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Wider centred column for the components catalog and Design System (matches
/// the admin console [_contentMaxWidth]).
const double kComponentsCatalogMaxWidth = 1080;

/// Title for a components-branch drill-down inside the admin shell.
class ComponentsDrillDown {
  final String title;

  const ComponentsDrillDown({required this.title});
}

/// Routes component catalog → design system / previews without leaving the
/// admin shell (sidebar + desktop application bar persist).
class ComponentsNavigation {
  const ComponentsNavigation._();

  static String adminPreviewPath(String componentName) =>
      adminRouteComponentsPreview(componentName);

  static const String adminDesignSystemPath = adminRouteComponentsDesignSystem;

  /// True on `/admin/tools/components` and its drill-downs.
  static bool isInAdminShell(BuildContext context) {
    final String path = GoRouterState.of(context).uri.path;
    return path == adminRouteComponents ||
        path.startsWith('$adminRouteComponents/');
  }

  /// When the admin components section is showing a preview or Design System.
  static ComponentsDrillDown? componentsDrillDown(BuildContext context) {
    if (!isInAdminShell(context)) {
      return null;
    }
    final String path = GoRouterState.of(context).uri.path;
    if (path == adminRouteComponentsDesignSystem) {
      return const ComponentsDrillDown(title: 'Design System');
    }
    const String prefix = '$adminRouteComponents/preview/';
    if (path.startsWith(prefix)) {
      final String raw = path.substring(prefix.length);
      final String name = Uri.decodeComponent(raw);
      final ComponentPreviewDefinition? definition =
          getComponentPreviewDefinition(name);
      return ComponentsDrillDown(title: definition?.title ?? name);
    }
    return null;
  }

  /// Admin component drill-down on tablet/desktop (Design System / preview):
  /// custom layout with "< Componentes" back, aligned with other admin sections.
  /// Phone keeps the shell page app bar instead.
  static bool usesAdminDesktopDrillDownLayout(BuildContext context) {
    return componentsDrillDown(context) != null &&
        MediaQuery.sizeOf(context).width >= DeviceType.medium.breakpoint;
  }

  /// Admin shell already renders the page app bar for a drill-down (phone only).
  /// Tablet/desktop use [usesAdminDesktopDrillDownLayout] for title + back.
  static bool shellProvidesAppBar(BuildContext context) {
    return componentsDrillDown(context) != null &&
        MediaQuery.sizeOf(context).width < DeviceType.medium.breakpoint;
  }

  static void openDesignSystem(BuildContext context) {
    if (isInAdminShell(context)) {
      context.push(adminDesignSystemPath);
      return;
    }
    context.push('/design-system');
  }

  static void openPreview(BuildContext context, String componentName) {
    if (isInAdminShell(context)) {
      context.push(adminPreviewPath(componentName));
      return;
    }
    context.push('/components/${Uri.encodeComponent(componentName)}');
  }

  /// Pops back to the catalog (admin shell child or root `/components`).
  static void popToCatalog(BuildContext context) {
    final GoRouter router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return;
    }
    if (isInAdminShell(context)) {
      context.go(adminRouteComponents);
      return;
    }
    context.go('/components');
  }
}
