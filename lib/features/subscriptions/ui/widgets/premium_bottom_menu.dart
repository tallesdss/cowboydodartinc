import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/environments.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/premium_page_factory.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Layout presets for paywall legal footers.
enum PremiumFooterStyle {
  /// Privacy | Restore | Terms in three equal columns (legacy paywalls).
  spread,

  /// Terms of Use · Privacy Policy · Restore (inline on mobile/tablet).
  dot,
}

/// Paywall footer: terms, privacy and optionally restore.
class BottomPremiumMenu extends StatelessWidget {
  const BottomPremiumMenu({
    super.key,
    this.onTapRestore,
    this.textColor,
    this.style = PremiumFooterStyle.spread,
  });

  final OnTap? onTapRestore;
  final Color? textColor;
  final PremiumFooterStyle style;

  @override
  Widget build(BuildContext context) {
    return switch (style) {
      PremiumFooterStyle.spread => _SpreadFooter(
        textColor: textColor,
        onTapRestore: onTapRestore,
      ),
      PremiumFooterStyle.dot => _DotFooter(
        textColor: textColor,
        onTapRestore: onTapRestore,
      ),
    };
  }
}

class _SpreadFooter extends StatelessWidget {
  const _SpreadFooter({
    required this.textColor,
    required this.onTapRestore,
  });

  final Color? textColor;
  final OnTap? onTapRestore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _LegalLink.privacy(context, color: textColor)),
        Expanded(
          child: _LegalLink.restore(
            context,
            color: textColor,
            onTap: onTapRestore,
          ),
        ),
        Expanded(child: _LegalLink.terms(context, color: textColor)),
      ],
    );
  }
}

class _DotFooter extends StatelessWidget {
  const _DotFooter({
    required this.textColor,
    this.onTapRestore,
  });

  final Color? textColor;
  final OnTap? onTapRestore;

  bool _usesInlineRestore(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (kIsWeb && width >= DeviceType.large.breakpoint) {
      return true;
    }
    final device = DeviceType.fromWidth(width);
    return device == DeviceType.small || device == DeviceType.medium;
  }

  TextStyle _linkTextStyle(BuildContext context) {
    return context.kasyTextTheme.caption;
  }

  TextStyle _dotTextStyle(BuildContext context, TextStyle linkStyle) {
    if (_usesInlineRestore(context)) {
      return context.kasyTextTheme.rowValue;
    }
    return linkStyle;
  }

  Widget? _restoreLink(BuildContext context, Color color, TextStyle textStyle) {
    if (onTapRestore == null) {
      return null;
    }
    return _LegalLink.restore(
      context,
      color: color,
      onTap: onTapRestore,
      compact: true,
      textStyle: textStyle,
    );
  }

  Widget _dotSeparatedLinks(
    BuildContext context, {
    required Color color,
    required TextStyle linkStyle,
    required TextStyle dotStyle,
    required Widget? restore,
  }) {
    final children = <Widget>[
      _LegalLink.termsOfUse(
        context,
        color: color,
        textStyle: linkStyle,
      ),
      _DotSeparator(
        color: color,
        textStyle: dotStyle,
      ),
      _LegalLink.privacyPolicy(
        context,
        color: color,
        textStyle: linkStyle,
      ),
    ];
    if (restore != null) {
      children.addAll([
        _DotSeparator(
          color: color,
          textStyle: dotStyle,
        ),
        restore,
      ]);
    }
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final base = textColor ?? context.colors.muted;
    final color = base;
    final linkStyle = _linkTextStyle(context);
    final dotStyle = _dotTextStyle(context, linkStyle);
    final restore = _restoreLink(context, color, linkStyle);
    final inlineRestore = _usesInlineRestore(context);
    if (restore == null || inlineRestore) {
      return _dotSeparatedLinks(
        context,
        color: color,
        linkStyle: linkStyle,
        dotStyle: dotStyle,
        restore: inlineRestore ? restore : null,
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dotSeparatedLinks(
          context,
          color: color,
          linkStyle: linkStyle,
          dotStyle: dotStyle,
          restore: null,
        ),
        const SizedBox(height: KasySpacing.xs),
        restore,
      ],
    );
  }
}

class _DotSeparator extends StatelessWidget {
  const _DotSeparator({
    required this.color,
    required this.textStyle,
  });

  final Color color;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        '·',
        style: _LegalLink.linkStyle(
          base: textStyle,
          color: color,
        ),
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({
    required this.label,
    required this.onTap,
    required this.color,
    required this.compact,
    this.textStyle,
  });

  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final bool compact;
  final TextStyle? textStyle;

  factory _LegalLink.terms(
    BuildContext context, {
    Color? color,
    bool compact = false,
    TextStyle? textStyle,
  }) {
    return _LegalLink(
      label: Translations.of(context).premium.terms,
      onTap: _openTerms,
      color: color,
      compact: compact,
      textStyle: textStyle,
    );
  }

  factory _LegalLink.termsOfUse(
    BuildContext context, {
    Color? color,
    TextStyle? textStyle,
  }) {
    return _LegalLink(
      label: Translations.of(context).premium.terms_of_use,
      onTap: _openTerms,
      color: color,
      compact: true,
      textStyle: textStyle,
    );
  }

  factory _LegalLink.privacy(
    BuildContext context, {
    Color? color,
    bool compact = false,
    TextStyle? textStyle,
  }) {
    return _LegalLink(
      label: Translations.of(context).premium.privacy,
      onTap: () => launchUrl(Uri.parse(kPrivacyUrl)),
      color: color,
      compact: compact,
      textStyle: textStyle,
    );
  }

  factory _LegalLink.privacyPolicy(
    BuildContext context, {
    Color? color,
    TextStyle? textStyle,
  }) {
    return _LegalLink(
      label: Translations.of(context).premium.privacy_policy,
      onTap: () => launchUrl(Uri.parse(kPrivacyUrl)),
      color: color,
      compact: true,
      textStyle: textStyle,
    );
  }

  factory _LegalLink.restore(
    BuildContext context, {
    Color? color,
    VoidCallback? onTap,
    bool compact = false,
    TextStyle? textStyle,
  }) {
    return _LegalLink(
      label: Translations.of(context).premium.restore_action,
      onTap: onTap,
      color: color,
      compact: compact,
      textStyle: textStyle,
    );
  }

  static TextStyle linkStyle({
    required TextStyle base,
    required Color color,
  }) {
    return base.copyWith(
      color: color.withValues(alpha: 0.65),
      fontWeight: FontWeight.w400,
      height: 1.2,
    );
  }

  static void _openTerms() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        launchUrl(Uri.parse(
          'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
        ));
      case TargetPlatform.android:
      default:
        launchUrl(Uri.parse(kTermsUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? context.colors.muted;
    final resolvedTextStyle = textStyle ?? context.kasyTextTheme.caption;

    if (compact) {
      return _CompactLegalLink(
        label: label,
        onTap: onTap,
        color: resolvedColor,
        textStyle: resolvedTextStyle,
      );
    }

    return KasyButton(
      variant: KasyButtonVariant.ghost,
      label: label,
      size: KasyButtonSize.small,
      expand: true,
      foregroundColor: resolvedColor,
      fontWeight: FontWeight.w500,
      onPressed: onTap,
    );
  }
}

class _CompactLegalLink extends StatelessWidget {
  const _CompactLegalLink({
    required this.label,
    required this.onTap,
    required this.color,
    required this.textStyle,
  });

  final String label;
  final VoidCallback? onTap;
  final Color color;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final style = _LegalLink.linkStyle(
      base: textStyle,
      color: onTap == null ? color.withValues(alpha: 0.45) : color,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KasyRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KasySpacing.xs,
            vertical: 2,
          ),
          child: Text(label, style: style, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
