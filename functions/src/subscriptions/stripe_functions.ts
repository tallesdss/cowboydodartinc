import {error} from "firebase-functions/logger";
import {onCall, onRequest, HttpsError} from "firebase-functions/v2/https";
import {onDocumentDeleted} from "firebase-functions/v2/firestore";
import {defineSecret, defineString} from "firebase-functions/params";
import * as admin from "firebase-admin";
import {Timestamp} from "firebase-admin/firestore";
import Stripe from "stripe";
import {Subscription} from "./models/subscriptions";
import {subscriptionsRepository, usersRepository} from "../core/data/repositories/repositories";
import {Stores, SubscriptionStatus} from "./models/subscription_status";

// Server-side only. Never exposed to the client.
const stripeSecretKey = defineSecret("STRIPE_SECRET_KEY");
const stripeWebhookSecret = defineSecret("STRIPE_WEBHOOK_SECRET");
// Optional: restrict the listed prices to a single Stripe product.
const stripeProductId = defineString("STRIPE_PRODUCT_ID", {default: ""});

// Firestore collection mapping a Firebase uid -> its Stripe customer id.
const CUSTOMERS_COLLECTION = "stripe_customers";

function stripeClient(): Stripe {
  return new Stripe(stripeSecretKey.value());
}

async function getOrCreateCustomer(
  stripe: Stripe,
  uid: string,
  email?: string,
): Promise<string> {
  const db = admin.firestore();
  const ref = db.collection(CUSTOMERS_COLLECTION).doc(uid);
  const snap = await ref.get();
  const existing = snap.data()?.customerId as string | undefined;
  if (existing) {
    // Keep the Stripe customer email in sync so Checkout pre-fills it and the
    // receipts carry the right address. The payment is bound to the app user by
    // UID (customer + metadata.firebaseUID), never by the typed email, so this
    // is purely UX / billing hygiene.
    if (email) await stripe.customers.update(existing, {email});
    return existing;
  }
  const customer = await stripe.customers.create({
    email,
    metadata: {firebaseUID: uid},
  });
  await ref.set({customerId: customer.id, created_at: Timestamp.now()});
  return customer.id;
}

function trialDaysFor(price: Stripe.Price, product: Stripe.Product): number | null {
  const meta = price.metadata?.trial_days ?? product.metadata?.trial_days;
  return meta ? Number(meta) : null;
}

// ---------------------------------------------------------------------------
// listPrices — active recurring prices, mapped to the paywall offer contract.
// ---------------------------------------------------------------------------
export const listPrices = onCall({secrets: [stripeSecretKey]}, async () => {
  const stripe = stripeClient();
  const params: Stripe.PriceListParams = {
    active: true,
    type: "recurring",
    expand: ["data.product"],
    limit: 100,
  };
  const productFilter = stripeProductId.value();
  if (productFilter) params.product = productFilter;

  const prices = await stripe.prices.list(params);
  return prices.data
    .filter((p) => Boolean(p.recurring))
    .map((p) => {
      const product = p.product as Stripe.Product;
      const features = (product.marketing_features ?? [])
        .map((f) => f.name)
        .filter((n): n is string => Boolean(n));
      return {
        priceId: p.id,
        productId: typeof p.product === "string" ? p.product : product.id,
        productName: product.name ?? "",
        description: product.description ?? "",
        unitAmount: p.unit_amount ?? 0,
        currency: p.currency,
        interval: p.recurring?.interval ?? "month",
        intervalCount: p.recurring?.interval_count ?? 1,
        trialDays: trialDaysFor(p, product),
        features,
      };
    });
});

// ---------------------------------------------------------------------------
// createCheckoutSession — hosted Stripe Checkout (mode=subscription).
// ---------------------------------------------------------------------------
export const createCheckoutSession = onCall(
  {secrets: [stripeSecretKey]},
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError("unauthenticated", "Sign in required");
    const priceId = request.data?.priceId as string | undefined;
    if (!priceId) throw new HttpsError("invalid-argument", "priceId is required");
    const successUrl = (request.data?.successUrl as string | undefined) ?? "";
    const cancelUrl = (request.data?.cancelUrl as string | undefined) ?? successUrl;
    // Pre-fill Checkout with the signed-in user's email (UX only; the user is
    // identified by uid, so paying with a different email still updates them).
    const email = request.auth?.token?.email as string | undefined;
    // Persist the app language on the user so server-side notifications (e.g.
    // the "subscription saved" message) are sent in the right language. On web
    // there is no registered device to read the locale from, so we capture it
    // here at purchase time.
    const locale = (request.data?.locale as string | undefined)
      ?.substring(0, 2)
      .toLowerCase();
    if (locale) {
      await admin
        .firestore()
        .collection("users")
        .doc(uid)
        .set({locale}, {merge: true});
    }

    const stripe = stripeClient();
    const customerId = await getOrCreateCustomer(stripe, uid, email);

    const price = await stripe.prices.retrieve(priceId, {expand: ["product"]});
    const trialDays = trialDaysFor(price, price.product as Stripe.Product);

    const allowPromoCodes = request.data?.allowPromoCodes as boolean | undefined;

    const session = await stripe.checkout.sessions.create({
      mode: "subscription",
      customer: customerId,
      client_reference_id: uid,
      line_items: [{price: priceId, quantity: 1}],
      success_url: successUrl,
      cancel_url: cancelUrl,
      subscription_data: {
        metadata: {firebaseUID: uid},
        ...(trialDays ? {trial_period_days: trialDays} : {}),
      },
      ...(allowPromoCodes ? {allow_promotion_codes: true} : {}),
    });
    return {url: session.url};
  },
);

// ---------------------------------------------------------------------------
// getOrCreatePortalConfig — creates (once) a Customer Portal configuration
// with subscription_update (plan switching) enabled and caches its ID in
// Firestore so we don't recreate it on every portal open. Falls back to
// undefined (default portal) if there are no prices to switch between.
// ---------------------------------------------------------------------------
async function getOrCreatePortalConfig(stripe: Stripe): Promise<string | undefined> {
  const db = admin.firestore();
  const configRef = db.doc("_config/stripe_portal");
  const snap = await configRef.get();
  const cachedId = snap.data()?.configId as string | undefined;
  if (cachedId) {
    try {
      const cfg = await stripe.billingPortal.configurations.retrieve(cachedId);
      if (cfg.active) return cachedId;
    } catch {
      // Cached config was deleted on Stripe — recreate below
    }
  }

  // Build allowed-prices list grouped by product. STRIPE_PRODUCT_ID narrows the
  // query to a single product; if it's not set we use all active recurring prices.
  const productId = stripeProductId.value();
  const priceParams: Stripe.PriceListParams = {active: true, type: "recurring", limit: 100};
  if (productId) priceParams.product = productId;
  const {data: prices} = await stripe.prices.list(priceParams);

  if (prices.length === 0) return undefined;

  const byProduct: Record<string, string[]> = {};
  for (const p of prices) {
    const pid = typeof p.product === "string" ? p.product : p.product.id;
    if (!byProduct[pid]) byProduct[pid] = [];
    byProduct[pid].push(p.id);
  }
  const products = Object.entries(byProduct).map(([prod, priceIds]) => ({
    product: prod,
    prices: priceIds,
  }));

  const config = await stripe.billingPortal.configurations.create({
    features: {
      subscription_update: {
        enabled: true,
        default_allowed_updates: ["price"],
        products,
      },
      subscription_cancel: {enabled: true, mode: "at_period_end"},
      payment_method_update: {enabled: true},
    },
  });

  await configRef.set({configId: config.id}, {merge: true});
  return config.id;
}

// ---------------------------------------------------------------------------
// createPortalSession — Stripe Customer Portal (manage / cancel / switch plan).
// ---------------------------------------------------------------------------
export const createPortalSession = onCall(
  {secrets: [stripeSecretKey]},
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError("unauthenticated", "Sign in required");
    const returnUrl = (request.data?.returnUrl as string | undefined) ?? "";
    const planSwitching = request.data?.planSwitching as boolean | undefined;

    const stripe = stripeClient();
    const snap = await admin
      .firestore()
      .collection(CUSTOMERS_COLLECTION)
      .doc(uid)
      .get();
    const customerId = snap.data()?.customerId as string | undefined;
    if (!customerId) {
      throw new HttpsError("failed-precondition", "No Stripe customer for user");
    }

    // When plan switching is requested, resolve (or create) a portal configuration
    // that has subscription_update enabled. This removes the need for any manual
    // setup in the Stripe dashboard.
    const configId = planSwitching ? await getOrCreatePortalConfig(stripe) : undefined;

    const session = await stripe.billingPortal.sessions.create({
      customer: customerId,
      return_url: returnUrl,
      ...(configId ? {configuration: configId} : {}),
    });
    return {url: session.url};
  },
);

// ---------------------------------------------------------------------------
// stripeWebhook — webhook. The ONLY writer of `subscriptions` for Stripe.
// ---------------------------------------------------------------------------
function statusFromStripe(sub: Stripe.Subscription): SubscriptionStatus {
  switch (sub.status) {
    case "active":
    case "trialing":
      return SubscriptionStatus.ACTIVE;
    default:
      // canceled, unpaid, past_due, incomplete, incomplete_expired, paused
      return SubscriptionStatus.EXPIRED;
  }
}

async function upsertFromStripeSubscription(sub: Stripe.Subscription): Promise<void> {
  const uid = sub.metadata?.firebaseUID;
  if (!uid) {
    console.log("[stripe-webhook] subscription without firebaseUID metadata, skipping");
    return;
  }
  // Skip if the user no longer exists. Deleting an account cancels the Stripe
  // customer, which fires customer.subscription.deleted AFTER deleteUserAccount
  // already removed subscriptions/{uid} — without this guard the webhook would
  // re-create an orphan doc for a user that is gone. (The Supabase webhook does
  // the same check.) The lookup also gives us the email to denormalize below.
  const user = await usersRepository.getFromId(uid);
  if (!user) {
    console.log(`[stripe-webhook] user ${uid} not found (likely deleted), skipping`);
    return;
  }
  const now = Timestamp.now();
  const existing = await subscriptionsRepository.getFromUserId(uid);
  // In Stripe API v18 the billing period lives on each subscription item.
  const item = sub.items.data[0];
  const priceId = item?.price?.id ?? "";
  const periodEnd = item?.current_period_end;
  const expiration = periodEnd
    ? Timestamp.fromMillis(periodEnd * 1000)
    : undefined;
  const trialEnd = sub.trial_end
    ? Timestamp.fromMillis(sub.trial_end * 1000)
    : undefined;

  const subscription = new Subscription(
    {
      userId: uid,
      status: statusFromStripe(sub),
      creationDate: existing?.creationDate ?? now,
      lastUpdate: now,
      expirationDate: expiration,
      trialEnd,
      store: Stores.STRIPE,
      productId: priceId,
      email: user.email,
    },
    subscriptionsRepository,
  );
  await subscription.save();
}

export const stripeWebhook = onRequest(
  {cors: false, secrets: [stripeSecretKey, stripeWebhookSecret]},
  async (req, res) => {
    const signature = req.header("stripe-signature");
    if (!signature) {
      res.status(400).send("Missing signature");
      return;
    }
    const stripe = stripeClient();
    let event: Stripe.Event;
    try {
      event = stripe.webhooks.constructEvent(
        req.rawBody,
        signature,
        stripeWebhookSecret.value(),
      );
    } catch (e) {
      console.log(`[stripe-webhook] signature verification failed: ${e}`);
      res.status(400).send("Invalid signature");
      return;
    }
    try {
      switch (event.type) {
        case "customer.subscription.created":
        case "customer.subscription.updated":
        case "customer.subscription.deleted":
          await upsertFromStripeSubscription(event.data.object as Stripe.Subscription);
          break;
        default:
          break;
      }
      res.status(200).send("ok");
    } catch (e) {
      error(e);
      res.status(500).send(e instanceof Error ? e.message : String(e));
    }
  },
);

// ---------------------------------------------------------------------------
// onUserDeletedCleanupStripe — tears down Stripe state when an account is
// deleted. deleteUserAccount removes the users/{uid} doc; this trigger fires on
// that deletion and (a) deletes the Stripe customer, which immediately cancels
// all of its subscriptions so billing stops, and (b) removes the local
// uid -> customer mapping so no orphan stripe_customers doc is left behind.
// Lives in the Stripe module so a non-Stripe app never deploys it.
// ---------------------------------------------------------------------------
export const onUserDeletedCleanupStripe = onDocumentDeleted(
  {document: "users/{userId}", secrets: [stripeSecretKey]},
  async (event) => {
    const uid = event.params.userId;
    const custRef = admin
      .firestore()
      .collection(CUSTOMERS_COLLECTION)
      .doc(uid);
    try {
      const snap = await custRef.get();
      const customerId = snap.data()?.customerId as string | undefined;
      if (customerId) {
        // Deleting the Stripe customer cancels all of its subscriptions, so
        // billing stops for the deleted account in a single call.
        await stripeClient().customers.del(customerId);
      }
    } catch (e) {
      console.log(`[stripe-cleanup] could not delete Stripe customer for ${uid}: ${e}`);
    }
    // Always drop the local mapping so no orphan remains.
    try {
      await custRef.delete();
    } catch (e) {
      console.log(`[stripe-cleanup] could not delete stripe_customers/${uid}: ${e}`);
    }
  },
);
