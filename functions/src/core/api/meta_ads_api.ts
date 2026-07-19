import {defineSecret} from "firebase-functions/params";
import {UserDevice, UserDeviceEntity, UserDeviceTypes} from "../data/entities/user_device_entity";
import {UserEntity} from "../data/entities/user_entity";

const META_ACCESS_TOKEN = defineSecret("META_ACCESS_TOKEN");
const META_DATASET_ID = defineSecret("META_DATASET_ID");


// Base interface for all Meta events
export interface BaseMetaEventParams {
  anonymousFbId: string;
  email?: string | null;
  operatingSystem: UserDeviceTypes;
  eventId: string;
  clientIpAddress?: string;
  mobileAdvertiserId?: string;
  appPackageName: string;
  appVersion: string;
  appLongVersion?: string;
  osVersion: string;
  deviceModel?: string;
  deviceLocale?: string;
  timezone?: string;
  carrier?: string;
  screenWidth?: string;
  screenHeight?: string;
  screenDensity?: string;
  cpuCores?: string;
  storageSize?: string;
  freeStorage?: string;
  deviceTimezone?: string;
  campaignIds?: string;
  installReferrer?: string;
}

// Specific event interfaces
export interface SendSubscriptionEventParams extends BaseMetaEventParams {
  subscriptionValue: number;
  currency: string;
}

export type SendInstallEventParams = BaseMetaEventParams;

export interface SendCustomEventParams extends BaseMetaEventParams {
  eventName: string;
  customData?: Record<string, string | number>;
}

// Event types enum for better type safety
export enum MetaEventType {
  PURCHASE = "Purchase",
  MOBILE_APP_INSTALL = "MobileAppInstall",
  COMPLETE_REGISTRATION = "CompleteRegistration",
  VIEW_CONTENT = "ViewContent",
  ADD_TO_CART = "AddToCart",
  INITIATE_CHECKOUT = "InitiateCheckout",
  ACHIEVE_LEVEL = "AchieveLevel",
  UNLOCK_ACHIEVEMENT = "UnlockAchievement",
  SPEND_CREDITS = "SpendCredits",
  RATE = "Rate",
  SEARCH = "Search",
  START_TRIAL = "StartTrial",
  SUBSCRIBE = "Subscribe",
  AD_IMPRESSION = "AdImpression",
  AD_CLICK = "AdClick",
}

export class MetaAdsApi {
  private apiVersion = "v24.0";

  constructor() {
    if (!META_ACCESS_TOKEN.value()) {
      throw new Error("META_ACCESS_TOKEN environment variable is required");
    }

    if (!META_DATASET_ID.value()) {
      throw new Error("META_DATASET_ID environment variable is required");
    }
  }

  /**
   * Base method to send any event to Meta Conversions API
   * Based on: https://developers.facebook.com/docs/marketing-api/conversions-api/app-events/
   */
  private async sendMetaEvent(
    eventType: MetaEventType,
    params: BaseMetaEventParams,
    customData?: Record<string, string | number>,
  ): Promise<void> {
    try {
      const {
        anonymousFbId,
        email,
        operatingSystem,
        eventId,
        clientIpAddress,
        mobileAdvertiserId,
        appPackageName,
        appVersion,
        appLongVersion,
        osVersion,
        deviceModel,
        deviceLocale,
        timezone,
        carrier,
        screenWidth,
        screenHeight,
        screenDensity,
        cpuCores,
        storageSize,
        freeStorage,
        deviceTimezone,
        campaignIds,
        installReferrer,
      } = params;

      // Build extinfo array - all values are required and must be in order
      // Missing values should be empty strings as placeholders
      const extinfo = [
        operatingSystem === UserDevice.ANDROID ? "a2" : "i2", // 0: extinfo version (required)
        appPackageName || "", // 1: app package name
        appVersion || "", // 2: short version
        appLongVersion || "", // 3: long version
        osVersion || "", // 4: OS version (required)
        deviceModel || "", // 5: device model name
        deviceLocale || "en_US", // 6: locale
        timezone || "", // 7: timezone abbreviation
        carrier || "", // 8: carrier
        screenWidth || "", // 9: screen width
        screenHeight || "", // 10: screen height
        screenDensity || "", // 11: screen density
        cpuCores || "", // 12: CPU cores
        storageSize || "", // 13: external storage size in GB
        freeStorage || "", // 14: free space on external storage in GB
        deviceTimezone || "", // 15: device timezone
      ];

      // Build user_data object
      const userData: Record<string, string | string[]> = {
        anon_id: anonymousFbId,
      };

      if (clientIpAddress) {
        userData.client_ip_address = clientIpAddress;
      }

      // Add email if available (should be hashed)
      if (email) {
        userData.em = [await this.hashEmail(email)];
      }

      // Add mobile advertiser ID if available (should NOT be hashed)
      if (mobileAdvertiserId) {
        userData.madid = mobileAdvertiserId;
      }

      // Build custom_data object (if provided)
      const customDataObj = customData || {};

      const advertiserTrackingEnabled = mobileAdvertiserId &&
        mobileAdvertiserId.length > 0;

      // Build app_data object with required fields
      const appData: Record<string, string | number | string[]> = {
        advertiser_tracking_enabled: advertiserTrackingEnabled ? 1 : 0, // Required - ATT permission (iOS 14.5+)
        application_tracking_enabled: advertiserTrackingEnabled ? 1 : 0, // Required - app-level tracking permission
        extinfo: extinfo, // Required - extended device information
      };

      // Add optional campaign IDs if available
      if (campaignIds) {
        appData.campaign_ids = campaignIds;
      }

      // Add install referrer for Android if available
      if (installReferrer && operatingSystem === UserDevice.ANDROID) {
        appData.install_referrer = installReferrer;
      }

      // Build server event
      const serverEvent = {
        event_name: eventType,
        event_time: Math.floor(Date.now() / 1000), // Unix timestamp
        action_source: "app", // Required - must be 'app' for app events
        event_id: eventId, // Required for deduplication
        user_data: userData,
        custom_data: customDataObj,
        app_data: appData,
      };

      // Build the payload
      const payload = {
        data: [serverEvent],
      };

      // Send the event via HTTP API
      const url =
        `https://graph.facebook.com/${this.apiVersion}/${META_DATASET_ID.value()}/events`;
      const response = await fetch(url, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${META_ACCESS_TOKEN.value()}`,
        },
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(
          `Meta API error: ${response.status} ${response.statusText} - ${errorText}`,
        );
      }

      await response.json();
    } catch (error) {
      console.error(`Error sending ${eventType} event to Meta:`, error);
      throw error;
    }
  }

  /**
   * Send a subscription conversion event to Meta Conversions API
   */
  sendSubscriptionEvent(params: SendSubscriptionEventParams): Promise<void> {
    const customData = {
      currency: params.currency,
      value: params.subscriptionValue.toString(),
    };
    return this.sendMetaEvent(MetaEventType.SUBSCRIBE, params, customData);
  }

  /**
   * Send a trial start event to Meta Conversions API
   */
  sendStartTrialEvent(
    params: BaseMetaEventParams & { trialValue?: number; currency?: string },
  ): Promise<void> {
    const customData: Record<string, string> = {};
    if (params.trialValue) customData.value = params.trialValue.toString();
    if (params.currency) customData.currency = params.currency;
    return this.sendMetaEvent(MetaEventType.START_TRIAL, params, customData);
  }

  sendLifetimeEvent(
    params: BaseMetaEventParams & { lifetimeValue?: number; currency?: string },
  ): Promise<void> {
    const customData: Record<string, string> = {};
    if (params.lifetimeValue) {
      customData.value = params.lifetimeValue.toString();
    }
    if (params.currency) customData.currency = params.currency;
    return this.sendMetaEvent(MetaEventType.PURCHASE, params, customData);
  }

  /**
   * Send a custom event to Meta Conversions API
   */
  sendCustomEvent(params: SendCustomEventParams): Promise<void> {
    return this.sendMetaEvent(
      params.eventName as MetaEventType,
      params,
      params.customData,
    );
  }

  /**
   * Send a user registration event to Meta Conversions API
   */
  sendRegistrationEvent(params: BaseMetaEventParams): Promise<void> {
    return this.sendMetaEvent(MetaEventType.COMPLETE_REGISTRATION, params);
  }

  /**
   * Send a level achievement event to Meta Conversions API
   */
  sendLevelAchievementEvent(
    params: BaseMetaEventParams & { level: number },
  ): Promise<void> {
    const customData = {
      level: params.level.toString(),
    };
    return this.sendMetaEvent(MetaEventType.ACHIEVE_LEVEL, params, customData);
  }

  /**
   * Send an achievement unlock event to Meta Conversions API
   */
  sendUnlockAchievementEvent(
    params: BaseMetaEventParams & { achievementId: string },
  ): Promise<void> {
    const customData = {
      achievement_id: params.achievementId,
    };
    return this.sendMetaEvent(
      MetaEventType.UNLOCK_ACHIEVEMENT,
      params,
      customData,
    );
  }

  /**
   * Send a spend credits event to Meta Conversions API
   */
  sendSpendCreditsEvent(
    params: BaseMetaEventParams & { credits: number },
  ): Promise<void> {
    const customData = {
      credits: params.credits.toString(),
    };
    return this.sendMetaEvent(MetaEventType.SPEND_CREDITS, params, customData);
  }

  /**
   * Send a content view event to Meta Conversions API
   */
  sendViewContentEvent(
    params: BaseMetaEventParams & { contentType?: string; contentId?: string },
  ): Promise<void> {
    const customData: Record<string, string> = {};
    if (params.contentType) customData.content_type = params.contentType;
    if (params.contentId) customData.content_id = params.contentId;

    return this.sendMetaEvent(MetaEventType.VIEW_CONTENT, params, customData);
  }

  /**
   * Hash email using SHA-256 (as required by Meta)
   */
  private async hashEmail(email: string): Promise<string> {
    // Normalize email: lowercase and trim whitespace
    const normalizedEmail = email.toLowerCase().trim();

    // Convert string to Uint8Array
    const encoder = new TextEncoder();
    const data = encoder.encode(normalizedEmail);

    // Hash using SHA-256
    const hashBuffer = await crypto.subtle.digest("SHA-256", data);

    // Convert to hex string
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    const hashHex = hashArray.map((b) => b.toString(16).padStart(2, "0")).join(
      "",
    );

    return hashHex;
  }
}

// Helper function to generate unique event IDs for deduplication
export function generateEventId(): string {
  return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
}

export function createBaseEventParams(
  user: UserEntity,
  device: UserDeviceEntity,
): BaseMetaEventParams {
  const normalizedDevice = device as UserDeviceEntity & {
    extraData?: { [key: string]: string };
    operating_system?: UserDeviceTypes;
  };
  const extraData = normalizedDevice.extra_data ?? normalizedDevice.extraData ?? {};
  const operatingSystem = normalizedDevice.operatingSystem ??
    normalizedDevice.type ??
    normalizedDevice.operating_system ??
    UserDevice.ANDROID;

  return {
    email: user.email,
    operatingSystem,
    osVersion: extraData.osVersion ?? "",
    eventId: generateEventId(),
    appPackageName: extraData.appPackageName ?? "",
    appVersion: extraData.appVersion ?? "",
    appLongVersion: extraData.appLongVersion ?? "",
    anonymousFbId: extraData.anonymousFbId ?? "",
    deviceModel: extraData.deviceModel ?? "",
    deviceLocale: extraData.deviceLocale ?? "",
    timezone: extraData.timezone ?? "",
    carrier: extraData.carrier ?? "",
    screenWidth: extraData.screenWidth ?? "",
    screenHeight: extraData.screenHeight ?? "",
    screenDensity: extraData.screenDensity ?? "",
    cpuCores: extraData.cpuCores ?? "",
    mobileAdvertiserId: extraData.mobileAdvertiserId ?? "",
    clientIpAddress: extraData.clientIpAddress ?? "",
  };
}
