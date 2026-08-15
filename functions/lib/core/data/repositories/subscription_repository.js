"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SubscriptionAdapter = exports.SubscriptionsRepository = void 0;
const entity_utils_1 = require("../entities/entity_utils");
const subscription_entity_1 = require("../entities/subscription_entity");
class SubscriptionsRepository {
    constructor(db) {
        this.db = db;
    }
    collection() {
        return this.db.collection("subscriptions");
    }
    document(userid) {
        return this.collection().doc(userid);
    }
    async save(subscription) {
        await this.document(subscription.userId).set(SubscriptionAdapter.toMap(subscription_entity_1.SubscriptionEntity.from(subscription)));
    }
    async getFromUserId(userId) {
        const snapshot = await this.document(userId).get();
        if (!snapshot.exists) {
            return null;
        }
        const entity = subscription_entity_1.SubscriptionEntity.fromDocument(snapshot);
        return entity.toSubscription(this);
    }
}
exports.SubscriptionsRepository = SubscriptionsRepository;
class SubscriptionAdapter {
    static toMap(data) {
        const cleanData = (0, entity_utils_1.cleanEntityId)(Object.assign({}, data));
        return Object.assign({}, cleanData);
    }
}
exports.SubscriptionAdapter = SubscriptionAdapter;
//# sourceMappingURL=subscription_repository.js.map