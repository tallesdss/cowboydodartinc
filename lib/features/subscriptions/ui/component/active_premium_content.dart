import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/data/models/subscription.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/settings/ui/widgets/settings_tile.dart';
import 'package:cowboydodartinc/features/subscriptions/providers/premium_page_provider.dart';
import 'package:cowboydodartinc/features/subscriptions/shared/subscription_management.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

typedef OnTapUnSubscribe = void Function(String reason);
typedef OnExit = void Function();

class ActivePremiumContent extends ConsumerStatefulWidget {
  // kept for API compatibility — the manage flow no longer uses a feedback
  // reason collected here; PremiumPage still wires this for legacy callers.
  final OnTapUnSubscribe? onTap;
  final OnExit? onExit;

  const ActivePremiumContent({super.key, this.onExit, required this.onTap});

  @override
  ConsumerState<ActivePremiumContent> createState() =>
      _ActivePremiumContentState();
}

class _ActivePremiumContentState extends ConsumerState<ActivePremiumContent> {
  bool _isManaging = false;
  bool _isRestoring = false;

  void _goBack() {
    if (widget.onExit != null) {
      widget.onExit!();
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  /// Opens the subscription management interface for the current platform.
  /// On iOS/Android with RevenueCat → App Store / Play Store subscriptions page.
  /// On web with Stripe → Stripe Customer Portal.
  /// Cross-platform mismatch → informational dialog (subscription managed elsewhere).
  Future<void> _handleManageTap() async {
    final store = ref.read(userStateNotifierProvider).subscription?.store;
    final t = Translations.of(context).activePremium;

    if (resolveManageLocation(store) == ManageLocation.elsewhere) {
      await showKasyBlurDialog<void>(
        context: context,
        builder: (dialogCtx) => KasyDialog(
          leadingIcon: KasyIcons.payment,
          iconTone: KasyDialogIconTone.info,
          title: t.managed_elsewhere_title,
          message: t.managed_elsewhere_description,
          showCloseButton: false,
          confirmLabel: t.cancel_button,
          onConfirm: () => Navigator.of(dialogCtx).pop(),
        ),
      );
      return;
    }

    if (_isManaging) return;
    setState(() => _isManaging = true);
    try {
      // Active content never renders in admin preview (preview always shows the
      // offers screen), so the non-preview provider instance is the right one.
      await ref.read(premiumStateProvider().notifier).unsubscribe();
    } finally {
      if (mounted) setState(() => _isManaging = false);
    }
  }

  /// Re-syncs the subscription from RevenueCat / Stripe backend.
  Future<void> _handleRestoreTap() async {
    if (_isRestoring) return;
    setState(() => _isRestoring = true);
    try {
      await ref
          .read(userStateNotifierProvider.notifier)
          .refreshSubscription();
      if (!mounted) return;
      showKasyToast(
        context,
        title: Translations.of(context).premium.restore_success_title,
        tone: KasyToastTone.success,
      );
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userStateNotifierProvider);
    final t = Translations.of(context).activePremium;
    final sub = userState.subscription;
    final activeData = sub is SubscriptionStateData ? sub : null;
    final planName = activeData?.activeOffer?.title ?? t.plan_fallback;
    final price = activeData?.activeOffer?.price;
    final currency = activeData?.activeOffer?.currency;
    final entitlement = activeData?.entitlements?.firstOrNull;
    final expirationDate = entitlement?.expirationDate;
    final willRenew = entitlement?.willRenew ?? false;
    final isInTrial = entitlement?.isInTrial ?? false;

    return KasyOverlayScaffold(
      title: t.billing_title,
      onBack: _goBack,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            // Horizontal gutter already comes from KasyOverlayScaffold; keep
            // only vertical spacing here so the side padding matches the
            // Notifications screen (a single gutter, not doubled).
            padding: const EdgeInsets.fromLTRB(
              0,
              KasySpacing.sm,
              0,
              KasySpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Plan info ─────────────────────────────────────────────
                _SectionLabel(t.plan_label),
                const SizedBox(height: KasySpacing.xs),
                _PlanCard(
                  planName: planName,
                  price: price,
                  currency: currency,
                  expirationDate: expirationDate,
                  willRenew: willRenew,
                  isLifetime: sub?.isLifetime ?? false,
                  isInTrial: isInTrial,
                ),

                const SizedBox(height: KasySpacing.xl),

                // ── Actions ───────────────────────────────────────────────
                _ActionsCard(
                  onManage: _isManaging ? null : _handleManageTap,
                  onRestore: _handleRestoreTap,
                  isManaging: _isManaging,
                  isRestoring: _isRestoring,
                  manageLabel: t.manage_subscription,
                  restoreLabel: t.restore_purchases,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Private sub-widgets ──────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: KasySpacing.xs),
      child: Text(
        label,
        style: context.kasyTextTheme.sectionLabel.copyWith(
          color: context.colors.muted,
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String planName;
  final double? price;
  final String? currency;
  final DateTime? expirationDate;
  final bool willRenew;
  final bool isLifetime;
  final bool isInTrial;

  const _PlanCard({
    required this.planName,
    required this.price,
    required this.currency,
    required this.expirationDate,
    required this.willRenew,
    required this.isLifetime,
    required this.isInTrial,
  });

  String? _formattedPrice(BuildContext context) {
    if (price == null || currency == null || isLifetime) return null;
    final locale = Localizations.localeOf(context).toString();
    return NumberFormat.simpleCurrency(locale: locale, name: currency)
        .format(price);
  }

  String? _dateLabel(BuildContext context, {String? formattedPrice}) {
    if (isLifetime || expirationDate == null) return null;
    final locale = Localizations.localeOf(context).toString();
    final formatted = DateFormat.yMMMd(locale).format(expirationDate!);
    final t = context.t.activePremium;
    if (isInTrial) {
      if (formattedPrice == null) return t.trial_until(date: formatted);
      return t.charges_from(price: formattedPrice, date: formatted);
    }
    return willRenew ? t.renews_on(date: formatted) : t.expires_on(date: formatted);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.activePremium;
    final formattedPrice = _formattedPrice(context);
    final dateLabel = _dateLabel(context, formattedPrice: formattedPrice);
    return KasyCard(
      borderRadius: BorderRadius.circular(KasyRadius.lg),
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.md,
        vertical: KasySpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: KasySpacing.sm),
            child: Row(
              children: [
                Icon(
                  KasyIcons.payment,
                  size: KasyIconSize.rowLeading,
                  color: context.colors.onSurface,
                ),
                const SizedBox(width: KasySpacing.sm),
                Expanded(
                  child: Text(
                    planName,
                    // Content card title: 16 (listRowTitle) — the same role as
                    // the action rows below it, so label vs rows read as one
                    // hierarchy instead of the plan name being a step smaller.
                    style: context.kasyTextTheme.listRowTitle.copyWith(
                      color: context.colors.onSurface,
                    ),
                  ),
                ),
                if (isInTrial)
                  _TrialBadge(label: t.trial_label)
                else if (formattedPrice != null)
                  Text(
                    formattedPrice,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.muted,
                    ),
                  ),
              ],
            ),
          ),
          if (dateLabel != null)
            Padding(
              padding: const EdgeInsets.only(
                left: KasyIconSize.rowLeading + KasySpacing.sm,
                bottom: KasySpacing.sm,
              ),
              child: Text(
                dateLabel,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.muted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrialBadge extends StatelessWidget {
  final String label;
  const _TrialBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(KasyRadius.sm),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActionsCard extends StatelessWidget {
  final VoidCallback? onManage;
  final VoidCallback onRestore;
  final bool isManaging;
  final bool isRestoring;
  final String manageLabel;
  final String restoreLabel;

  const _ActionsCard({
    required this.onManage,
    required this.onRestore,
    required this.isManaging,
    required this.isRestoring,
    required this.manageLabel,
    required this.restoreLabel,
  });

  @override
  Widget build(BuildContext context) {
    return KasyCard(
      borderRadius: BorderRadius.circular(KasyRadius.lg),
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.md,
        vertical: KasySpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsTile(
            icon: KasyIcons.payment,
            title: manageLabel,
            onTap: isManaging ? () {} : (onManage ?? () {}),
            trailingWidget: isManaging
                ? KasySpinner(
                    diameter: KasyIconSize.rowTrailing,
                    color: context.colors.muted,
                  )
                : null,
          ),
          const SettingsDivider(),
          SettingsTile(
            icon: KasyIcons.refresh,
            title: restoreLabel,
            onTap: isRestoring ? () {} : onRestore,
            trailingWidget: isRestoring
                ? KasySpinner(
                    diameter: KasyIconSize.rowTrailing,
                    color: context.colors.muted,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
