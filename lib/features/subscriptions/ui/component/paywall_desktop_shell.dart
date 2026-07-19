import 'package:cowboydodartinc/components/kasy_modal_scrim.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/premium_close_button.dart';
import 'package:flutter/material.dart';

/// Full-viewport paywall shell: close control, optional header, scroll body, footer.
class PaywallDesktopFullscreenShell extends StatelessWidget {
  const PaywallDesktopFullscreenShell({
    super.key,
    required this.backgroundColor,
    required this.body,
    this.onClose,
    this.closeScrim,
    this.closeIconColor,
    this.header,
    this.footer,
    this.horizontalPadding = KasySpacing.xxl,
    this.closePadding,
    this.footerTopPadding = KasySpacing.lg,
  });

  final Color backgroundColor;
  final VoidCallback? onClose;
  final Color? closeScrim;
  final Color? closeIconColor;
  final Widget? header;
  final Widget body;
  final Widget? footer;
  final double horizontalPadding;
  final EdgeInsets? closePadding;
  final double footerTopPadding;

  @override
  Widget build(BuildContext context) {
    final Widget? headerWidget = header;
    final Widget? footerWidget = footer;
    final resolvedClosePadding = closePadding ??
        EdgeInsets.fromLTRB(
          horizontalPadding,
          KasySpacing.sm,
          horizontalPadding,
          0,
        );
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: resolvedClosePadding,
              child: Row(
                children: [
                  AppCloseButton(
                    onTap: onClose,
                    backgroundColor: closeScrim,
                    iconColor: closeIconColor,
                  ),
                  const Spacer(),
                ],
              ),
            ),
            if (headerWidget != null) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: headerWidget,
              ),
              const SizedBox(height: KasySpacing.xl),
            ],
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: body,
              ),
            ),
            if (footerWidget != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  footerTopPadding,
                  horizontalPadding,
                  KasySpacing.lg,
                ),
                child: footerWidget,
              ),
          ],
        ),
      ),
    );
  }
}

/// Centered panel over a lightly blurred backdrop, matching [showKasyBlurDialog].
///
/// Requires a non-opaque route (see [kasyModalOverlayPage]) so the previous
/// screen remains painted underneath.
class PaywallDesktopModalShell extends StatelessWidget {
  const PaywallDesktopModalShell({
    super.key,
    required this.panelColor,
    required this.child,
    this.onClose,
    this.closeScrim,
    this.closeIconColor,
    this.maxWidth = 960,
    this.maxHeight = 680,
    this.blurSigma = KasyShadows.modalScrimBlur,
    this.barrierDismissible = true,
  });

  final Color panelColor;
  final Widget child;
  final VoidCallback? onClose;
  final Color? closeScrim;
  final Color? closeIconColor;
  final double maxWidth;
  final double maxHeight;
  final double blurSigma;
  final bool barrierDismissible;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          KasyModalScrim(
            blurSigma: blurSigma,
            onTap: barrierDismissible ? onClose : null,
          ),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.all(KasySpacing.xl),
                child: Material(
                  color: panelColor,
                  elevation: 16,
                  shadowColor: Colors.black.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(KasyRadius.xl),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(child: child),
                      Positioned(
                        top: KasySpacing.md,
                        left: KasySpacing.md,
                        child: AppCloseButton(
                          onTap: onClose,
                          backgroundColor: closeScrim,
                          iconColor: closeIconColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
