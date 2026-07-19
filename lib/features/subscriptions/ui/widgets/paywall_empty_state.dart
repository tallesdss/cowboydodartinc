import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/premium_page_factory.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/premium_background_gradient.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/premium_bottom_menu.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/premium_close_button.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';

class PaywallEmptyState extends StatelessWidget {
  final OnTap? onTapRestore;
  final OnTap? onSkip;

  const PaywallEmptyState({
    super.key,
    required this.onTapRestore,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context).premium;

    return Scaffold(
      backgroundColor: context.colors.primary,
      body: PremiumBackgroundGradient(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KasySpacing.pageHorizontalGutter,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: AppCloseButton(onTap: () => onSkip?.call()),
                ),
                const Spacer(),
                Text(
                  translations.no_products_title,
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: context.colors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: KasySpacing.smd),
                Text(
                  translations.no_products_description,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onPrimary.withValues(alpha: .9),
                  ),
                ),
                const Spacer(),
                BottomPremiumMenu(
                  textColor: context.colors.onPrimary,
                  onTapRestore: onTapRestore,
                ),
                const SizedBox(height: KasySpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
