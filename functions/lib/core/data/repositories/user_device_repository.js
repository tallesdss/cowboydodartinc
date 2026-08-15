"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserDevicesRepository = void 0;
const firestore_1 = require("firebase-admin/firestore");
const user_device_entity_1 = require("../entities/user_device_entity");
// Devices that did not heartbeat within this window are treated as orphans
// from prior installs (a fresh install creates a new doc with a different
// installationId). Skipping them avoids sending the same push multiple times
// to the same physical device after re-installs (e.g. Xcode -> TestFlight).
const STALE_DEVICE_TTL_MS = 60 * 24 * 60 * 60 * 1000;
class UserDevicesRepository {
    constructor(db) {
        this.db = db;
    }
    collection(userId) {
        return this.db
            .collection("users")
            .doc(userId)
            .collection("devices")
            .withConverter({
            fromFirestore: user_device_entity_1.UserDeviceEntity.fromDocument,
            toFirestore: (device) => user_device_entity_1.UserDeviceAdapter.toMap(device),
        });
    }
    async getDevices(userIds) {
        const cutoffMs = Date.now() - STALE_DEVICE_TTL_MS;
        const result = [];
        for (const userId of userIds) {
            const userResult = await this.collection(userId).get();
            for (const doc of userResult.docs) {
                const device = doc.data();
                // Backward-compat: docs without lastUpdateDate (older app versions) pass through.
                const lastUpdate = device.lastUpdateDate;
                if (lastUpdate instanceof firestore_1.Timestamp && lastUpdate.toMillis() < cutoffMs) {
                    continue;
                }
                result.push(device);
            }
        }
        return result;
    }
    async delete(userId, deviceId) {
        await this.collection(userId).doc(deviceId).delete();
    }
}
exports.UserDevicesRepository = UserDevicesRepository;
//# sourceMappingURL=user_device_repository.js.map