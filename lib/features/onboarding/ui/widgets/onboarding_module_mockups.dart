import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:cowboydodartinc/components/kasy_spinner.dart';
import 'package:cowboydodartinc/core/haptics/kasy_haptics.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Live, in‑Flutter mockups of the kit's modules used as onboarding heroes.
///
/// They are purely presentational (no interaction) and built entirely from
/// theme tokens, so they adapt to light/dark and to the brand color. Each one
/// is a tiny, faithful preview of a real module the kit ships with.
// ─────────────────────────────────────────────────────────────────────────
// Shared building blocks
// ─────────────────────────────────────────────────────────────────────────
/// A soft brand glow behind a floating card, framed in a clean stage.
class _MockStage extends StatelessWidget {
  const _MockStage({
    required this.child,
    this.maxWidth = 300,
    this.showGlow = true,
  });

  final Widget child;
  final double maxWidth;

  /// Soft brand halo behind the card. Off for scenes that already carry their
  /// own color (e.g. the earnings flow), where the halo reads as a stray shadow.
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Radial brand glow centered behind the card.
            if (showGlow)
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: maxWidth * 0.9,
                    height: maxWidth * 0.9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          primary.withValues(
                              alpha: context.isDark ? 0.22 : 0.16),
                          primary.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            child,
          ],
        ),
      ),
    );
  }
}

/// A floating surface card with hairline border + soft elevation.
class _Card extends StatelessWidget {
  const _Card({
    required this.child,
    this.padding = const EdgeInsets.all(KasySpacing.md),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: KasyRadius.xlBorderRadius,
        border: Border.all(
          // Hairline: a faint light edge in dark mode, a faint dark edge in light.
          color: context.isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          // Always a dark shadow (never tinted by onBackground, which flips to
          // near‑white in dark mode and produced a strange halo).
          BoxShadow(
            color: Colors.black.withValues(
              alpha: context.isDark ? 0.30 : 0.10,
            ),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Brand‑colored rounded icon badge.
class _IconBadge extends StatelessWidget {
  const _IconBadge(this.icon, {this.glyph = 20});

  final IconData icon;
  final double glyph;

  static const double _size = 40;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary,
            Color.lerp(colors.primary, Colors.black, 0.18)!,
          ],
        ),
        borderRadius: BorderRadius.circular(_size * 0.3),
      ),
      child: Icon(icon, color: colors.onPrimary, size: glyph),
    );
  }
}

/// Skeleton line used to suggest text without spelling it out.
class _Bar extends StatelessWidget {
  const _Bar({required this.width, this.height = 8, this.strong = false});

  final double width;
  final double height;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.onSurface.withValues(alpha: strong ? 0.55 : 0.14),
        borderRadius: KasyRadius.fullBorderRadius,
      ),
    );
  }
}

/// Faux primary pill (looks like [KasyButton] without being interactive).
class _PillButton extends StatelessWidget {
  const _PillButton(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 38,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: KasySpacing.md),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: KasyRadius.mdBorderRadius,
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: context.textTheme.labelLarge?.copyWith(
          color: colors.onPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Paywall / subscriptions
// ─────────────────────────────────────────────────────────────────────────

class PaywallMockup extends StatelessWidget {
  const PaywallMockup({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final t = Translations.of(context).onboarding.mockups.paywall;
    return _MockStage(
      maxWidth: 320,
      child: _Card(
        padding: const EdgeInsets.all(KasySpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const _IconBadge(KasyIcons.star),
                const SizedBox(width: KasySpacing.smd),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.title,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const _Bar(width: 96),
                  ],
                ),
              ],
            ),
            const SizedBox(height: KasySpacing.lg),
            _PlanRow(
              title: t.annual,
              price: t.price_year,
              badge: t.save_badge,
              selected: true,
            ),
            const SizedBox(height: KasySpacing.sm),
            _PlanRow(title: t.monthly, price: t.price_month),
            const SizedBox(height: KasySpacing.lg),
            _PillButton(t.cta),
          ],
        ),
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.title,
    required this.price,
    this.badge,
    this.selected = false,
  });

  final String title;
  final String price;
  final String? badge;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.smd,
        vertical: KasySpacing.smd,
      ),
      decoration: BoxDecoration(
        color: selected ? colors.surfacePrimarySoft : colors.surfaceNeutralSoft,
        borderRadius: KasyRadius.lgBorderRadius,
        border: Border.all(
          color: selected ? colors.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? colors.primary : Colors.transparent,
              border: Border.all(
                color: selected ? colors.primary : colors.outlineButton,
                width: 2,
              ),
            ),
            child: selected
                ? Icon(KasyIcons.check, size: KasyIconSize.xxs, color: colors.onPrimary)
                : null,
          ),
          const SizedBox(width: KasySpacing.smd),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.titleSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: KasySpacing.sm),
          if (badge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: KasyRadius.fullBorderRadius,
              ),
              child: Text(
                badge!,
                style: context.textTheme.labelSmall?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            const SizedBox(width: KasySpacing.sm),
          ],
          Text(
            price,
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Earnings flow (subscription → payment → payout)
// ─────────────────────────────────────────────────────────────────────────

/// A small, organic "money flowing in" scene, mirroring the Zero onboarding
/// hero: a notification card tilted one way, a thin tinted pill in the middle
/// that's still loading, and a tinted summary card tilted the other way —
/// connected by hand‑drawn curved arrows. No icons anywhere (deliberate): the
/// cards and arrows carry the story on their own.
class EarningsMockup extends StatefulWidget {
  const EarningsMockup({super.key});

  @override
  State<EarningsMockup> createState() => _EarningsMockupState();
}

class _EarningsMockupState extends State<EarningsMockup>
    with SingleTickerProviderStateMixin {
  // One master timeline (4100ms) drives the whole scene so the beats stay in
  // sync. A short lead-in lets the screen settle FIRST, then the notification
  // is clearly seen dropping in from above:
  //   450–1150ms   notification drops in from above (+ sound + haptic)
  //   1250–1850ms  first arrow traces
  //   1900–2300ms  "processing payment" pill appears
  //   …~0.6s pause (snappier second half)…
  //   2900–3500ms  second arrow traces
  //   3550–3950ms  payout summary appears
  static const int _totalMs = 4100;
  late final AnimationController _c;
  final AudioPlayer _player = AudioPlayer();
  int _cueStep = 0;

  late final Animation<double> _notif;
  late final Animation<double> _arrow1;
  late final Animation<double> _pill;
  late final Animation<double> _arrow2;
  late final Animation<double> _summary;

  // Fraction of the timeline for a given millisecond mark.
  double _at(int ms) => ms / _totalMs;

  Animation<double> _seg(int beginMs, int endMs, Curve curve) => CurvedAnimation(
        parent: _c,
        curve: Interval(_at(beginMs), _at(endMs), curve: curve),
      );

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _totalMs),
    );
    _notif = _seg(450, 1150, Curves.easeOutBack);
    _arrow1 = _seg(1250, 1850, Curves.easeInOut);
    _pill = _seg(1900, 2300, Curves.easeOut);
    _arrow2 = _seg(2900, 3500, Curves.easeInOut);
    _summary = _seg(3550, 3950, Curves.easeOut);

    // Respect the device's silent switch: the iOS "ambient" category is muted
    // by the ring/silent switch, so on silent the cue is FELT (haptic) but not
    // heard. (Default "playback" would play even on silent.)
    _player.setAudioContext(
      AudioContext(
        // `ambient` is muted by the silent switch (so on silent: vibrate only)
        // and already mixes with other audio — mixWithOthers is disallowed here.
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.ambient,
        ),
        android: const AudioContextAndroid(
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.notificationEvent,
          audioFocus: AndroidAudioFocus.none,
        ),
      ),
    );

    _c.addListener(_maybeCue);
    _c.forward();
  }

  // Each container announces itself: the notification lands with sound + a
  // medium thud, then the "processing" pill and the earnings summary each give
  // a lighter tap as they arrive. The sound obeys silent mode; haptics always.
  void _maybeCue() {
    if (_cueStep == 0 && _c.value >= _at(450)) {
      _cueStep = 1;
      _player.play(AssetSource('sounds/notification.wav'));
      KasyHaptics.medium(context);
    }
    if (_cueStep == 1 && _c.value >= _at(1900)) {
      _cueStep = 2;
      KasyHaptics.light(context);
    }
    if (_cueStep == 2 && _c.value >= _at(3550)) {
      _cueStep = 3;
      KasyHaptics.light(context);
    }
  }

  @override
  void dispose() {
    _c.removeListener(_maybeCue);
    _c.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context).onboarding.mockups.earnings;
    return _MockStage(
      maxWidth: 320,
      showGlow: false,
      child: SizedBox(
        width: 290,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The ONLY element that drops in from above (a push notification).
              _DropIn(
                value: _notif.value,
                child: Transform.rotate(
                  angle: -0.045,
                  child: _NotifyCard(
                    title: t.notify_title,
                    subtitle: t.notify_subtitle,
                    time: t.notify_time,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 26),
                  child: _CurvedArrow(progress: _arrow1.value),
                ),
              ),
              // Payment processing — a thin tinted pill with a live spinner.
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 208),
                child: _Appear(
                  value: _pill.value,
                  child: _LoadingPill(label: t.processing),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 26),
                  child: _CurvedArrow(flip: true, progress: _arrow2.value),
                ),
              ),
              // The payout summary — tilted slightly right, deeper tint.
              _Appear(
                value: _summary.value,
                child: Transform.rotate(
                  angle: 0.05,
                  child: _SummaryCard(
                    label: t.summary_label,
                    body: t.summary_body,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Slides its child down into place from above while fading in. The layout slot
/// is always reserved (Transform/Opacity don't affect layout), so nothing jumps.
class _DropIn extends StatelessWidget {
  const _DropIn({required this.value, required this.child});

  final double value;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Opacity ramps faster than the slide, so the card is already visible while
    // it's still travelling down — you actually SEE it drop, not just fade.
    final double opacity = (value * 1.8).clamp(0.0, 1.0);
    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        // Comes from well above its slot (90px) and settles into place.
        offset: Offset(0, (1 - value) * -90),
        child: child,
      ),
    );
  }
}

/// Fades + gently scales its child into place (no sliding).
class _Appear extends StatelessWidget {
  const _Appear({required this.value, required this.child});

  final double value;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: value.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: 0.92 + 0.08 * value,
        child: child,
      ),
    );
  }
}

/// Soft surface card (hairline border + gentle shadow), used for the top
/// notification. Lighter than [_Card] so the scene feels airy.
class _NotifyCard extends StatelessWidget {
  const _NotifyCard({
    required this.title,
    required this.subtitle,
    required this.time,
  });

  final String title;
  final String subtitle;
  final String time;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.md,
        vertical: KasySpacing.smd,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: KasyRadius.lgBorderRadius,
        border: Border.all(
          color: context.isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.28 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Push‑notification header: app icon + name, time trailing.
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.asset(
                  'assets/branding/app-icon.png',
                  width: 22,
                  height: 22,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: KasySpacing.sm),
              Text(
                'Kasy',
                style: context.textTheme.labelMedium?.copyWith(
                  color: colors.muted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const Spacer(),
              Text(
                time,
                style: context.textTheme.labelSmall?.copyWith(
                  color: colors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: KasySpacing.sm),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Thin tinted pill that's mid‑action: a label + a live [KasySpinner].
class _LoadingPill extends StatelessWidget {
  const _LoadingPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.md,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        // Soft green — money coming in, mid‑processing.
        color: colors.successSoft,
        borderRadius: KasyRadius.fullBorderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.successSoftForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: KasySpacing.sm),
          KasySpinner(
            size: KasySpinnerSize.sm,
            diameter: 16,
            color: colors.success,
          ),
        ],
      ),
    );
  }
}

/// Tinted summary card (deeper brand tint), borderless, holding the payout copy.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.body});

  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KasySpacing.md),
      decoration: BoxDecoration(
        // Brand color filling the card evenly — slightly stronger at the edges
        // than the center, but the center stays clearly tinted (never hollow),
        // so the whole surface reads as one harmonious wash.
        gradient: RadialGradient(
          radius: 1.0,
          colors: [
            colors.primary.withValues(alpha: context.isDark ? 0.14 : 0.09),
            colors.primary.withValues(alpha: context.isDark ? 0.22 : 0.14),
          ],
        ),
        borderRadius: KasyRadius.lgBorderRadius,
        // Soft primary outline.
        border: Border.all(
          color: colors.primary.withValues(alpha: context.isDark ? 0.38 : 0.30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: context.textTheme.labelSmall?.copyWith(
              // Label stays on primary so it still reads as a brand tag in
              // light; in dark primary-on-tint is too low-contrast, so lift
              // to onSurface (near-white).
              color: context.isDark ? colors.onSurface : colors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: context.textTheme.bodySmall?.copyWith(
              // Body must stay readable on the dark primary wash: use
              // onSurface in dark, keep primary in light (already fine).
              color: context.isDark ? colors.onSurface : colors.primary,
              fontWeight: FontWeight.w600,
              height: 1.38,
            ),
          ),
        ],
      ),
    );
  }
}

/// A thin, hand‑drawn curved arrow that *draws itself in* — the stroke traces
/// along its path, then the arrowhead pops at the tip. [flip] mirrors it;
/// [progress] (0→1) is driven by the parent timeline so the arrows trace in
/// sequence with the rest of the scene.
class _CurvedArrow extends StatelessWidget {
  const _CurvedArrow({this.flip = false, required this.progress});

  final bool flip;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 36,
      child: CustomPaint(
        painter: _CurvedArrowPainter(
          color: context.colors.muted.withValues(alpha: 0.6),
          flip: flip,
          progress: progress,
        ),
      ),
    );
  }
}

class _CurvedArrowPainter extends CustomPainter {
  _CurvedArrowPainter({
    required this.color,
    required this.flip,
    required this.progress,
  });

  final Color color;
  final bool flip;

  /// 0 → nothing drawn, 1 → full arrow (stroke first, then arrowhead).
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    if (flip) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final start = Offset(size.width * 0.14, size.height * 0.06);
    final c1 = Offset(size.width * 0.08, size.height * 0.74);
    final c2 = Offset(size.width * 0.52, size.height * 0.64);
    final end = Offset(size.width * 0.84, size.height * 0.9);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);

    // Stroke grows over the first ~82% of progress; the head fades in last.
    final double lineT = (progress / 0.82).clamp(0.0, 1.0);
    final double headT = ((progress - 0.78) / 0.22).clamp(0.0, 1.0);

    final metric = path.computeMetrics().first;
    canvas.drawPath(metric.extractPath(0, metric.length * lineT), paint);

    if (headT > 0) {
      const headLen = 7.0;
      const spread = 0.5;
      final angle = math.atan2(end.dy - c2.dy, end.dx - c2.dx);
      final p1 = end -
          Offset(math.cos(angle - spread) * headLen,
              math.sin(angle - spread) * headLen);
      final p2 = end -
          Offset(math.cos(angle + spread) * headLen,
              math.sin(angle + spread) * headLen);
      final headPaint = Paint()
        ..color = color.withValues(alpha: color.a * headT)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(
        Path()
          ..moveTo(p1.dx, p1.dy)
          ..lineTo(end.dx, end.dy)
          ..lineTo(p2.dx, p2.dy),
        headPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CurvedArrowPainter old) =>
      old.color != color || old.flip != flip || old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────
// Authentication
// ─────────────────────────────────────────────────────────────────────────

class AuthMockup extends StatefulWidget {
  const AuthMockup({super.key});

  @override
  State<AuthMockup> createState() => _AuthMockupState();
}

class _AuthMockupState extends State<AuthMockup>
    with SingleTickerProviderStateMixin {
  // A LIVE mini physics scene (no package): provider-logo balls rain in (in
  // waves, the last few slower), bounce, collide and settle into a natural,
  // never-overlapping pile. Then ANY ball can be dragged (finger or mouse) and
  // it shoves the others around. Plain circle gravity + collision resolution.
  static const double _w = 340; // sim space (also the gesture box)
  static const double _h = 300;
  static const double _r = 20; // ball radius (logo disc = 40)
  static const double _gravity = 2000; // px/s²
  static const double _slop = 1.0; // allowed overlap → kills resting jitter
  static const double _velDamp = 0.98; // velocity bleed (energy loss)
  static const double _restSpeed = 9; // snap velocities below this to zero
  static const double _sleepSpeed = 6; // settle threshold → stop ticking

  late final List<_Ball> _balls;
  late final _ticker = createTicker(_onTick);
  Duration _last = Duration.zero;
  int _elapsedMs = 0;
  int _spawned = 0;
  int? _held; // index of the dragged ball
  Offset _pointer = Offset.zero;
  double _lastHapticMs = -1000;

  // Dragging the pile keeps the physics loop running on every touch. On weaker
  // devices (all Android, and older iPhones) that's a needless battery/CPU draw
  // for a hero animation, so there the balls just rain in and settle — no drag.
  // Desktop/web and modern iPhones (12+) keep the playful interaction.
  bool _interactive = true;

  @override
  void initState() {
    super.initState();
    _balls = _buildBalls();
    _resolveInteractivity();
    _ticker.start();
  }

  /// Decide whether the pile is draggable, by platform/device class:
  ///   • web & desktop → yes
  ///   • Android       → no
  ///   • iOS           → only iPhone 12 and newer (iPhone13,x and up); older
  ///                     iPhones and unknowns stay non‑interactive.
  /// iPads/simulators (no `iPhoneN,M` machine id) keep it on — they're capable.
  Future<void> _resolveInteractivity() async {
    if (kIsWeb) return; // web preview: keep it interactive
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        if (mounted) setState(() => _interactive = false);
      case TargetPlatform.iOS:
        bool ok = true;
        try {
          final IosDeviceInfo info = await DeviceInfoPlugin().iosInfo;
          ok = _isModernIPhone(info.utsname.machine);
        } catch (_) {
          ok = false; // can't tell → play it safe on mobile
        }
        if (mounted) setState(() => _interactive = ok);
      default:
        break; // macOS/Windows/Linux: stays interactive
    }
  }

  /// `machine` is the hardware id, e.g. "iPhone14,5". iPhone 12 == iPhone13,1,
  /// so a leading model number ≥ 13 means iPhone 12 or newer. Non‑iPhone ids
  /// (iPad, iPod, simulator) return true (treated as capable).
  bool _isModernIPhone(String machine) {
    final RegExpMatch? m = RegExp(r'^iPhone(\d+),').firstMatch(machine);
    if (m == null) return true;
    return (int.tryParse(m.group(1)!) ?? 0) >= 13;
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  /// Balls enter from above in WAVES (a first burst, then smaller groups; the
  /// last few much slower), spread across the width with the slow tail biased
  /// toward the right.
  List<_Ball> _buildBalls() {
    const List<String> kinds = <String>['google', 'apple', 'facebook'];
    const List<(int, int)> waves = <(int, int)>[
      (12, 26), (8, 38), (8, 50), (7, 70), (5, 120), (4, 170), (2, 240),
    ]; // 46 balls; (count, gap-ms between spawns)
    const int wavePause = 120;
    const int total = 46;
    const double usable = _w - 2 * _r - 24;
    final List<_Ball> out = <_Ball>[];
    int t = 0;
    int i = 0;
    for (final (int count, int gap) in waves) {
      for (int k = 0; k < count; k++) {
        final bool tail = i >= total - 8; // last 8 → bias right
        final double frac = tail
            ? 0.5 + ((i * 53) % 50) / 100.0
            : ((i * 97) % 1000) / 1000.0;
        final double x = (_r + 12 + frac * usable).clamp(_r + 2, _w - _r - 2);
        out.add(
          _Ball(
            kind: kinds[i % 3],
            rot: (((i * 53) % 30) - 15) * math.pi / 180,
            spawnMs: t,
            spawnX: x,
          ),
        );
        t += gap;
        i++;
      }
      t += wavePause;
    }
    return out;
  }

  void _onTick(Duration elapsed) {
    final double dt = _last == Duration.zero
        ? 1 / 60
        : ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 1 / 30);
    _last = elapsed;
    _elapsedMs = elapsed.inMilliseconds;
    _step(dt);
    setState(() {});
    if (_held == null && _spawned == _balls.length && _isAsleep()) {
      _ticker.stop();
    }
  }

  bool _isAsleep() {
    for (final _Ball b in _balls) {
      if (!b.active) continue;
      if (b.vx.abs() > _sleepSpeed || b.vy.abs() > _sleepSpeed) return false;
    }
    return true;
  }

  void _wake() {
    if (!_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  void _step(double dt) {
    if (dt <= 0) return;
    // Spawn balls whose time has come (drop in from just above the top edge).
    for (final _Ball b in _balls) {
      if (!b.active && _elapsedMs >= b.spawnMs) {
        b.active = true;
        b.x = b.spawnX;
        b.y = -_r;
        b.prevX = b.spawnX;
        b.prevY = -_r - 4; // implies a small initial downward velocity
        _spawned++;
      }
    }
    // PBD predict: remember where it was, then move under gravity — or stick the
    // held ball to the pointer.
    for (int i = 0; i < _balls.length; i++) {
      final _Ball b = _balls[i];
      if (!b.active) continue;
      b.prevX = b.x;
      b.prevY = b.y;
      if (i == _held) {
        b.x = _pointer.dx.clamp(_r, _w - _r);
        b.y = _pointer.dy.clamp(_r, _h - _r);
      } else {
        b.vy += _gravity * dt;
        b.x += b.vx * dt;
        b.y += b.vy * dt;
      }
    }
    // Resolve constraints by moving POSITIONS only (no restitution → no jitter):
    // separate overlapping balls, leaving a tiny [_slop] so a resting pile stops
    // fighting gravity, then clamp to the walls/floor.
    for (int iter = 0; iter < 6; iter++) {
      for (int a = 0; a < _balls.length; a++) {
        final _Ball ba = _balls[a];
        if (!ba.active) continue;
        for (int c = a + 1; c < _balls.length; c++) {
          final _Ball bb = _balls[c];
          if (!bb.active) continue;
          final double dx = bb.x - ba.x;
          final double dy = bb.y - ba.y;
          final double d2 = dx * dx + dy * dy;
          const double minD = 2 * _r;
          if (d2 >= minD * minD || d2 < 0.0001) continue;
          final double d = math.sqrt(d2);
          final double push = minD - d - _slop;
          if (push <= 0) continue;
          final double nx = dx / d;
          final double ny = dy / d;
          if (a == _held) {
            bb.x += nx * push;
            bb.y += ny * push;
          } else if (c == _held) {
            ba.x -= nx * push;
            ba.y -= ny * push;
          } else {
            ba.x -= nx * push * 0.5;
            ba.y -= ny * push * 0.5;
            bb.x += nx * push * 0.5;
            bb.y += ny * push * 0.5;
          }
        }
      }
      for (final _Ball b in _balls) {
        if (!b.active) continue;
        if (b.x < _r) b.x = _r;
        if (b.x > _w - _r) b.x = _w - _r;
        if (b.y > _h - _r) b.y = _h - _r; // floor (no ceiling)
      }
    }
    // Derive velocity from the ACTUAL movement. A wedged ball barely moved →
    // velocity ≈ 0 → it rests firmly instead of vibrating.
    for (int i = 0; i < _balls.length; i++) {
      final _Ball b = _balls[i];
      if (!b.active || i == _held) continue;
      double nvx = (b.x - b.prevX) / dt * _velDamp;
      double nvy = (b.y - b.prevY) / dt * _velDamp;
      if (nvx.abs() < _restSpeed) nvx = 0;
      if (nvy.abs() < _restSpeed) nvy = 0;
      b.vx = nvx;
      b.vy = nvy;
      // Light haptic the first time a ball comes to rest after its drop.
      if (!b.landed &&
          _elapsedMs > b.spawnMs + 150 &&
          nvx.abs() < 28 &&
          nvy.abs() < 28) {
        b.landed = true;
        if (_elapsedMs - _lastHapticMs > 70) {
          _lastHapticMs = _elapsedMs.toDouble();
          KasyHaptics.light(context);
        }
      }
    }
    if (_held != null) {
      final _Ball b = _balls[_held!];
      b.vx = (b.x - b.prevX) / dt;
      b.vy = (b.y - b.prevY) / dt;
    }
  }

  void _grabAt(Offset p) {
    // Topmost ball under the pointer (search from the front of the pile).
    for (int i = _balls.length - 1; i >= 0; i--) {
      final _Ball b = _balls[i];
      if (!b.active) continue;
      final double dx = p.dx - b.x;
      final double dy = p.dy - b.y;
      if (dx * dx + dy * dy <= _r * _r * 1.7) {
        _held = i;
        _pointer = p;
        _lastHapticMs = -1000;
        _wake();
        return;
      }
    }
  }

  String _assetFor(String kind, String appleAsset) => switch (kind) {
        'google' => 'assets/icons/google.svg',
        'facebook' => 'assets/icons/facebook.svg',
        _ => appleAsset,
      };

  @override
  Widget build(BuildContext context) {
    // The login screen swaps the Apple logo by theme (white on dark surfaces).
    final String appleAsset = context.isDark
        ? 'assets/icons/apple_white.svg'
        : 'assets/icons/apple_black.svg';

    final Widget stack = Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        for (final _Ball b in _balls)
          if (b.active)
            Transform.translate(
              offset: Offset(b.x - _r, b.y - _r),
              child: Opacity(
                // Fade in as it drops in from the top edge.
                opacity: ((b.y + _r) / 70).clamp(0.0, 1.0),
                child: Transform.rotate(
                  angle: b.rot,
                  child: _LogoBall(
                    asset: _assetFor(b.kind, appleAsset),
                    size: _r * 2,
                  ),
                ),
              ),
            ),
      ],
    );

    return _MockStage(
      maxWidth: _w,
      showGlow: false,
      child: SizedBox(
        width: _w,
        height: _h,
        // On weaker devices the pile is non‑interactive: just render the balls.
        child: !_interactive
            ? stack
            : GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanDown: (DragDownDetails d) => _grabAt(d.localPosition),
                onPanUpdate: (DragUpdateDetails d) {
                  if (_held == null) return;
                  _pointer = d.localPosition;
                  _wake();
                },
                onPanEnd: (_) => _held = null,
                onPanCancel: () => _held = null,
                child: stack,
              ),
      ),
    );
  }
}

/// One ball in the live physics scene: which provider logo, a fixed tilt, when
/// it spawns and from where, plus its live position / velocity.
class _Ball {
  _Ball({
    required this.kind,
    required this.rot,
    required this.spawnMs,
    required this.spawnX,
  });

  final String kind;
  final double rot; // fixed visual tilt (radians)
  final int spawnMs; // when it enters from the top
  final double spawnX; // x it drops from

  double x = 0; // live centre
  double y = 0;
  double prevX = 0; // position last frame (PBD velocity derivation)
  double prevY = 0;
  double vx = 0;
  double vy = 0;
  bool active = false;
  bool landed = false; // fired its "came to rest" haptic yet?
}

/// A circular ball holding a provider's brand logo (the SVG the login screen
/// uses). Purely presentational — the fall and rotation are applied by the
/// caller; this just draws the disc + centered logo.
class _LogoBall extends StatelessWidget {
  const _LogoBall({required this.asset, required this.size});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: context.isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.32 : 0.14),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: SvgPicture.asset(asset, width: size * 0.46, height: size * 0.46),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// AI assistant (a chat that types itself out)
// ─────────────────────────────────────────────────────────────────────────

/// A self‑playing AI‑assistant conversation, mirroring the kit's built‑in chat
/// module. Messages appear one after another (user → assistant → …) with a
/// smooth fade/slide — no typing indicator.
class AiChatMockup extends StatefulWidget {
  const AiChatMockup({super.key});

  @override
  State<AiChatMockup> createState() => _AiChatMockupState();
}

class _ChatBubbleItem {
  _ChatBubbleItem({
    required this.controller,
    required this.fromUser,
    required this.text,
  });

  final AnimationController controller;
  final bool fromUser;
  final String text;
}

class _AiChatMockupState extends State<AiChatMockup>
    with TickerProviderStateMixin {
  static const int _messageCount = 4;
  static const Duration _initialDelay = Duration(milliseconds: 220);
  static const Duration _interval = Duration(milliseconds: 820);

  final List<_ChatBubbleItem> _items = [];

  Timer? _timer;
  int _nextIndex = 0;
  List<({bool fromUser, String text})>? _script;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_initialDelay, _showNextMessage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_script != null) return;
    final t = Translations.of(context).onboarding.mockups.ai_chat;
    _script = [
      (fromUser: true, text: t.u1),
      (fromUser: false, text: t.a1),
      (fromUser: true, text: t.u2),
      (fromUser: false, text: t.a2),
    ];
  }

  void _showNextMessage() {
    if (!mounted || _script == null) return;
    if (_nextIndex >= _messageCount) {
      _timer?.cancel();
      return;
    }

    final spec = _script![_nextIndex++];
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );

    setState(() {
      _items.add(_ChatBubbleItem(
        controller: controller,
        fromUser: spec.fromUser,
        text: spec.text,
      ));
    });

    unawaited(KasyHaptics.light(context));
    controller.forward();

    _timer = Timer(_interval, _showNextMessage);
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final item in _items) {
      item.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _MockStage(
      maxWidth: 330,
      showGlow: false,
      child: SizedBox(
        width: 300,
        height: 280,
        child: Align(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final item in _items)
                _AnimatedChatRow(
                  key: ValueKey(item),
                  item: item,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedChatRow extends StatelessWidget {
  const _AnimatedChatRow({super.key, required this.item});

  final _ChatBubbleItem item;

  @override
  Widget build(BuildContext context) {
    final slide = Tween<Offset>(
      begin: Offset(item.fromUser ? 0.14 : -0.1, 0.16),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: item.controller,
      curve: Curves.easeOutCubic,
    ));

    final fade = CurvedAnimation(
      parent: item.controller,
      curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: SlideTransition(
        position: slide,
        child: FadeTransition(
          opacity: fade,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: item.fromUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (!item.fromUser) ...[
                const _AssistantLogo(),
                const SizedBox(width: 8),
              ],
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: _ChatBubble(
                  fromUser: item.fromUser,
                  text: item.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssistantLogo extends StatelessWidget {
  const _AssistantLogo();

  static const String _asset = 'assets/branding/app-icon.png';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: Image.asset(
        _asset,
        width: 28,
        height: 28,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) {
          final colors = context.colors;
          return Container(
            width: 28,
            height: 28,
            color: colors.primary.withValues(alpha: 0.14),
            alignment: Alignment.center,
            child: Icon(
              Icons.smart_toy_outlined,
              size: 16,
              color: colors.primary,
            ),
          );
        },
      ),
    );
  }
}

/// A single chat bubble: filled brand color for the user (right), a clean
/// surface card for the assistant (left), each with the tail corner tightened
/// toward its sender.
class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.fromUser, required this.text});

  final bool fromUser;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const Radius r = Radius.circular(18);
    const Radius tail = Radius.circular(6);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.smd,
        vertical: KasySpacing.sm,
      ),
      decoration: BoxDecoration(
        color: fromUser ? colors.primary : colors.surface,
        borderRadius: BorderRadius.only(
          topLeft: r,
          topRight: r,
          bottomLeft: fromUser ? r : tail,
          bottomRight: fromUser ? tail : r,
        ),
        border: fromUser
            ? null
            : Border.all(
                color: context.isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.black.withValues(alpha: 0.06),
              ),
        boxShadow: [
          BoxShadow(
            color: fromUser
                ? colors.primary.withValues(alpha: 0.28)
                : Colors.black.withValues(alpha: context.isDark ? 0.26 : 0.07),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        text,
        style: context.textTheme.bodySmall?.copyWith(
          color: fromUser ? colors.onPrimary : colors.onSurface,
          fontWeight: FontWeight.w500,
          height: 1.32,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Notifications (push toast stack)
// ─────────────────────────────────────────────────────────────────────────

class NotificationsMockup extends StatelessWidget {
  const NotificationsMockup({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final t = Translations.of(context).onboarding.mockups.notification;
    return _MockStage(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Faded card behind for depth.
          Transform.translate(
            offset: const Offset(0, 14),
            child: Transform.scale(
              scale: 0.92,
              child: const Opacity(
                opacity: 0.5,
                child: _Card(
                  child: SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: Row(
                      children: [
                        _Bar(width: 32, height: 32),
                        SizedBox(width: KasySpacing.smd),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Bar(width: 120, strong: true),
                            SizedBox(height: 6),
                            _Bar(width: 80),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          _Card(
            child: Row(
              children: [
                const _IconBadge(KasyIcons.notificationActive, glyph: 18),
                const SizedBox(width: KasySpacing.smd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              t.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.titleSmall?.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            t.time,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: colors.muted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const _Bar(width: 160),
                      const SizedBox(height: 6),
                      const _Bar(width: 110),
                    ],
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
