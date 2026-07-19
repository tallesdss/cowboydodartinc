import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_background.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_progress.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_step_header.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_sticky_footer.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/selectable_row_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef OptionBuilder = Widget Function(String key, bool selected);

typedef ReassuranceBuilder = Widget? Function(String key);

typedef OnOptionIdSelected = void Function(String id);

typedef OnValidate = void Function(String? key);

/// How the options are laid out: a full‑width stacked [list] (rows), or a
/// centered [wrap] of pill chips (compact, great for short labels).
enum OnboardingQuestionLayout { list, wrap }

/// No‑op for the invisible secondary‑action placeholder (never tapped — its
/// [Visibility] keeps it non‑interactive). A top‑level tear‑off so the
/// placeholder can stay `const`.
void _noop() {}

/// Single choice question with selectable tiles, matching the clean‑premium
/// onboarding layout (shared header, left‑aligned title, sticky footer).
class OnboardingRadioQuestion extends ConsumerStatefulWidget {
  final int step;
  final int totalSteps;
  final String title;
  final String description;
  final String btnText;
  final List<String> optionIds;
  final OptionBuilder optionBuilder;
  final ReassuranceBuilder? reassuranceBuilder;
  final OnOptionIdSelected? onOptionIdSelected;
  final OnValidate? onValidate;
  final OnboardingQuestionLayout layout;

  /// When set, the screen becomes an image hero: the asset fills the backdrop
  /// (faces near the top) with a bottom‑to‑top scrim, and the question + options
  /// sit over the solid lower part. Null → the standard clean layout.
  final String? heroImageAsset;

  /// Optional deterministic chip‑row split for the `wrap` layout, e.g. `[3, 2]`.
  /// Null → a single flowing wrap. Only used when [layout] is `wrap`.
  final List<int>? wrapRowCounts;

  const OnboardingRadioQuestion({
    super.key,
    required this.title,
    required this.description,
    required this.btnText,
    required this.optionIds,
    required this.optionBuilder,
    required this.step,
    this.totalSteps = kOnboardingSteps,
    this.onOptionIdSelected,
    this.onValidate,
    this.reassuranceBuilder,
    this.layout = OnboardingQuestionLayout.list,
    this.heroImageAsset,
    this.wrapRowCounts,
  });

  @override
  ConsumerState<OnboardingRadioQuestion> createState() =>
      _OnboardingRadioQuestionState();
}

class _OnboardingRadioQuestionState
    extends ConsumerState<OnboardingRadioQuestion> {
  String? selectedChoiceId;

  static const double _gutter = KasySpacing.lg;

  Widget _title(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(_gutter, _gutter, _gutter, 0),
        child: Text(
          widget.title,
          textAlign: TextAlign.start,
          // Design-system page-title scale (headlineMedium = 24/w700),
          // matching the illustration steps instead of a bespoke 26px size.
          style: context.textTheme.headlineMedium?.copyWith(
            color: context.colors.onBackground,
          ),
        ),
      );

  Widget _description(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          _gutter,
          KasySpacing.smd,
          _gutter,
          KasySpacing.lg,
        ),
        child: Text(
          widget.description,
          textAlign: TextAlign.start,
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colors.muted,
            height: 1.45,
          ),
        ),
      );

  /// Centered title + description for the image‑hero layout, mirroring the
  /// feature steps (headlineLarge title, bodyLarge muted description, centered).
  Widget _heroTextBlock(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: _gutter),
        child: Column(
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: context.textTheme.headlineLarge?.copyWith(
                color: context.colors.onBackground,
              ),
            ),
            const SizedBox(height: KasySpacing.smd),
            Text(
              widget.description,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.muted,
                height: 1.45,
              ),
            ),
          ],
        ),
      );

  /// The selectable options (chips in a wrap, or full‑width rows). No entrance
  /// animation and no outer padding — callers add the gutter.
  Widget _optionsGroup() {
    final options = [
      for (int i = 0; i < widget.optionIds.length; i++)
        widget.optionBuilder(
          widget.optionIds[i],
          widget.optionIds[i] == selectedChoiceId,
        ),
    ];
    void onSelect(int index, bool selected) {
      widget.onOptionIdSelected?.call(widget.optionIds[index]);
      setState(() => selectedChoiceId = widget.optionIds[index]);
    }

    return widget.layout == OnboardingQuestionLayout.wrap
        ? OnboardingSelectableChipGroup(
            options: options,
            onSelect: onSelect,
            rowCounts: widget.wrapRowCounts,
          )
        : OnboardingSelectableRowGroup(
            physics: const NeverScrollableScrollPhysics(),
            options: options,
            onSelect: onSelect,
            onSelectInfoWidget: widget.optionIds
                .map((el) => widget.reassuranceBuilder?.call(el))
                .toList(),
          );
  }

  Widget _footer(BuildContext context) => DeviceSizeBuilder(
        builder: (device) => OnboardingStickyFooter(
          // Match the illustration steps exactly so the counter + button land at
          // the same height on every screen: no entrance animation, an `xl` gap
          // under the counter, and the same reserved (invisible) secondary slot.
          animate: false,
          maxContentWidth: device == DeviceType.small ? null : 600,
          children: [
            OnboardingProgress(step: widget.step, totalSteps: widget.totalSteps),
            const SizedBox(height: KasySpacing.xl),
            KasyButton(
              label: widget.btnText,
              expand: true,
              onPressed: selectedChoiceId == null
                  ? null
                  : () => widget.onValidate?.call(selectedChoiceId),
            ),
            const SizedBox(height: KasySpacing.xs),
            // Reserve the secondary action's footprint (the feature steps have a
            // login/secondary link here), keeping the primary button aligned.
            const Visibility(
              visible: false,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: KasyButton(
                label: ' ',
                variant: KasyButtonVariant.link,
                expand: true,
                onPressed: _noop,
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (widget.heroImageAsset != null) return _buildImageHero(context);

    final scrollBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingStepHeader(),
        _title(context),
        _description(context),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _gutter),
          child: _optionsGroup(),
        ),
        const SizedBox(height: KasySpacing.xl),
      ],
    );

    return OnboardingBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: KasySpacing.md),
                child: ResponsiveBuilder(
                  small: scrollBody,
                  medium: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: scrollBody,
                    ),
                  ),
                ),
              ),
            ),
          ),
          _footer(context),
        ],
      ),
    );
  }

  /// Image‑hero layout: the asset fills the backdrop (top‑aligned so faces stay
  /// visible) under a bottom‑to‑top scrim; the question + options ride the solid
  /// lower part, with the sticky footer below. Scrolls if the content is tall.
  Widget _buildImageHero(BuildContext context) {
    final Color bg = context.colors.background;
    return ColoredBox(
      color: bg,
      child: Stack(
        children: [
          Positioned.fill(
            // fitWidth (vs cover) shows the full scene side‑to‑side — a touch
            // less zoomed; the small upward nudge lifts the framing and trims the
            // empty headroom at the top. The image's lower edge lands inside the
            // solid part of the scrim below, so there's no visible seam.
            child: Transform.translate(
              offset: const Offset(0, -28),
              child: Image.asset(
                widget.heroImageAsset!,
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          // Solid at the bottom (where the content sits), clearing over the image.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [bg, bg, bg.withValues(alpha: 0.0)],
                  stops: const [0.0, 0.50, 0.80],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SafeArea(
                  bottom: false,
                  child: LayoutBuilder(
                    builder: (ctx, c) => SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: c.maxHeight),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const OnboardingStepHeader(),
                            // Reserve the upper area for the image, pushing the
                            // question block down onto the scrim.
                            SizedBox(height: c.maxHeight * 0.50),
                            // Centered title + description, matching the feature
                            // steps (OnboardingIllustrationScaffold) exactly.
                            _heroTextBlock(context),
                            const SizedBox(height: KasySpacing.lg),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: _gutter,
                              ),
                              child: _optionsGroup(),
                            ),
                            const SizedBox(height: KasySpacing.md),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _footer(context),
            ],
          ),
        ],
      ),
    );
  }
}
