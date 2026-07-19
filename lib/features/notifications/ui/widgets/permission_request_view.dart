import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/animations/movefade_anim.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_brand_badge.dart';
import 'package:flutter/material.dart';

/// Reusable "ask before the OS dialog" permission screen.
///
/// This is the painted skeleton: a brand badge (or your own [illustration]) over
/// a title, a description and two actions (accept / skip). Drop it into any page
/// or sheet and feed it copy + callbacks. The OS permission call itself lives in
/// [onAccept] so this widget stays UI‑only and reusable for ANY permission.
///
/// Example — a camera permission screen in ~10 lines:
/// ```dart
/// PermissionRequestView(
///   icon: KasyIcons.camera,
///   title: 'Enable the camera?',
///   description: 'Scan documents and snap photos right inside the app.',
///   acceptLabel: 'Allow camera',
///   skipLabel: 'Not now',
///   onAccept: () => askCameraPermission(),
///   onSkip: () => Navigator.of(context).pop(),
/// );
/// ```
class PermissionRequestView extends StatelessWidget {
  const PermissionRequestView({
    super.key,
    this.icon,
    this.illustration,
    required this.title,
    required this.description,
    required this.acceptLabel,
    required this.skipLabel,
    required this.onAccept,
    this.onSkip,
  }) : assert(
         icon != null || illustration != null,
         'PermissionRequestView needs an icon or an illustration',
       );

  /// Icon shown in the brand badge. Ignored when [illustration] is set.
  final IconData? icon;

  /// Custom hero (e.g. a module mockup). Overrides the badge when provided.
  final Widget? illustration;

  final String title;
  final String description;

  /// Primary action label. Trigger the real OS permission request in [onAccept].
  final String acceptLabel;

  /// Secondary ("maybe later") action label.
  final String skipLabel;

  final VoidCallback onAccept;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          KasySpacing.lg,
          KasySpacing.xl,
          KasySpacing.lg,
          KasySpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            MoveFadeAnim(
              delayInMs: 40,
              child: Center(
                child:
                    illustration ??
                    KasyBrandBadge(icon: icon, size: 76, glyphSize: KasyIconSize.display),
              ),
            ),
            const SizedBox(height: KasySpacing.xl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: KasySpacing.smd),
            Text(
              description,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.muted,
                height: 1.45,
              ),
            ),
            const Spacer(),
            KasyButton(
              label: acceptLabel,
              expand: true,
              onPressed: onAccept,
            ),
            const SizedBox(height: KasySpacing.smd),
            KasyButton(
              label: skipLabel,
              variant: KasyButtonVariant.soft,
              expand: true,
              onPressed: onSkip,
            ),
          ],
        ),
      ),
    );
  }
}
