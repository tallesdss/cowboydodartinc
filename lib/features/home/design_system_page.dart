import 'dart:ui' show ImageFilter;

import 'package:cowboydodartinc/components/kasy_app_bar.dart';
import 'package:cowboydodartinc/components/kasy_tabs.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/theme/type_scale.dart';
import 'package:cowboydodartinc/core/widgets/kasy_scroll_behavior.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/home/admin_components_layout.dart';
import 'package:cowboydodartinc/features/home/components_navigation.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DesignSystemPage extends StatelessWidget {
  const DesignSystemPage({super.key});

  static const List<Widget> _sections = [
    _SectionHeader('Colors'),
    SizedBox(height: KasySpacing.md),
    _ColorsSection(),
    SizedBox(height: KasySpacing.xl),
    _SectionHeader('Typography'),
    SizedBox(height: KasySpacing.md),
    _TypographySection(),
    SizedBox(height: KasySpacing.xl),
    _SectionHeader('Effect Styles'),
    SizedBox(height: KasySpacing.md),
    _EffectsSection(),
    SizedBox(height: KasySpacing.xl),
    _SectionHeader('Radius'),
    SizedBox(height: KasySpacing.md),
    _RadiusSection(),
    SizedBox(height: KasySpacing.xl),
    _SectionHeader('Spacing'),
    SizedBox(height: KasySpacing.md),
    _SpacingSection(),
    SizedBox(height: KasySpacing.xl),
    _SectionHeader('Icon Sizes'),
    SizedBox(height: KasySpacing.md),
    _IconSizesSection(),
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> slivers = [
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(bottom: KasySpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _sections,
          ),
        ),
      ),
    ];

    if (ComponentsNavigation.usesAdminDesktopDrillDownLayout(context)) {
      return AdminComponentsDrillDownLayout(
        title: 'Design System',
        backLabel: t.home.components_preview.nav_title,
        onBack: () => ComponentsNavigation.popToCatalog(context),
        body: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _sections,
        ),
      );
    }

    if (ComponentsNavigation.shellProvidesAppBar(context)) {
      return ScrollConfiguration(
        behavior: const KasyKitScrollBehavior(),
        child: CustomScrollView(
          slivers: kasyOverlayPaddedSlivers(
            context,
            maxContentWidth: kComponentsCatalogMaxWidth,
            omitAppBarOverlap: true,
            slivers: slivers,
          ),
        ),
      );
    }

    return ScrollConfiguration(
      behavior: const KasyKitScrollBehavior(),
      child: KasyOverlayScaffold(
        title: 'Design System',
        backLabel: t.home.components_preview.nav_title,
        onBack: () => ComponentsNavigation.popToCatalog(context),
        maxContentWidth: kComponentsCatalogMaxWidth,
        slivers: slivers,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.textTheme.labelLarge?.copyWith(
        color: context.colors.muted,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Divider between token rows
// ---------------------------------------------------------------------------

class _TokenDivider extends StatelessWidget {
  const _TokenDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: context.colors.outline.withValues(alpha: 0.28),
    );
  }
}

// ---------------------------------------------------------------------------
// Colors
// ---------------------------------------------------------------------------

/// Accessor that reads one token from a [KasyColors] theme (light or dark).
typedef _Pick = Color Function(KasyColors c);

class _Variant {
  final String name;
  final _Pick pick;

  /// Force a hairline border on the swatch (for near-surface / transparent tones).
  final bool border;
  const _Variant(this.name, this.pick, {this.border = false});
}

class _ColorsSection extends StatelessWidget {
  const _ColorsSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ColorsIntro(),
        SizedBox(height: KasySpacing.lg),

        // --- Semantic roles (solid + soft preview) ---
        _SemanticCategory(
          name: 'Primary',
          description:
              'The primary brand CTA fill. Used for key actions and focus. '
              'Light `#0553B1`, dark `#2563EB` (Figma `brand/primary/base`).',
          base: _pickPrimary,
          onColor: _pickPrimaryForeground,
          soft: _pickPrimarySoft,
          softForeground: _pickPrimarySoftForeground,
          variants: [
            _Variant('primary', _pickPrimary),
            _Variant('primary-hover', _pickPrimaryHover),
            _Variant('primary-foreground', _pickPrimaryForeground,
                border: true),
            _Variant('primary-soft', _pickPrimarySoft, border: true),
            _Variant('primary-soft-hover', _pickPrimarySoftHover,
                border: true),
            _Variant('primary-soft-foreground', _pickPrimarySoftForeground),
          ],
        ),
        SizedBox(height: KasySpacing.xl),
        _SemanticCategory(
          name: 'Default',
          description:
              'The neutral backbone of the system. Used for most '
              'non-emphasized UI elements.',
          base: _pickNeutral,
          onColor: _pickNeutralForeground,
          variants: [
            _Variant('default', _pickNeutral, border: true),
            _Variant('default-hover', _pickNeutralHover, border: true),
            _Variant('default-foreground', _pickNeutralForeground),
          ],
        ),
        SizedBox(height: KasySpacing.xl),
        _SemanticCategory(
          name: 'Success',
          description:
              'Communicates positive outcomes, confirmations and completed '
              'states.',
          base: _pickSuccess,
          onColor: _pickSuccessForeground,
          soft: _pickSuccessSoft,
          softForeground: _pickSuccessSoftForeground,
          variants: [
            _Variant('success', _pickSuccess),
            _Variant('success-hover', _pickSuccessHover),
            _Variant('success-foreground', _pickSuccessForeground, border: true),
            _Variant('success-soft', _pickSuccessSoft, border: true),
            _Variant('success-soft-hover', _pickSuccessSoftHover, border: true),
            _Variant('success-soft-foreground', _pickSuccessSoftForeground),
          ],
        ),
        SizedBox(height: KasySpacing.xl),
        _SemanticCategory(
          name: 'Warning',
          description:
              'Indicates caution or risk that requires attention but is not '
              'destructive.',
          base: _pickWarning,
          onColor: _pickWarningForeground,
          soft: _pickWarningSoft,
          softForeground: _pickWarningSoftForeground,
          variants: [
            _Variant('warning', _pickWarning),
            _Variant('warning-hover', _pickWarningHover),
            _Variant('warning-foreground', _pickWarningForeground, border: true),
            _Variant('warning-soft', _pickWarningSoft, border: true),
            _Variant('warning-soft-hover', _pickWarningSoftHover, border: true),
            _Variant('warning-soft-foreground', _pickWarningSoftForeground),
          ],
        ),
        SizedBox(height: KasySpacing.xl),
        _SemanticCategory(
          name: 'Danger',
          description:
              'Represents destructive, irreversible or critical actions and '
              'states.',
          base: _pickDanger,
          onColor: _pickDangerForeground,
          soft: _pickDangerSoft,
          softForeground: _pickDangerSoftForeground,
          variants: [
            _Variant('danger', _pickDanger),
            _Variant('danger-hover', _pickDangerHover),
            _Variant('danger-foreground', _pickDangerForeground, border: true),
            _Variant('danger-soft', _pickDangerSoft, border: true),
            _Variant('danger-soft-hover', _pickDangerSoftHover, border: true),
            _Variant('danger-soft-foreground', _pickDangerSoftForeground),
          ],
        ),
        SizedBox(height: KasySpacing.xl),
        _SemanticCategory(
          name: 'Info',
          description:
              'Neutral informational cues (tips, helper callouts) that are not '
              'success, warning or danger.',
          base: _pickInfo,
          onColor: _pickInfoForeground,
          soft: _pickInfoSoft,
          softForeground: _pickInfoSoftForeground,
          variants: [
            _Variant('info', _pickInfo),
            _Variant('info-hover', _pickInfoHover),
            _Variant('info-foreground', _pickInfoForeground, border: true),
            _Variant('info-soft', _pickInfoSoft, border: true),
            _Variant('info-soft-hover', _pickInfoSoftHover, border: true),
            _Variant('info-soft-foreground', _pickInfoSoftForeground),
          ],
        ),
        SizedBox(height: KasySpacing.xl),

        // --- Neutral swatch roles ---
        _SwatchCategory(
          name: 'Foreground',
          description:
              'Primary content such as text and icons. Adapts automatically to '
              'background and surface contexts.',
          variants: [
            _Variant('foreground', _pickForeground),
            _Variant('muted', _pickForegroundMuted),
            _Variant('tertiary', _pickForegroundTertiary),
            _Variant('segment', _pickForegroundSegment),
            _Variant('overlay', _pickForegroundOverlay),
            _Variant('link', _pickForegroundLink),
            _Variant('inverse', _pickForegroundInverse, border: true),
          ],
        ),
        SizedBox(height: KasySpacing.xl),
        _SwatchCategory(
          name: 'Background',
          description:
              'The base canvas of the interface. Establishes overall contrast '
              'and mood while staying visually quiet.',
          variants: [
            _Variant('background', _pickBackground, border: true),
            _Variant('background-secondary', _pickBackgroundSecondary, border: true),
            _Variant('background-tertiary', _pickBackgroundTertiary, border: true),
            _Variant('background-inverse', _pickBackgroundInverse),
          ],
        ),
        SizedBox(height: KasySpacing.xl),
        _SwatchCategory(
          name: 'Surface',
          description:
              'Containers such as cards, panels, modals and dropdowns. Create '
              'separation through elevation and layering.',
          variants: [
            _Variant('surface', _pickSurface, border: true),
            _Variant('surface-secondary', _pickSurfaceSecondary, border: true),
            _Variant('surface-tertiary', _pickSurfaceTertiary, border: true),
            _Variant('surface-elevated', _pickSurfaceElevated, border: true),
            _Variant('surface-transparent', _pickSurfaceTransparent, border: true),
          ],
        ),
        SizedBox(height: KasySpacing.xl),
        _SwatchCategory(
          name: 'Form field',
          description:
              'Specialized tokens for inputs and controls, accounting for '
              'default, hover and focus states.',
          variants: [
            _Variant('field-background', _pickFieldBackground, border: true),
            _Variant('field-background-hover', _pickFieldBackgroundHover, border: true),
            _Variant('field-background-focus', _pickFieldBackgroundFocus, border: true),
            _Variant('field-placeholder', _pickFieldPlaceholder),
            _Variant('field-foreground', _pickFieldForeground),
            _Variant('field-border', _pickFieldBorder, border: true),
            _Variant('field-border-hover', _pickFieldBorderHover, border: true),
          ],
        ),
        SizedBox(height: KasySpacing.xl),
        _SwatchCategory(
          name: 'Separator',
          description:
              'Dividers, outlines and subtle boundaries. Low contrast and '
              'unobtrusive by design.',
          variants: [
            _Variant('separator', _pickSeparator, border: true),
            _Variant('separator-secondary', _pickSeparatorSecondary, border: true),
            _Variant('separator-tertiary', _pickSeparatorTertiary, border: true),
          ],
        ),
        SizedBox(height: KasySpacing.xl),
        _SwatchCategory(
          name: 'Other',
          description:
              'Shared utility tokens used for borders, overlays, segmented '
              'controls and backdrops. Chrome borders mirror Figma '
              '`border/soft` (overlay panels), `border/elevated`, '
              '`border/field`, `border/field-flat`, `border/subtle`, '
              '`border/strong`.',
          variants: [
            _Variant('border', _pickBorder, border: true),
            _Variant('border-soft', _pickBorderSoft, border: true),
            _Variant('border-elevated', _pickBorderElevated, border: true),
            _Variant('border-field', _pickBorderField, border: true),
            _Variant('border-field-flat', _pickBorderFieldFlat, border: true),
            _Variant('border-subtle', _pickBorderSubtle, border: true),
            _Variant('border-strong', _pickBorderStrong, border: true),
            _Variant('overlay', _pickOverlay, border: true),
            _Variant('segment', _pickSegment, border: true),
            _Variant('backdrop', _pickBackdrop, border: true),
          ],
        ),
      ],
    );
  }
}

// --- Token accessors (kept top-level so the section tree stays const) ---
Color _pickPrimary(KasyColors c) => c.primary;
Color _pickPrimaryHover(KasyColors c) => c.primaryHover;
Color _pickPrimaryForeground(KasyColors c) => c.primaryForeground;
Color _pickPrimarySoft(KasyColors c) => c.primarySoft;
Color _pickPrimarySoftHover(KasyColors c) => c.primarySoftHover;
Color _pickPrimarySoftForeground(KasyColors c) => c.primarySoftForeground;
Color _pickNeutral(KasyColors c) => c.neutral;
Color _pickNeutralHover(KasyColors c) => c.neutralHover;
Color _pickNeutralForeground(KasyColors c) => c.neutralForeground;
Color _pickSuccess(KasyColors c) => c.success;
Color _pickSuccessHover(KasyColors c) => c.successHover;
Color _pickSuccessForeground(KasyColors c) => c.successForeground;
Color _pickSuccessSoft(KasyColors c) => c.successSoft;
Color _pickSuccessSoftHover(KasyColors c) => c.successSoftHover;
Color _pickSuccessSoftForeground(KasyColors c) => c.successSoftForeground;
Color _pickWarning(KasyColors c) => c.warning;
Color _pickWarningHover(KasyColors c) => c.warningHover;
Color _pickWarningForeground(KasyColors c) => c.warningForeground;
Color _pickWarningSoft(KasyColors c) => c.warningSoft;
Color _pickWarningSoftHover(KasyColors c) => c.warningSoftHover;
Color _pickWarningSoftForeground(KasyColors c) => c.warningSoftForeground;
Color _pickDanger(KasyColors c) => c.danger;
Color _pickDangerHover(KasyColors c) => c.dangerHover;
Color _pickDangerForeground(KasyColors c) => c.dangerForeground;
Color _pickDangerSoft(KasyColors c) => c.dangerSoft;
Color _pickDangerSoftHover(KasyColors c) => c.dangerSoftHover;
Color _pickDangerSoftForeground(KasyColors c) => c.dangerSoftForeground;
Color _pickInfo(KasyColors c) => c.info;
Color _pickInfoHover(KasyColors c) => c.infoHover;
Color _pickInfoForeground(KasyColors c) => c.infoForeground;
Color _pickInfoSoft(KasyColors c) => c.infoSoft;
Color _pickInfoSoftHover(KasyColors c) => c.infoSoftHover;
Color _pickInfoSoftForeground(KasyColors c) => c.infoSoftForeground;
Color _pickForeground(KasyColors c) => c.foreground;
Color _pickForegroundMuted(KasyColors c) => c.foregroundMuted;
Color _pickForegroundTertiary(KasyColors c) => c.foregroundTertiary;
Color _pickForegroundSegment(KasyColors c) => c.foregroundSegment;
Color _pickForegroundOverlay(KasyColors c) => c.foregroundOverlay;
Color _pickForegroundLink(KasyColors c) => c.foregroundLink;
Color _pickForegroundInverse(KasyColors c) => c.foregroundInverse;
Color _pickBackground(KasyColors c) => c.background;
Color _pickBackgroundSecondary(KasyColors c) => c.backgroundSecondary;
Color _pickBackgroundTertiary(KasyColors c) => c.backgroundTertiary;
Color _pickBackgroundInverse(KasyColors c) => c.backgroundInverse;
Color _pickSurface(KasyColors c) => c.surface;
Color _pickSurfaceSecondary(KasyColors c) => c.surfaceSecondary;
Color _pickSurfaceTertiary(KasyColors c) => c.surfaceTertiary;
Color _pickSurfaceElevated(KasyColors c) => c.surfaceElevated;
Color _pickSurfaceTransparent(KasyColors c) => c.surfaceTransparent;
Color _pickFieldBackground(KasyColors c) => c.fieldBackground;
Color _pickFieldBackgroundHover(KasyColors c) => c.fieldBackgroundHover;
Color _pickFieldBackgroundFocus(KasyColors c) => c.fieldBackgroundFocus;
Color _pickFieldPlaceholder(KasyColors c) => c.fieldPlaceholder;
Color _pickFieldForeground(KasyColors c) => c.fieldForeground;
Color _pickFieldBorder(KasyColors c) => c.fieldBorder;
Color _pickFieldBorderHover(KasyColors c) => c.fieldBorderHover;
Color _pickSeparator(KasyColors c) => c.separator;
Color _pickSeparatorSecondary(KasyColors c) => c.separatorSecondary;
Color _pickSeparatorTertiary(KasyColors c) => c.separatorTertiary;
Color _pickBorder(KasyColors c) => c.border;
Color _pickBorderSoft(KasyColors c) => c.borderSoft;
Color _pickBorderElevated(KasyColors c) => c.borderElevated;
Color _pickBorderField(KasyColors c) => c.borderField;
Color _pickBorderFieldFlat(KasyColors c) => c.borderFieldFlat;
Color _pickBorderSubtle(KasyColors c) => c.borderSubtle;
Color _pickBorderStrong(KasyColors c) => c.borderStrong;
Color _pickOverlay(KasyColors c) => c.overlay;
Color _pickSegment(KasyColors c) => c.segment;
Color _pickBackdrop(KasyColors c) => c.backdrop;

String _hexOf(Color color) {
  final int v = color.toARGB32();
  final int a = (v >> 24) & 0xFF;
  final int r = (v >> 16) & 0xFF;
  final int g = (v >> 8) & 0xFF;
  final int b = v & 0xFF;
  String two(int x) => x.toRadixString(16).padLeft(2, '0').toUpperCase();
  final String rgb = '${two(r)}${two(g)}${two(b)}';
  return a == 0xFF ? '#$rgb' : '#$rgb${two(a)}';
}

// ---------------------------------------------------------------------------
// Colors — intro
// ---------------------------------------------------------------------------

class _ColorsIntro extends StatelessWidget {
  const _ColorsIntro();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Built around semantic intent, not raw palettes. A small set of color '
      'roles covers most interface needs. Each role resolves for the active '
      'theme (toggle light/dark in Settings to compare both).',
      style: context.textTheme.bodyMedium?.copyWith(
        color: context.colors.muted,
        height: 1.5,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category heading (name + description)
// ---------------------------------------------------------------------------

class _CategoryHeading extends StatelessWidget {
  final String name;
  final String description;
  const _CategoryHeading({required this.name, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: KasySpacing.xs),
        Text(
          description,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.muted,
            height: 1.45,
          ),
        ),
        const SizedBox(height: KasySpacing.smd),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Semantic category: heading + Light/Dark solid+soft preview + variant list
// ---------------------------------------------------------------------------

class _SemanticCategory extends StatelessWidget {
  final String name;
  final String description;
  final _Pick base;
  final _Pick onColor;
  final _Pick? soft;
  final _Pick? softForeground;
  final List<_Variant> variants;

  const _SemanticCategory({
    required this.name,
    required this.description,
    required this.base,
    required this.onColor,
    required this.variants,
    this.soft,
    this.softForeground,
  });

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CategoryHeading(name: name, description: description),
        Row(
          children: [
            Expanded(child: _PreviewPill(bg: base(c), fg: onColor(c), text: 'Solid')),
            if (soft != null && softForeground != null) ...[
              const SizedBox(width: KasySpacing.sm),
              Expanded(child: _PreviewPill(bg: soft!(c), fg: softForeground!(c), text: 'Soft')),
            ],
          ],
        ),
        const SizedBox(height: KasySpacing.smd),
        _VariantList(variants: variants),
      ],
    );
  }
}

class _PreviewPill extends StatelessWidget {
  final Color bg;
  final Color fg;
  final String text;
  const _PreviewPill({required this.bg, required this.fg, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(KasyRadius.sm),
      ),
      child: Text(
        text,
        style: context.textTheme.labelMedium?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Swatch category: heading + variant list (Light/Dark chips)
// ---------------------------------------------------------------------------

class _SwatchCategory extends StatelessWidget {
  final String name;
  final String description;
  final List<_Variant> variants;

  const _SwatchCategory({
    required this.name,
    required this.description,
    required this.variants,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CategoryHeading(name: name, description: description),
        _VariantList(variants: variants),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Variant list (one row per token: Light chip, Dark chip, name, hex pair)
// ---------------------------------------------------------------------------

class _VariantList extends StatelessWidget {
  final List<_Variant> variants;
  const _VariantList({required this.variants});

  @override
  Widget build(BuildContext context) {
    return _TokenCard(
      children: [
        for (int i = 0; i < variants.length; i++) ...[
          _VariantRow(variant: variants[i]),
          if (i < variants.length - 1) const _TokenDivider(),
        ],
      ],
    );
  }
}

class _VariantRow extends StatelessWidget {
  final _Variant variant;
  const _VariantRow({required this.variant});

  @override
  Widget build(BuildContext context) {
    // Single swatch resolved against the CURRENT theme. The Design System app
    // bar already toggles light/dark, so each row shows the token in the active
    // theme instead of doubling it up with a light + dark chip on a surface.
    final Color color = variant.pick(context.colors);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.md,
        vertical: 10,
      ),
      child: Row(
        children: [
          _Swatch(color: color, border: variant.border),
          const SizedBox(width: KasySpacing.smd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  variant.name,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _hexOf(color),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.muted,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;

  /// Force a stronger hairline (near-surface / transparent tones); a subtle
  /// hairline is always drawn so every swatch reads cleanly against the card.
  final bool border;
  const _Swatch({required this.color, this.border = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(KasyRadius.xs),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: border ? 0.5 : 0.28),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Typography
// ---------------------------------------------------------------------------

/// One breakpoint shown by the typography preview: its label, the [DeviceType]
/// it maps to, and a short range caption.
class _Breakpoint {
  final String label;
  final DeviceType device;
  final String range;
  const _Breakpoint(this.label, this.device, this.range);
}

const List<_Breakpoint> _breakpoints = [
  _Breakpoint('Mobile', DeviceType.small, '< 768px'),
  _Breakpoint('Tablet', DeviceType.medium, '768 - 1024px'),
  _Breakpoint('Desktop', DeviceType.large, '>= 1024px'),
];

class _TypographySection extends StatefulWidget {
  const _TypographySection();

  @override
  State<_TypographySection> createState() => _TypographySectionState();
}

class _TypographySectionState extends State<_TypographySection> {
  /// Selected breakpoint tab. Null until the first build, where it defaults to
  /// the device currently viewing the screen; a tap pins it from then on.
  int? _index;

  static const List<_TypeRole> _roles = [
    _TypeRole('Display Large', KasyTypeScale.displayLarge, FontWeight.w800, 'ExtraBold', display: true),
    _TypeRole('Display Medium', KasyTypeScale.displayMedium, FontWeight.w800, 'ExtraBold', display: true),
    _TypeRole('Heading 1', KasyTypeScale.heading1, FontWeight.w800, 'ExtraBold', display: true),
    _TypeRole('Heading 2', KasyTypeScale.heading2, FontWeight.w700, 'Bold', display: true),
    _TypeRole('Heading 3', KasyTypeScale.heading3, FontWeight.w600, 'SemiBold'),
    _TypeRole('Heading 4', KasyTypeScale.heading4, FontWeight.w600, 'SemiBold'),
    _TypeRole('Subtitle', KasyTypeScale.subtitle, FontWeight.w400, 'Regular'),
    _TypeRole('Body base', KasyTypeScale.bodyBase, FontWeight.w400, 'Regular'),
    _TypeRole('Body base medium', KasyTypeScale.bodyBase, FontWeight.w500, 'Medium'),
    _TypeRole('Body sm', KasyTypeScale.bodySm, FontWeight.w400, 'Regular'),
    _TypeRole('Body sm medium', KasyTypeScale.bodySm, FontWeight.w500, 'Medium'),
    _TypeRole('Body xs', KasyTypeScale.bodyXs, FontWeight.w400, 'Regular'),
    _TypeRole('Body xs medium', KasyTypeScale.bodyXs, FontWeight.w500, 'Medium'),
    _TypeRole('Link base', KasyTypeScale.bodyBase, FontWeight.w500, 'Medium · Underlined', underline: true),
    _TypeRole('Link sm', KasyTypeScale.bodySm, FontWeight.w500, 'Medium · Underlined', underline: true),
    _TypeRole('Text field base', KasyTypeScale.bodyBase, FontWeight.w400, 'Regular'),
    _TypeRole('Text field sm', KasyTypeScale.bodySm, FontWeight.w400, 'Regular'),
    _TypeRole('Button base', KasyTypeScale.bodyBase, FontWeight.w500, 'Medium'),
    _TypeRole('Button sm', KasyTypeScale.bodySm, FontWeight.w500, 'Medium'),
  ];

  int _defaultIndexFor(double width) => switch (DeviceType.fromWidth(width)) {
        DeviceType.small => 0,
        DeviceType.medium => 1,
        DeviceType.large || DeviceType.xlarge => 2,
      };

  @override
  Widget build(BuildContext context) {
    final Color fg = context.colors.onSurface;
    final double width = MediaQuery.sizeOf(context).width;
    final int index = _index ?? _defaultIndexFor(width);
    final _Breakpoint bp = _breakpoints[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Poppins (single family). Display / Heading 1–2 use tracking '
          '-2.2% / -1%; body roles stay at 0. Each role has an explicit size and '
          'line height per breakpoint: headings step down from desktop to mobile, '
          'while body and labels stay constant for stable reading.',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.muted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: KasySpacing.md),
        KasyTabs(
          tabs: [for (final b in _breakpoints) b.label],
          selectedIndex: index,
          mode: KasyTabsMode.fill,
          onTabSelected: (i) => setState(() => _index = i),
        ),
        const SizedBox(height: KasySpacing.sm),
        Text(
          '${bp.label} · ${bp.range}',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.muted,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: KasySpacing.md),
        _TokenCard(
          children: [
            for (int i = 0; i < _roles.length; i++) ...[
              _TypeRow(role: _roles[i], foreground: fg, device: bp.device),
              if (i < _roles.length - 1) const _TokenDivider(),
            ],
          ],
        ),
      ],
    );
  }
}

/// Formats a size: integers stay integer (16), fractions show one decimal (17.0).
String _fmt(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

class _TypeRole {
  final String name;
  final RampSize ramp;
  final FontWeight weight;

  /// Human-readable weight (and decoration) description for the spec line.
  final String label;
  final bool underline;

  /// True for display roles that use negative tracking (Heading 1–2, Display).
  final bool display;
  const _TypeRole(
    this.name,
    this.ramp,
    this.weight,
    this.label, {
    this.underline = false,
    this.display = false,
  });
}

class _TypeRow extends StatelessWidget {
  final _TypeRole role;
  final Color foreground;

  /// The breakpoint whose size this row previews.
  final DeviceType device;

  const _TypeRow({
    required this.role,
    required this.foreground,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    final double size = role.ramp.size(device);
    final double line = role.ramp.lineHeight(device);
    const String family = 'Poppins';
    // Default ink per role, matching Figma Tokens · Typography samples.
    final Color ink = switch (role.name) {
      'Subtitle' ||
      'Body sm' ||
      'Body xs' ||
      'Body xs medium' =>
        context.colors.muted,
      'Link base' || 'Link sm' => context.colors.foregroundLink,
      'Text field base' || 'Text field sm' => context.colors.fieldForeground,
      _ => foreground,
    };
    final TextStyle sample = GoogleFonts.poppins(
      fontSize: size,
      fontWeight: role.weight,
      height: line / size,
      letterSpacing: role.display
          ? (role.name.startsWith('Display') ? size * -0.022 : size * -0.01)
          : 0,
      color: ink,
      decoration: role.underline ? TextDecoration.underline : null,
      decorationColor: ink,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.md,
        vertical: KasySpacing.smd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role.name,
            style: sample,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '$family · ${role.label} · ${_fmt(size)}/${_fmt(line)}',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.muted,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Spacing
// ---------------------------------------------------------------------------

class _SpacingSection extends StatelessWidget {
  const _SpacingSection();

  /// Single spacing ruler (0–160), mirrors Figma collection 02. Named aliases
  /// (xs…xxxl) appear as labels on the steps they share; extra steps (0, 40,
  /// 56, …) have no alias.
  static const List<({String name, double value})> _rulerTokens = [
    (name: '0', value: KasySpacing.space0),
    (name: 'xs · 4', value: KasySpacing.xs),
    (name: 'sm · 8', value: KasySpacing.sm),
    (name: 'smd · 12', value: KasySpacing.smd),
    (name: 'md · 16', value: KasySpacing.md),
    (name: 'lg · 24', value: KasySpacing.lg),
    (name: 'xl · 32', value: KasySpacing.xl),
    (name: '40', value: KasySpacing.space40),
    (name: 'xxl · 48', value: KasySpacing.xxl),
    (name: '56', value: KasySpacing.space56),
    (name: 'xxxl · 64', value: KasySpacing.xxxl),
    (name: '80', value: KasySpacing.space80),
    (name: '96', value: KasySpacing.space96),
    (name: '128', value: KasySpacing.space128),
    (name: '160', value: KasySpacing.space160),
  ];

  static const List<({String name, String figma, double value})> _layoutTokens = [
    (
      name: 'pageHorizontalGutter',
      figma: 'spacing/page-x',
      value: KasySpacing.pageHorizontalGutter,
    ),
    (
      name: 'pageVerticalGutter',
      figma: 'spacing/page-y',
      value: KasySpacing.pageVerticalGutter,
    ),
    (
      name: 'chromeGap',
      figma: 'spacing/chrome-gap',
      value: KasySpacing.chromeGap,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'From lib/core/theme/spacing.dart (KasySpacing). One ruler (0–160) '
          'mirrors Figma collection 02; named aliases (xs…xxxl) label the '
          'steps used in layout. Page gutters and chrome gap are separate '
          'layout contracts.',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.muted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: KasySpacing.lg),
        const _SpacingSubheading('Scale (0–160)'),
        const SizedBox(height: KasySpacing.smd),
        const _SpacingTokenCard(
          tokens: _rulerTokens,
          maxBarValue: KasySpacing.space160,
        ),
        const SizedBox(height: KasySpacing.xl),
        const _SpacingSubheading('Layout'),
        const SizedBox(height: KasySpacing.smd),
        const _LayoutSpacingCard(tokens: _layoutTokens),
      ],
    );
  }
}

class _SpacingSubheading extends StatelessWidget {
  final String label;
  const _SpacingSubheading(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: context.kasyTextTheme.sectionTitle.copyWith(
        color: context.colors.onSurface,
      ),
    );
  }
}

class _SpacingTokenCard extends StatelessWidget {
  final List<({String name, double value})> tokens;
  final double maxBarValue;

  const _SpacingTokenCard({
    required this.tokens,
    this.maxBarValue = KasySpacing.xxxl,
  });

  @override
  Widget build(BuildContext context) {
    return _TokenCard(
      children: List.generate(tokens.length, (i) {
        final t = tokens[i];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SpacingRow(name: t.name, value: t.value, maxBarValue: maxBarValue),
            if (i < tokens.length - 1) const _TokenDivider(),
          ],
        );
      }),
    );
  }
}

class _LayoutSpacingCard extends StatelessWidget {
  final List<({String name, String figma, double value})> tokens;
  const _LayoutSpacingCard({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return _TokenCard(
      children: List.generate(tokens.length, (i) {
        final t = tokens[i];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: KasySpacing.md,
                vertical: 10,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.name,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.figma,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${t.value.toInt()}px',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.muted,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            if (i < tokens.length - 1) const _TokenDivider(),
          ],
        );
      }),
    );
  }
}

class _SpacingRow extends StatelessWidget {
  final String name;
  final double value;
  final double maxBarValue;
  const _SpacingRow({
    required this.name,
    required this.value,
    this.maxBarValue = KasySpacing.xxxl,
  });

  @override
  Widget build(BuildContext context) {
    const double maxBarWidth = 160;
    final double barWidth = maxBarValue == 0
        ? 0
        : (value / maxBarValue) * maxBarWidth;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.md,
        vertical: 10,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              name,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurface,
              ),
            ),
          ),
          const SizedBox(width: KasySpacing.md),
          Container(
            width: barWidth,
            height: 10,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(KasyRadius.xs),
            ),
          ),
          const SizedBox(width: KasySpacing.smd),
          Text(
            '${value.toInt()}px',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.muted,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Radius
// ---------------------------------------------------------------------------

class _RadiusSection extends StatelessWidget {
  const _RadiusSection();

  static const List<({String name, double value, String alias})> _semanticTokens = [
    (name: 'xs', value: KasyRadius.xs, alias: '→ rounded-sm (4)'),
    (name: 'sm', value: KasyRadius.sm, alias: '→ rounded-lg (8)'),
    (name: 'md', value: KasyRadius.md, alias: '→ rounded-xl (12)'),
    (name: 'lg', value: KasyRadius.lg, alias: '→ rounded-2xl (16)'),
    (name: 'xl', value: KasyRadius.xl, alias: '→ rounded-3xl (24)'),
    (name: 'full', value: KasyRadius.full, alias: '999 (≠ rounded-full 9999)'),
  ];

  static const List<({String name, double value})> _roundedTokens = [
    (name: 'rounded-none', value: KasyRadius.roundedNone),
    (name: 'rounded-xs', value: KasyRadius.roundedXs),
    (name: 'rounded-sm', value: KasyRadius.roundedSm),
    (name: 'rounded-md', value: KasyRadius.roundedMd),
    (name: 'rounded-lg', value: KasyRadius.roundedLg),
    (name: 'rounded-xl', value: KasyRadius.roundedXl),
    (name: 'rounded-2xl', value: KasyRadius.rounded2xl),
    (name: 'rounded-2.5xl', value: KasyRadius.rounded2_5xl),
    (name: 'rounded-3xl', value: KasyRadius.rounded3xl),
    (name: 'rounded-4xl', value: KasyRadius.rounded4xl),
    (name: 'rounded-full', value: KasyRadius.roundedFull),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'From lib/core/theme/radius.dart (KasyRadius). Semantic aliases '
          '(xs–full) map into the HeroUI rounded-* scale. KasyCard defaults '
          'to xl (24).',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.muted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: KasySpacing.lg),
        const _SpacingSubheading('Semantic aliases'),
        const SizedBox(height: KasySpacing.smd),
        _TokenCard(
          children: List.generate(_semanticTokens.length, (i) {
            final t = _semanticTokens[i];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _RadiusRow(name: t.name, value: t.value, alias: t.alias),
                if (i < _semanticTokens.length - 1) const _TokenDivider(),
              ],
            );
          }),
        ),
        const SizedBox(height: KasySpacing.xl),
        const _SpacingSubheading('Rounded scale'),
        const SizedBox(height: KasySpacing.smd),
        _TokenCard(
          children: List.generate(_roundedTokens.length, (i) {
            final t = _roundedTokens[i];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _RadiusRow(name: t.name, value: t.value),
                if (i < _roundedTokens.length - 1) const _TokenDivider(),
              ],
            );
          }),
        ),
      ],
    );
  }
}

class _RadiusRow extends StatelessWidget {
  final String name;
  final double value;
  final String? alias;
  const _RadiusRow({required this.name, required this.value, this.alias});

  @override
  Widget build(BuildContext context) {
    // 48px swatch: radii ≥ 24 read as a full circle (true full / rounded-full).
    final double previewRadius =
        value >= 24 ? 24 : value.clamp(0, 24).toDouble();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.md,
        vertical: 10,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurface,
                  ),
                ),
                if (alias != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    alias!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: KasySpacing.md),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.colors.surface,
              border: Border.all(color: context.colors.separator),
              borderRadius: BorderRadius.circular(previewRadius),
            ),
          ),
          const SizedBox(width: KasySpacing.smd),
          Text(
            value >= 999 ? '${value.toInt()}' : '${value.toInt()}px',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.muted,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared card shell
// ---------------------------------------------------------------------------

class _TokenCard extends StatelessWidget {
  final List<Widget> children;
  const _TokenCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(KasyRadius.lg);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: radius,
        border: Border.all(
          color: context.colors.borderSoft,
        ),
        boxShadow: KasyShadows.cardElevated(context),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Effect Styles — Shadows, Blur, Focus Rings
// ---------------------------------------------------------------------------

class _EffectsSection extends StatelessWidget {
  const _EffectsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Shadows below are Figma 01 Effect Styles via KasyShadows helpers '
          '(same calls as KasyCard, KasyTextField, KasySwitch, KasyTabs, '
          'Menu / Dropdown / Popover). Inner is BlurStyle.inner. Blur / focus '
          'tiles use frostedBlur, modalScrimBlur, and focusRing helpers.',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.muted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: KasySpacing.lg),
        const _EffectGroupLabel('Shadows'),
        const SizedBox(height: KasySpacing.smd),
        Wrap(
          spacing: KasySpacing.md,
          runSpacing: KasySpacing.md,
          children: [
            const _InnerShadowTile(
              label: 'Inner',
              caption: 'inset token · unused in UI yet',
            ),
            _ShadowTile(
              label: 'Card',
              caption: 'KasyCard · surface / cardElevated()',
              shadows: KasyShadows.cardElevated(context),
            ),
            _ShadowTile(
              label: 'Field',
              caption: 'KasyTextField primary · inputField()',
              shadows: KasyShadows.inputField(context, enabled: true),
            ),
            _ShadowTile(
              label: 'Switch',
              caption: 'KasySwitch thumb · switchControl',
              shadows: KasyShadows.switchControlOf(context),
            ),
            _ShadowTile(
              label: 'Tab',
              caption: 'KasyTabs pill · tabOf()',
              shadows: KasyShadows.tabOf(context),
            ),
            _ShadowTile(
              label: 'Overlay',
              caption: 'Menu · Dropdown · Popover · bell',
              shadows: KasyShadows.overlayPanel(context),
            ),
          ],
        ),
        const SizedBox(height: KasySpacing.lg),
        const _EffectGroupLabel('Blur'),
        const SizedBox(height: KasySpacing.smd),
        const Wrap(
          spacing: KasySpacing.xl,
          runSpacing: KasySpacing.md,
          children: [
            _BlurTile(
              title: 'Blur',
              caption: 'frosted · blur/frosted\n(KasyShadows.frostedBlur)',
              sigma: KasyShadows.frostedBlur,
              gradientColors: [Color(0xFF7DB9F0), Color(0xFF8FE3B0)],
            ),
            _BlurTile(
              title: 'Backdrop',
              caption: 'scrim · blur/scrim\n(KasyModalScrim)',
              sigma: KasyShadows.modalScrimBlur,
              dimAlpha: KasyShadows.modalScrimDimAlpha,
              gradientColors: [Color(0xFFF7C27E), Color(0xFFF09090)],
            ),
          ],
        ),
        const SizedBox(height: KasySpacing.lg),
        const _EffectGroupLabel('Focus Rings'),
        const SizedBox(height: KasySpacing.smd),
        const Wrap(
          spacing: KasySpacing.lg,
          runSpacing: KasySpacing.md,
          children: [
            _FocusTile(label: 'Focus Ring', field: false),
            _FocusTile(label: 'Focus Ring Field', field: true),
          ],
        ),
      ],
    );
  }
}

class _EffectGroupLabel extends StatelessWidget {
  final String label;
  const _EffectGroupLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: context.kasyTextTheme.sectionTitle.copyWith(
        color: context.colors.onSurface,
      ),
    );
  }
}

/// 72×72 labeled sample tile shared by the effect groups. Bold [title] +
/// optional muted [caption] below, matching the Figma reference (a short
/// name, then the exact spec on its own line) instead of one long wrapping
/// string.
class _EffectTile extends StatelessWidget {
  final String title;
  final String? caption;
  final Widget box;
  const _EffectTile({required this.title, this.caption, required this.box});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        box,
        const SizedBox(height: KasySpacing.sm),
        SizedBox(
          width: 130,
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (caption != null) ...[
                const SizedBox(height: 2),
                Text(
                  caption!,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.muted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ShadowTile extends StatelessWidget {
  final String label;
  final String caption;
  final List<BoxShadow> shadows;
  const _ShadowTile({
    required this.label,
    required this.caption,
    required this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return _EffectTile(
      title: label,
      caption: caption,
      box: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(KasyRadius.md),
          // Figma tiles have fill + drop shadow only (no stroke).
          boxShadow: shadows,
        ),
      ),
    );
  }
}

class _InnerShadowTile extends StatelessWidget {
  final String label;
  final String caption;
  const _InnerShadowTile({required this.label, required this.caption});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Figma 64:2381 — INNER_SHADOW. Soft recess via BlurStyle.inner
    // (blur/alpha tuned in innerShadowOf so it reads inward, not as a ring).
    return _EffectTile(
      title: label,
      caption: caption,
      box: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(KasyRadius.md),
          boxShadow: KasyShadows.innerShadowOf(context),
        ),
      ),
    );
  }
}

class _BlurTile extends StatelessWidget {
  final String title;
  final String caption;

  /// Real [ImageFilter.blur] sigma used in the preview — matches an actual
  /// runtime value (`KasyShadows.modalScrimBlur` or a representative ad-hoc
  /// frosted-panel sigma in the 4–8 range).
  final double sigma;

  /// Black dim tint painted over the blur (0 for a plain frosted panel,
  /// KasyShadows.modalScrimDimAlpha for the real modal scrim).
  final double dimAlpha;

  /// Soft two-stop backdrop gradient (matches the Figma reference tiles —
  /// a calm blue→green or peach→red wash, not the busy 4-color rainbow).
  final List<Color> gradientColors;

  const _BlurTile({
    required this.title,
    required this.caption,
    required this.sigma,
    required this.gradientColors,
    this.dimAlpha = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Two offset layers (matches the HeroUI reference): a gradient panel
    // anchored top-left, and a blurred panel offset toward the bottom-right —
    // the gap between them lets the back panel's corner peek through, which
    // reads as "blur" far more clearly than blurring a single smooth gradient
    // (a plain gradient has no texture for the blur to visibly soften).
    return _EffectTile(
      title: title,
      caption: caption,
      box: SizedBox(
        width: 72,
        height: 72,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 58,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(KasyRadius.sm),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              top: 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(KasyRadius.sm),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                  child: Container(
                    width: 58,
                    height: 54,
                    color: dimAlpha > 0
                        ? Colors.black.withValues(alpha: dimAlpha)
                        : context.colors.surface.withValues(alpha: 0.10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusTile extends StatelessWidget {
  final String label;
  final bool field;
  const _FocusTile({required this.label, required this.field});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return _EffectTile(
      title: label,
      caption: field
          ? 'focusRingField · spread ${KasyShadows.ringOffsetWidth.toInt()}'
          : 'focusRing · ${KasyShadows.ringFocusWidth.toInt()} / '
              '${KasyShadows.ringOffsetWidth.toInt()}',
      box: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(KasyRadius.md),
          border: Border.all(color: c.separator),
          boxShadow: field
              ? KasyShadows.focusRingField(ring: c.primary)
              : KasyShadows.focusRing(ring: c.primary, gap: c.background),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Icon Sizes
// ---------------------------------------------------------------------------

class _IconSizesSection extends StatelessWidget {
  const _IconSizesSection();

  static const List<({String name, double value})> _tokens = [
    (name: 'xxs', value: KasyIconSize.xxs),
    (name: 'xs', value: KasyIconSize.xs),
    (name: 'sm', value: KasyIconSize.sm),
    (name: 'md', value: KasyIconSize.md),
    (name: 'lg', value: KasyIconSize.lg),
    (name: 'xl', value: KasyIconSize.xl),
    (name: 'xxl', value: KasyIconSize.xxl),
    (name: 'display', value: KasyIconSize.display),
    (name: 'hero', value: KasyIconSize.hero),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'From lib/core/theme/icon_sizes.dart (KasyIconSize). Single source of '
          'truth for every icon dimension in the app — xxs (12) micro glyphs to '
          'hero (72) focused-screen glyphs. Semantic aliases map the scale onto '
          'common contexts (row leading/trailing, chrome, inline).',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.muted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: KasySpacing.lg),
        Wrap(
          spacing: KasySpacing.lg,
          runSpacing: KasySpacing.md,
          children: [
            for (final t in _tokens)
              _IconSizeTile(name: t.name, value: t.value),
          ],
        ),
        const SizedBox(height: KasySpacing.md),
        Text(
          'Semantic aliases: rowLeading 20 (list-row leading icon) · '
          'rowTrailing 16 (trailing chevron / value) · chrome 20 (app-bar '
          'actions) · inline 18 (chip / inline glyph).',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.muted,
          ),
        ),
      ],
    );
  }
}

class _IconSizeTile extends StatelessWidget {
  final String name;
  final double value;
  const _IconSizeTile({required this.name, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 96,
          height: 96,
          child: Center(
            child: Icon(
              KasyIcons.star,
              size: value,
              color: context.colors.primary,
            ),
          ),
        ),
        const SizedBox(height: KasySpacing.sm),
        Text(
          name,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '${value.toInt()}px',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.muted,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
