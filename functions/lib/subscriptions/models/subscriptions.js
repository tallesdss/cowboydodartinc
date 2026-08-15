"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.Subscription = exports.subscriptionDuration = void 0;
const admin = __importStar(require("firebase-admin"));
const subscription_status_1 = require("./subscription_status");
exports.subscriptionDuration = {
    WEEKLY: "WEEKLY",
    MONTHLY: "MONTHLY",
    YEARLY: "YEARLY",
    LIFETIME: "LIFETIME",
};
class Subscription {
    constructor({ userId, status, creationDate, lastUpdate, expirationDate, trialEnd, store, productId, email, }, subscriptionRepository) {
        this.subscriptionRepository = subscriptionRepository;
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
    static async fromRevenueCat({ event, userRepository, subscriptionRepository, }) {
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
                    ? subscription_status_1.Stores.APPLE_STORE
                    : subscription_status_1.Stores.PLAY_STORE,
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
                ? subscription_status_1.Stores.APPLE_STORE
                : subscription_status_1.Stores.PLAY_STORE,
            productId: event.product_id,
            email: user.email,
        }, subscriptionRepository);
    }
    static fromEntity(entity, subscriptionRepository) {
        if (!entity.id) {
            throw new Error("Subscription entity must have an id");
        }
        return new Subscription({
            userId: entity.id,
            status: entity.status,
            creationDate: entity.creation_date,
            lastUpdate: entity.last_activity,
            expirationDate: entity.expiration_date,
            store: entity.store,
            productId: entity.product_id,
            email: entity.email,
        }, subscriptionRepository);
    }
    static async fromUserId({ userId, subscriptionRepository, }) {
        const userAuth = await admin.auth().getUser(userId);
        const isEarlyBird = userAuth.customClaims &&
            userAuth.customClaims.EARLY_BIRD;
        if (isEarlyBird) {
            return new Subscription({
                userId,
                status: subscription_status_1.SubscriptionStatus.ACTIVE,
                creationDate: admin.firestore.Timestamp.now(),
                lastUpdate: admin.firestore.Timestamp.now(),
                store: subscription_status_1.Stores.EARLY_BIRD,
                productId: "early_bird",
            }, subscriptionRepository);
        }
        return subscriptionRepository.getFromUserId(userId);
    }
    async save() {
        await this.subscriptionRepository.save(this);
    }
    get active() {
        var _a;
        if (this.status == subscription_status_1.SubscriptionStatus.ACTIVE) {
            return true;
        }
        if (this.status == subscription_status_1.SubscriptionStatus.LIFETIME) {
            return true;
        }
        if (!this.expirationDate) {
            return false;
        }
        const now = new Date();
        const expirationDate = (_a = this.expirationDate) === null || _a === void 0 ? void 0 : _a.toDate();
        if (expirationDate && expirationDate > now) {
            return true;
        }
        return false;
    }
    get duration() {
        if (!this.expirationDate) {
            return exports.subscriptionDuration.LIFETIME;
        }
        if (this.productId.includes("weekly")) {
            return exports.subscriptionDuration.WEEKLY;
        }
        else if (this.productId.includes("monthly")) {
            return exports.subscriptionDuration.MONTHLY;
        }
        else if (this.productId.includes("annual")) {
            return exports.subscriptionDuration.YEARLY;
        }
        if (this.productId.includes("lifetime")) {
            return exports.subscriptionDuration.LIFETIME;
        }
        return exports.subscriptionDuration.LIFETIME;
    }
}
exports.Subscription = Subscription;
//# sourceMappingURL=subscriptions.js.map