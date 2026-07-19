import 'package:cowboydodartinc/components/kasy_button.dart';
import 'package:cowboydodartinc/components/kasy_close_button.dart';
import 'package:cowboydodartinc/components/kasy_modal_scrim.dart';
import 'package:cowboydodartinc/components/kasy_text_field.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';

/// Tint for [KasyDialog.leadingIcon] bubble (aligned with sheet / alert semantics).
enum KasyDialogIconTone { info, success, warning, danger, neutral }

/// Visual treatment for the optional trailing dismiss control on [KasyDialog].
///
/// Both styles use [KasyCloseButton] (filled neutral circle, Figma CloseButton).
enum KasyDialogCloseButtonStyle {
  /// Default 24px [KasyCloseButton] — matches Figma Dialog / Toast.
  standard,

  /// Larger [KasyCloseButton]; tune with [KasyDialog.closeFilledButtonExtent].
  filledNeutral,
}

/// Centered modal card: icon bubble, title, body, optional dismiss control, actions.
///
/// **Single trailing button:** pass [confirmLabel] (and optional [onConfirm]).
///
/// **Stacked full-width buttons:** pass [actions]. When non-empty, it replaces
/// [confirmLabel]. If both are set, [actions] wins. Use [actionsAxis] ==
/// [Axis.horizontal] for a proportional side-by-side row instead of the
/// default column.
///
/// **[footer]** replaces that default footer entirely (custom rows, dual actions).
///
/// **Custom body:** when [body] is non-null it is rendered after the title; otherwise
/// a non-null, non-empty [message] renders the dimmed subtitle text.
///
/// Present with [showKasyDialog] or [showKasyBlurDialog]; prefer [KasyButton] in [actions].
///
/// [KasyTextFieldVariant.primary] fields in [body] get an elevated fill via
/// [kasyElevatedSurfaceInputFill], matching [KasyBottomSheet] so forms read the
/// same on desktop dialog and mobile sheet without per-call [variant] overrides.
///
/// Omit [leadingIcon] (leave null) for a compact header row: title and close button only.
/// Use [titleCentered] together with null [leadingIcon] to mirror centered header layouts.
/// Use [closeAboveTitle] with null [leadingIcon] and [titleCentered] false to put the close
/// control on its own top row (trailing), with the title full-width on the line below.
/// Use [closeButtonStyle] for a larger dismiss chip ([KasyDialogCloseButtonStyle.filledNeutral]).
/// Default [KasyDialogCloseButtonStyle.standard] is the 24px [KasyCloseButton] (Figma).
/// For [filledNeutral], optional [closeFilledButtonExtent] and [closeFilledIconGlyphSize]
/// tune diameter (glyph scales with the button).
class KasyDialog extends StatelessWidget {
  final IconData? leadingIcon;
  final KasyDialogIconTone iconTone;
  final String title;
  /// When [leadingIcon] is null and this is true, the title aligns to the centered column.
  final bool titleCentered;
  /// When true (and [leadingIcon] is null, [titleCentered] is false, [showCloseButton] is true),
  /// close sits on a dedicated top row (end-aligned), title on the next row below.
  final bool closeAboveTitle;
  /// Subtitle paragraph; omitted when null/empty unless [body] is used ([body] wins).
  final String? message;
  /// Replaces the default subtitle when set (e.g. form fields).
  final Widget? body;
  /// Replaces computed confirm / [actions] footer when non-null.
  final Widget? footer;

  /// Used when [footer] is null and [actions] is null or empty (basic dialog).
  final String? confirmLabel;
  final VoidCallback? onConfirm;

  /// When non-empty, replaces the single trailing [confirmLabel] row (full-width column).
  final List<Widget>? actions;

  /// When [actions] is non-empty, lays them out horizontally with equal flex
  /// ([Expanded]) instead of a full-width column.
  final Axis actionsAxis;

  final VoidCallback? onClose;
  final bool showCloseButton;

  /// How the trailing close control is rendered when [showCloseButton] is true.
  final KasyDialogCloseButtonStyle closeButtonStyle;

  /// Overrides the circular hit area for [KasyDialogCloseButtonStyle.filledNeutral] (icon-only extent).
  final double? closeFilledButtonExtent;

  /// Overrides the close icon glyph size for [KasyDialogCloseButtonStyle.filledNeutral].
  final double? closeFilledIconGlyphSize;

  const KasyDialog({
    super.key,
    this.leadingIcon,
    this.iconTone = KasyDialogIconTone.warning,
    required this.title,
    this.titleCentered = false,
    this.closeAboveTitle = false,
    this.message,
    this.body,
    this.footer,
    this.confirmLabel,
    this.onConfirm,
    this.actions,
    this.actionsAxis = Axis.vertical,
    this.onClose,
    this.showCloseButton = true,
    this.closeButtonStyle = KasyDialogCloseButtonStyle.standard,
    this.closeFilledButtonExtent,
    this.closeFilledIconGlyphSize,
  });

  static const double _maxCardWidthCompact = 400;
  static const double _maxCardWidthDesktop = 480;

  static bool _isDesktopLayout(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= DeviceType.large.breakpoint;

  bool get _usesActionList => actions != null && actions!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = _isDesktopLayout(context);
    final EdgeInsets cardPadding = isDesktop
        ? const EdgeInsets.all(KasySpacing.lg)
        : const EdgeInsets.all(KasySpacing.md);
    final double closeSlotWidth = isDesktop ? 44 : 40;
    final double maxCardWidth =
        isDesktop ? _maxCardWidthDesktop : _maxCardWidthCompact;
    final double headerTitleGap =
        isDesktop ? KasySpacing.md : KasySpacing.sm;
    final double gapAfterHeader = isDesktop
        ? (leadingIcon != null ? KasySpacing.md : KasySpacing.lg)
        : (leadingIcon != null ? KasySpacing.sm : KasySpacing.md);
    final double gapAfterMessage =
        isDesktop ? KasySpacing.md : KasySpacing.sm;
    final double gapBeforeFooter =
        isDesktop ? KasySpacing.xl : KasySpacing.lg;
    if (footer == null) {
      assert(
        _usesActionList ||
            (confirmLabel != null && confirmLabel!.trim().isNotEmpty),
      );
    }

    void handleClose() {
      if (onClose != null) {
        onClose!();
      } else {
        Navigator.of(context).maybePop();
      }
    }

    Widget buildCloseTrailing() {
      // Always [KasyCloseButton]: filled neutral circle at rest (Figma CloseButton),
      // every breakpoint — never a naked X that only gains a fill on hover.
      final double size = switch (closeButtonStyle) {
        KasyDialogCloseButtonStyle.filledNeutral =>
          closeFilledButtonExtent ?? (isDesktop ? 32.0 : 28.0),
        KasyDialogCloseButtonStyle.standard => 24.0,
      };
      final Widget close = KasyCloseButton(
        onPressed: handleClose,
        size: size,
        semanticLabel: MaterialLocalizations.of(context).closeButtonTooltip,
      );
      if (isDesktop) return close;
      return Transform.translate(
        offset: const Offset(0, -4),
        child: close,
      );
    }

    // Dialog title = titleLarge (20 / w600 = Heading 3), the SAME role the
    // bottom sheet uses for its title, so the two surfaces read identically.
    // Sourced from the non-null kasyTextTheme so there's no hardcoded fallback.
    final TextStyle titleStyle = context.kasyTextTheme.titleLarge.copyWith(
      color: context.colors.onSurface,
    );

    late final Widget headerBlock;
    if (leadingIcon != null) {
      headerBlock = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DialogIconBubble(icon: leadingIcon!, tone: iconTone),
              const Spacer(),
              if (showCloseButton) buildCloseTrailing(),
            ],
          ),
          SizedBox(height: headerTitleGap),
          Text(
            title,
            style: titleStyle,
            // Keep title + message on the same axis. With a leading icon the
            // row above is icon | spacer | close; body copy still honors
            // [titleCentered] so the two lines never disagree.
            textAlign: titleCentered ? TextAlign.center : TextAlign.start,
          ),
        ],
      );
    } else if (closeAboveTitle && showCloseButton) {
      headerBlock = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [buildCloseTrailing()],
          ),
          SizedBox(height: headerTitleGap),
          Text(
            title,
            style: titleStyle,
            textAlign: titleCentered ? TextAlign.center : TextAlign.start,
          ),
        ],
      );
    } else if (titleCentered) {
      headerBlock = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: closeSlotWidth),
          Expanded(
            child: Text(title, textAlign: TextAlign.center, style: titleStyle),
          ),
          if (showCloseButton)
            SizedBox(width: closeSlotWidth, child: buildCloseTrailing())
          else
            SizedBox(width: closeSlotWidth),
        ],
      );
    } else {
      headerBlock = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(title, style: titleStyle)),
          if (showCloseButton) buildCloseTrailing(),
        ],
      );
    }

    final Widget footerWidget =
        footer ??
        (_usesActionList
            ? actionsAxis == Axis.horizontal
                  ? Row(
                      children: [
                        for (int i = 0; i < actions!.length; i++) ...[
                          if (i > 0) const SizedBox(width: KasySpacing.sm),
                          Expanded(child: actions![i]),
                        ],
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int i = 0; i < actions!.length; i++) ...[
                          if (i > 0) const SizedBox(height: KasySpacing.sm),
                          actions![i],
                        ],
                      ],
                    )
            : Row(
                children: [
                  const Spacer(),
                  KasyButton(
                    label: confirmLabel!,
                    variant: KasyButtonVariant.neutral,
                    onPressed: onConfirm,
                  ),
                ],
              ));

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxCardWidth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(KasyRadius.lg),
          border: Border.all(
            color: context.colors.borderSoft,
          ),
          boxShadow: KasyShadows.overlayPanel(context),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
              fillColor: kasyElevatedSurfaceInputFill(context),
            ),
          ),
          child: Padding(
            padding: cardPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                headerBlock,
                if (body != null) ...[
                  SizedBox(height: gapAfterHeader),
                  body!,
                ] else if (message != null && message!.trim().isNotEmpty) ...[
                  SizedBox(height: gapAfterMessage),
                  Text(
                    message!,
                    textAlign: titleCentered ? TextAlign.center : TextAlign.start,
                    // Supporting text uses the body token (14); the sheet uses the
                    // same, so dialog and sheet read identically (they are the same
                    // surface on desktop). No off-ladder 15.
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.6),
                      height: 1.5,
                    ),
                  ),
                ],
                SizedBox(height: gapBeforeFooter),
                footerWidget,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Scrollable region capped at [maxHeight]. Sizes to its [child] when the
/// content is shorter than the cap (no dead vertical gap in the dialog body).
/// Optional top/bottom fades appear only when the content actually scrolls.
class KasyDialogScrollableBody extends StatefulWidget {
  static const double _fadeHeight = 28;

  final double maxHeight;
  final Widget child;
  final bool fadeBottomEdge;
  final bool fadeTopEdge;
  final EdgeInsetsGeometry padding;

  const KasyDialogScrollableBody({
    super.key,
    required this.maxHeight,
    required this.child,
    this.fadeBottomEdge = true,
    this.fadeTopEdge = true,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<KasyDialogScrollableBody> createState() =>
      _KasyDialogScrollableBodyState();
}

class _KasyDialogScrollableBodyState extends State<KasyDialogScrollableBody> {
  final ScrollController _scrollController = ScrollController();
  bool _showTopFade = false;
  bool _showBottomFade = false;
  bool _contentFits = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureScrollNeed());
  }

  @override
  void didUpdateWidget(covariant KasyDialogScrollableBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child ||
        oldWidget.maxHeight != widget.maxHeight) {
      _contentFits = false;
      _showTopFade = false;
      _showBottomFade = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureScrollNeed());
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _measureScrollNeed() {
    if (!mounted || _contentFits) return;
    if (!_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureScrollNeed());
      return;
    }
    final double extent = _scrollController.position.maxScrollExtent;
    if (extent <= 0.5) {
      if (!_contentFits) {
        setState(() => _contentFits = true);
      }
      return;
    }
    _onScroll();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _contentFits) return;
    final double extent = _scrollController.position.maxScrollExtent;
    if (extent <= 0.5) return;
    final bool atTop = _scrollController.offset <= 0;
    final bool atBottom = _scrollController.offset >= extent;
    final bool newShowTop = !atTop;
    final bool newShowBottom = !atBottom;
    if (newShowTop != _showTopFade || newShowBottom != _showBottomFade) {
      setState(() {
        _showTopFade = newShowTop;
        _showBottomFade = newShowBottom;
      });
    }
  }

  Widget _buildFade({
    required Color surfaceColor,
    required bool top,
    required bool visible,
  }) {
    return Positioned(
      left: 0,
      right: 0,
      top: top ? 0 : null,
      bottom: top ? null : 0,
      height: KasyDialogScrollableBody._fadeHeight,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: top
                    ? [surfaceColor, surfaceColor.withValues(alpha: 0)]
                    : [surfaceColor.withValues(alpha: 0), surfaceColor],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_contentFits) {
      return Padding(padding: widget.padding, child: widget.child);
    }

    final Color surfaceColor = context.colors.surface;
    final Widget scrollable = SingleChildScrollView(
      controller: _scrollController,
      padding: widget.padding,
      physics: const ClampingScrollPhysics(),
      child: widget.child,
    );

    if (!widget.fadeBottomEdge && !widget.fadeTopEdge) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: widget.maxHeight),
        child: scrollable,
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: widget.maxHeight),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(KasyRadius.md),
        child: Stack(
          children: [
            Positioned.fill(child: scrollable),
            if (widget.fadeTopEdge)
              _buildFade(
                surfaceColor: surfaceColor,
                top: true,
                visible: _showTopFade,
              ),
            if (widget.fadeBottomEdge)
              _buildFade(
                surfaceColor: surfaceColor,
                top: false,
                visible: _showBottomFade,
              ),
          ],
        ),
      ),
    );
  }
}

class _DialogIconBubble extends StatelessWidget {
  final IconData icon;
  final KasyDialogIconTone tone;

  const _DialogIconBubble({required this.icon, required this.tone});

  static const double _size = 44;

  @override
  Widget build(BuildContext context) {
    final _DialogIconPalette p = _palette(context, tone);
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(color: p.background, shape: BoxShape.circle),
      child: Icon(icon, size: KasyIconSize.lg, color: p.foreground),
    );
  }

  _DialogIconPalette _palette(BuildContext context, KasyDialogIconTone tone) {
    final KasyColors c = context.colors;
    final bool dark = context.isDark;
    return switch (tone) {
      KasyDialogIconTone.info => _DialogIconPalette(
        background: c.primary.withValues(alpha: dark ? 0.22 : 0.12),
        foreground: c.primary,
      ),
      KasyDialogIconTone.success => _DialogIconPalette(
        background: c.success.withValues(alpha: dark ? 0.22 : 0.12),
        foreground: c.success,
      ),
      KasyDialogIconTone.warning => _DialogIconPalette(
        background: c.warning.withValues(alpha: dark ? 0.22 : 0.12),
        foreground: c.warning,
      ),
      KasyDialogIconTone.danger => _DialogIconPalette(
        background: c.error.withValues(alpha: dark ? 0.22 : 0.12),
        foreground: c.error,
      ),
      KasyDialogIconTone.neutral => _DialogIconPalette(
        background: c.outline.withValues(alpha: dark ? 0.22 : 0.12),
        foreground: c.onSurface.withValues(alpha: 0.72),
      ),
    };
  }
}

class _DialogIconPalette {
  final Color background;
  final Color foreground;

  const _DialogIconPalette({
    required this.background,
    required this.foreground,
  });
}

/// Two-button confirm/cancel dialog built on [KasyDialog].
///
/// Feature code supplies copy and callbacks; layout stays in the design system.
/// Every confirm dialog is presented over the same blurred, dimmed backdrop
/// ([showKasyBlurDialog]) so the experience is identical project-wide — the
/// [destructive] flag only switches the accent to danger (red button + trash
/// icon), not whether there's a blur.
Future<void> showKasyConfirmDialog(
  BuildContext context, {
  required String title,
  String? message,
  required String cancelLabel,
  required String confirmLabel,
  VoidCallback? onCancel,
  VoidCallback? onConfirm,
  Future<void> Function()? onConfirmAsync,
  bool destructive = false,
  bool barrierDismissible = false,
  IconData? leadingIcon,
  // Defaults to [info] (primary tone) so the icon bubble matches the primary
  // confirm button — same harmony destructive flows get (danger icon + danger
  // button). Override per call when a different accent is needed.
  KasyDialogIconTone iconTone = KasyDialogIconTone.info,
}) {
  return showKasyBlurDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogCtx) {
      var isLoading = false;
      return StatefulBuilder(
        builder: (ctx, setState) => KasyDialog(
          leadingIcon: leadingIcon ?? (destructive ? KasyIcons.trash : null),
          iconTone: destructive ? KasyDialogIconTone.danger : iconTone,
          title: title,
          titleCentered: leadingIcon == null && !destructive,
          message: message,
          showCloseButton: false,
          actionsAxis: Axis.horizontal,
          actions: [
            KasyButton(
              label: cancelLabel,
              variant: KasyButtonVariant.outline,
              expand: true,
              onPressed: isLoading
                  ? null
                  : () {
                      Navigator.of(dialogCtx).pop();
                      onCancel?.call();
                    },
            ),
            KasyButton(
              label: confirmLabel,
              variant: destructive
                  ? KasyButtonVariant.destructive
                  : KasyButtonVariant.primary,
              expand: true,
              isLoading: isLoading,
              onPressed: isLoading
                  ? null
                  : () {
                      if (onConfirmAsync != null) {
                        setState(() => isLoading = true);
                        onConfirmAsync().whenComplete(() {
                          if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
                        });
                      } else {
                        Navigator.of(dialogCtx).pop();
                        onConfirm?.call();
                      }
                    },
            ),
          ],
        ),
      );
    },
  );
}

/// Shows a centered dialog using [showDialog]. Default barrier is semi-opaque dark;
/// pass [barrierColor] for a solid scrim (e.g. canvas tone via [showKasyScaffoldToneDialog]).
Future<T?> showKasyDialog<T>({
  required BuildContext context,
  required Widget Function(BuildContext dialogContext) builder,
  bool barrierDismissible = true,
  Color? barrierColor,
}) {
  final ThemeData theme = Theme.of(context);
  final bool dark = theme.brightness == Brightness.dark;
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor:
        barrierColor ??
        Colors.black.withValues(alpha: dark ? 0.58 : 0.42),
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.lg,
        vertical: KasySpacing.xl,
      ),
      child: builder(ctx),
    ),
  );
}

/// [showKasyDialog] with a solid barrier matching the scaffold / page canvas tone.
Future<T?> showKasyScaffoldToneDialog<T>({
  required BuildContext context,
  required Widget Function(BuildContext dialogContext) builder,
  bool barrierDismissible = true,
}) {
  return showKasyDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Theme.of(context).scaffoldBackgroundColor,
    builder: builder,
  );
}

/// Entrance animation for the foreground content in [showKasyBlurDialog].
enum KasyBlurDialogTransitionStyle {
  /// Fade in while moving up from below (sheet-like on mobile).
  slideUpFade,
  /// Fade in with a slight scale-up around the layout center (legacy).
  scaleFade,
  /// Fade in with subtle scale, smooth entrance (recommended for input dialogs).
  scaleFadeSoft,
}

/// Centered dialog over a blurred, lightly dimmed backdrop (full-screen blur).
///
/// Foreground content is laid out in a [Center]; by default it **animates in**
/// with [KasyBlurDialogTransitionStyle.slideUpFade] (slide from below + fade).
/// Use [transitionStyle] for the previous scale + fade pop-in.
Future<T?> showKasyBlurDialog<T>({
  required BuildContext context,
  required Widget Function(BuildContext dialogContext) builder,
  bool barrierDismissible = true,
  double blurSigma = KasyShadows.modalScrimBlur,
  KasyBlurDialogTransitionStyle transitionStyle =
      KasyBlurDialogTransitionStyle.slideUpFade,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (ctx, animation, _) => _BlurDialogScaffold(
      animation: animation,
      blurSigma: blurSigma,
      barrierDismissible: barrierDismissible,
      transitionStyle: transitionStyle,
      child: builder(ctx),
    ),
    transitionBuilder: (_, _, _, child) => child,
  );
}

class _BlurDialogScaffold extends StatefulWidget {
  final Animation<double> animation;
  final double blurSigma;
  final bool barrierDismissible;
  final KasyBlurDialogTransitionStyle transitionStyle;
  final Widget child;

  const _BlurDialogScaffold({
    required this.animation,
    required this.blurSigma,
    required this.barrierDismissible,
    required this.transitionStyle,
    required this.child,
  });

  @override
  State<_BlurDialogScaffold> createState() => _BlurDialogScaffoldState();
}

class _BlurDialogScaffoldState extends State<_BlurDialogScaffold> {
  double _bottomInset = 0;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    widget.animation.addStatusListener(_onStatusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Tracks the keyboard rising; freezes when it closes.
    if (!_isClosing) {
      _bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    }
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_onStatusChange);
    super.dispose();
  }

  void _onStatusChange(AnimationStatus status) {
    if (status == AnimationStatus.forward) {
      _isClosing = false;
    }
  }

  void _startClosingSequence(Object? result) {
    if (_isClosing) return;
    setState(() => _isClosing = true);
    Navigator.of(context).pop(result);
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) FocusScope.of(context).unfocus();
    });
  }

  Widget _buildForeground(Animation<double> curved, Widget child) {
    switch (widget.transitionStyle) {
      case KasyBlurDialogTransitionStyle.slideUpFade:
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      case KasyBlurDialogTransitionStyle.scaleFade:
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
            child: child,
          ),
        );
      case KasyBlurDialogTransitionStyle.scaleFadeSoft:
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved),
            child: child,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: widget.animation,
      curve: Curves.easeOutQuart,
      reverseCurve: Curves.easeIn,
    );
    // Backdrop disappears quickly on exit
    final backdropCurved = CurvedAnimation(
      parent: widget.animation,
      curve: Curves.linear,
      reverseCurve: Curves.easeOut,
    );
    final materialChild = Material(
      type: MaterialType.transparency,
      child: widget.child,
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _startClosingSequence(result);
      },
      child: AnimatedBuilder(
      animation: curved,
      builder: (ctx, _) {
        final double backdropT = backdropCurved.value;
        return Stack(
          fit: StackFit.expand,
          children: [
            KasyModalScrim(
              opacity: backdropT,
              blurSigma: widget.blurSigma,
              onTap: widget.barrierDismissible && !_isClosing
                  ? () => _startClosingSequence(null)
                  : null,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: KasySpacing.lg,
                right: KasySpacing.lg,
                top: KasySpacing.xl,
                bottom: KasySpacing.xl + _bottomInset,
              ),
              child: Center(
                child: _buildForeground(curved, materialChild),
              ),
            ),
          ],
        );
      },
      ),
    );
  }
}
