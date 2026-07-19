import {DocumentSnapshot, QueryDocumentSnapshot, Timestamp} from "firebase-admin/firestore";

export interface UserEntityData {
    id?: string,
    name?: string;
    email?: string;
    creation_date: Timestamp;
    last_update_date: Timestamp;
    locale?: string;
    /**
     * Set to true once the one-time welcome notification has been sent for this
     * account. Guards against re-sending it when a device is re-registered after
     * a logout/login cycle (which otherwise looks like a brand-new first device).
     */
    welcome_sent?: boolean;
}

export type NewUserEntityData = Omit<UserEntityData, "id">;

export interface UserEntity extends UserEntityData {}

export class UserEntity {
  constructor({
    id,
    name,
    email,
    creation_date,
    last_update_date,
    locale,
    welcome_sent
  }: UserEntityData
  ) {
    this.id = id;
    this.name = name;
    this.email = email;
    this.creation_date = creation_date;
    this.last_update_date = last_update_date;
    this.locale = locale;
    this.welcome_sent = welcome_sent;
  }

  static fromData(data: UserEntityData): UserEntity {
    return new UserEntity(data);
  }

  static fromDocument(data: QueryDocumentSnapshot | DocumentSnapshot): UserEntity {
    const result = data.data() as UserEntityData;
    result.id = data.id;
    return new UserEntity(result);
  }
}
