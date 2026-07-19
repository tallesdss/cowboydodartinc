import 'package:cowboydodartinc/components/kasy_card.dart';
import 'package:cowboydodartinc/components/kasy_skeleton.dart';
import 'package:cowboydodartinc/core/haptics/kasy_haptics.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_hover.dart';
import 'package:flutter/material.dart';

class FeatureCard extends StatefulWidget {
  final String title;
  final String description;
  final int votes;
  final VoidCallback onVote;
  final bool disabled;
  final bool voted;

  const FeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.votes,
    required this.onVote,
    this.disabled = false,
    required this.voted,
  });

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  @override
  Widget build(BuildContext context) {
    return KasyCard(
      variant: KasyCardVariant.outlined,
      color: context.colors.surface,
      borderRadius: KasyRadius.lgBorderRadius,
      padding: const EdgeInsets.all(KasySpacing.md),
      child: Row(
        children: [
          switch (widget.voted) {
            false => VoteCard.blank(
                context: context,
                id: widget.title,
                votes: widget.votes,
                onVote: widget.onVote,
                disabled: widget.disabled,
              ),
            true => VoteCard.voted(
                context: context,
                id: widget.title,
                votes: widget.votes,
                onVote: widget.onVote,
                disabled: widget.disabled,
              ),
          },
          const SizedBox(width: KasySpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: context.kasyTextTheme.listRowTitle.copyWith(
                    color: context.colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.muted,
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

class VoteCard extends StatefulWidget {
  final int votes;
  final VoidCallback onVote;
  final Color borderColor;
  final Color bgColor;
  final Color textColor;
  final bool isBold;
  final bool disabled;
  final String id;

  const VoteCard({
    super.key,
    required this.votes,
    required this.onVote,
    required this.bgColor,
    required this.textColor,
    required this.isBold,
    required this.borderColor,
    required this.disabled,
    required this.id,
  });

  /// Not yet voted — muted/gray, inviting but clearly distinct from voted.
  factory VoteCard.blank({
    required BuildContext context,
    required VoidCallback onVote,
    required int votes,
    required bool disabled,
    required String id,
  }) =>
      VoteCard(
        id: id,
        onVote: onVote,
        votes: votes,
        bgColor: Colors.transparent,
        textColor: context.colors.muted,
        borderColor: context.colors.muted.withValues(alpha: 0.3),
        isBold: false,
        disabled: disabled,
      );

  /// Already voted — clear blue tint so the user knows they voted here.
  factory VoteCard.voted({
    required BuildContext context,
    required VoidCallback onVote,
    required int votes,
    required bool disabled,
    required String id,
  }) =>
      VoteCard(
        id: id,
        onVote: onVote,
        votes: votes,
        bgColor: context.colors.primary.withValues(alpha: 0.1),
        textColor: context.colors.primary,
        borderColor: context.colors.primary.withValues(alpha: 0.4),
        isBold: true,
        disabled: disabled,
      );

  @override
  State<VoteCard> createState() => _VoteCardState();
}

class _VoteCardState extends State<VoteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _nudge;
  bool _goingUp = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _nudge = Tween<double>(begin: 0, end: -4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(VoteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.votes != oldWidget.votes) {
      _goingUp = widget.votes > oldWidget.votes;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const colorDuration = Duration(milliseconds: 250);

    return KasyHover(
      onTap: () {
        if (widget.disabled) return;
        KasyHaptics.selection(context);
        widget.onVote();
        _controller.forward().then((_) => _controller.reverse());
      },
      borderRadius: KasyRadius.smBorderRadius,
      pressColor: widget.textColor,
      hapticEnabled: false,
      focusable: true,
      focusGapColor: context.colors.surface,
      child: AnimatedContainer(
        duration: colorDuration,
        curve: Curves.easeOut,
        width: 46,
        decoration: BoxDecoration(
          color: widget.bgColor,
          borderRadius: KasyRadius.smBorderRadius,
          border: Border.all(color: widget.borderColor),
        ),
        padding: const EdgeInsets.only(
          left: KasySpacing.xs,
          right: KasySpacing.xs,
          top: KasySpacing.xs,
          bottom: KasySpacing.sm,
        ),
        child: AnimatedBuilder(
          animation: _nudge,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, _nudge.value),
            child: child,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                KasyIcons.voteUp,
                size: KasyIconSize.lg,
                color: widget.textColor,
              ),
              ClipRect(
                child: AnimatedSwitcher(
                  duration: colorDuration,
                  transitionBuilder: (child, animation) {
                    final isIncoming = (child.key as ValueKey?)?.value ==
                        'votes-${widget.id}-${widget.votes}';
                    final beginOffset = isIncoming
                        ? (_goingUp
                            ? const Offset(0, 1)
                            : const Offset(0, -1))
                        : (_goingUp
                            ? const Offset(0, -1)
                            : const Offset(0, 1));
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: beginOffset,
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      )),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Text(
                    key: ValueKey('votes-${widget.id}-${widget.votes}'),
                    widget.votes.toString(),
                    style: context.textTheme.labelLarge?.copyWith(
                      fontSize: 15, // design-check: ignore — vote-count badge
                      height: 1,
                      fontWeight: FontWeight.w800,
                      color: widget.textColor,
                    ),
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

/// Skeleton placeholder mirroring [FeatureCard] (vote chip + title + body).
class FeatureCardSkeleton extends StatelessWidget {
  const FeatureCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return KasyCard(
      variant: KasyCardVariant.outlined,
      color: context.colors.surface,
      borderRadius: KasyRadius.lgBorderRadius,
      padding: const EdgeInsets.all(KasySpacing.md),
      child: const KasySkeletonGroup(
        child: Row(
          children: [
            KasySkeleton(
              width: 48,
              height: 56,
              borderRadius: BorderRadius.all(Radius.circular(KasyRadius.sm)),
            ),
            SizedBox(width: KasySpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KasySkeleton(width: double.infinity, height: 14),
                  SizedBox(height: 6),
                  KasySkeleton(width: double.infinity, height: 12),
                  SizedBox(height: 4),
                  KasySkeleton(width: 180, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
