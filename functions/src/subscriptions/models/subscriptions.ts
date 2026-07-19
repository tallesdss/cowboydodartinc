import { Timestamp } from "firebase-admin/firestore";
import { RevenueCatEvent } from "./revenuecat_events";
import * as admin from "firebase-admin";
import { Stores, SubscriptionStatus } from "./subscription_status";
import { UserRepository } from "../../core/data/repositories/user_repository";
import { SubscriptionsRepository } from "../../core/data/repositories/subscription_repository";
import { SubscriptionEntity } from "../../core/data/entities/subscription_entity";

export const subscriptionDuration = {
  WEEKLY: "WEEKLY",
  MONTHLY: "MONTHLY",
  YEARLY: "YEARLY",
  LIFETIME: "LIFETIME",
} as const;

export type SubscriptionDuration =
  (typeof subscriptionDuration)[keyof typeof subscriptionDuration];

export interface SubscriptionData {
  userId: string;
  status: SubscriptionStatus;
  creationDate: Timestamp;
  lastUpdate: Timestamp;
  expirationDate?: Timestamp;
  trialEnd?: Timestamp;
  store: Stores;
  productId: string;
  // Denormalized copy of the subscriber's email. Firestore is a non-relational
  // store, so we duplicate it onto the subscription doc to list/show subscribers
  // without a second read. (On the relational backends the user is referenced by
  // a user_id foreign key and the email is joined from the users table instead.)
  email?: string;
}

export interface Subscription extends SubscriptionData {}

export class Subscription {
  constructor(
    {
      userId,
      status,
      creationDate,
      lastUpdate,
      expirationDate,
      trialEnd,
      store,
      productId,
      email,
    }: SubscriptionData,
    private subscriptionRepository: SubscriptionsRepository,
  ) {
    this.userId = userId;
    this.status = status;
    this.creationDate = creationDate;
    this.lastUpdate = lastUpdate;
    this.expirationDate = expirationDate;
    this.trialEnd = trialEnd;
    this.store = store;
    this.productId = productId;
    this.email = email;
  }

  static async fromRevenueCat({
    event,
    userRepository,
    subscriptionRepository,
  }: {
    event: RevenueCatEvent;
    userRepository: UserRepository;
    subscriptionRepository: SubscriptionsRepository;
  }): Promise<Subscription> {
    const user = await userRepository.getFromId(event.app_user_id);
    if (!user || !user.id) {
      throw new Error(`User ${event.app_user_id} not found`);
    }
    const subscription = await subscriptionRepository.getFromUserId(user.id);
    const now = admin.firestore.Timestamp.now();
    if (!subscription) {
        return new Subscription({
            userId: user.id,
            status: event.subscriptionStatus,
            creationDate: now,
            lastUpdate: now,
            expirationDate: event.expirationTimestamp,
            store: event.store == "APP_STORE"
                ? Stores.APPLE_STORE
                : Stores.PLAY_STORE,
            productId: event.product_id,
            email: user.email,
        }, subscriptionRepository);
    }
    return new Subscription({
        userId: user.id,
        status: event.subscriptionStatus,
        creationDate: subscription.creationDate,
        lastUpdate: now,
        expirationDate: event.expirationTimestamp,
        store: event.store == "APP_STORE"
            ? Stores.APPLE_STORE
            : Stores.PLAY_STORE,
        productId: event.product_id,
        email: user.email,
      }, subscriptionRepository);
  }

  static fromEntity(
    entity: SubscriptionEntity,
    subscriptionRepository: SubscriptionsRepository,
  ): Subscription {
    if (!entity.id) {
        throw new Error("Subscription entity must have an id");
    }
    return new Subscription({
      userId: entity.id!,
      status: entity.status,
      creationDate: entity.creation_date,
      lastUpdate: entity.last_activity,
      expirationDate: entity.expiration_date,
      store: entity.store,
      productId: entity.product_id,
      email: entity.email,
    }, subscriptionRepository);
  }

  static async fromUserId({
    userId,
    subscriptionRepository,
  }: {
    userId: string;
    subscriptionRepository: SubscriptionsRepository;
  }): Promise<Subscription | null> {
    const userAuth = await admin.auth().getUser(userId);
    const isEarlyBird = userAuth.customClaims &&
      userAuth.customClaims.EARLY_BIRD;
    if (isEarlyBird) {
      return new Subscription({
        userId,
        status: SubscriptionStatus.ACTIVE,
        creationDate: admin.firestore.Timestamp.now(),
        lastUpdate: admin.firestore.Timestamp.now(),
        store: Stores.EARLY_BIRD,
        productId: "early_bird",
      }, subscriptionRepository);
    }
    return subscriptionRepository.getFromUserId(userId);
  }

  async save(): Promise<void> {
    await this.subscriptionRepository.save(this);
  }

  get active(): boolean {
    if (this.status == SubscriptionStatus.ACTIVE) {
      return true;
    }
    if (this.status == SubscriptionStatus.LIFETIME) {
      return true;
    }
    if (!this.expirationDate) {
      return false;
    }
    const now = new Date();
    const expirationDate = this.expirationDate?.toDate();
    if (expirationDate && expirationDate > now) {
      return true;
    }
    return false;
  }

  get duration(): SubscriptionDuration {
    if (!this.expirationDate) {
      return subscriptionDuration.LIFETIME;
    }
    if (this.productId.includes("weekly")) {
      return subscriptionDuration.WEEKLY;
    } else if (this.productId.includes("monthly")) {
      return subscriptionDuration.MONTHLY;
    } else if (this.productId.includes("annual")) {
      return subscriptionDuration.YEARLY;
    }
    if (this.productId.includes("lifetime")) {
      return subscriptionDuration.LIFETIME;
    }
    return subscriptionDuration.LIFETIME;
  }
}
