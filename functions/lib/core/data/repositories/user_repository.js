"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserAdapter = exports.UserRepository = void 0;
const entity_utils_1 = require("../entities/entity_utils");
const firestore_1 = require("firebase-admin/firestore");
const user_entity_1 = require("../entities/user_entity");
class UserRepository {
    constructor(db) {
        this.db = db;
    }
    collection() {
        return this.db.collection("users")
            .withConverter({
            fromFirestore: (snapshot) => {
                return user_entity_1.UserEntity.fromDocument(snapshot);
            },
            toFirestore: (user) => UserAdapter.toMap(user),
        });
    }
    async create(user) {
        const userEntityWithoutId = (0, entity_utils_1.cleanEntityId)(Object.assign({}, user));
        await this.collection().doc(user.id).set(userEntityWithoutId);
        return user;
    }
    async getFromId(userId) {
        const snapshot = await this.collection()
            .doc(userId)
            .get();
        if (!snapshot.exists) {
            return null;
        }
        return user_entity_1.UserEntity.fromDocument(snapshot);
    }
    async update(user) {
        const userEntityWithoutId = (0, entity_utils_1.cleanEntityId)(Object.assign({}, user));
        await this.collection().doc(user.id).set(userEntityWithoutId);
    }
    async updateEmail(userId, email) {
        await this.collection().doc(userId).update({
            email,
            "last_update_date": firestore_1.Timestamp.now(),
        });
    }
    /**
     * Atomically claims the one-time welcome for a user.
     *
     * Returns true for exactly ONE caller per account — the one that should send
     * the welcome notification — and false for every later call (e.g. a device
     * re-registered after a logout/login cycle, or a second device registering at
     * the same time). The flag flip and the read happen inside a transaction, so
     * two concurrent device registrations can never both send the welcome.
     */
    async claimWelcome(userId) {
        const ref = this.db.collection("users").doc(userId);
        return this.db.runTransaction(async (tx) => {
            const snapshot = await tx.get(ref);
            if (!snapshot.exists) {
                return false;
            }
            if (snapshot.get("welcome_sent") === true) {
                return false;
            }
            tx.update(ref, {
                "welcome_sent": true,
                "last_update_date": firestore_1.Timestamp.now(),
            });
            return true;
        });
    }
    async list({ limit = 100, startAfter, }) {
        let query = this.collection()
            .orderBy("creation_date", "asc");
        if (startAfter) {
            query = query.startAfter(startAfter);
        }
        if (limit) {
            query = query.limit(limit);
        }
        return query
            .get()
            .then((snapshot) => {
            if (snapshot.empty) {
                return { items: [] };
            }
            const entities = snapshot.docs.map((doc) => user_entity_1.UserEntity.fromDocument(doc));
            return {
                items: entities,
                lastSnapshot: snapshot.docs[snapshot.docs.length - 1],
            };
        });
    }
}
exports.UserRepository = UserRepository;
class UserAdapter {
    static toMap(entity) {
        const cleanedEntity = (0, entity_utils_1.cleanEntityId)(Object.assign({}, entity));
        return cleanedEntity;
    }
}
exports.UserAdapter = UserAdapter;
//# sourceMappingURL=user_repository.js.map