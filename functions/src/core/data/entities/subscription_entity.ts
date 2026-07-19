import {DocumentData, QueryDocumentSnapshot, Timestamp} from "firebase-admin/firestore";
import {SubscriptionsRepository} from "../repositories/subscription_repository";
import {Stores, SubscriptionStatus} from "../../../subscriptions/models/subscription_status";
import {Subscription} from "../../../subscriptions/models/subscriptions";

export interface SubscriptionEntityData {
    id?: string,
    // Denormalized reference to the subscriber, written as explicit fields on the
    // Firestore doc (besides being the doc id) so a subscribers list / admin view
    // can read who owns it and their email without a second lookup.
    user_id?: string;
    email?: string;
    creation_date: Timestamp;
    last_activity: Timestamp;
    expiration_date?: Timestamp;
    trial_end?: Timestamp;
    status: SubscriptionStatus;
    store: Stores,
    product_id: string;
}

export type NewSubscriptionEntityData = Omit<SubscriptionEntityData, "id">;

export interface SubscriptionEntity extends SubscriptionEntityData {}

export class SubscriptionEntity {
  constructor({
    id,
    user_id,
    email,
    creation_date,
    last_activity,
    expiration_date,
    trial_end,
    status,
    store,
    product_id,
  }: SubscriptionEntityData
  ) {
    this.id = id;
    this.user_id = user_id;
    this.email = email;
    this.creation_date = creation_date;
    this.last_activity = last_activity;
    this.expiration_date = expiration_date;
    this.trial_end = trial_end;
    this.status = status;
    this.store = store;
    this.product_id = product_id;
  }

  static fromData(data: SubscriptionEntityData): SubscriptionEntity {
    return new SubscriptionEntity(data);
  }

  static fromDocument(data: QueryDocumentSnapshot | DocumentData): SubscriptionEntity {
    const serieData = <SubscriptionEntityData>{
      id: data.id,
      ...data.data(),
    };
    return new SubscriptionEntity(serieData);
  }

  static from(subscription: Subscription): SubscriptionEntity {
    return new SubscriptionEntity({
      id: subscription.userId,
      user_id: subscription.userId,
      email: subscription.email,
      creation_date: subscription.creationDate,
      last_activity: subscription.lastUpdate,
      expiration_date: subscription.expirationDate,
      trial_end: subscription.trialEnd,
      status: subscription.status,
      store: subscription.store,
      product_id: subscription.productId,
    });
  }

  toSubscription(subscriptionRepository: SubscriptionsRepository) {
    return new Subscription({
      userId: this.id!,
      creationDate: this.creation_date,
      lastUpdate: this.last_activity,
      expirationDate: this.expiration_date,
      trialEnd: this.trial_end,
      status: this.status,
      store: this.store,
      productId: this.product_id,
      email: this.email,
    }, subscriptionRepository);
  }
}

