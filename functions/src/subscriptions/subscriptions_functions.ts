import { error } from "firebase-functions/logger";
import { https } from "firebase-functions";
import {onRequest} from "firebase-functions/v2/https";
import * as express from "express";
import { Subscription } from "./models/subscriptions";
import {
  subscriptionsRepository,
  userDevicesRepository,
  usersRepository,
} from "../core/data/repositories/repositories";
import {PeriodTypes, RevenueCatEvent} from "./models/revenuecat_events";
import {defineSecret} from "firebase-functions/params";
import {SubscriptionStatus} from "./models/subscription_status";
import {createBaseEventParams, MetaAdsApi} from "../core/api/meta_ads_api";


// firebase functions:config:set revenuecat.token=""
const revenuecatToken = defineSecret("REVENUECAT_WEBHOOK_KEY");
const metaAccessToken = defineSecret("META_ACCESS_TOKEN");
const metaDatasetId = defineSecret("META_DATASET_ID");

async function sendMetaEventsForSubscription(
  event: RevenueCatEvent,
  subscription: Subscription,
): Promise<void> {
  if (!metaAccessToken.value() || !metaDatasetId.value()) return;
  try {
    const user = await usersRepository.getFromId(event.app_user_id);
    if (!user) {
      console.log("[meta-ads] user not found, skipping");
      return;
    }

    const userDevices = await userDevicesRepository.getDevices([event.app_user_id]);
    if (userDevices.length === 0) {
      console.log("[meta-ads] no device found, skipping");
      return;
    }

    // Prefer device with anonymousFbId when possible.
    const selectedDevice = userDevices.find(
      (device) => Boolean(device.extra_data?.anonymousFbId),
    ) ?? userDevices[0];

    const params = createBaseEventParams(user, selectedDevice);
    if (!params.anonymousFbId) {
      console.log("[meta-ads] device has no anonymousFbId, skipping");
      return;
    }

    const api = new MetaAdsApi();
    if (event.type === "INITIAL_PURCHASE" && event.period_type === PeriodTypes.TRIAL) {
      await api.sendStartTrialEvent({
        ...params,
        trialValue: event.price_in_purchased_currency ?? undefined,
        currency: event.currency ?? undefined,
      });
      return;
    }

    if (event.subscriptionStatus === SubscriptionStatus.LIFETIME) {
      await api.sendLifetimeEvent({
        ...params,
        lifetimeValue: event.price_in_purchased_currency ?? undefined,
        currency: event.currency ?? undefined,
      });
      return;
    }

    if (event.isInitialPurchase || event.type === "RENEWAL") {
      if (event.price_in_purchased_currency == null || event.currency == null) {
        console.log("[meta-ads] missing currency/value for subscription event");
        return;
      }
      await api.sendSubscriptionEvent({
        ...params,
        subscriptionValue: event.price_in_purchased_currency,
        currency: event.currency,
      });
    }
  } catch (e) {
    // Meta conversion should never break webhook processing.
    console.log(`[meta-ads] skipped: ${e}`);
  }
}

export const revenuecatWebhook = onRequest({cors: true, secrets: [revenuecatToken, metaAccessToken, metaDatasetId]}, async (
  req: https.Request, 
  res: express.Response,
) => {
    console.log("[revenuecatWebhook]");
    const authorization = req.header("Authorization");
    if (!authorization) {
      console.log("Unauthorized - no token provided");
      res.status(401).send("Unauthorized - no token provided");
      return;
    }
    if (authorization !== revenuecatToken.value()) {
      console.log("Unauthorized - invalid token");
      res.status(401).send("Unauthorized - invalid token");
      return;
    }
    const event = RevenueCatEvent.fromData({ ...req.body.event });
    console.log("event type", event.type);
    console.log("product id", event.product_id);
    if (event.shouldIgnore) {
      console.log("ignored event");
      res.status(200).send("ignored event");
      return;
    }
    try {
      const subscription = await Subscription.fromRevenueCat({
        event,
        userRepository: usersRepository,
        subscriptionRepository: subscriptionsRepository,
      });
      await subscription.save();
      await sendMetaEventsForSubscription(event, subscription);
  
      if (event.isInitialPurchase || event.type === "RENEWAL") {
        //-- new subscription or renewal
      } else if (
        event.type === "INITIAL_PURCHASE" &&
        event.period_type === PeriodTypes.TRIAL
      ) {
        //-- trial started
      } else if (event.subscriptionStatus === SubscriptionStatus.LIFETIME) {
        //-- 
      }
      res.status(200).send("ok");
    } catch (e) {
      error(e);
      res.status(500).send(e instanceof Error ? e.message : String(e));
    }
  });
