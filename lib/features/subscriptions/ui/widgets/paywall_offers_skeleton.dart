import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Placeholder for a single price line while store offerings load.
class PaywallPriceSkeleton extends StatelessWidget {
  const PaywallPriceSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const KasySkeletonGroup(
      child: KasySkeleton(width: 128, height: 28),
    );
  }
}

/// Placeholder for side-by-side plan chips ([PaywallCompare]).
class PaywallPlanRowSkeleton extends StatelessWidget {
  const PaywallPlanRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const KasySkeletonGroup(
      child: Row(
        children: [
          Expanded(child: KasySkeleton(height: 88)),
          SizedBox(width: KasySpacing.sm),
          Expanded(child: KasySkeleton(height: 88)),
        ],
      ),
    );
  }
}

/// Placeholder for stacked plan cards ([PaywallUnlock]).
class PaywallPlanColSkeleton extends StatelessWidget {
  const PaywallPlanColSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const KasySkeletonGroup(
      child: Column(
        children: [
          KasySkeleton(width: double.infinity, height: 72),
          SizedBox(height: KasySpacing.sm),
          KasySkeleton(width: double.infinity, height: 72),
        ],
      ),
    );
  }
}

/// Placeholder for the trial toggle row ([PaywallTrial]).
class PaywallTrialSwitchSkeleton extends StatelessWidget {
  const PaywallTrialSwitchSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const KasySkeletonGroup(
      child: KasySkeleton(width: double.infinity, height: 52),
    );
  }
}
