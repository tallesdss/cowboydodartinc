import 'dart:async';

import 'package:cowboydodartinc/core/haptics/haptic_feedback_notifier.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_focus_ring.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Universal hover/press wrapper — works on any widget shape, any platform.
///
/// **Press feedback:** animated background fill + optional haptic. No Material
/// ripple. The pressed state persists for at least [_kMinPressDuration] so
/// it is always visible, even on quick taps.
///
/// **Hover feedback:** subtle overlay on pointer-capable devices (web,
/// desktop, trackpad). Has no visible effect on touch-only devices.
///
/// **Cursor:** [SystemMouseCursors.click] is set automatically on all
/// platforms that support pointer input.
///
/// ### Customising colours
///
/// - [pressColor] — tint base for the press overlay (defaults to
///   `onSurface`). Pass the surface accent colour (e.g. `primary`) to avoid
///   a mismatched gray cast on tinted backgrounds.
///
/// - [hoverColor] — exact solid background colour shown while the pointer is
///   over the widget. When set, **replaces** the default semi-transparent
///   overlay with a solid fill. Use this on navigation items where hover and
///   selected states must look identical (same bg, bolder text/icon in the
///   child widget signals selection). When null, falls back to a subtle
///   [pressColor]-tinted overlay.
///
/// Contrast with [KasyPressableDepth]: this component uses a background fill
/// while [KasyPressableDepth] uses a scale/depth animation.
class KasyHover extends ConsumerStatefulWidget {
  const KasyHover({
    super.key,
    required this.child,
    required this.onTap,
    this.padding,
    this.borderRadius = BorderRadius.zero,
    this.margin,
    this.semanticLabel,
    this.hapticEnabled = true,
    this.hoverEnabled = true,
    this.pressEnabled = true,
    this.hoverColor,
    this.pressColor,
    this.focusable = false,
    this.focusGapColor,
  });

  final Widget child;
  final VoidCallback onTap;

  /// Internal padding (rendered inside the feedback overlay area).
  final EdgeInsetsGeometry? padding;

  /// Corner radius of the feedback overlay. Match the value of the parent
  /// container so the pressed fill does not bleed outside the rounded shape.
  final BorderRadius borderRadius;

  /// External spacing (not covered by the feedback overlay).
  final EdgeInsetsGeometry? margin;

  /// Accessibility label for TalkBack / VoiceOver.
  final String? semanticLabel;

  /// Haptic on tap (automatically ignored on web).
  final bool hapticEnabled;

  /// Whether the pointer-hover overlay is shown on pointer-capable devices.
  ///
  /// When false, the resting/press feedback and click cursor are kept, but no
  /// background fill appears while hovering. Use on plain list rows (e.g.
  /// settings) where a hover highlight is visually unwanted.
  final bool hoverEnabled;

  /// Whether the pressed-state background fill is shown on tap.
  ///
  /// When false, tapping triggers [onTap] (and haptic/cursor) with no visible
  /// background highlight. Use on plain list rows (e.g. settings) where the tap
  /// should just navigate without leaving a grey flash behind.
  final bool pressEnabled;

  /// Exact background colour used while the pointer hovers over the widget.
  ///
  /// When non-null, this solid colour replaces the default semi-transparent
  /// overlay during hover. Ideal for navigation items: pass the same colour
  /// used for the selected state so hover and active look identical — the
  /// child widget is responsible for rendering the selected indicator (e.g.
  /// bolder text, accent icon colour).
  ///
  /// When null, a subtle [pressColor]-tinted overlay is used instead.
  final Color? hoverColor;

  /// Tint base for the press overlay.
  ///
  /// When null, falls back to [ColorScheme.onSurface] — a neutral dark/light
  /// overlay suited for plain surfaces.
  ///
  /// Pass the surface's accent colour (e.g. [KasyColors.primary]) when the
  /// background is already tinted so the feedback stays on-palette.
  final Color? pressColor;

  /// When true, the control becomes a keyboard tab-stop by wrapping its visual
  /// in the kit's [KasyFocusRing]: a focus ring appears during keyboard
  /// navigation (never on pointer/touch) and Enter/Space triggers [onTap].
  /// Pointer and touch behaviour are unchanged. Defaults to false so existing
  /// call sites stay plain, non-focusable rows.
  final bool focusable;

  /// Gap colour forwarded to the focus ring (only used when [focusable]). Pass
  /// the surface colour the row sits on so the keyboard ring's hair-line gap
  /// blends in instead of showing a darker halo (notably in dark mode). When
  /// null the ring falls back to [KasyColors.background].
  final Color? focusGapColor;

  @override
  ConsumerState<KasyHover> createState() => _KasyHoverState();
}

class _KasyHoverState extends ConsumerState<KasyHover> {
  // Minimum duration the pressed background stays visible — prevents an
  // imperceptible flash on very quick taps.
  static const Duration _kMinPressDuration = Duration(milliseconds: 160);

  bool _hovered = false;
  bool _pressed = false;
  Timer? _releaseTimer;

  @override
  void dispose() {
    _releaseTimer?.cancel();
    super.dispose();
  }

  Color _overlayColor(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color base = widget.pressColor ?? context.colors.onSurface;

    // Nav-item style: a solid hover/selected colour was provided. Keep the
    // resting, hover and pressed states on the SAME hue — only the intensity
    // changes, never the colour — so clicking never flashes.
    //
    // Resting must be that hue at alpha=0 (NOT Colors.transparent, which is
    // transparent *black*): an AnimatedContainer lerping from black-transparent
    // to a light solid passes through dark intermediates and flickers.
    // Press = the hover fill blended a touch deeper, so hover→press→hover stays
    // continuous instead of swapping to a different translucent overlay.
    if (widget.hoverColor != null) {
      if (_pressed && widget.pressEnabled) {
        return Color.alphaBlend(
          base.withValues(alpha: isDark ? 0.06 : 0.08),
          widget.hoverColor!,
        );
      }
      if (_hovered && widget.hoverEnabled) return widget.hoverColor!;
      return widget.hoverColor!.withValues(alpha: 0);
    }

    // Plain rows: a subtle translucent overlay that fades in on hover/press.
    if (_pressed && widget.pressEnabled) {
      return base.withValues(alpha: isDark ? 0.04 : 0.10);
    }
    if (_hovered && widget.hoverEnabled) {
      return base.withValues(alpha: isDark ? 0.02 : 0.06);
    }
    return Colors.transparent;
  }

  void _onTapDown(TapDownDetails _) {
    _releaseTimer?.cancel();
    setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    // Release is controlled by the timer in _handleTap so the pressed
    // state is always visible for at least _kMinPressDuration.
  }

  void _onTapCancel() {
    _releaseTimer?.cancel();
    setState(() => _pressed = false);
  }

  void _handleTap() {
    if (widget.hapticEnabled && !kIsWeb && ref.read(hapticFeedbackProvider)) {
      HapticFeedback.selectionClick();
    }
    widget.onTap();
    _releaseTimer = Timer(_kMinPressDuration, () {
      if (mounted) setState(() => _pressed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: _overlayColor(context),
        borderRadius: widget.borderRadius,
      ),
      padding: widget.padding,
      child: widget.child,
    );

    // Keyboard focus is owned by the kit's single focus indicator so Tab +
    // Enter/Space behave identically to login, signup and the chat send button.
    final Widget focusContent = widget.focusable
        ? KasyFocusRing(
            borderRadius: widget.borderRadius,
            onActivate: widget.onTap,
            gapColor: widget.focusGapColor,
            child: content,
          )
        : content;

    Widget interactive = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: focusContent,
    );

    // MouseRegion is active on all platforms:
    // - Web / desktop / trackpad: fires onEnter/onExit for real hover effects.
    // - Touch-only (iOS/Android): pointer events never fire, zero overhead.
    // The click cursor is also set universally so desktop feels native.
    interactive = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) {
        setState(() {
          _hovered = false;
          _pressed = false;
        });
      },
      child: interactive,
    );

    if (widget.semanticLabel != null) {
      interactive = Semantics(
        button: true,
        label: widget.semanticLabel,
        child: interactive,
      );
    }

    if (widget.margin != null) {
      return Padding(padding: widget.margin!, child: interactive);
    }
    return interactive;
  }
}
