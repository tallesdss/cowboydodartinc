import 'dart:math' as math;
import 'dart:ui';

import 'package:cowboydodartinc/components/kasy_app_bar.dart';
import 'package:cowboydodartinc/core/chrome/app_bar_scope.dart';
import 'package:cowboydodartinc/core/haptics/kasy_haptics.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/home/admin_components_layout.dart';
import 'package:cowboydodartinc/features/home/components_navigation.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart'
    show PointerScrollEvent, PointerSignalEvent;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ComponentPreviewVariant {
  final String label;
  final WidgetBuilder builder;
  const ComponentPreviewVariant({required this.label, required this.builder});
}

/// Route arguments for Bart inner route [/home/components-preview].
class HomeComponentPreviewRouteExtra {
  const HomeComponentPreviewRouteExtra({
    required this.title,
    required this.variants,
  });

  final String title;
  final List<ComponentPreviewVariant> variants;
}

/// Shared interactive scaffold used by component showcase pages.
class HomeComponentsPreviewPage extends StatefulWidget {
  final String title;
  final List<ComponentPreviewVariant> variants;
  final int initialVariantIndex;

  const HomeComponentsPreviewPage({
    super.key,
    required this.title,
    required this.variants,
    this.initialVariantIndex = 0,
  });

  @override
  State<HomeComponentsPreviewPage> createState() =>
      _HomeComponentsPreviewPageState();
}

class _HomeComponentsPreviewPageState extends State<HomeComponentsPreviewPage>
    with SingleTickerProviderStateMixin {
  /// Commit swipe on release: lower = shorter drag / lighter flick still swaps.
  static const double _dragDistanceThreshold = 14;
  static const double _dragVelocityThreshold = 70;
  static const double _maxDragFactor = 0.84;
  static const double _maxBlurSigma = 13;
  static const double _visualCenterYOffset = -0.14;
  static const double _footerVariantTitleStrength = 0.72;

  /// Reserve at bottom so short previews center above the overlay footer.
  static const double _footerOverlayLayoutReserve = 48;

  /// Extra lift so the footer sits visibly above the bottom edge.
  static const double _footerBottomLift = 36;

  /// Extra below [MediaQuery.viewPadding] so iOS home-indicator swipes
  /// are not captured by the variant vertical-drag layer.
  static const double _systemGestureBottomReserve = 10;

  /// Desktop preview frame width. Keeps full-width components readable when
  /// the admin column is wider (accordion, dropdown, etc.).
  static const double _desktopPreviewMaxWidth = 450;
  static const double _minSwipeNormalizationExtent = 160;
  static const double _dragOffsetIdleEpsilon = 0.05;

  /// Accumulated mouse-wheel delta (web only). Triggers navigation once it
  /// exceeds [_scrollWheelThreshold] so trackpad micro-movements don't fire
  /// immediately, but a single mouse-wheel notch (~100 px) always does.
  static const double _scrollWheelThreshold = 50.0;

  /// Trackpad two-finger swipes keep emitting decaying "momentum" scroll
  /// events well after the fingers lift — longer than the 280ms settle
  /// animation. Without this cooldown that tail re-crosses the threshold
  /// once the animation finishes and fires a second, unwanted navigation.
  /// A real mouse wheel notch has no momentum, so it's unaffected.
  static const Duration _scrollWheelCooldown = Duration(milliseconds: 500);
  DateTime? _lastWheelNavigationAt;
  double _pendingScrollDelta = 0.0;

  double _dragOffset = 0;
  double _viewportHeight = 0;
  late int _activeVariantIndex;
  late final AnimationController _settleController;
  Animation<double>? _offsetAnimation;
  int? _pendingVariantIndex;
  final Map<int, double> _variantContentHeights = <int, double>{};

  /// Separate animation for the incoming page (independent easeOut curve).
  Animation<double>? _enterOffsetAnimation;
  double? _enterAnimOffset;

  @override
  void initState() {
    super.initState();
    _activeVariantIndex = widget.initialVariantIndex.clamp(
      0,
      widget.variants.length - 1,
    );
    _settleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _settleController
      ..addListener(() {
        final Animation<double>? animation = _offsetAnimation;
        if (animation == null) {
          return;
        }
        setState(() {
          _dragOffset = animation.value;
          final Animation<double>? enterAnim = _enterOffsetAnimation;
          if (enterAnim != null) {
            _enterAnimOffset = enterAnim.value;
          }
        });
      })
      ..addStatusListener((AnimationStatus status) {
        if (status != AnimationStatus.completed) {
          return;
        }
        final int? nextVariantIndex = _pendingVariantIndex;
        _pendingVariantIndex = null;
        _enterOffsetAnimation = null;
        if (nextVariantIndex == null) {
          setState(() {
            _dragOffset = 0;
            _enterAnimOffset = null;
          });
          return;
        }
        setState(() {
          _activeVariantIndex = nextVariantIndex;
          _dragOffset = 0;
          _enterAnimOffset = null;
        });
        KasyHaptics.selection(context);
      });
  }

  @override
  void dispose() {
    _settleController.dispose();
    super.dispose();
  }

  Widget _buildFooterVariantTitle(BuildContext context) {
    final Color labelBase = context.colors.onBackground;
    final TextStyle baseStyle =
        context.textTheme.titleMedium?.copyWith(
          letterSpacing: 0.1,
        ) ??
        const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 17,
          letterSpacing: 0.1,
        );
    Widget coloredLabel({required String text, required double colorStrength}) {
      final double a = _footerVariantTitleStrength * colorStrength.clamp(0, 1);
      return Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: baseStyle.copyWith(
          color: labelBase.withValues(alpha: a),
          height: 1,
        ),
      );
    }

    final int? crossTarget = _draggingVariantIndex;
    final bool isCrossfading =
        crossTarget != null && crossTarget != _activeVariantIndex;
    if (!isCrossfading) {
      final String label = widget.variants[_activeVariantIndex].label;
      return Align(
        alignment: AlignmentDirectional.topStart,
        child: coloredLabel(text: label, colorStrength: 1),
      );
    }
    final String exitLabel = widget.variants[_activeVariantIndex].label;
    final String enterLabel = widget.variants[crossTarget].label;
    if (exitLabel == enterLabel) {
      return Align(
        alignment: AlignmentDirectional.topStart,
        child: coloredLabel(text: exitLabel, colorStrength: 1),
      );
    }
    final double rawP = _dragProgress.clamp(0.0, 1.0);
    final double p = Curves.easeInCubic.transform(rawP);
    return Stack(
      children: [
        coloredLabel(text: enterLabel, colorStrength: p),
        coloredLabel(text: exitLabel, colorStrength: 1 - p),
      ],
    );
  }

  bool get _hasPreviousVariant => _activeVariantIndex > 0;

  bool get _hasNextVariant => _activeVariantIndex < widget.variants.length - 1;

  int? get _draggingVariantIndex {
    if (_dragOffset.abs() < _dragOffsetIdleEpsilon) {
      return null;
    }
    if (_dragOffset < 0 && _hasNextVariant) {
      return _activeVariantIndex + 1;
    }
    if (_dragOffset > 0 && _hasPreviousVariant) {
      return _activeVariantIndex - 1;
    }
    return null;
  }

  double _swipeNormalizationHeight() {
    return math.max(_viewportHeight, _minSwipeNormalizationExtent);
  }

  double get _dragProgress {
    return (_dragOffset.abs() / _swipeNormalizationHeight()).clamp(0.0, 1.0);
  }

  /// Matches footer title emphasis: which variant the swipe hint should treat
  /// as active while dragging / settling (not only after [activeIndex] commits).
  int get _footerHintActiveIndex {
    final int? target = _draggingVariantIndex;
    if (target == null || target == _activeVariantIndex) {
      return _activeVariantIndex;
    }
    final double blendedP = Curves.easeInCubic.transform(
      _dragProgress.clamp(0.0, 1.0),
    );
    return blendedP >= 0.42 ? target : _activeVariantIndex;
  }

  void _animateOffsetTo({
    required double targetOffset,
    required Duration duration,
    int? targetVariantIndex,
  }) {
    _pendingVariantIndex = targetVariantIndex;
    _enterOffsetAnimation = null;

    // Outgoing page uses easeIn (accelerates outward, keeps the momentum).
    // Cancelling page uses easeOutCubic (eases smoothly back).
    _offsetAnimation = Tween<double>(begin: _dragOffset, end: targetOffset)
        .animate(
          CurvedAnimation(
            parent: _settleController,
            curve: targetVariantIndex != null
                ? Curves.easeIn
                : Curves.easeOutCubic,
          ),
        );

    if (targetVariantIndex != null) {
      // Incoming page: starts from the opposite side and lands with easeOut (decelerates on arrival).
      final double enterStart = targetOffset < 0
          ? _viewportHeight + _dragOffset
          : -_viewportHeight + _dragOffset;
      _enterOffsetAnimation = Tween<double>(begin: enterStart, end: 0.0)
          .animate(
            CurvedAnimation(
              parent: _settleController,
              curve: Curves.easeOutCubic,
            ),
          );
      _enterAnimOffset = enterStart;
    }

    _settleController
      ..duration = duration
      ..forward(from: 0);
  }

  /// Mouse-wheel / trackpad scroll → navigate variants (web only).
  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (widget.variants.length <= 1) return;
    if (_settleController.isAnimating) return;

    final DateTime now = DateTime.now();
    final DateTime? lastNavigationAt = _lastWheelNavigationAt;
    if (lastNavigationAt != null &&
        now.difference(lastNavigationAt) < _scrollWheelCooldown) {
      // Still inside the trackpad momentum window from the previous swipe:
      // swallow it instead of letting it accumulate toward another trigger.
      return;
    }

    _pendingScrollDelta += event.scrollDelta.dy;
    if (_pendingScrollDelta.abs() < _scrollWheelThreshold) return;

    // scrollDelta.dy > 0 → user scrolled down → go to previous variant.
    // scrollDelta.dy < 0 → user scrolled up  → go to next variant.
    if (_pendingScrollDelta > 0 && _hasPreviousVariant) {
      _pendingScrollDelta = 0;
      _lastWheelNavigationAt = now;
      _animateOffsetTo(
        targetOffset: _viewportHeight,
        duration: const Duration(milliseconds: 280),
        targetVariantIndex: _activeVariantIndex - 1,
      );
    } else if (_pendingScrollDelta < 0 && _hasNextVariant) {
      _pendingScrollDelta = 0;
      _lastWheelNavigationAt = now;
      _animateOffsetTo(
        targetOffset: -_viewportHeight,
        duration: const Duration(milliseconds: 280),
        targetVariantIndex: _activeVariantIndex + 1,
      );
    } else {
      _pendingScrollDelta = 0;
    }
  }

  void _handleDragStart(DragStartDetails details) {
    _pendingVariantIndex = null;
    _enterOffsetAnimation = null;
    _enterAnimOffset = null;
    _settleController.stop();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (widget.variants.length <= 1) {
      return;
    }
    _enterAnimOffset = null;
    final bool triesToGoNext = details.delta.dy < 0;
    final bool triesToGoPrevious = details.delta.dy > 0;
    final bool cannotMoveInDirection =
        (triesToGoNext && !_hasNextVariant) ||
        (triesToGoPrevious && !_hasPreviousVariant);
    final double delta = cannotMoveInDirection
        ? details.delta.dy * 0.18
        : details.delta.dy;
    final double swipeExtent = math.max(
      _viewportHeight,
      _minSwipeNormalizationExtent,
    );
    final double maxDragDistance = swipeExtent * _maxDragFactor;
    setState(() {
      _dragOffset = (_dragOffset + delta).clamp(
        -maxDragDistance,
        maxDragDistance,
      );
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (widget.variants.length <= 1) {
      _animateOffsetTo(
        targetOffset: 0,
        duration: const Duration(milliseconds: 160),
      );
      return;
    }
    final double speed = details.primaryVelocity ?? 0;
    final bool swipedUpByDistance = _dragOffset < -_dragDistanceThreshold;
    final bool swipedDownByDistance = _dragOffset > _dragDistanceThreshold;
    final bool swipedUpByVelocity = speed < -_dragVelocityThreshold;
    final bool swipedDownByVelocity = speed > _dragVelocityThreshold;
    final bool swipeUp = swipedUpByDistance || swipedUpByVelocity;
    final bool swipeDown = swipedDownByDistance || swipedDownByVelocity;

    // Duration proportional to velocity: a fast flick → a faster animation.
    final double absSpeed = speed.abs();
    final double remainingDistance = (_viewportHeight - _dragOffset.abs())
        .clamp(0.0, _viewportHeight);
    final int commitMs = absSpeed > 150
        ? (remainingDistance / absSpeed * 1000).clamp(120.0, 280.0).round()
        : 280;

    if (swipeUp && _hasNextVariant) {
      _animateOffsetTo(
        targetOffset: -_viewportHeight,
        duration: Duration(milliseconds: commitMs),
        targetVariantIndex: _activeVariantIndex + 1,
      );
      return;
    }
    if (swipeDown && _hasPreviousVariant) {
      _animateOffsetTo(
        targetOffset: _viewportHeight,
        duration: Duration(milliseconds: commitMs),
        targetVariantIndex: _activeVariantIndex - 1,
      );
      return;
    }
    _animateOffsetTo(
      targetOffset: 0,
      duration: const Duration(milliseconds: 160),
    );
  }

  bool _previewUsesPageHorizontalGutter(double width) {
    return width < DeviceType.large.breakpoint;
  }

  /// Admin drill-down layout already applies [pageHorizontalGutter]; stacking
  /// another here pushed the preview past the "< Componentes" column edge.
  bool _layoutOwnsHorizontalGutter(BuildContext context) {
    return ComponentsNavigation.usesAdminDesktopDrillDownLayout(context);
  }

  Widget _buildDesktopConstrainedPreview({
    required BuildContext context,
    required BoxConstraints constraints,
    required Widget child,
  }) {
    final DeviceType device = DeviceType.fromWidth(constraints.maxWidth);
    final bool isDesktop =
        device == DeviceType.large || device == DeviceType.xlarge;
    if (!isDesktop) {
      if (_layoutOwnsHorizontalGutter(context)) {
        return SizedBox(width: double.infinity, child: child);
      }
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KasySpacing.pageHorizontalGutter,
        ),
        child: SizedBox(width: double.infinity, child: child),
      );
    }
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _desktopPreviewMaxWidth),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }

  Widget _buildVariantContent({
    required BuildContext context,
    required int index,
    required double blurSigma,
  }) {
    final Widget variantBody = _MeasuredSize(
      onSizeChanged: (Size size) {
        final double nextHeight = size.height;
        final double? previousHeight = _variantContentHeights[index];
        if (previousHeight == nextHeight) {
          return;
        }
        setState(() {
          _variantContentHeights[index] = nextHeight;
        });
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return _buildDesktopConstrainedPreview(
            context: context,
            constraints: constraints,
            child: widget.variants[index].builder(context),
          );
        },
      ),
    );
    if (blurSigma <= 0.01) {
      return _buildCenteredOrTopScrollable(
        context: context,
        child: variantBody,
        contentHeight: _variantContentHeights[index],
      );
    }
    final Widget blurred = ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
      child: variantBody,
    );
    return _buildCenteredOrTopScrollable(
      context: context,
      child: blurred,
      contentHeight: _variantContentHeights[index],
    );
  }

  Widget _buildCenteredOrTopScrollable({
    required BuildContext context,
    required Widget child,
    required double? contentHeight,
  }) {
    final double keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final double footerBottomPad =
        MediaQuery.paddingOf(context).bottom +
        KasySpacing.sm +
        _footerBottomLift;
    final double chromeTopOverlap = _skipPageAppBarOverlap(context)
        ? 0
        : kasyAppBarBodyTopOverlap(context);
    final double rawContentHeight =
        _viewportHeight -
        _footerOverlayLayoutReserve -
        footerBottomPad -
        keyboardInset;
    final double safeViewportHeight = rawContentHeight <= 1
        ? 1
        : rawContentHeight;
    final bool canCenter =
        contentHeight != null && contentHeight < safeViewportHeight;
    final ScrollPhysics previewPhysics = canCenter
        ? const NeverScrollableScrollPhysics()
        : const BouncingScrollPhysics();
    return AnimatedPadding(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: SingleChildScrollView(
        physics: previewPhysics,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: chromeTopOverlap),
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: safeViewportHeight),
              child: Align(
                alignment: canCenter
                    ? const Alignment(0, _visualCenterYOffset)
                    : Alignment.topCenter,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedVariant({
    required BuildContext context,
    required int index,
    required double translateY,
    required double blurSigma,
    required double opacity,
  }) {
    return Transform.translate(
      offset: Offset(0, translateY),
      child: Opacity(
        opacity: opacity,
        child: _buildVariantContent(
          context: context,
          index: index,
          blurSigma: blurSigma,
        ),
      ),
    );
  }

  bool _shellOwnsAppBar(BuildContext context) {
    return ComponentsNavigation.shellProvidesAppBar(context);
  }

  bool _usesDesktopShellChrome(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= DeviceType.large.breakpoint &&
        KasyAppBarScope.of(context);
  }

  bool _skipPageAppBarOverlap(BuildContext context) {
    return _usesDesktopShellChrome(context) || _shellOwnsAppBar(context);
  }

  Widget _buildPreviewStack(BuildContext context) {
    final int? draggingVariantIndex = _draggingVariantIndex;
    final double progress = _dragProgress;
    final double blurCurve = Curves.easeOut.transform(progress);
    final double activeBlurSigma = _maxBlurSigma * blurCurve;
    final double incomingBlurSigma =
        _maxBlurSigma * (1 - progress).clamp(0.12, 1) * 0.45;
    final Widget chromeFooter = _VariantFooter(
      title: _buildFooterVariantTitle(context),
      hintActiveIndex: _footerHintActiveIndex,
      totalVariants: widget.variants.length,
    );
    final double systemGestureExcludeBottom =
        MediaQuery.viewPaddingOf(context).bottom + _systemGestureBottomReserve;
    final bool inShell = _skipPageAppBarOverlap(context);
    final bool applyPageGutter = _previewUsesPageHorizontalGutter(
          MediaQuery.sizeOf(context).width,
        ) &&
        !_layoutOwnsHorizontalGutter(context);
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerSignal: kIsWeb ? _handlePointerSignal : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Stack(
              children: [
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      final double chromeTopOverlap = inShell
                          ? 0
                          : kasyAppBarBodyTopOverlap(context);
                      _viewportHeight = math.max(
                        constraints.maxHeight - chromeTopOverlap,
                        1,
                      );
                      final double incomingTranslateY;
                      if (draggingVariantIndex == null) {
                        incomingTranslateY = 0;
                      } else if (_enterAnimOffset != null) {
                        incomingTranslateY = _enterAnimOffset!;
                      } else if (_dragOffset < 0) {
                        incomingTranslateY = _viewportHeight + _dragOffset;
                      } else {
                        incomingTranslateY = -_viewportHeight + _dragOffset;
                      }
                      return ClipRect(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (draggingVariantIndex != null)
                              _buildAnimatedVariant(
                                context: context,
                                index: draggingVariantIndex,
                                translateY: incomingTranslateY,
                                blurSigma: incomingBlurSigma,
                                opacity: 0.7 + (progress * 0.3),
                              ),
                            _buildAnimatedVariant(
                              context: context,
                              index: _activeVariantIndex,
                              translateY: _dragOffset,
                              blurSigma: activeBlurSigma,
                              opacity: 1,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      applyPageGutter ? KasySpacing.pageHorizontalGutter : 0,
                      0,
                      applyPageGutter ? KasySpacing.pageHorizontalGutter : 0,
                      MediaQuery.paddingOf(context).bottom +
                          KasySpacing.sm +
                          _footerBottomLift,
                    ),
                    child: Row(children: [Expanded(child: chromeFooter)]),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: systemGestureExcludeBottom,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragStart: _handleDragStart,
              onVerticalDragUpdate: _handleDragUpdate,
              onVerticalDragEnd: _handleDragEnd,
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (ComponentsNavigation.usesAdminDesktopDrillDownLayout(context)) {
      return AdminComponentsDrillDownLayout(
        title: widget.title,
        backLabel: t.home.components_preview.nav_title,
        onBack: () => ComponentsNavigation.popToCatalog(context),
        scrollBody: false,
        body: _buildPreviewStack(context),
      );
    }
    if (_usesDesktopShellChrome(context)) {
      return KasyOverlayScaffold(
        title: widget.title,
        backLabel: t.home.components_preview.nav_title,
        onBack: () => ComponentsNavigation.popToCatalog(context),
        maxContentWidth: kKasyContentMaxWidth,
        slivers: [
          SliverFillRemaining(child: _buildPreviewStack(context)),
        ],
      );
    }
    if (_shellOwnsAppBar(context)) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: context.colors.background,
        body: _buildPreviewStack(context),
      );
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildPreviewStack(context),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: KasyAppBar(
              title: widget.title,
              onBack: () => ComponentsNavigation.popToCatalog(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _VariantFooter extends StatelessWidget {
  final Widget title;
  final int hintActiveIndex;
  final int totalVariants;

  const _VariantFooter({
    required this.title,
    required this.hintActiveIndex,
    required this.totalVariants,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VerticalSwipeHint(
            activeIndex: hintActiveIndex,
            totalVariants: totalVariants,
          ),
          const SizedBox(width: KasySpacing.sm),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 90),
              curve: Curves.easeOutCubic,
              transform: Matrix4.translationValues(
                0,
                _VerticalSwipeHint.titleAlignTranslateY(
                  hintActiveIndex,
                  totalVariants,
                ),
                0,
              ),
              transformAlignment: AlignmentDirectional.topStart,
              child: title,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalSwipeHint extends StatelessWidget {
  final int activeIndex;
  final int totalVariants;

  const _VerticalSwipeHint({
    required this.activeIndex,
    required this.totalVariants,
  });

  static const double _activeWidth = 24;
  static const double _nearWidth = 20;
  static const double _farWidth = 15;
  static const double _activeHeight = 3.5;
  static const double _restHeight = 2.5;
  static const double _barGap = 5.5;

  /// First-line vertical center for footer title: [fontSize] 17 + `height: 1` +
  /// semibold — tuned so the cap band sits on the active bar’s midline.
  static const double _titleFirstLineCenterY = 7.15;

  /// Top of [activeIndex] bar from the top of the hint column.
  static double _topOfActiveBar(int activeIndex, int totalVariants) {
    // One bar per variant: the indicator follows the real count (was hard-capped
    // at 9, which broke the active mark once a card had more variants). 99 is a
    // sanity ceiling, not a real limit.
    final int count = totalVariants.clamp(1, 99);
    final int a = activeIndex.clamp(0, count - 1);
    double y = 0;
    for (int i = 0; i < a; i++) {
      y += _barHeight(i, a) + _barGap;
    }
    return y;
  }

  /// Translate the title so the **first line’s center** meets the **active bar’s
  /// center** (can be slightly negative for the first bar).
  static double titleAlignTranslateY(int activeIndex, int totalVariants) {
    // One bar per variant: the indicator follows the real count (was hard-capped
    // at 9, which broke the active mark once a card had more variants). 99 is a
    // sanity ceiling, not a real limit.
    final int count = totalVariants.clamp(1, 99);
    final int a = activeIndex.clamp(0, count - 1);
    final double topBar = _topOfActiveBar(activeIndex, totalVariants);
    final double h = _barHeight(a, a);
    return topBar + h * 0.5 - _titleFirstLineCenterY;
  }

  static double _barHeight(int index, int activeIndex) {
    final int distance = (index - activeIndex).abs();
    return distance == 0 ? _activeHeight : _restHeight;
  }

  @override
  Widget build(BuildContext context) {
    final Color base = context.colors.onBackground;
    final Color strong = base.withValues(alpha: 0.82);
    final Color near = base.withValues(alpha: 0.46);
    final Color mid = base.withValues(alpha: 0.28);
    final Color weak = base.withValues(alpha: 0.18);
    // One bar per variant: the indicator follows the real count (was hard-capped
    // at 9, which broke the active mark once a card had more variants). 99 is a
    // sanity ceiling, not a real limit.
    final int count = totalVariants.clamp(1, 99);
    return SizedBox(
      width: _activeWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List<Widget>.generate(count, (int index) {
          final int distance = (index - activeIndex).abs();
          final Color color = switch (distance) {
            0 => strong,
            1 => near,
            2 => mid,
            _ => weak,
          };
          final double width = switch (distance) {
            0 => _activeWidth,
            1 => _nearWidth,
            _ => _farWidth,
          };
          final double height = _barHeight(index, activeIndex);
          return Padding(
            padding: EdgeInsets.only(bottom: index == count - 1 ? 0 : _barGap),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 90),
              curve: Curves.easeOutCubic,
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(KasyRadius.full),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _MeasuredSize extends SingleChildRenderObjectWidget {
  final ValueChanged<Size> onSizeChanged;

  const _MeasuredSize({required this.onSizeChanged, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _MeasuredSizeRenderObject(onSizeChanged: onSizeChanged);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _MeasuredSizeRenderObject renderObject,
  ) {
    renderObject.onSizeChanged = onSizeChanged;
  }
}

class _MeasuredSizeRenderObject extends RenderProxyBox {
  ValueChanged<Size> onSizeChanged;
  Size? _oldSize;

  _MeasuredSizeRenderObject({required this.onSizeChanged});

  @override
  void performLayout() {
    super.performLayout();
    final Size nextSize = size;
    if (_oldSize == nextSize) {
      return;
    }
    _oldSize = nextSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onSizeChanged(nextSize);
    });
  }
}
