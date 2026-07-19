import 'package:cowboydodartinc/components/kasy_link.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Inline auth switcher: muted lead + emphasised link.
///
/// Spec from Figma Sign In · Mobile (`52:87`–`52:91`):
/// - lead: Poppins Medium 14 / 20 / muted ("Não tem uma conta?")
/// - link: Poppins SemiBold 14 / 20 / onSurface ("Cadastre-se"), underline on
///   hover only
/// - gap 4 between lead and link
/// - row min height 44 (touch target; Figma `Signup center`)
///
/// Shared by sign-in, sign-up and recover so the three screens stay in sync.
class AuthAccountSwitchPrompt extends StatelessWidget {
  const AuthAccountSwitchPrompt({
    super.key,
    required this.lead,
    required this.linkLabel,
    required this.onLinkPressed,
  });

  final String lead;
  final String linkLabel;
  final VoidCallback onLinkPressed;

  /// Figma `Signup center` touch row height.
  static const double rowMinHeight = 44;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: rowMinHeight),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                lead,
                style: context.kasyTextTheme.bodyMedium.copyWith(
                  color: context.colors.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: KasySpacing.xs),
              KasyLink(
                label: linkLabel,
                color: context.colors.onSurface,
                focusable: false,
                underline: KasyLinkUnderline.hover,
                fontWeight: FontWeight.w600,
                onPressed: onLinkPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
