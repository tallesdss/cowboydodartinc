import {cleanEntityId} from "../entities/entity_utils";
import { Timestamp } from "firebase-admin/firestore";
import {Page} from "../entities/page";
import {UserEntity, UserEntityData} from "../entities/user_entity";

export class UserRepository {
  constructor(
        private db: FirebaseFirestore.Firestore,
  ) { }

  private collection() {
    return this.db.collection("users")
      .withConverter({
        fromFirestore: (snapshot: FirebaseFirestore.QueryDocumentSnapshot) => {
          return UserEntity.fromDocument(snapshot);
        },
        toFirestore: (user: UserEntity) => UserAdapter.toMap(user),
      });
  }

  async create(user: UserEntity): Promise<UserEntity> {
    const userEntityWithoutId = cleanEntityId({...user});
    await this.collection().doc(user.id!).set(userEntityWithoutId);
    return user;
  }

  async getFromId(userId: string) {
    const snapshot = await this.collection()
      .doc(userId)
      .get();
    if (!snapshot.exists) {
      return null;
    }
    return UserEntity.fromDocument(snapshot);
  }

  async update(user: UserEntity) {
    const userEntityWithoutId = cleanEntityId({ ...user });
    await this.collection().doc(user.id!).set(userEntityWithoutId);
  }

  async updateEmail(userId: string, email: string) {
    await this.collection().doc(userId).update({
      email,
      "last_update_date": Timestamp.now(),
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
  async claimWelcome(userId: string): Promise<boolean> {
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
        "last_update_date": Timestamp.now(),
      });
      return true;
    });
  }

  async list({
    limit = 100,
    startAfter,
  }: {
        limit?: number,
        startAfter?: FirebaseFirestore.DocumentSnapshot,
    }) : Promise<Page<UserEntity>> {
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
          return <Page<UserEntity>>{items: []};
        }
        const entities = snapshot.docs.map((doc) => UserEntity.fromDocument(doc));
        return <Page<UserEntity>>{
          items: entities,
          lastSnapshot: snapshot.docs[snapshot.docs.length - 1],
        };
      });
  }
}

export class UserAdapter {
  static toMap(entity: UserEntityData): { [key: string]: unknown } {
    const cleanedEntity = cleanEntityId({...entity});
    return cleanedEntity;
  }
}
