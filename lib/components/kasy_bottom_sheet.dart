import 'package:cowboydodartinc/components/kasy_modal_scrim.dart';
import 'package:cowboydodartinc/components/kasy_text_field.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_hover.dart';
import 'package:cowboydodartinc/core/widgets/kasy_scroll_behavior.dart';
import 'package:flutter/material.dart';

/// Tone for the icon bubble displayed at the top of [KasyBottomSheet].
enum KasySheetIconTone { info, success, warning, danger, neutral }

/// A design-system bottom sheet panel.
///
/// Use [showKasyBottomSheet] to present it. The sheet handles drag-handle,
/// optional icon bubble, title, message, custom body, and action buttons. It is
/// a bottom sheet on every screen size; for a desktop dialog or menu, pick that
/// surface explicitly at the call site.
///
/// [KasyTextFieldVariant.primary] fields inside the sheet get an elevated fill
/// via [kasyElevatedSurfaceInputFill] (same as [KasyDialog] on desktop).
class KasyBottomSheet extends StatelessWidget {
  final String? title;
  final String? message;

  /// Optional icon shown inside a soft-tinted bubble above the title.
  final IconData? icon;
  final KasySheetIconTone iconTone;

  /// Custom content displayed between [message] and [actions].
  final Widget? body;

  /// Action buttons displayed at the bottom (usually [KasyButton] widgets).
  final List<Widget> actions;

  final bool showDragHandle;

  /// Whether to pad the bottom by the safe area inset.
  final bool addBottomSafeArea;

  /// When true, the sheet grows by the keyboard inset so its surface continues
  /// underneath the keyboard while content remains visible above it.
  final bool addKeyboardInset;

  /// Internal: a form sheet (built with [KasyBottomSheet.form]) uses a tighter,
  /// left-aligned layout that hugs its content, versus the roomier alert layout.
  final bool _isForm;

  /// An alert / confirmation bottom sheet: an optional icon bubble over a
  /// centered title, message and stacked action buttons (roomy by design).
  const KasyBottomSheet({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.iconTone = KasySheetIconTone.info,
    this.body,
    this.actions = const [],
    this.showDragHandle = true,
    this.addBottomSafeArea = true,
    this.addKeyboardInset = false,
  }) : _isForm = false;

  /// A form bottom sheet: a compact, left-aligned title over a custom [body]
  /// (usually a [KasyTextField]) and stacked [actions]. The layout hugs its
  /// content and lifts above the keyboard, and inputs contrast against the
  /// surface automatically. Use this instead of hand-building a sheet form.
  const KasyBottomSheet.form({
    super.key,
    this.title,
    required this.body,
    this.actions = const [],
    this.addBottomSafeArea = true,
    this.addKeyboardInset = true,
  })  : _isForm = true,
        message = null,
        icon = null,
        iconTone = KasySheetIconTone.info,
        showDragHandle = true;

  @override
  Widget build(BuildContext context) {
    final double bottomSafeArea =
        addBottomSafeArea ? MediaQuery.paddingOf(context).bottom : 0;
    final double keyboardInset =
        addKeyboardInset ? MediaQuery.viewInsetsOf(context).bottom : 0;
    final double bottomInset = bottomSafeArea + keyboardInset;
    final bool hasIcon = icon != null;
    final bool centered = hasIcon;
    final bool form = _isForm;

    // A form sheet hugs its content (tight, left-aligned, compact title); an
    // alert sheet breathes (roomy padding, larger centered title).
    final double topPad =
        hasIcon ? KasySpacing.lg : (form ? KasySpacing.xs : KasySpacing.md);
    final double sidePad = form ? KasySpacing.md : KasySpacing.lg;
    final double bottomPad = form ? KasySpacing.md : KasySpacing.lg;
    final double beforeBody = form ? KasySpacing.smd : KasySpacing.md;
    final double beforeActions = form ? KasySpacing.md : KasySpacing.lg;

    // Elevate the input fill color for any KasyTextField.primary inside the
    // sheet, so fields contrast against the surface without callers setting a
    // variant.
    final Color elevatedFill = kasyElevatedSurfaceInputFill(context);

    return Material(
      color: context.colors.surface,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(KasyRadius.xl)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
            fillColor: elevatedFill,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            if (showDragHandle) const KasyDragHandle(),
            AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.fromLTRB(
                sidePad,
                topPad,
                sidePad,
                bottomInset + bottomPad,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: centered
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  if (hasIcon) ...[
                    _IconBubble(icon: icon!, tone: iconTone),
                    const SizedBox(height: KasySpacing.md),
                  ],
                  if (title != null)
                    Text(
                      title!,
                      textAlign: centered ? TextAlign.center : TextAlign.start,
                      // Sheet title = Heading 3 (20 / w600), a clear step above
                      // the 16 body/options — the same as the dialog convention,
                      // for both the alert and the form layout.
                      style: context.kasyTextTheme.titleLarge.copyWith(
                        color: context.colors.onSurface,
                      ),
                    ),
                  if (message != null) ...[
                    const SizedBox(height: KasySpacing.sm),
                    Text(
                      message!,
                      textAlign: centered ? TextAlign.center : TextAlign.start,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurface.withValues(alpha: 0.6),
                        height: 1.5,
                      ),
                    ),
                  ],
                  if (body != null) ...[
                    SizedBox(height: beforeBody),
                    body!,
                  ],
                  if (actions.isNotEmpty) ...[
                    SizedBox(height: beforeActions),
                    ...actions.expand(
                      (w) => [
                        w,
                        if (w != actions.last)
                          const SizedBox(height: KasySpacing.sm),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Surface chrome for custom sheet bodies presented via [showKasyBottomSheet].
///
/// Paints the design-system surface as a bottom sheet: top-rounded corners with
/// a drag handle. Wrap bespoke content (option lists, pickers) with this so it
/// gets the standard sheet look.
class KasySheetSurface extends StatelessWidget {
  final Widget child;

  /// Shows the drag handle at the top of the sheet.
  final bool showDragHandle;

  /// Surface color; defaults to [KasyColors.surface].
  final Color? color;

  const KasySheetSurface({
    super.key,
    required this.child,
    this.showDragHandle = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? context.colors.surface,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(KasyRadius.xl)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDragHandle) const KasyDragHandle(),
            // Flexible lets the body shrink within a bottom sheet's bounded
            // height. The Theme elevates the input fill so a KasyTextField
            // inside the sheet contrasts against the surface (same as
            // KasyBottomSheet), instead of blending into it.
            Flexible(
              child: Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: Theme.of(context)
                      .inputDecorationTheme
                      .copyWith(fillColor: kasyElevatedSurfaceInputFill(context)),
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One tappable option row for a bottom-sheet chooser (avatar actions, language
/// picker, ...). Compose several inside a [KasySheetSurface] to build a choice
/// sheet that hugs its content.
///
/// Mirrors the design-system list row: optional leading [icon], [label] at
/// [KasyTextTheme.listRowTitle] (16 / Medium), an optional trailing check when
/// [selected], and destructive styling when [danger]. Hover / press / keyboard
/// feedback come from [KasyHover] (radius 12).
class KasyBottomSheetOption extends StatelessWidget {
  const KasyBottomSheetOption({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.selected = false,
    this.danger = false,
  });

  /// Leading icon (omit for a text-only option like a language row).
  final IconData? icon;

  /// Row label.
  final String label;

  /// Draws a trailing check and marks the row as the current selection.
  final bool selected;

  /// Destructive styling (label and icon in the error color).
  final bool danger;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color fg = danger ? context.colors.error : context.colors.onSurface;
    return KasyHover(
      onTap: onTap,
      focusable: true,
      borderRadius: BorderRadius.circular(KasyRadius.md),
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.smd,
        vertical: KasySpacing.smd,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: KasyIconSize.rowLeading, color: fg),
            const SizedBox(width: KasySpacing.smd),
          ],
          Expanded(
            child: Text(
              label,
              style: context.kasyTextTheme.listRowTitle.copyWith(color: fg),
            ),
          ),
          if (selected)
            Icon(
              KasyIcons.check,
              size: KasyIconSize.rowLeading,
              color: context.colors.primary,
            ),
        ],
      ),
    );
  }
}

/// Presents a choice-list bottom sheet: a thin surface that hugs its content,
/// with an optional [title] over a stack of [options]. This owns the chooser
/// layout, so call sites only declare the title and the options (avatar photo
/// actions, language picker, ...) and never rebuild the scaffold.
///
/// Each option's `onTap` is the pure action: the sheet dismisses itself first,
/// then runs it. A destructive option ([KasyBottomSheetOption.danger]) is
/// automatically separated from the rest by a hairline divider.
Future<T?> showKasyChoiceSheet<T>({
  required BuildContext context,
  required List<KasyBottomSheetOption> options,
  String? title,
}) {
  return showKasyBottomSheet<T>(
    context: context,
    builder: (sheetCtx) {
      final List<Widget> rows = [];
      bool dividerDrawn = false;
      for (int i = 0; i < options.length; i++) {
        final KasyBottomSheetOption option = options[i];
        // Separate the first destructive option from the rest.
        if (option.danger && !dividerDrawn && i > 0) {
          dividerDrawn = true;
          rows.add(
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: KasySpacing.smd,
                vertical: KasySpacing.xs,
              ),
              child: Divider(
                height: 1,
                thickness: 1,
                color: sheetCtx.colors.outline.withValues(alpha: 0.18),
              ),
            ),
          );
        }
        rows.add(
          KasyBottomSheetOption(
            icon: option.icon,
            label: option.label,
            selected: option.selected,
            danger: option.danger,
            onTap: () {
              Navigator.of(sheetCtx).pop();
              option.onTap();
            },
          ),
        );
      }
      return KasySheetSurface(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            KasySpacing.sm,
            KasySpacing.xs,
            KasySpacing.sm,
            KasySpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    KasySpacing.smd,
                    KasySpacing.xs,
                    KasySpacing.smd,
                    KasySpacing.sm,
                  ),
                  child: Text(
                    title,
                    // Heading 3 (20 / w600) — a clear step above the 16 options,
                    // matching the dialog / sheet title convention.
                    style: sheetCtx.kasyTextTheme.titleLarge.copyWith(
                      color: sheetCtx.colors.onSurface,
                    ),
                  ),
                ),
              ...rows,
            ],
          ),
        ),
      );
    },
  );
}

/// Shows a [KasyBottomSheet] as a modal bottom sheet, on every screen size.
///
/// For a desktop dialog or menu, choose that surface explicitly at the call site
/// (see [kasySheetUsesDialog]).
///
/// Example:
/// ```dart
/// showKasyBottomSheet(
///   context: context,
///   builder: (_) => KasyBottomSheet(
///     icon: KasyIcons.security,
///     iconTone: KasySheetIconTone.success,
///     title: 'Keep yourself safe',
///     message: 'Update your app for better security.',
///     actions: [
///       KasyButton(label: 'Update Now', expand: true, onPressed: () {}),
///       KasyButton(label: 'Later', variant: KasyButtonVariant.ghost, expand: true, onPressed: () {}),
///     ],
///   ),
/// );
/// ```
Future<T?> showKasyBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
  bool isScrollControlled = false,
  Color? barrierColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    barrierColor: barrierColor ??
        Colors.black.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? 0.6 : 0.45,
        ),
    // Let a mouse / trackpad drag the sheet and its scroll views on web &
    // desktop, so scrollable / snap sheets behave like they do on touch.
    builder: (ctx) => ScrollConfiguration(
      behavior: const KasyKitScrollBehavior(),
      child: builder(ctx),
    ),
  );
}

/// Shows a [KasyBottomSheet] with a frosted-glass blur overlay instead of the
/// standard dim barrier. A bottom sheet on every screen size.
Future<T?> showKasyBlurBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  double blurSigma = KasyShadows.modalScrimBlur,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: isDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (ctx, animation, _) => _BlurSheetScaffold(
      animation: animation,
      blurSigma: blurSigma,
      isDismissible: isDismissible,
      child: ScrollConfiguration(
        behavior: const KasyKitScrollBehavior(),
        child: builder(ctx),
      ),
    ),
    transitionBuilder: (_, _, _, child) => child,
  );
}

class _BlurSheetScaffold extends StatelessWidget {
  final Animation<double> animation;
  final double blurSigma;
  final bool isDismissible;
  final Widget child;

  const _BlurSheetScaffold({
    required this.animation,
    required this.blurSigma,
    required this.isDismissible,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final CurvedAnimation curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    return AnimatedBuilder(
      animation: curved,
      builder: (ctx, _) {
        final double t = curved.value;
        return Stack(
          children: [
            KasyModalScrim(
              opacity: t,
              blurSigma: blurSigma,
              onTap: isDismissible ? () => Navigator.of(ctx).pop() : null,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The grab bar at the top of a bottom sheet (36×4, fully rounded). The single
/// source for this handle — sheets, the date picker and any custom sheet body
/// use it so the look stays identical everywhere.
class KasyDragHandle extends StatelessWidget {
  const KasyDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: KasySpacing.smd),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            // Based on onSurface (near-black on light, near-white on dark) so the
            // grab bar reads clearly in BOTH themes — darker on light, lighter on
            // dark — instead of the faint, non-inverting outline.
            color: context.colors.onSurface.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(KasyRadius.full),
          ),
        ),
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  final IconData icon;
  final KasySheetIconTone tone;

  const _IconBubble({required this.icon, required this.tone});

  @override
  Widget build(BuildContext context) {
    final _SheetIconPalette p = _resolvePalette(context, tone);
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(color: p.background, shape: BoxShape.circle),
      child: Icon(icon, size: KasyIconSize.xxl, color: p.foreground),
    );
  }

  _SheetIconPalette _resolvePalette(BuildContext context, KasySheetIconTone tone) {
    final KasyColors c = context.colors;
    final bool dark = context.isDark;
    return switch (tone) {
      KasySheetIconTone.info => _SheetIconPalette(
        background: c.primary.withValues(alpha: dark ? 0.22 : 0.12),
        foreground: c.primary,
      ),
      KasySheetIconTone.success => _SheetIconPalette(
        background: c.success.withValues(alpha: dark ? 0.22 : 0.12),
        foreground: c.success,
      ),
      KasySheetIconTone.warning => _SheetIconPalette(
        background: c.warning.withValues(alpha: dark ? 0.22 : 0.12),
        foreground: c.warning,
      ),
      KasySheetIconTone.danger => _SheetIconPalette(
        background: c.error.withValues(alpha: dark ? 0.22 : 0.12),
        foreground: c.error,
      ),
      KasySheetIconTone.neutral => _SheetIconPalette(
        background: c.outline.withValues(alpha: dark ? 0.22 : 0.12),
        foreground: c.onSurface.withValues(alpha: 0.7),
      ),
    };
  }
}

class _SheetIconPalette {
  final Color background;
  final Color foreground;

  const _SheetIconPalette({required this.background, required this.foreground});
}
