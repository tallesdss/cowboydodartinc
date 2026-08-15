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
exports.notificationsApi = exports.NotificationsApi = void 0;
const admin = __importStar(require("firebase-admin"));
const notification_entity_1 = require("../core/data/entities/notification_entity");
const repositories_1 = require("../core/data/repositories/repositories");
class NotificationsApi {
    constructor(messaging, userNotificationsRepository) {
        this.messaging = messaging;
        this.userNotificationsRepository = userNotificationsRepository;
    }
    static create() {
        return new NotificationsApi(admin.messaging(), repositories_1.notificationsRepository);
    }
    /**
       * Creates a notification for the given users
       * A document is added in the user's notifications collection
       * This triggers a function that will call the sendSystemNotification function
       *
       * If you only want to send a system notification to the user,
       * use the [sendSystemNotification] function
       */
    async notify(userIds, notificationParams) {
        let type = notification_entity_1.NotificationTypes.OTHER;
        if (notificationParams.systemNotification) {
            type = notificationParams.systemNotification.type;
        }
        await this.userNotificationsRepository.saveAll(userIds, new notification_entity_1.NotificationEntity({
            title: notificationParams.title,
            body: notificationParams.body,
            image_url: notificationParams.image_url,
            type: type,
            creation_date: admin.firestore.Timestamp.now(),
            notify_user: true,
        }));
    }
    /**
       * Creates a notification for the given users
       * A document is added in the user's notifications collection
       * - This won't noty user with a system notification
       *
       * If you only want to send a system notification to the user,
       * use the [sendSystemNotification] function
       */
    async createNotificationOnly(userIds, notificationParams) {
        for (const userId of userIds) {
            await this.userNotificationsRepository.save(userId, new notification_entity_1.NotificationEntity({
                title: notificationParams.title,
                body: notificationParams.body,
                type: notificationParams.systemNotification.type,
                creation_date: admin.firestore.Timestamp.now(),
                notify_user: false,
            }));
        }
    }
    /**
       * Sends a system notification to the given users (tokens)
       * @param tokens
       * @param notification
       * @param data
       * @param android
       * @param apns
       * @param webpush
       */
    async sendSystemNotification(tokens, notification, data, android, apns, webpush) {
        if (tokens.length === 0) {
            return;
        }
        try {
            if (tokens.length > 500) {
                throw new Error("Too many tokens");
            }
            const messages = [];
            for (const token of tokens) {
                const msge = {
                    token: token,
                    data: data != null ? this.cleanNotStringData(data) : undefined,
                    notification: notification,
                    apns: {
                        payload: {
                            aps: {
                                contentAvailable: true,
                            },
                        },
                    },
                };
                if (android) {
                    msge.android = android;
                }
                if (apns) {
                    msge.apns = apns;
                }
                if (webpush) {
                    msge.webpush = webpush;
                }
                messages.push(msge);
            }
            // Invalid/expired tokens are detected from the BatchResponse and removed by the caller.
            // Rate limiting per user is enforced at the trigger level before this method is called.
            return this.messaging.sendEach(messages);
        }
        catch (err) {
            throw new Error(`Error while sending notification: ${err}`);
        }
    }
    cleanNotStringData(data) {
        for (const key of Object.keys(data)) {
            if (typeof data[key] !== "string") {
                delete data[key];
            }
        }
        return data;
    }
}
exports.NotificationsApi = NotificationsApi;
exports.notificationsApi = NotificationsApi.create();
//# sourceMappingURL=notifications_api.js.map