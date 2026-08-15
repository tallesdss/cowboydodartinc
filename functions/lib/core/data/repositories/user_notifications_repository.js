"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserNotificationsRepository = void 0;
const notification_entity_1 = require("../entities/notification_entity");
class UserNotificationsRepository {
    constructor(db) {
        this.db = db;
    }
    collection(userId) {
        return this.db
            .collection("users")
            .doc(userId)
            .collection("notifications")
            .withConverter({
            fromFirestore: (snapshot) => {
                return notification_entity_1.NotificationEntity.fromDocument(snapshot);
            },
            toFirestore: (notification) => notification_entity_1.NotificationAdapter.toMap(notification),
        });
    }
    async save(userId, notification) {
        const res = await this.collection(userId).add(notification);
        notification.id = res.id;
        return notification;
    }
    async getLast(userId) {
        const res = await this.collection(userId)
            .orderBy("creation_date", "desc")
            .limit(1)
            .get();
        if (res.empty) {
            return undefined;
        }
        return res.docs[0].data();
    }
    async saveAll(userIds, notifications) {
        const chunkSize = 500;
        const processedUserIds = [];
        while (processedUserIds.length < userIds.length) {
            const chunk = userIds.slice(processedUserIds.length, processedUserIds.length + chunkSize);
            const batch = this.db.batch();
            try {
                for (const userId of chunk) {
                    const userRef = this.collection(userId);
                    batch.create(userRef.doc(), notifications);
                }
                await batch.commit();
            }
            catch (e) {
                console.error(e);
                throw Error("Error saving notifications");
            }
            processedUserIds.push(...chunk);
        }
    }
}
exports.UserNotificationsRepository = UserNotificationsRepository;
//# sourceMappingURL=user_notifications_repository.js.map