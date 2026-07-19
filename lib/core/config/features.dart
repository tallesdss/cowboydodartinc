/// Feature flags — gerado pelo Kasy CLI conforme escolhas do usuário.
/// Quando false, o router ignora as rotas dessa feature e o guard ignora.
// ignore_for_file: avoid_redundant_argument_values
const bool withOnboarding = true;
const bool withAiChat    = true;
// AdMob ads module (banner, interstitial, rewarded, rewarded-interstitial).
// Mobile-only; no-op on web. Premium users skip auto-served ads.
const bool withAds = true;
const bool withFeedback            = true;
const bool withRevenuecat          = true;
// Stripe web subscriptions module (independent from RevenueCat mobile IAP).
const bool withStripe              = true;
// When true, Stripe Checkout shows a promo-code / coupon field.
const bool withStripePromoCodes = true;
// When true, the Stripe Customer Portal lets subscribers switch plans (upgrade / downgrade).
const bool withStripePlanSwitching = true;
const bool withLocalReminders  = true;
const bool withKanban = true;
// Apple sign-in on web: ships false until configured with `kasy apple-web` (needs a
// paid Apple Service ID + signed secret). The command flips this to true once web
// Apple actually works, so the button never appears dead. Native always shows it.
const bool withAppleWebSignin = false;
// Facebook sign-in on web: ships false until configured with `kasy facebook` on the
// Firebase backend (signInWithPopup). On Supabase the web flow is roadmap, so it stays
// false there. Native (iOS/Android) always shows the Facebook button.
const bool withFacebookWebSignin = false;
/// Quando true, o app inclui suporte web:
///   - cadastro anônimo desativado na web (usuário redirecionado para /signin)
///   - onboarding ignorado na web
///   - home widgets e background fetch são no-op na web
const bool withWeb = true;
