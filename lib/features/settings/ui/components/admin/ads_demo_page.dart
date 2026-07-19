import 'package:cowboydodartinc/components/kasy_app_bar.dart';
import 'package:cowboydodartinc/components/kasy_card.dart';
import 'package:cowboydodartinc/core/ads/ads_provider.dart';
import 'package:cowboydodartinc/core/ads/ads_types.dart';
import 'package:cowboydodartinc/core/ads/widgets/kasy_ad_banner.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/toast/toast_service.dart';
import 'package:cowboydodartinc/core/widgets/kasy_hover.dart';
import 'package:cowboydodartinc/core/widgets/kasy_scroll_behavior.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/environments.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Developer showcase of the four AdMob formats (banner, interstitial, rewarded,
/// rewarded-interstitial), shown with Google test ads.
///
/// Built for "easy to test + easy to place": tap a card to fire the ad, and copy
/// the exact snippet to drop it wherever you want. A status line says whether
/// real ids are configured and how to set them (`kasy configure`).
///
/// Native-only: on web the banner renders nothing and the actions show a "native
/// only" toast. Reached as a drill-down from the admin Debug section (kDebugMode).
class AdsDemoPage extends ConsumerWidget {
  const AdsDemoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = t.settings.admin;
    final ads = ref.read(googleAdsProvider.notifier);
    final toast = ref.read(toastProvider);
    final bool isConfigured = ref.read(environmentProvider).isAdsConfigured;

    void onFailed() => toast.alert(
      title: t.common.native_only_title,
      text: kIsWeb ? admin.native_only : admin.ads_load_failed,
    );
    void onReward(AdReward reward) => toast.alert(
      title: admin.ads_demo_title,
      text: admin.ads_reward_earned(
        amount: reward.amount.toString(),
        type: reward.type,
      ),
    );
    void copy(String code) {
      Clipboard.setData(ClipboardData(text: code));
      toast.alert(title: t.common.copied, text: admin.ads_code_copied);
    }

    return ScrollConfiguration(
      behavior: const KasyKitScrollBehavior(),
      child: KasyOverlayScaffold(
        title: admin.ads_demo_title,
        onBack: () => context.pop(),
        // Contain + center on desktop, matching the other admin drill-downs.
        maxContentWidth: kKasyContentMaxWidth,
        slivers: [
          SliverList.list(
            children: [
              Text(
                admin.ads_demo_subtitle,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.muted,
                ),
              ),
              const SizedBox(height: KasySpacing.md),
              _StatusCard(
                isConfigured: isConfigured,
                onCopyCommand: () => copy('kasy configure'),
              ),
              const SizedBox(height: KasySpacing.md),
              _BannerCard(label: admin.ads_banner_label, onCopy: copy),
              const SizedBox(height: KasySpacing.md),
              _AdFormatCard(
                title: admin.ads_interstitial_title,
                description: admin.ads_interstitial_desc,
                code: 'ref.read(googleAdsProvider.notifier)\n'
                    '    .showInterstitial();',
                onShow: () =>
                    ads.showInterstitial(onFailed: onFailed, forceTestAd: true),
                onCopy: copy,
              ),
              const SizedBox(height: KasySpacing.sm),
              _AdFormatCard(
                title: admin.ads_rewarded_title,
                description: admin.ads_rewarded_desc,
                code: 'ref.read(googleAdsProvider.notifier).showRewarded(\n'
                    '  onReward: (reward) {/* grant it */},\n'
                    ');',
                onShow: () => ads.showRewarded(
                  onReward: onReward,
                  onFailed: onFailed,
                  forceTestAd: true,
                ),
                onCopy: copy,
              ),
              const SizedBox(height: KasySpacing.sm),
              _AdFormatCard(
                title: admin.ads_rewarded_interstitial_title,
                description: admin.ads_rewarded_interstitial_desc,
                code:
                    'ref.read(googleAdsProvider.notifier).showRewardedInterstitial(\n'
                    '  onReward: (reward) {/* grant it */},\n'
                    ');',
                onShow: () => ads.showRewardedInterstitial(
                  onReward: onReward,
                  onFailed: onFailed,
                  forceTestAd: true,
                ),
                onCopy: copy,
              ),
              const SizedBox(height: KasySpacing.md),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Test ads in use / real ids configured" + a copyable `kasy configure` hint.
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.isConfigured, required this.onCopyCommand});

  final bool isConfigured;
  final VoidCallback onCopyCommand;

  @override
  Widget build(BuildContext context) {
    final admin = t.settings.admin;
    return KasyCard(
      padding: const EdgeInsets.all(KasySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Safety note (always): this demo never serves real ads, so tapping it
          // can't trigger AdMob "invalid activity" (self-clicks) in production.
          Row(
            children: [
              Icon(
                KasyIcons.checkCircle,
                size: KasyIconSize.sm,
                color: context.colors.success,
              ),
              const SizedBox(width: KasySpacing.sm),
              Expanded(
                child: Text(
                  admin.ads_status_safe,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.muted,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: KasySpacing.sm),
          Text(
            isConfigured ? admin.ads_status_real : admin.ads_status_test,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.muted,
              height: 1.35,
            ),
          ),
          if (!isConfigured) ...[
            const SizedBox(height: KasySpacing.smd),
            _CodeBlock(code: 'kasy configure', onCopy: onCopyCommand),
          ],
        ],
      ),
    );
  }
}

/// A live banner (native) or a "native only" note (web), plus its snippet.
class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.label, required this.onCopy});

  final String label;
  final void Function(String code) onCopy;

  @override
  Widget build(BuildContext context) {
    const String code = 'const KasyAdBanner()';
    return KasyCard(
      padding: const EdgeInsets.all(KasySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: KasySpacing.sm),
          if (kIsWeb)
            Text(
              t.settings.admin.native_only,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.muted,
              ),
            )
          else
            const Center(
              // Always a test ad — safe to render in any build (incl. production).
              child: KasyAdBanner(
                size: KasyAdBannerSize.mediumRectangle,
                forceTestAd: true,
              ),
            ),
          const SizedBox(height: KasySpacing.smd),
          _CodeBlock(code: code, onCopy: () => onCopy(code)),
        ],
      ),
    );
  }
}

/// A full-screen format: tap the card to fire it, copy the snippet to use it.
class _AdFormatCard extends StatelessWidget {
  const _AdFormatCard({
    required this.title,
    required this.description,
    required this.code,
    required this.onShow,
    required this.onCopy,
  });

  final String title;
  final String description;
  final String code;
  final VoidCallback onShow;
  final void Function(String code) onCopy;

  @override
  Widget build(BuildContext context) {
    return KasyHover(
      onTap: onShow,
      borderRadius: BorderRadius.circular(KasyRadius.lg),
      semanticLabel: title,
      child: KasyCard(
        padding: const EdgeInsets.all(KasySpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: KasySpacing.sm),
                Icon(
                  KasyIcons.chevronRight,
                  size: 18,
                  color: context.colors.muted,
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              description,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.muted,
                height: 1.35,
              ),
            ),
            const SizedBox(height: KasySpacing.smd),
            _CodeBlock(code: code, onCopy: () => onCopy(code)),
          ],
        ),
      ),
    );
  }
}

/// Monospace, full-width code block with a copy button. Its own tap target, so
/// it never triggers the surrounding card.
class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.code, required this.onCopy});

  final String code;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.surfaceNeutralSoft,
        borderRadius: BorderRadius.circular(KasyRadius.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              code,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.onSurface,
                fontFamily: 'monospace',
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(width: KasySpacing.sm),
          KasyHover(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(KasyRadius.sm),
            semanticLabel: t.common.copied,
            child: Icon(KasyIcons.copy, size: 14, color: context.colors.primary),
          ),
        ],
      ),
    );
  }
}
