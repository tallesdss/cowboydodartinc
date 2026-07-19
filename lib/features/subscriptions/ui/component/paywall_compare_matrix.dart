import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_compare_palette.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Grátis vs Premium feature matrix for [PaywallCompare]. Compare-only UI.
class PaywallCompareFeatureMatrix extends StatelessWidget {
  const PaywallCompareFeatureMatrix({
    super.key,
    this.motionReduced = false,
    this.desktopScale = false,
  });

  final bool motionReduced;
  final bool desktopScale;

  static const double _premiumColumnFlex = 22;
  static const double _freeColumnFlex = 18;
  static const double _featureColumnFlex = 44;

  @override
  Widget build(BuildContext context) {
    final comparison = Translations.of(context).premium.comparison;
    final rows = <_MatrixRow>[
      _MatrixRow(comparison.no_ads, free: false, premium: true),
      _MatrixRow(comparison.premium_themes, free: false, premium: true),
      _MatrixRow(comparison.advanced_customization, free: false, premium: true),
      _MatrixRow(comparison.priority_support, free: false, premium: true),
      _MatrixRow(comparison.home_widget, free: true, premium: true),
      _MatrixRow(comparison.talk_with_assistant, free: false, premium: true),
    ];

    final matrix = DecoratedBox(
      decoration: BoxDecoration(
        color: PaywallComparePalette.card,
        borderRadius: BorderRadius.circular(KasyRadius.xl),
        border: Border.all(color: PaywallComparePalette.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(KasyRadius.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MatrixHeader(
              freeLabel: comparison.free_version,
              premiumLabel: comparison.premium_version,
              desktopScale: desktopScale,
            ),
            for (var i = 0; i < rows.length; i++)
              _MatrixFeatureRow(
                label: rows[i].label,
                free: rows[i].free,
                premium: rows[i].premium,
                isLast: i == rows.length - 1,
                desktopScale: desktopScale,
              ),
          ],
        ),
      ),
    );

    if (motionReduced) {
      return matrix;
    }

    return Animate(
      effects: [
        FadeEffect(duration: 360.ms, curve: Curves.easeOut),
        MoveEffect(
          duration: 400.ms,
          curve: Curves.easeOut,
          begin: const Offset(0, 12),
          end: Offset.zero,
        ),
      ],
      child: matrix,
    );
  }
}

class _MatrixRow {
  const _MatrixRow(this.label, {required this.free, required this.premium});

  final String label;
  final bool free;
  final bool premium;
}

class _MatrixHeader extends StatelessWidget {
  const _MatrixHeader({
    required this.freeLabel,
    required this.premiumLabel,
    required this.desktopScale,
  });

  final String freeLabel;
  final String premiumLabel;
  final bool desktopScale;

  @override
  Widget build(BuildContext context) {
    final featuresLabelStyle = desktopScale
        ? context.textTheme.titleLarge!.withWeight(FontWeight.w600).copyWith(
            color: PaywallComparePalette.onCanvas,
          )
        : context.textTheme.titleSmall!.withWeight(FontWeight.w600).copyWith(
            color: PaywallComparePalette.onCanvas,
          );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: PaywallCompareFeatureMatrix._featureColumnFlex.toInt(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                KasySpacing.lg,
                KasySpacing.lg,
                KasySpacing.sm,
                KasySpacing.lg,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  Translations.of(context).premium.comparison.features_label,
                  style: featuresLabelStyle,
                ),
              ),
            ),
          ),
          Expanded(
            flex: PaywallCompareFeatureMatrix._freeColumnFlex.toInt(),
            child: _HeaderCell(
              label: freeLabel,
              highlight: false,
              desktopScale: desktopScale,
            ),
          ),
          Expanded(
            flex: PaywallCompareFeatureMatrix._premiumColumnFlex.toInt(),
            child: _HeaderCell(
              label: premiumLabel,
              highlight: true,
              desktopScale: desktopScale,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.label,
    required this.highlight,
    required this.desktopScale,
  });

  final String label;
  final bool highlight;
  final bool desktopScale;

  @override
  Widget build(BuildContext context) {
    final freeHeaderStyle = desktopScale
        ? context.textTheme.titleLarge!.withWeight(FontWeight.w600).copyWith(
            color: PaywallComparePalette.subtle,
          )
        : context.textTheme.labelLarge!.withWeight(FontWeight.w600).copyWith(
            color: PaywallComparePalette.subtle,
          );

    final premiumHeaderStyle = desktopScale
        ? context.textTheme.titleMedium!.withWeight(FontWeight.w700).copyWith(
            color: PaywallComparePalette.primary,
          )
        : context.textTheme.labelLarge!.withWeight(FontWeight.w700).copyWith(
            color: PaywallComparePalette.primary,
          );

    final premiumBadgePadding = desktopScale
        ? const EdgeInsets.symmetric(
            horizontal: KasySpacing.smd,
            vertical: KasySpacing.xs,
          )
        : const EdgeInsets.symmetric(
            horizontal: KasySpacing.sm,
            vertical: 6,
          );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlight
            ? PaywallComparePalette.matrixPremiumFill
            : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: PaywallComparePalette.border.withValues(alpha: 0.65),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KasySpacing.sm,
          vertical: KasySpacing.lg,
        ),
        child: Center(
          child: highlight
              ? Container(
                  padding: premiumBadgePadding,
                  decoration: BoxDecoration(
                    color: PaywallComparePalette.primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(KasyRadius.full),
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: premiumHeaderStyle,
                  ),
                )
              : Text(
                  label,
                  textAlign: TextAlign.center,
                  style: freeHeaderStyle,
                ),
        ),
      ),
    );
  }
}

class _MatrixFeatureRow extends StatelessWidget {
  const _MatrixFeatureRow({
    required this.label,
    required this.free,
    required this.premium,
    required this.isLast,
    required this.desktopScale,
  });

  final String label;
  final bool free;
  final bool premium;
  final bool isLast;
  final bool desktopScale;

  @override
  Widget build(BuildContext context) {
    final labelStyle = context.textTheme.bodyLarge!.withWeight(
      FontWeight.w500,
    ).copyWith(
      color: PaywallComparePalette.onCanvas,
      height: 1.25,
    );

    return IntrinsicHeight(
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  top: BorderSide(
                    color: PaywallComparePalette.border.withValues(alpha: 0.55),
                  ),
                ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: PaywallCompareFeatureMatrix._featureColumnFlex.toInt(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  KasySpacing.lg,
                  KasySpacing.md,
                  KasySpacing.sm,
                  KasySpacing.md,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: labelStyle,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: PaywallCompareFeatureMatrix._freeColumnFlex.toInt(),
              child: _ValueCell(
                available: free,
                premiumColumn: false,
              ),
            ),
            Expanded(
              flex: PaywallCompareFeatureMatrix._premiumColumnFlex.toInt(),
              child: _ValueCell(
                available: premium,
                premiumColumn: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueCell extends StatelessWidget {
  const _ValueCell({
    required this.available,
    required this.premiumColumn,
  });

  final bool available;
  final bool premiumColumn;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: premiumColumn
            ? PaywallComparePalette.matrixPremiumFill
            : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: PaywallComparePalette.border.withValues(alpha: 0.65),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: KasySpacing.md),
        child: Center(
          child: _AvailabilityMark(
            available: available,
            premiumColumn: premiumColumn,
          ),
        ),
      ),
    );
  }
}

class _AvailabilityMark extends StatelessWidget {
  const _AvailabilityMark({
    required this.available,
    required this.premiumColumn,
  });

  final bool available;
  final bool premiumColumn;

  @override
  Widget build(BuildContext context) {
    if (available) {
      return Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: premiumColumn
              ? PaywallComparePalette.primary.withValues(alpha: 0.22)
              : PaywallComparePalette.border.withValues(alpha: 0.55),
          shape: BoxShape.circle,
        ),
        child: Icon(
          KasyIcons.check,
          size: 16,
          color: premiumColumn
              ? PaywallComparePalette.primary
              : PaywallComparePalette.muted,
        ),
      );
    }

    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      child: Container(
        width: 14,
        height: 2,
        decoration: BoxDecoration(
          color: PaywallComparePalette.subtle.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(KasyRadius.full),
        ),
      ),
    );
  }
}
