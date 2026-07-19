import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Prominence of a [KasySurface] (HeroUI Surface variant).
///
/// [transparent] = structure/radius only, no fill. [defaultSurface] = the white
/// elevated surface (with the kit's field shadow). [secondary] / [tertiary] =
/// progressively recessed neutral fills for nested surfaces. [image] = clips a
/// child (e.g. an image) to the radius with no fill.
enum KasySurfaceVariant {
  transparent,
  defaultSurface,
  secondary,
  tertiary,
  image,
}

/// The kit's field elevation shadow (HeroUI shadow-surface, drop-shadow part).
const List<BoxShadow> _kSurfaceShadow = <BoxShadow>[
  BoxShadow(color: Color(0x0F000000), blurRadius: 1),
  BoxShadow(color: Color(0x0F000000), blurRadius: 2, offset: Offset(0, 1)),
  BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
];

/// Kasy-styled surface (HeroUI Surface) — a container that provides background,
/// elevation, rounding and clipping for the content placed inside it. Use it to
/// group content into cards, panels and nested surfaces.
class KasySurface extends StatelessWidget {
  const KasySurface({
    super.key,
    this.child,
    this.variant = KasySurfaceVariant.defaultSurface,
    this.borderRadius,
    this.padding,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget? child;
  final KasySurfaceVariant variant;

  /// Corner radius. Defaults to the kit's container radius (16), matching
  /// [KasyCard] and the internal-screen language.
  final BorderRadiusGeometry? borderRadius;

  final EdgeInsetsGeometry? padding;
  final Clip clipBehavior;

  Color _fill(KasyColors c) => switch (variant) {
        KasySurfaceVariant.transparent => Colors.transparent,
        KasySurfaceVariant.image => Colors.transparent,
        KasySurfaceVariant.defaultSurface => c.surface,
        KasySurfaceVariant.secondary => c.surfaceSecondary,
        KasySurfaceVariant.tertiary => c.surfaceTertiary,
      };

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    final BorderRadiusGeometry radius =
        borderRadius ?? BorderRadius.circular(KasyRadius.rounded2xl);

    final Widget? content = padding != null && child != null
        ? Padding(padding: padding!, child: child)
        : child;

    // Image surfaces clip their child to the radius with no fill or shadow.
    if (variant == KasySurfaceVariant.image) {
      return ClipRRect(
        borderRadius: radius.resolve(Directionality.of(context)),
        clipBehavior: clipBehavior,
        child: content,
      );
    }

    return Container(
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: _fill(c),
        borderRadius: radius,
        boxShadow: variant == KasySurfaceVariant.defaultSurface
            ? _kSurfaceShadow
            : null,
      ),
      child: content,
    );
  }
}
