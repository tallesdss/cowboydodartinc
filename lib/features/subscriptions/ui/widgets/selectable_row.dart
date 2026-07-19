import 'package:cowboydodartinc/core/haptics/kasy_haptics.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_hover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

typedef OnSelectItem<T> = void Function(T data);

class SelectableRowGroup<T> extends StatefulWidget {
  final List<SelectableOption<T>> items;
  final OnSelectItem<T> onSelectItem;
  final int initialSelectedIndex;
  final Brightness brightness;

  const SelectableRowGroup({
    super.key,
    required this.items,
    required this.onSelectItem,
    this.initialSelectedIndex = 0,
    this.brightness = Brightness.light,
  });

  @override
  State<SelectableRowGroup> createState() => _SelectableRowGroupState<T>();
}

class _SelectableRowGroupState<T> extends State<SelectableRowGroup<T>> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialSelectedIndex;
  }

  OnSelectItem<T> get onSelectItem => widget.onSelectItem;

  void _selectIndex(int i) {
    setState(() {
      if (selectedIndex == i) {
        return;
      }
      KasyHaptics.heavy(context);
      selectedIndex = i;
      onSelectItem(widget.items[i].data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < widget.items.length; i++)
          KasyHover(
            onTap: () => _selectIndex(i),
            focusable: true,
            borderRadius: KasyRadius.mdBorderRadius,
            // The card paints its own animated selection border, so suppress the
            // hover/press fill: KasyHover only contributes the web click cursor
            // and the keyboard focus ring. The heavy selection haptic is fired
            // by _selectIndex, so opt out of the default tap haptic.
            hapticEnabled: false,
            hoverEnabled: false,
            pressEnabled: false,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: i == widget.items.length - 1 ? 0 : KasySpacing.sm,
              ),
              child: Animate(
                effects: [
                  FadeEffect(
                    delay: Duration(milliseconds: 100 + 100 * i),
                    duration: const Duration(milliseconds: 500),
                  ),
                ],
                child: SelectableRow.fromOption(
                  key: ValueKey('item_$i'),
                  widget.items[i],
                  selected: selectedIndex == i,
                  brightness: widget.brightness,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class SelectableOption<T> {
  final String label;
  final String price;
  final String sublabel;
  final String? trial;
  final String? promotion;
  final T data;
  final IconData? icon;
  final String? pricePerOtherDuration;

  const SelectableOption({
    this.icon,
    required this.label,
    required this.price,
    required this.data,
    required this.sublabel,
    this.promotion,
    this.trial,
    this.pricePerOtherDuration,
  });
}

class SelectableRow extends StatefulWidget {
  final bool selected;
  final String label;
  final String price;
  final String? pricePerOtherDuration;
  final String sublabel;
  final String? trial;
  final String? promotion;
  final bool disabled;
  final Brightness brightness;

  const SelectableRow({
    super.key,
    required this.selected,
    required this.label,
    required this.price,
    required this.sublabel,
    required this.brightness,
    this.pricePerOtherDuration,
    this.promotion,
    this.disabled = false,
    this.trial,
  });

  factory SelectableRow.fromOption(
    SelectableOption option, {
    Key? key,
    required bool selected,
    required Brightness brightness,
  }) {
    return SelectableRow(
      key: key,
      selected: selected,
      label: option.label,
      price: option.price,
      sublabel: option.sublabel,
      trial: option.trial,
      promotion: option.promotion,
      pricePerOtherDuration: option.pricePerOtherDuration,
      brightness: brightness,
    );
  }

  @override
  State<SelectableRow> createState() => _SelectableRowState();
}

class _SelectableRowState extends State<SelectableRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _iconSizeAnimation;

  @override
  void didUpdateWidget(covariant SelectableRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected && widget.selected) {
      _controller.forward();
    } else if (oldWidget.selected != widget.selected && !widget.selected) {
      _controller.reverse();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _opacityAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.ease));
    _iconSizeAnimation = Tween(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.ease));
    if (widget.selected) {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => SizedBox(
        height: widget.trial != null ? 110 : 90,
        child: Stack(
          children: [
            Positioned(
              top: KasySpacing.smd,
              left: 0,
              right: 0,
              bottom: 0,
              child: Opacity(
                opacity: widget.disabled ? .6 : 1,
                child: Container(
                  height: widget.trial != null ? 90 : 90,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: .1),
                    borderRadius: KasyRadius.mdBorderRadius,
                    border: Border.all(
                      width: 3,
                      strokeAlign: BorderSide.strokeAlignOutside,
                      color: widget.selected
                          ? context.colors.primary.withValues(
                              alpha: _opacityAnimation.value,
                            )
                          : context.colors.primary.withValues(
                              alpha: .3 * _opacityAnimation.value + .15,
                            ),
                    ),
                  ),
                  // padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: KasySpacing.smd),
                            Expanded(
                              flex: 3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Spacer(),
                                  Flexible(
                                    flex: 0,
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: widget.label.toUpperCase(),
                                            style: context.textTheme.titleMedium?.copyWith(
                                                  color: switch (widget
                                                      .brightness) {
                                                    Brightness.dark =>
                                                      context
                                                          .colors
                                                          .onBackground,
                                                    Brightness.light =>
                                                      context.colors.background,
                                                  },
                                                ),
                                          ),
                                          if (widget.pricePerOtherDuration !=
                                              null)
                                            TextSpan(
                                              text:
                                                  '    (${widget.pricePerOtherDuration!})',
                                              style: context.textTheme.bodySmall?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: switch (widget
                                                        .brightness) {
                                                      Brightness.dark =>
                                                        context
                                                            .colors
                                                            .onBackground
                                                            .withValues(
                                                              alpha: 0.7,
                                                            ),
                                                      Brightness.light =>
                                                        context
                                                            .colors
                                                            .background
                                                            .withValues(
                                                              alpha: 0.7,
                                                            ),
                                                    },
                                                  ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: KasySpacing.xs),
                                  Text(
                                    widget.sublabel,
                                    style: context.textTheme.bodySmall?.copyWith(
                                          color: switch (widget.brightness) {
                                            Brightness.dark =>
                                              context.colors.onBackground
                                                  .withValues(alpha: 0.6),
                                            Brightness.light =>
                                              context.colors.background
                                                  .withValues(alpha: 0.6),
                                          },
                                        ),
                                    maxLines: 1,
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            ),
                            const SizedBox(width: KasySpacing.md),
                            if (widget.selected)
                              RoundRadioBox.selected(
                                context,
                                iconOpacity: _opacityAnimation.value,
                                iconSize: _iconSizeAnimation.value,
                              )
                            else
                              RoundRadioBox.unselected(context),
                            const SizedBox(width: KasySpacing.md),
                          ],
                        ),
                      ),
                      if (widget.trial != null)
                        Flexible(
                          flex: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.colors.background,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(KasyRadius.md),
                                bottomRight: Radius.circular(KasyRadius.md),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: KasySpacing.xs),
                            child: Text(
                              widget.trial!,
                              textAlign: TextAlign.center,
                              style: context.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: context.colors.onBackground
                                        .withValues(alpha: .87),
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.promotion != null)
              Positioned(
                top: 0,
                right: KasySpacing.lg,
                child: Container(
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    borderRadius: KasyRadius.mdBorderRadius,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: KasySpacing.md),
                  child: Text(
                    widget.promotion!,
                    textAlign: TextAlign.center,
                    style: context.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                      color: context.colors.onPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class RoundRadioBox extends StatelessWidget {
  final Color bgColor;
  final Color borderColor;
  final IconData? icon;
  final double iconOpacity;
  final double iconSize;

  const RoundRadioBox({
    super.key,
    required this.bgColor,
    required this.borderColor,
    this.iconOpacity = 1,
    this.iconSize = 1,
    this.icon,
  });

  factory RoundRadioBox.selected(
    BuildContext context, {
    double iconOpacity = 1,
    double iconSize = 1,
  }) {
    return RoundRadioBox(
      bgColor: context.colors.primary,
      borderColor: context.colors.onBackground.withValues(alpha: .3),
      icon: KasyIcons.check,
      iconOpacity: iconOpacity,
      iconSize: iconSize,
    );
  }

  // ignore: avoid_unused_constructor_parameters
  factory RoundRadioBox.unselected(BuildContext context) {
    return RoundRadioBox(
      bgColor: context.colors.outline,
      borderColor: context.colors.onBackground.withValues(alpha: .3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Center(
        child: icon != null
            ? Opacity(
                opacity: iconOpacity,
                child: Transform.scale(
                  scale: iconSize,
                  child: Icon(icon, color: context.colors.background, size: KasyIconSize.sm),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
