import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/feedbacks/models/feature_requests.dart';
import 'package:cowboydodartinc/features/feedbacks/providers/feedback_page_notifier.dart';
import 'package:cowboydodartinc/features/feedbacks/ui/component/add_feature_form.dart';
import 'package:cowboydodartinc/features/feedbacks/ui/widgets/feature_card.dart';
import 'package:cowboydodartinc/features/settings/ui/widgets/settings_subpage_scaffold.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedbackPage extends ConsumerWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedbackPageProvider);
    final translations = Translations.of(context).feature_requests;

    return SettingsSubpageScaffold(
      title: translations.title,
      trailing: _AddChipButton(
        label: translations.add_feature.chip_label,
        onPressed: () async {
          final success = await showAddFeatureSheet(context);
          if (success == true && context.mounted) {
            showSuccessToast(
              context: context,
              title: translations.add_feature.toast_success.title,
              text: translations.add_feature.toast_success.description,
            );
          }
        },
      ),
      body: state.map(
        data: (data) {
          if (data.value.featureRequests.isEmpty) {
            return KasyEmptyState(
              icon: KasyIcons.idea,
              title: translations.no_requests,
              subtitle: translations.no_requests_hint,
              padding: const EdgeInsets.all(KasySpacing.lg),
            );
          }
          return _FeatureRequestList(
            featureRequests: data.value.featureRequests,
            hasVoted: data.value.hasVoted,
            onVote: (index) {
              ref
                  .read(feedbackPageProvider.notifier)
                  .vote(data.value.featureRequests[index]);
            },
          );
        },
        error: (error) => Center(child: Text(error.error.toString())),
        loading: (data) {
          if (!data.hasValue) {
            return const _FeatureRequestListSkeleton();
          }
          return _FeatureRequestList(
            featureRequests: data.value!.featureRequests,
            hasVoted: data.value!.hasVoted,
            onVote: (_) {},
            disabled: true,
          );
        },
      ),
    );
  }
}

class _FeatureRequestList extends StatelessWidget {
  const _FeatureRequestList({
    required this.featureRequests,
    required this.hasVoted,
    required this.onVote,
    this.disabled = false,
  });

  final List<FeatureRequest> featureRequests;
  final bool Function(FeatureRequest request) hasVoted;
  final ValueChanged<int> onVote;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < featureRequests.length; i++) ...[
          if (i > 0) const SizedBox(height: KasySpacing.sm),
          FeatureCard(
            title: featureRequests[i].title,
            description: featureRequests[i].description,
            votes: featureRequests[i].votes,
            onVote: () => onVote(i),
            disabled: disabled,
            voted: hasVoted(featureRequests[i]),
          ),
        ],
      ],
    );
  }
}

class _FeatureRequestListSkeleton extends StatelessWidget {
  const _FeatureRequestListSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeatureCardSkeleton(),
        SizedBox(height: KasySpacing.sm),
        FeatureCardSkeleton(),
        SizedBox(height: KasySpacing.sm),
        FeatureCardSkeleton(),
        SizedBox(height: KasySpacing.sm),
        FeatureCardSkeleton(),
      ],
    );
  }
}

class _AddChipButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _AddChipButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return KasyAppBarChromeTap(
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: KasySpacing.md,
          vertical: KasySpacing.sm,
        ),
        decoration: BoxDecoration(
          color: context.colors.primary.withValues(alpha: 0.1),
          borderRadius: KasyRadius.mdBorderRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              KasyIcons.add,
              size: KasyIconSize.xs,
              color: context.colors.primary,
            ),
            const SizedBox(width: KasySpacing.xs),
            Text(
              label,
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
