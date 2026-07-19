import 'package:cowboydodartinc/core/config/features.dart';
import 'package:cowboydodartinc/core/data/models/entitlement.dart';
import 'package:cowboydodartinc/core/data/models/subscription.dart';
import 'package:cowboydodartinc/features/subscriptions/api/entities/subscription_entity.dart';
import 'package:cowboydodartinc/features/subscriptions/api/stripe_backend_api.dart';
import 'package:cowboydodartinc/features/subscriptions/api/subscription_payment_api.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:url_launcher/url_launcher.dart';

/// Stripe web subscription provider.
///
/// Uses hosted Stripe Checkout + Customer Portal: all card handling / PCI stay
/// on Stripe and the client only opens the URLs the backend returns. Premium
/// status lives server-side (the Stripe webhook writes the `subscriptions`
/// record), so this provider exposes no local entitlements — the repository
/// reads the status from the backend just like for RevenueCat.
class StripePaymentApi implements SubscriptionPaymentApi {
  final StripeBackendApi _backend;

  StripePaymentApi({required StripeBackendApi backend}) : _backend = backend;

  @override
  Future<void> init() async {}

  @override
  Future<void> initUser(String userId) async {}

  @override
  Future<void> disconnectUser() async {}

  @override
  Future<List<SubscriptionProduct>> getOffers(String? offerId) {
    return _backend.listPrices();
  }

  @override
  Future<void> purchaseProduct(SubscriptionProduct product) async {
    // On success, Stripe redirects this new tab to a tiny standalone page
    // (web/stripe_success.html) instead of reloading the whole app in a second
    // tab. The original app tab keeps polling and flips to premium via the
    // webhook. On cancel we send the user back to the app where they were.
    final appUrl = Uri.base.toString();
    // Pass the in-app language so the success page renders in the locale the
    // user picked here, not just the browser's (?lang= takes priority there).
    final lang = LocaleSettings.instance.currentLocale.languageCode;
    final successUrl = '${Uri.base.origin}/stripe_success.html?lang=$lang';
    final url = await _backend.createCheckoutSession(
      priceId: product.skuId,
      successUrl: successUrl,
      cancelUrl: appUrl,
      // Send the app language so the backend can persist it on the user and
      // deliver subscription notifications in the right language (on web there
      // is no registered device to read the locale from).
      locale: LocaleSettings.instance.currentLocale.languageCode,
      allowPromoCodes: withStripePromoCodes,
    );
    await _open(url);
    // Checkout is now open in a new tab. Payment is NOT confirmed yet — the
    // webhook will write the subscription record when the user pays. Throw so
    // the provider knows to poll for activation instead of setting active now.
    throw PendingWebCheckoutException();
  }

  @override
  Future<void> unsubscribe(SubscriptionStore? origin) async {
    final url = await _backend.createPortalSession(
      returnUrl: Uri.base.toString(),
      planSwitching: withStripePlanSwitching,
    );
    await _open(url);
  }

  @override
  Future<void> restorePurchase() async {
    // Stripe status is server-side (webhook -> backend). Nothing to restore on
    // the device; the repository re-reads the subscription from the backend.
  }

  @override
  Future<List<Entitlement>> getPermissions() async => [];

  @override
  Future<List<Entitlement>?> getEntitlements() async => [];

  @override
  Future<SubscriptionProduct?> getFromProductId(String productId) async {
    final prices = await _backend.listPrices();
    for (final price in prices) {
      if (price.skuId == productId) return price;
    }
    return null;
  }

  @override
  Future<void> presentCodeRedemptionSheet() async {}

  Future<void> _open(String url) async {
    await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
  }
}
