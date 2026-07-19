import 'dart:async';

import 'package:cowboydodartinc/components/kasy_close_button.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_brand_logo.dart';
import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';

// ---------------------------------------------------------------------------
// Public types
// ---------------------------------------------------------------------------
/// Semantic tone of a [KasyToast].
enum KasyToastTone { neutral, primary, success, warning, danger }

/// Where the toast stack appears on screen.
enum KasyToastPlacement { top, bottom }

// ---------------------------------------------------------------------------
// KasyToast — visual widget (card)
// ---------------------------------------------------------------------------

/// The toast card widget. Can be embedded statically for previews;
/// for live use call [showKasyToast].
class KasyToast extends StatelessWidget {
  const KasyToast({
    super.key,
    required this.title,
    this.message,
    this.tone = KasyToastTone.neutral,
    this.icon,
    this.onClose,
    this.showCloseButton = true,
  });

  final String title;
  final String? message;
  final KasyToastTone tone;

  /// Custom leading widget (e.g. an app logo). Falls back to the tone's
  /// default icon when null.
  final Widget? icon;

  final VoidCallback? onClose;

  /// When false the trailing Close action is hidden (e.g. static previews).
  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    final _ToastStyle style = _resolveStyle(c, tone);

    // A toast must never render an empty title line. If a caller passes a blank
    // title (e.g. a short confirmation that only has a body), promote the
    // message to the title so it always reads as a clean single-line toast.
    final bool hasTitle = title.trim().isNotEmpty;
    final String shownTitle = hasTitle ? title : (message ?? '');
    final String? shownMessage = hasTitle ? message : null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: KasyRadius.lgBorderRadius,
        border: Border.all(color: c.borderSoft),
        boxShadow: KasyShadows.overlayPanel(context),
      ),
      child: Padding(
        padding: const EdgeInsets.all(KasySpacing.smd),
        child: Row(
          // Center everything for a single-line toast (no message) so nothing
          // sits low; top-align when a longer message wraps.
          crossAxisAlignment: shownMessage != null
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            _buildLeading(style),
            const SizedBox(width: KasySpacing.smd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    shownTitle,
                    // HeroUI Toast: title = Body sm medium (14 / w500), message
                    // = Body sm (14 / w400). titleSmall is already 14/w500, so
                    // no weight override — the 500-vs-400 carries the hierarchy.
                    style: context.textTheme.titleSmall?.copyWith(
                      color: c.onSurface,
                    ),
                  ),
                  if (shownMessage != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      shownMessage,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: c.muted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showCloseButton) ...[
              const SizedBox(width: KasySpacing.sm),
              KasyCloseButton(onPressed: onClose),
            ],
          ],
        ),
      ),
    );
  }

  /// The leading slot. A fully custom [icon] wins; otherwise the neutral tone
  /// shows the app brand logo (so it always matches the splash / current brand)
  /// and the semantic tones show a tone-coloured icon bubble.
  Widget _buildLeading(_ToastStyle style) {
    if (icon != null) return icon!;
    if (style.useBrandLogo) {
      return const SizedBox(
        height: 32,
        child: Center(child: KasyBrandLogo(height: 24)),
      );
    }
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: style.iconBubbleColor,
        shape: BoxShape.circle,
      ),
      child: Icon(style.icon, size: KasyIconSize.sm, color: style.iconColor),
    );
  }
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Shows a toast at the top or bottom of the screen and returns a callback to
/// dismiss it early. Toasts stack when called multiple times.
///
/// ```dart
/// showKasyToast(context,
///   title: 'Upload complete',
///   message: 'Your file has been saved.',
///   tone: KasyToastTone.success,
///   placement: KasyToastPlacement.bottom,
/// );
/// ```
VoidCallback showKasyToast(
  BuildContext context, {
  required String title,
  String? message,
  KasyToastTone tone = KasyToastTone.neutral,

  /// Custom leading widget — falls back to the tone's icon when null.
  Widget? icon,
  Duration duration = const Duration(seconds: 4),

  /// When true the toast persists until dismissed manually.
  bool persistent = false,
  VoidCallback? onClose,
  KasyToastPlacement placement = KasyToastPlacement.top,
}) {
  if (Platform.environment.containsKey('FLUTTER_TEST')) return () {};
  return _KasyToastManager.instance.show(
    context,
    _ToastData(
      title: title,
      message: message,
      tone: tone,
      icon: icon,
      duration: duration,
      persistent: persistent,
      onClose: onClose,
      placement: placement,
    ),
  );
}

/// Immediately dismisses every visible toast.
void hideAllKasyToasts() => _KasyToastManager.instance.hideAll();

/// Shows a fully custom toast built by [builder]. Returns a callback to
/// dismiss it early.
///
/// ```dart
/// showKasyToastWidget(context,
///   builder: (dismiss) => MyCustomToastCard(onClose: dismiss),
/// );
/// ```
VoidCallback showKasyToastWidget(
  BuildContext context, {
  required Widget Function(VoidCallback dismiss) builder,
  Duration duration = const Duration(seconds: 4),
  bool persistent = false,
  VoidCallback? onClose,
  KasyToastPlacement placement = KasyToastPlacement.top,
}) {
  if (Platform.environment.containsKey('FLUTTER_TEST')) return () {};
  return _KasyToastManager.instance.show(
    context,
    _ToastData(
      title: '',
      duration: duration,
      persistent: persistent,
      onClose: onClose,
      placement: placement,
      customBuilder: builder,
    ),
  );
}

// ---------------------------------------------------------------------------
// Internal data class
// ---------------------------------------------------------------------------

class _ToastData {
  const _ToastData({
    required this.title,
    this.message,
    this.tone = KasyToastTone.neutral,
    this.icon,
    this.duration = const Duration(seconds: 4),
    this.persistent = false,
    this.onClose,
    this.placement = KasyToastPlacement.top,
    this.customBuilder,
  });

  final String title;
  final String? message;
  final KasyToastTone tone;
  final Widget? icon;
  final Duration duration;
  final bool persistent;
  final VoidCallback? onClose;
  final KasyToastPlacement placement;

  /// When set, renders this widget instead of [KasyToast]. The callback
  /// passed to the builder dismisses the toast when called.
  final Widget Function(VoidCallback dismiss)? customBuilder;
}

// ---------------------------------------------------------------------------
// Singleton manager
// ---------------------------------------------------------------------------

class _KasyToastManager {
  _KasyToastManager._();
  static final _KasyToastManager instance = _KasyToastManager._();

  final Map<KasyToastPlacement, OverlayEntry?> _entries = {
    KasyToastPlacement.top: null,
    KasyToastPlacement.bottom: null,
  };

  final Map<KasyToastPlacement, _KasyToastLayerState?> _layers = {
    KasyToastPlacement.top: null,
    KasyToastPlacement.bottom: null,
  };

  final Map<KasyToastPlacement, List<_ToastData>> _pending = {
    KasyToastPlacement.top: [],
    KasyToastPlacement.bottom: [],
  };

  VoidCallback show(BuildContext ctx, _ToastData data) {
    final p = data.placement;
    if (_entries[p] == null) {
      _entries[p] = OverlayEntry(
        builder: (_) => _KasyToastLayer(placement: p),
      );
      _overlayFor(ctx)?.insert(_entries[p]!);
      _pending[p]!.add(data);
      // Capture dismiss callbacks once the layer is mounted next frame.
      VoidCallback? storedDismiss;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final d in _pending[p]!) {
          final cb = _layers[p]?.addToast(d);
          if (d == data) storedDismiss = cb;
        }
        _pending[p]!.clear();
      });
      // Delegate: after the next frame storedDismiss will be populated.
      return () => storedDismiss?.call();
    }
    return _layers[p]?.addToast(data) ?? () {};
  }

  void hideAll() {
    for (final p in KasyToastPlacement.values) {
      _layers[p]?.hideAll();
    }
  }

  void _onLayerEmpty(KasyToastPlacement p) {
    _entries[p]?.remove();
    _entries[p] = null;
    _layers[p] = null;
  }

  OverlayState? _overlayFor(BuildContext ctx) {
    try {
      return Navigator.of(ctx, rootNavigator: true).overlay;
    } catch (_) {
      return Overlay.maybeOf(ctx);
    }
  }
}

// ---------------------------------------------------------------------------
// Overlay layer (manages active toasts + animations)
// ---------------------------------------------------------------------------

class _KasyToastLayer extends StatefulWidget {
  const _KasyToastLayer({required this.placement});

  final KasyToastPlacement placement;

  @override
  State<_KasyToastLayer> createState() => _KasyToastLayerState();
}

class _ToastItem {
  _ToastItem({required this.data, required this.controller});
  final _ToastData data;
  final AnimationController controller;

  Timer? _timer;
  Duration _remaining = Duration.zero;
  final Stopwatch _watch = Stopwatch();
  VoidCallback? _onExpire;

  void scheduleTimer(VoidCallback onExpire) {
    if (data.persistent) return;
    _onExpire = onExpire;
    _remaining = data.duration;
    _watch.start();
    _timer = Timer(data.duration, onExpire);
  }

  /// Pauses the auto-dismiss timer (hover / press hold).
  void pause() {
    if (_timer == null) return;
    _timer!.cancel();
    _timer = null;
    _watch.stop();
    final Duration left = _remaining - _watch.elapsed;
    _remaining = left < Duration.zero ? Duration.zero : left;
    _watch.reset();
  }

  /// Resumes from where it left off.
  void resume() {
    if (_onExpire == null || _timer != null) return;
    if (_remaining <= Duration.zero) {
      _onExpire!();
      return;
    }
    _watch.start();
    _timer = Timer(_remaining, _onExpire!);
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
    _watch.stop();
  }
}

class _KasyToastLayerState extends State<_KasyToastLayer>
    with TickerProviderStateMixin {
  final List<_ToastItem> _items = [];
  final Map<_ToastItem, GlobalKey> _keys = {};
  final Map<_ToastItem, double> _heights = {};

  static const int _maxVisible = 3;
  static const double _peekOffset = 8.0;

  @override
  void initState() {
    super.initState();
    _KasyToastManager.instance._layers[widget.placement] = this;
  }

  @override
  void dispose() {
    _KasyToastManager.instance._layers[widget.placement] = null;
    for (final item in _items) {
      item.cancelTimer();
      item.controller.dispose();
    }
    super.dispose();
  }

  GlobalKey _keyFor(_ToastItem item) =>
      _keys.putIfAbsent(item, () => GlobalKey());

  void _measureHeights() {
    bool changed = false;
    for (final entry in _keys.entries) {
      final box =
          entry.value.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) continue;
      final h = box.size.height;
      if (_heights[entry.key] != h) {
        _heights[entry.key] = h;
        changed = true;
      }
    }
    if (changed && mounted) setState(() {});
  }

  VoidCallback addToast(_ToastData data) {
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      reverseDuration: const Duration(milliseconds: 260),
    );
    final item = _ToastItem(data: data, controller: ctrl);
    if (mounted) {
      setState(() {
        if (_items.length >= 10) {
          _dismiss(_items.last);
        }
        _items.insert(0, item);
      });
    }
    ctrl.forward();
    item.scheduleTimer(() => _dismiss(item));
    return () => _dismiss(item);
  }

  void _dismiss(_ToastItem item) {
    if (!mounted || !_items.contains(item)) return;
    item.cancelTimer();
    item.controller.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _items.remove(item);
        _keys.remove(item);
        _heights.remove(item);
      });
      item.controller.dispose();
      if (_items.isEmpty) {
        _KasyToastManager.instance._onLayerEmpty(widget.placement);
      }
    });
  }

  void hideAll() {
    for (final item in List.of(_items)) {
      _dismiss(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const SizedBox.shrink();

    final bool isTop = widget.placement == KasyToastPlacement.top;

    // Mede alturas todo frame para manter o posicionamento do stack correto.
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureHeights());

    return Positioned(
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      left: 0,
      right: 0,
      child: SafeArea(
        top: isTop,
        bottom: !isTop,
        child: Padding(
          padding: EdgeInsets.only(
            top: isTop ? KasySpacing.sm : 0,
            bottom: isTop ? 0 : KasySpacing.sm,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KasySpacing.md,
                ),
                child: _items.length == 1
                    ? _AnimatedToast(
                        key: _keyFor(_items[0]),
                        item: _items[0],
                        onClose: () => _dismiss(_items[0]),
                        swipeable: true,
                      )
                    : _buildStack(isTop),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStack(bool isTop) {
    final visible = _items.sublist(0, _maxVisible.clamp(0, _items.length));
    final renderOrder = visible.reversed.toList();
    final double? frontHeight = _heights[visible[0]];

    return Stack(
      clipBehavior: Clip.none,
      children: renderOrder.map((item) {
        final int fromFront = visible.indexOf(item);
        final bool isFront = fromFront == 0;

        // For top: use the measured height so the peek is always _peekOffset px.
        // For bottom: a fixed negative offset already guarantees a consistent peek.
        double yOffset;
        if (isTop && frontHeight != null) {
          final double cardH = _heights[item] ?? frontHeight;
          yOffset = frontHeight + fromFront * _peekOffset - cardH;
        } else {
          yOffset = fromFront * _peekOffset * (isTop ? 1.0 : -1.0);
        }

        Widget child = _AnimatedToast(
          key: _keyFor(item),
          item: item,
          onClose: () => _dismiss(item),
          swipeable: isFront,
        );

        child = Transform.translate(
          offset: Offset(0, yOffset),
          child: Transform.scale(
            scaleX: (1.0 - fromFront * 0.05).clamp(0.0, 1.0),
            alignment: Alignment.topCenter,
            child: Opacity(
              opacity: (1.0 - fromFront * 0.12).clamp(0.0, 1.0),
              child: child,
            ),
          ),
        );

        return isFront ? child : IgnorePointer(child: child);
      }).toList(),
    );
  }

}

// ---------------------------------------------------------------------------
// Animated wrapper per toast
// ---------------------------------------------------------------------------

class _AnimatedToast extends StatefulWidget {
  const _AnimatedToast({
    super.key,
    required this.item,
    required this.onClose,
    this.swipeable = false,
  });

  final _ToastItem item;
  final VoidCallback onClose;
  final bool swipeable;

  @override
  State<_AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<_AnimatedToast>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0;
  AnimationController? _snapCtrl;
  Widget? _cachedCustom;

  // Pause tracking: hover (web/desktop) and press-hold (native)
  bool _hovering = false;
  bool _pressing = false;

  void _updatePause() {
    if (_hovering || _pressing) {
      widget.item.pause();
    } else {
      widget.item.resume();
    }
  }

  @override
  void dispose() {
    _snapCtrl?.dispose();
    super.dispose();
  }

  void _snapBack() {
    final double start = _dragOffset;
    _snapCtrl?.dispose();
    _snapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    final anim = Tween<double>(begin: start, end: 0).animate(
      CurvedAnimation(parent: _snapCtrl!, curve: Curves.easeOut),
    );
    anim.addListener(() => setState(() => _dragOffset = anim.value));
    _snapCtrl!.forward();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTop =
        widget.item.data.placement == KasyToastPlacement.top;

    final Animation<Offset> slide = Tween<Offset>(
      begin: Offset(0, isTop ? -1.8 : 1.8),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: widget.item.controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    final Animation<double> fade = CurvedAnimation(
      parent: widget.item.controller,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
      reverseCurve: const Interval(0.45, 1.0, curve: Curves.easeIn),
    );

    void dismiss() {
      widget.item.data.onClose?.call();
      widget.onClose();
    }

    Widget innerContent;
    if (widget.item.data.customBuilder != null) {
      _cachedCustom ??= widget.item.data.customBuilder!(dismiss);
      innerContent = _cachedCustom!;
    } else {
      innerContent = KasyToast(
        title: widget.item.data.title,
        message: widget.item.data.message,
        tone: widget.item.data.tone,
        icon: widget.item.data.icon,
        onClose: dismiss,
      );
    }

    final toastCard = SlideTransition(
      position: slide,
      child: FadeTransition(
        opacity: fade,
        child: innerContent,
      ),
    );

    Widget result = toastCard;

    if (widget.swipeable) {
      result = GestureDetector(
        onVerticalDragUpdate: (details) {
          final double delta = details.delta.dy;
          if (isTop && delta > 0) return;
          if (!isTop && delta < 0) return;
          setState(() => _dragOffset += delta);
        },
        onVerticalDragEnd: (details) {
          final double velocity = details.primaryVelocity ?? 0;
          final bool shouldDismiss =
              _dragOffset.abs() > 60 || velocity.abs() > 600;
          if (shouldDismiss) {
            widget.item.data.onClose?.call();
            widget.onClose();
          } else {
            _snapBack();
          }
        },
        child: Transform.translate(
          offset: Offset(0, _dragOffset),
          child: toastCard,
        ),
      );
    }

    // Pause on web hover; pause on native press-hold.
    // Listener uses translucent behaviour so it doesn't block swipe gestures.
    return MouseRegion(
      onEnter: (_) {
        _hovering = true;
        _updatePause();
      },
      onExit: (_) {
        _hovering = false;
        _updatePause();
      },
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) {
          _pressing = true;
          _updatePause();
        },
        onPointerUp: (_) {
          _pressing = false;
          _updatePause();
        },
        onPointerCancel: (_) {
          _pressing = false;
          _updatePause();
        },
        child: result,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Palette resolution
// ---------------------------------------------------------------------------

/// Fully-resolved visual style for a toast tone.
///
/// Every toast shares the same plain surface bar, neutral title/message and a
/// neutral [KasyCloseButton] — the toast is never flooded with colour. The tone is
/// carried *only by the leading icon bubble*:
/// - **neutral** shows the app brand logo (no bubble).
/// - **accent / danger** get a solid coloured bubble with a white icon inside
///   (the "white inside the blue / red").
/// - **success / warning** get a soft tinted bubble with a coloured icon.
class _ToastStyle {
  const _ToastStyle({
    required this.icon,
    required this.iconColor,
    required this.iconBubbleColor,
    this.useBrandLogo = false,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBubbleColor;

  /// When true the leading slot shows the app brand logo (neutral tone).
  final bool useBrandLogo;
}

_ToastStyle _resolveStyle(KasyColors c, KasyToastTone tone) {
  switch (tone) {
    case KasyToastTone.neutral:
      return _ToastStyle(
        icon: KasyIcons.notification,
        iconColor: c.onSurface,
        iconBubbleColor: Colors.transparent,
        useBrandLogo: true,
      );
    // Solid bubble, white icon inside.
    case KasyToastTone.primary:
      return _ToastStyle(
        icon: KasyIcons.info,
        iconColor: c.onPrimary,
        iconBubbleColor: c.primary,
      );
    case KasyToastTone.danger:
      return _ToastStyle(
        icon: KasyIcons.error,
        iconColor: c.onError,
        iconBubbleColor: c.error,
      );
    // Soft tinted bubble, coloured icon.
    case KasyToastTone.success:
      final Color successDark = HSLColor.fromColor(c.success)
          .withLightness(
            (HSLColor.fromColor(c.success).lightness - 0.09).clamp(0.0, 1.0),
          )
          .toColor();
      return _ToastStyle(
        icon: KasyIcons.checkCircle,
        iconColor: successDark,
        iconBubbleColor: c.success.withValues(alpha: 0.14),
      );
    case KasyToastTone.warning:
      return _ToastStyle(
        icon: KasyIcons.privacy,
        iconColor: c.warning,
        iconBubbleColor: c.warning.withValues(alpha: 0.16),
      );
  }
}

// ---------------------------------------------------------------------------
// Backward-compatible API (keep existing callers working)
// ---------------------------------------------------------------------------

/// Retained for backwards compat — prefer [showKasyToast].
void showSuccessToast({
  required BuildContext context,
  required String title,
  required String text,
  Duration duration = const Duration(seconds: 3),
}) {
  showKasyToast(
    context,
    title: title,
    message: text,
    tone: KasyToastTone.success,
    duration: duration,
  );
}

/// Retained for backwards compat — prefer [showKasyToast].
void showErrorToast({
  required BuildContext context,
  required String title,
  required String text,
  Duration duration = const Duration(seconds: 3),
  String? reason,
}) {
  showKasyToast(
    context,
    title: title,
    message: reason != null ? '$text ($reason)' : text,
    tone: KasyToastTone.danger,
    duration: duration,
  );
}

