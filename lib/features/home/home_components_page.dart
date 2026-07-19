import 'package:cowboydodartinc/components/kasy_app_bar.dart';
import 'package:cowboydodartinc/components/kasy_text_field.dart';
import 'package:cowboydodartinc/core/haptics/kasy_haptics.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_hover.dart';
import 'package:cowboydodartinc/core/widgets/kasy_scroll_behavior.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/home/components_navigation.dart';
import 'package:cowboydodartinc/features/home/home_components_preview_registry.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';

/// UI-kit catalog, reachable from the home dashboard.
///
/// Unlike [KasyOverlayScaffold] screens, the frosted bar does not overlay the list:
/// scroll lives **inside** the inset card so the catalog reads as a contained sheet.
class HomeComponentsPage extends StatelessWidget {
  const HomeComponentsPage({super.key});

  static int get sectionCount => _kCatalog.length;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const KasyKitScrollBehavior(),
      child: KasyOverlayScaffold(
        title: t.home.dashboard.components_title,
        onBack: () => ComponentsNavigation.popToCatalog(context),
        maxContentWidth: kComponentsCatalogMaxWidth,
        slivers: const [
          SliverFillRemaining(
            child: HomeComponentsCatalog(omitOuterPadding: true),
          ),
        ],
      ),
    );
  }
}

/// The UI-kit catalog list on its own (no app bar / scaffold), so it can be the
/// body of [HomeComponentsPage] AND a section inside the admin console (which
/// supplies its own chrome). Fills the space it is given.
class HomeComponentsCatalog extends StatefulWidget {
  /// When true, horizontal/top/bottom page gutters are omitted because a parent
  /// ([KasyOverlayScaffold], admin tab padding) already applied them.
  final bool omitOuterPadding;

  const HomeComponentsCatalog({super.key, this.omitOuterPadding = false});

  @override
  State<HomeComponentsCatalog> createState() => _HomeComponentsCatalogState();
}

class _HomeComponentsCatalogState extends State<HomeComponentsCatalog> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Reset the filter the moment we navigate away to a component, so coming
  /// back shows the full catalog instead of the stale search term. Done up
  /// front (not via a navigation-return callback) because go_router's pop
  /// callbacks fire unreliably, which made the reset intermittent.
  void _clearSearch() {
    if (_query.isEmpty && _searchCtrl.text.isEmpty) return;
    _searchCtrl.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final String q = _query.trim().toLowerCase();
    final List<_CatalogRow> rows = q.isEmpty
        ? _kCatalog
        : _kCatalog
            .where((r) => r.name.toLowerCase().contains(q))
            .toList(growable: false);

    // Search position flips by breakpoint: pinned at the BOTTOM on mobile
    // (thumb reach, with the list dissolving into a scrim just above it), kept
    // at the TOP on tablet/desktop where the cursor lives up there.
    final bool isMobile =
        DeviceType.fromWidth(MediaQuery.sizeOf(context).width) ==
        DeviceType.small;

    final EdgeInsets outerPadding = widget.omitOuterPadding
        ? EdgeInsets.zero
        : EdgeInsets.fromLTRB(
            KasySpacing.pageHorizontalGutter,
            KasySpacing.belowChromeContentGap,
            KasySpacing.pageHorizontalGutter,
            MediaQuery.paddingOf(context).bottom +
                KasySpacing.belowChromeContentGap,
          );

    final Widget searchField = _ComponentsSearchField(
      controller: _searchCtrl,
      onChanged: (v) => setState(() => _query = v),
    );

    if (isMobile) {
      // List fills the area above the search bar. Its bottom dissolves into a
      // page-coloured scrim (no card shadow — the scrim is the bottom edge).
      final Widget listArea = rows.isEmpty
          ? const _ComponentsEmptyResults()
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Align(
                  alignment: Alignment.topCenter,
                  child: _catalogSurface(context, rows, withShadow: false),
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(child: _ComponentsBottomScrim()),
                ),
              ],
            );
      return Padding(
        padding: outerPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(child: listArea),
            const SizedBox(height: KasySpacing.smd),
            // Inset the floating search bar so it reads a touch narrower than
            // the list card above it, not edge-to-edge identical.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: KasySpacing.md),
              child: searchField,
            ),
          ],
        ),
      );
    }

    // Tablet / desktop: search on top, card hugs its content right below it.
    return Padding(
      padding: outerPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          searchField,
          const SizedBox(height: KasySpacing.smd),
          if (rows.isEmpty)
            const Expanded(child: _ComponentsEmptyResults())
          else
            Flexible(child: _catalogSurface(context, rows, withShadow: true)),
        ],
      ),
    );
  }

  /// The inset list surface (card) wrapping the catalog [ListView]. Hugs its
  /// content via [ListView.shrinkWrap] and only scrolls once rows outgrow the
  /// space. Rows run full-width (no horizontal padding) so the [KasyHover] fill
  /// reaches the rounded corners — the inset's ClipRRect rounds them; row text
  /// keeps its inset via the row's own internal padding.
  Widget _catalogSurface(
    BuildContext context,
    List<_CatalogRow> rows, {
    required bool withShadow,
  }) {
    return _componentsCatalogInset(
      context,
      withShadow: withShadow,
      child: ScrollConfiguration(
        behavior: const KasyKitScrollBehavior(),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: rows.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 1,
            indent: KasySpacing.md,
            endIndent: KasySpacing.md,
            color: context.colors.outline.withValues(alpha: 0.33),
          ),
          itemBuilder: (context, index) => _catalogRow(context, rows[index]),
        ),
      ),
    );
  }

  Widget _catalogRow(BuildContext context, _CatalogRow row) {
    return KasyHover(
      hapticEnabled: false,
      onTap: () {
        KasyHaptics.selection(context);
        if (row.name == 'Design System') {
          _clearSearch();
          ComponentsNavigation.openDesignSystem(context);
          return;
        }
        // Skip rows without a preview yet (registry returns null); otherwise
        // open /components/:name, which the router resolves back to this
        // component's preview.
        if (getComponentPreviewDefinition(row.name) == null) {
          return;
        }
        _clearSearch();
        ComponentsNavigation.openPreview(context, row.name);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KasySpacing.md,
          vertical: 16,
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      row.name,
                      // Content list row title: 16 / w500 (listRowTitle), the
                      // same as the Settings rows — these are spacious iOS-style
                      // content rows, not a dense nav. Stable across breakpoints.
                      style: context.kasyTextTheme.listRowTitle.copyWith(
                        color: context.colors.onSurface,
                      ),
                    ),
                  ),
                  if (_kReviewComponents.contains(row.name)) ...[
                    const SizedBox(width: KasySpacing.sm),
                    Text(
                      t.home.dashboard.needs_review,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ] else if (!_kReadyComponents.contains(row.name)) ...[
                    const SizedBox(width: KasySpacing.sm),
                    Text(
                      t.home.dashboard.in_production,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (_kUrgentComponents.contains(row.name)) ...[
                    const SizedBox(width: KasySpacing.sm),
                    Text(
                      'Prioridade: Urgente',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              KasyIcons.chevronRight,
              color: context.colors.muted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

/// Search field that filters the catalog by component name. Uses the kit's
/// [KasyTextField] in its default (primary) configuration — exactly the field
/// shown under components/TextField — with the standard search affix icon.
class _ComponentsSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _ComponentsSearchField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return KasyTextField(
      controller: controller,
      onChanged: onChanged,
      hint: t.home.dashboard.search_hint,
      variant: KasyTextFieldVariant.tonal,
      prefix: const Icon(KasyIcons.search),
      textInputAction: TextInputAction.search,
    );
  }
}

/// Shown inside the catalog surface when a search matches nothing.
class _ComponentsEmptyResults extends StatelessWidget {
  const _ComponentsEmptyResults();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KasySpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              KasyIcons.searchEmpty,
              size: 30,
              color: context.colors.muted,
            ),
            const SizedBox(height: KasySpacing.sm),
            Text(
              t.home.dashboard.search_empty,
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogRow {
  final String name;

  const _CatalogRow(this.name);
}

const Set<String> _kReadyComponents = <String>{
  'Accordion',
  'Alert',
  'AppBar',
  'Avatar',
  'Badge',
  'BottomSheet',
  'Button',
  'Card',
  'Checkbox',
  'Chip',
  'CloseButton',
  'DatePicker',
  'Description',
  'Design System',
  'Dialog',
  'DropDown',
  'FieldError',
  'Hover',
  'Label',
  'LinkButton',
  'Menu',
  'NumberField',
  'ProgressBar',
  'ProgressCircle',
  'Radio Group',
  'Separator',
  'Slider',
  'SocialAuthButton',
  'Tabs',
  'Tag',
  'TagGroup',
  'TextArea',
  'TextField',
  'TimePicker',
  'ScrollShadow',
  'Sidebar',
  'Skeleton',
  'Spinner',
  'Status Tag',
  'Surface',
  'SwipeAction',
  'Switch',
  'TextFieldOTP',
  'Toast',
  'ToggleButton',
  'ToggleButtonGroup',
  'Tooltip',
};

const Set<String> _kUrgentComponents = <String>{};

/// Components built in the current session that still need a design-review pass.
/// Surfaced with a distinct "Revisar" badge so they stand out from the catalog
/// at a glance, to be cleared once each has been reviewed.
const Set<String> _kReviewComponents = <String>{
  'Breadcrumbs',
  'Calendar',
  'CloseButton',
  'Kbd',
  'Description',
  'FieldError',
  'Label',
  'LinkButton',
  'NumberField',
  'ProgressBar',
  'ProgressCircle',
  'Radio Group',
  'ScrollShadow',
  'Separator',
  'Slider',
  'SocialAuthButton',
  'Spinner',
  'Surface',
  'Switch',
  'Tag',
  'TagGroup',
  'ToggleButton',
  'ToggleButtonGroup',
  'Tooltip',
};

const List<_CatalogRow> _kCatalog = [
  // Design System — tokens showcase
  _CatalogRow('Design System'),
  // Ready (_kReadyComponents), A–Z
  _CatalogRow('Accordion'),
  _CatalogRow('Alert'),
  _CatalogRow('AppBar'),
  _CatalogRow('Avatar'),
  _CatalogRow('Badge'),
  _CatalogRow('BottomSheet'),
  _CatalogRow('Button'),
  _CatalogRow('Card'),
  _CatalogRow('Checkbox'),
  _CatalogRow('Chip'),
  _CatalogRow('CloseButton'),
  _CatalogRow('DatePicker'),
  _CatalogRow('Description'),
  _CatalogRow('Dialog'),
  _CatalogRow('DropDown'),
  _CatalogRow('FieldError'),
  _CatalogRow('Hover'),
  _CatalogRow('Label'),
  _CatalogRow('LinkButton'),
  _CatalogRow('Menu'),
  _CatalogRow('NumberField'),
  _CatalogRow('ProgressBar'),
  _CatalogRow('ProgressCircle'),
  _CatalogRow('Radio Group'),
  _CatalogRow('ScrollShadow'),
  _CatalogRow('Separator'),
  _CatalogRow('Sidebar'),
  _CatalogRow('Skeleton'),
  _CatalogRow('Slider'),
  _CatalogRow('SocialAuthButton'),
  _CatalogRow('Spinner'),
  _CatalogRow('Status Tag'),
  _CatalogRow('Surface'),
  _CatalogRow('SwipeAction'),
  _CatalogRow('Switch'),
  _CatalogRow('Tabs'),
  _CatalogRow('Tag'),
  _CatalogRow('TagGroup'),
  _CatalogRow('TextArea'),
  _CatalogRow('TextField'),
  _CatalogRow('TimePicker'),
  _CatalogRow('TextFieldOTP'),
  _CatalogRow('Toast'),
  _CatalogRow('ToggleButton'),
  _CatalogRow('ToggleButtonGroup'),
  _CatalogRow('Tooltip'),
  // Demais, A–Z
  _CatalogRow('BarChart'),
  _CatalogRow('Breadcrumbs'),
  _CatalogRow('Calendar'),
  _CatalogRow('ControlField'),
  _CatalogRow('DateField'),
  _CatalogRow('DateRangePicker'),
  _CatalogRow('Kbd'),
  _CatalogRow('TextFieldGroup'),
  _CatalogRow('TextFieldOTPGroup'),
  _CatalogRow('LineChart'),
  _CatalogRow('ListGroup'),
  _CatalogRow('NumberStepper'),
  _CatalogRow('NumberValue'),
  _CatalogRow('Popover'),
  _CatalogRow('PressableFeedback'),
  _CatalogRow('ProgressButton'),
  _CatalogRow('Radio ButtonGroup'),
  _CatalogRow('RangeCalendar'),
  _CatalogRow('Rating'),
  _CatalogRow('SearchFieldSelect'),
  _CatalogRow('SlideButton'),
  _CatalogRow('SplitView'),
  _CatalogRow('Stepper'),
  _CatalogRow('TrendChip'),
  _CatalogRow('Widget'),
];

/// UI-kit catalog only — inset list surface (not a shared app shell).
Widget _componentsCatalogInset(
  BuildContext context, {
  required Widget child,
  bool withShadow = true,
}) {
  const double radius = 20;
  final bool isDark = Theme.of(context).brightness == Brightness.dark;
  return DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: context.colors.outline.withValues(alpha: 0.4)),
      boxShadow: withShadow
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.07),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ]
          : null,
    ),
    child: ClipRRect(borderRadius: BorderRadius.circular(radius), child: child),
  );
}

/// Mobile-only scrim sitting at the bottom of the list area, just above the
/// search bar: the page background melts up over the catalog so rows dissolve
/// into it before they reach the search field. Based on the app bar's top scrim
/// (flipped to fade upward) but with a longer, gentler tail near the top so the
/// gradient eases into transparency instead of cutting off. Sits *over* the
/// content via a [Stack] so things pass under it.
class _ComponentsBottomScrim extends StatelessWidget {
  const _ComponentsBottomScrim();

  /// Dissolve height — tall enough to melt the last couple of rows. Sits above
  /// the search bar, so it needs no safe-area strip of its own.
  static const double _height = 48.0;

  @override
  Widget build(BuildContext context) {
    final Color base = context.colors.background;
    return SizedBox(
      height: _height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: <Color>[
              base.withValues(alpha: 0.96),
              base.withValues(alpha: 0.96),
              base.withValues(alpha: 0.55),
              base.withValues(alpha: 0.18),
              base.withValues(alpha: 0.0),
            ],
            stops: const <double>[0.0, 0.16, 0.46, 0.74, 1.0],
          ),
        ),
      ),
    );
  }
}
