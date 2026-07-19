import 'dart:ui' as ui show lerpDouble;

import 'package:cowboydodartinc/components/kasy_avatar_presets.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_focus_ring.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Logical sizes for [KasyAvatar] (diameter in logical pixels).
enum KasyAvatarSize {
  small(40),
  medium(54),
  large(70);

  const KasyAvatarSize(this.diameter);
  final double diameter;
}

/// Accent palette for text / icon fallbacks.
enum KasyAvatarTone { blue, neutral, green, orange, red }

/// Surface treatment for fallback content (initials / icon).
enum KasyAvatarFallbackSurface { default_, soft }

/// Clip shape for photo avatars.
enum KasyAvatarShape { circle, roundedSquare }

/// Online / presence indicator (drawn at bottom-trailing).
enum KasyAvatarStatus { online }

/// Design-system avatar: image, initials, icon, gradient, or custom child.
///
/// Decorative linear fills: optional [KasyAvatarGradients] (barrel presets).
class KasyAvatar extends StatelessWidget {
  final KasyAvatarSize size;

  /// When set, overrides [KasyAvatarSize.diameter] (e.g. grouped stacks).
  final double? diameter;
  final ImageProvider? image;
  final String? initials;
  final IconData? icon;
  final Widget? customChild;
  final KasyAvatarTone tone;
  final KasyAvatarFallbackSurface fallbackSurface;
  final KasyAvatarShape shape;
  final bool showShadow;
  final bool showStoryRing;
  final Gradient? storyRingGradient;
  final KasyAvatarStatus? status;
  final KasyAvatarGradientData? backgroundGradient;
  final VoidCallback? onTap;
  final String? semanticLabel;

  const KasyAvatar({
    super.key,
    this.size = KasyAvatarSize.medium,
    this.diameter,
    this.image,
    this.initials,
    this.icon,
    this.customChild,
    this.tone = KasyAvatarTone.blue,
    this.fallbackSurface = KasyAvatarFallbackSurface.default_,
    this.shape = KasyAvatarShape.circle,
    this.showShadow = false,
    this.showStoryRing = false,
    this.storyRingGradient,
    this.status,
    this.backgroundGradient,
    this.onTap,
    this.semanticLabel,
  });

  /// Gradient fill only (e.g. size showcase / decorative).
  factory KasyAvatar.gradientFill({
    Key? key,
    required KasyAvatarSize size,
    required KasyAvatarGradientData gradient,
    double? diameter,
    bool showShadow = true,
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    return KasyAvatar(
      key: key,
      size: size,
      diameter: diameter,
      backgroundGradient: gradient,
      showShadow: showShadow,
      onTap: onTap,
      semanticLabel: semanticLabel,
    );
  }

  double get _d => diameter ?? size.diameter;

  @override
  Widget build(BuildContext context) {
    final Widget core = SizedBox(
      width: _d,
      height: _d,
      child: _buildCore(context),
    );
    final Widget disk = showStoryRing && shape == KasyAvatarShape.circle
        ? _storyRingWrap(context, core)
        : _clip(context, core);
    Widget body = disk;
    if (showShadow) {
      body = DecoratedBox(
        decoration: BoxDecoration(
          shape: shape == KasyAvatarShape.circle
              ? BoxShape.circle
              : BoxShape.rectangle,
          borderRadius: shape == KasyAvatarShape.roundedSquare
              ? BorderRadius.circular(_d * 0.32)
              : null,
          boxShadow: [KasyShadows.component(context)],
        ),
        child: disk,
      );
    }
    if (status != null) {
      body = _statusWrap(context, body);
    }
    if (onTap == null) {
      return _maybeSemantics(body);
    }
    return _KasyAvatarPressable(
      onPressed: onTap!,
      semanticLabel: semanticLabel ?? 'Avatar',
      minSide: _d < 44 ? 44.0 : _d,
      child: body,
    );
  }

  Widget _maybeSemantics(Widget child) {
    if (semanticLabel == null) {
      return child;
    }
    return Semantics(label: semanticLabel, child: child);
  }

  Widget _buildCore(BuildContext context) {
    if (customChild != null) {
      return SizedBox(
        width: _d,
        height: _d,
        child: Center(child: customChild),
      );
    }
    if (image != null) {
      return Image(
        image: image!,
        width: _d,
        height: _d,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
        // Placeholder only until the first frame. Do NOT stack fallback under
        // the image: transparent PNGs (wordmarks / icons with alpha) would
        // show both layers and look like a double logo.
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) return child;
          return SizedBox(
            width: _d,
            height: _d,
            child: _fallbackContent(context, useIcon: icon != null),
          );
        },
        errorBuilder: (context, error, stack) =>
            _fallbackContent(context, useIcon: true),
      );
    }
    if (backgroundGradient != null) {
      final String? initialsRaw = initials?.trim();
      return Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _AvatarOrbPainter(backgroundGradient!)),
          if (initialsRaw != null && initialsRaw.isNotEmpty)
            Center(
              child: Text(
                _twoInitials(initialsRaw),
                style: context.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: _d * 0.34,
                  height: 1,
                ),
              ),
            ),
        ],
      );
    }
    final String? t = initials?.trim();
    if (t != null && t.isNotEmpty) {
      return _fallbackContent(context, label: _twoInitials(t));
    }
    return _fallbackContent(context, useIcon: true);
  }

  String _twoInitials(String raw) {
    final List<String> parts = raw
        .split(RegExp(r'\s+'))
        .where((String e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return '';
    }
    if (parts.length == 1) {
      final String w = parts.first;
      return w.length >= 2 ? w.substring(0, 2).toUpperCase() : w.toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Widget _fallbackContent(
    BuildContext context, {
    String? label,
    bool useIcon = false,
  }) {
    final _KasyAvatarColors c = _colorsForTone(context, tone, fallbackSurface);
    final Color bg = c.background;
    final Color fg = c.foreground;
    if (useIcon) {
      final IconData glyph = icon ?? KasyIcons.person;
      return ColoredBox(
        color: bg,
        child: Center(
          child: Icon(glyph, size: _d * 0.444, color: fg),
        ),
      );
    }
    return ColoredBox(
      color: bg,
      child: Center(
        child: Text(
          label ?? '',
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w500,
            fontSize: _d * 0.333,
            height: 1,
            leadingDistribution: TextLeadingDistribution.even,
          ),
        ),
      ),
    );
  }

  Widget _clip(BuildContext context, Widget child) {
    if (shape == KasyAvatarShape.circle) {
      return ClipOval(child: child);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(_d * 0.32),
      child: child,
    );
  }

  Widget _storyRingWrap(BuildContext context, Widget core) {
    final Gradient ring =
        storyRingGradient ??
        const LinearGradient(
          colors: [Color(0xFFFF6B9D), Color(0xFFFF9F43), Color(0xFFFFE066)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    final Color innerDisc = context.colors.surface;
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: ring),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(color: innerDisc, shape: BoxShape.circle),
        child: ClipOval(
          child: SizedBox(width: _d, height: _d, child: core),
        ),
      ),
    );
  }

  Widget _statusWrap(BuildContext context, Widget inner) {
    final double badge = (_d * 0.26).clamp(11.0, 16.0);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        inner,
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: badge,
            height: badge,
            decoration: BoxDecoration(
              color: context.colors.success,
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.surface, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

/// Horizontal stacked avatars with [KasyColors.surface] separation ring,
/// optional +N counter, and optional add-action button.
///
/// Set [onAdd] to show the "+" button at the end (12 px gap, per Figma spec).
class KasyAvatarGroup extends StatelessWidget {
  final List<Widget> avatars;
  final int maxVisible;
  final int extraCount;
  final double overlapFactor;
  final bool showShadow;
  final double itemDiameter;

  /// When non-null a circular "+" button is shown after the group.
  final VoidCallback? onAdd;

  const KasyAvatarGroup({
    super.key,
    required this.avatars,
    this.maxVisible = 4,
    this.extraCount = 0,
    this.overlapFactor = 0.28,
    this.showShadow = false,
    this.itemDiameter = 48,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final int n = avatars.length.clamp(0, maxVisible);
    final double d = itemDiameter;
    final double step = d * (1 - overlapFactor);
    final int showCounter = extraCount > 0 ? 1 : 0;
    final int totalSlots = n + showCounter;
    final double stackW = totalSlots <= 0 ? 0 : step * (totalSlots - 1) + d + 4;

    final Widget stack = SizedBox(
      width: stackW,
      height: d + 4,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < n; i++)
            Positioned(
              left: i * step,
              top: 0,
              child: _ringWrap(context, d, avatars[i], showShadow),
            ),
          if (showCounter > 0)
            Positioned(
              left: n * step,
              top: 0,
              child: _ringWrap(
                context,
                d,
                ColoredBox(
                  color: context.colors.avatarFallbackFill,
                  child: Center(
                    child: Text(
                      '+$extraCount',
                      style: TextStyle(
                        color: context.isDark
                            ? const Color(0xFFFCFCFC)
                            : const Color(0xFF18181B),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        height: 16 / 12,
                        leadingDistribution: TextLeadingDistribution.even,
                      ),
                    ),
                  ),
                ),
                showShadow,
              ),
            ),
        ],
      ),
    );

    if (onAdd == null) return stack;

    // Add-action button: circle with "+" icon, 12 px gap (Figma layout_EJ08D4).
    final Widget addBtn = _KasyAvatarPressable(
      onPressed: onAdd!,
      semanticLabel: 'Add member',
      minSide: d < 44 ? 44.0 : d,
      child: Container(
        width: d,
        height: d,
        decoration: BoxDecoration(
          color: context.colors.avatarFallbackFill,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            KasyIcons.add,
            size: d * 0.444,
            color: context.colors.primary,
          ),
        ),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [stack, const SizedBox(width: 12), addBtn],
    );
  }

  Widget _ringWrap(BuildContext context, double d, Widget child, bool shadow) {
    return Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.surface, width: 2.0),
        boxShadow: shadow ? [KasyShadows.component(context)] : null,
      ),
      child: ClipOval(
        child: SizedBox(width: d, height: d, child: child),
      ),
    );
  }
}

class _KasyAvatarColors {
  final Color background;
  final Color foreground;

  const _KasyAvatarColors({required this.background, required this.foreground});
}

_KasyAvatarColors _colorsForTone(
  BuildContext context,
  KasyAvatarTone tone,
  KasyAvatarFallbackSurface fallbackSurface,
) {
  final KasyColors k = context.colors;
  final bool dark = context.isDark;

  // Accent color per tone, from the global theme tokens: the "blue" tone maps
  // to the primary accent, success/warning/danger to their semantic tokens,
  // neutral to the foreground.
  Color accentColor() => switch (tone) {
    KasyAvatarTone.blue    => k.primary,
    KasyAvatarTone.neutral => k.grey3,
    KasyAvatarTone.green   => k.success,
    KasyAvatarTone.orange  => k.warning,
    KasyAvatarTone.red     => k.error,
  };

  // Solid surface: all types share the same #EBEBEC bg (Figma fill_J18KAR).
  // Foreground: neutral → onSurface (#18181B light), others → accent color.
  if (fallbackSurface == KasyAvatarFallbackSurface.default_) {
    final Color fg = tone == KasyAvatarTone.neutral
        ? k.onSurface
        : accentColor();
    return _KasyAvatarColors(background: k.avatarFallbackFill, foreground: fg);
  }

  // Neutral soft = same as neutral solid (Figma: no tint for default type).
  if (tone == KasyAvatarTone.neutral) {
    return _KasyAvatarColors(
      background: k.avatarFallbackFill,
      foreground: k.onSurface,
    );
  }

  // Colored soft: rgba(accent, 0.15) blended over surface (white light / dark).
  // Figma fill_MVOTCC: rgba(4,133,247,0.15) + #FFFFFF light
  //                    rgba(4,133,247,0.15) + #18181B dark
  // Foreground: pure accent color (Figma uses raw accent even in soft).
  final Color a = accentColor();
  final Color base = dark ? k.surface : const Color(0xFFFFFFFF);
  final Color bg = Color.alphaBlend(a.withValues(alpha: 0.15), base);
  return _KasyAvatarColors(background: bg, foreground: a);
}

// ─────────────────────────────────────────────────────────────────────────────
// Orb painter
// ─────────────────────────────────────────────────────────────────────────────

/// Renders the HeroUI-style orb effect: a soft linear-gradient background
/// plus a blurred sphere in the lower-center, using geometry extracted from
/// the Figma SVGs (all 14 presets share identical shape, only colors differ).
class _AvatarOrbPainter extends CustomPainter {
  final KasyAvatarGradientData data;

  const _AvatarOrbPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    // Background: linear gradient top → bottom.
    final Rect rect = Offset.zero & size;
    final Paint bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [data.bgTop, data.bgBottom],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // Orb: blurred circle with diagonal linear gradient.
    // Geometry normalised from 80x80 px Figma SVG:
    //   center = (45.625, 52.5)  → (0.5703 w, 0.6563 h)
    //   radius = 27.5            → 0.344 w
    //   blur   = stdDeviation 7.8125 → 0.0977 w
    final Offset center = Offset(
      size.width * 0.5703,
      size.height * 0.6563,
    );
    final double radius = size.width * 0.344;
    final double blurSigma = size.width * 0.0977;

    // Gradient aligned to the orb bounding box.
    final Rect orbRect = Rect.fromCircle(center: center, radius: radius);
    final Paint orbPaint = Paint()
      ..shader = LinearGradient(
        begin: const Alignment(-0.24, 0.0),
        end: const Alignment(0.75, 1.21),
        colors: [data.orbTop, data.orbBottom],
      ).createShader(orbRect)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);

    canvas.drawCircle(center, radius, orbPaint);
  }

  @override
  bool shouldRepaint(_AvatarOrbPainter old) => data != old.data;
}

// ─────────────────────────────────────────────────────────────────────────────
// Pressable wrapper
// ─────────────────────────────────────────────────────────────────────────────

class _KasyAvatarPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final String semanticLabel;
  final double minSide;

  const _KasyAvatarPressable({
    required this.child,
    required this.onPressed,
    required this.semanticLabel,
    required this.minSide,
  });

  @override
  State<_KasyAvatarPressable> createState() => _KasyAvatarPressableState();
}

class _KasyAvatarPressableState extends State<_KasyAvatarPressable>
    with SingleTickerProviderStateMixin {
  static const double _pressIn = 0.94;
  static const double _releasePeak = 1.03;
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double get _s {
    final double t = _c.value.clamp(0.0, 1.0);
    if (t <= 0.28) {
      return ui.lerpDouble(1.0, _pressIn, t / 0.28)!;
    }
    if (t <= 0.55) {
      return ui.lerpDouble(_pressIn, _releasePeak, (t - 0.28) / 0.27)!;
    }
    return ui.lerpDouble(_releasePeak, 1.0, (t - 0.55) / 0.45)!;
  }

  void _tap() {
    widget.onPressed();
    _c.forward(from: 0).whenComplete(() {
      if (mounted) {
        _c.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget inner = Semantics(
      button: true,
      label: widget.semanticLabel,
      child: KasyFocusRing(
        onActivate: _tap,
        // The avatar is circular, so a large radius keeps the focus ring
        // hugging the circle (radius >= half the diameter).
        borderRadius: BorderRadius.circular(widget.minSide),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _tap,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: widget.minSide,
              minHeight: widget.minSide,
            ),
            child: Center(
              child: Transform.scale(scale: _s, child: widget.child),
            ),
          ),
        ),
      ),
    );
    if (!kIsWeb) return inner;
    return MouseRegion(cursor: SystemMouseCursors.click, child: inner);
  }
}
