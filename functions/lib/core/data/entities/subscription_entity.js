"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SubscriptionEntity = void 0;
const subscriptions_1 = require("../../../subscriptions/models/subscriptions");
class SubscriptionEntity {
    constructor({ id, user_id, email, creation_date, last_activity, expiration_date, trial_end, status, store, product_id, }) {
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
    static fromData(data) {
        return new SubscriptionEntity(data);
    }
    static fromDocument(data) {
        const serieData = Object.assign({ id: data.id }, data.data());
        return new SubscriptionEntity(serieData);
    }
    static from(subscription) {
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
    toSubscription(subscriptionRepository) {
        return new subscriptions_1.Subscription({
            userId: this.id,
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
exports.SubscriptionEntity = SubscriptionEntity;
//# sourceMappingURL=subscription_entity.js.map