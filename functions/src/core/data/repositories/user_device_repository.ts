import {Timestamp} from "firebase-admin/firestore";
import {UserDeviceAdapter, UserDeviceEntity} from "../entities/user_device_entity";

// Devices that did not heartbeat within this window are treated as orphans
// from prior installs (a fresh install creates a new doc with a different
// installationId). Skipping them avoids sending the same push multiple times
// to the same physical device after re-installs (e.g. Xcode -> TestFlight).
const STALE_DEVICE_TTL_MS = 60 * 24 * 60 * 60 * 1000;

export class UserDevicesRepository {
  constructor(
        private db: FirebaseFirestore.Firestore,
  ) { }

  private collection(userId: string) {
    return this.db
      .collection("users")
      .doc(userId)
      .collection("devices")
      .withConverter({
        fromFirestore: UserDeviceEntity.fromDocument,
        toFirestore: (device: UserDeviceEntity) => UserDeviceAdapter.toMap(device),
      });
  }

  async getDevices(userIds: string[]): Promise<UserDeviceEntity[]> {
    const cutoffMs = Date.now() - STALE_DEVICE_TTL_MS;
    const result: UserDeviceEntity[] = [];
    for (const userId of userIds) {
      const userResult = await this.collection(userId).get();
      for (const doc of userResult.docs) {
        const device = doc.data();
        // Backward-compat: docs without lastUpdateDate (older app versions) pass through.
        const lastUpdate = device.lastUpdateDate;
        if (lastUpdate instanceof Timestamp && lastUpdate.toMillis() < cutoffMs) {
          continue;
        }
        result.push(device);
      }
    }
    return result;
  }

  async delete(userId: string, deviceId: string): Promise<void> {
    await this.collection(userId).doc(deviceId).delete();
  }
}
