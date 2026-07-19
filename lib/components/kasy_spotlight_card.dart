import 'package:cowboydodartinc/components/kasy_card.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Spotlight card — gradient header + compact body. Two layouts:
///
/// * [KasySpotlightCard.icon] — circular icon hero (privacy, feature highlights)
/// * [KasySpotlightCard.media] — image hero (brand splash, promos)
///
/// Built on [KasyCard] with [KasyCardVariant.spotlight] (radius 16, component shadow).
class KasySpotlightCard extends StatelessWidget {
  const KasySpotlightCard.icon({
    super.key,
    required this.tag,
    required this.icon,
    this.headline,
    this.body,
    this.iconSize = 32,
    this.headerHeight = 100,
    this.maxWidth,
  })  : imageAsset = null,
        imageWidget = null,
        imageHeight = null,
        cta = null;

  const KasySpotlightCard.media({
    super.key,
    required this.tag,
    this.headline,
    this.body,
    this.cta,
    this.imageAsset,
    this.imageWidget,
    this.imageHeight = 108,
    this.maxWidth,
  })  : icon = null,
        iconSize = null,
        headerHeight = null;

  static const double radius = 16;
  static const EdgeInsets bodyPadding = EdgeInsets.fromLTRB(11, 9, 11, 11);

  final String tag;
  final String? headline;
  final String? body;
  final String? cta;

  final IconData? icon;
  final double? iconSize;
  final double? headerHeight;

  final String? imageAsset;
  final Widget? imageWidget;
  final double? imageHeight;

  final double? maxWidth;

  bool get _isIcon => icon != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final double resolvedHeaderHeight =
        _isIcon ? (headerHeight ?? 100) : (imageHeight ?? 108);

    Widget card = KasyCard(
      variant: KasyCardVariant.spotlight,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(radius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: resolvedHeaderHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.primary.withValues(alpha: 0.16),
                    colors.primary.withValues(alpha: 0.05),
                    colors.surface,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
              child: Center(child: _buildHeader(context)),
            ),
          ),
          if (_hasBody) _buildBody(context),
        ],
      ),
    );

    if (maxWidth != null) {
      card = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: card,
      );
    }

    return card;
  }

  bool get _hasBody =>
      tag.isNotEmpty ||
      (headline != null && headline!.isNotEmpty) ||
      (body != null && body!.isNotEmpty) ||
      (cta != null && cta!.isNotEmpty);

  Widget _buildHeader(BuildContext context) {
    if (_isIcon) {
      final colors = context.colors;
      final double size = iconSize ?? 32;
      return Container(
        width: size * 2,
        height: size * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.primary.withValues(alpha: 0.14),
          border: Border.all(
            color: colors.primary.withValues(alpha: 0.28),
          ),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: size, color: colors.primary),
      );
    }

    if (imageWidget != null) {
      return imageWidget!;
    }

    if (imageAsset != null) {
      return Image.asset(
        imageAsset!,
        height: (imageHeight ?? 108) * 0.72,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) => Icon(
          Icons.image_outlined,
          size: 40,
          color: context.colors.muted,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBody(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: bodyPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tag.isNotEmpty) ...[
            _SpotlightTag(label: tag),
            if (headline != null || body != null || cta != null)
              const SizedBox(height: 7),
          ],
          if (headline != null && headline!.isNotEmpty) ...[
            Text(
              headline!,
              style: context.textTheme.labelLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                height: 1.25,
              ),
            ),
            if (body != null || cta != null) const SizedBox(height: 4),
          ],
          if (body != null && body!.isNotEmpty) ...[
            Text(
              body!,
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.muted,
                fontSize: 12,
                height: 1.35,
              ),
            ),
            if (cta != null && cta!.isNotEmpty) const SizedBox(height: 8),
          ],
          if (cta != null && cta!.isNotEmpty)
            Text(
              cta!,
              style: context.textTheme.labelSmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}

class _SpotlightTag extends StatelessWidget {
  const _SpotlightTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.12),
        borderRadius: KasyRadius.fullBorderRadius,
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: colors.primary,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
