import {QueryDocumentSnapshot, Timestamp} from "firebase-admin/firestore";
import {cleanEntityId} from "./entity_utils";

export const UserDevice = {
  ANDROID: "android",
  IOS: "ios",
  WEB: "WEB",
} as const;

export type UserDeviceTypes = (typeof UserDevice)[keyof typeof UserDevice];

export interface UserDeviceEntityData {
    id?: string,
    token: string;
    device_id: string;
    operatingSystem: UserDeviceTypes;
    type: UserDeviceTypes;
    creation_date: Timestamp;
    // Heartbeat timestamp written by the Flutter client. The field name matches
    // what the client actually serializes (camelCase) — see device_entity.g.dart.
    lastUpdateDate?: Timestamp;
    extra_data?: { [key: string]: string };
}

export type NewUserDeviceEntityData = Omit<UserDeviceEntityData, "id">;

export interface UserDeviceEntity extends UserDeviceEntityData {}

export class UserDeviceEntity {
  constructor({
    id,
    token,
    device_id,
    type,
    operatingSystem,
    creation_date,
    extra_data,
  }: UserDeviceEntityData
  ) {
    this.id = id;
    this.token = token;
    this.device_id = device_id;
    this.type = type;
    this.operatingSystem = operatingSystem;
    this.creation_date = creation_date;
    this.extra_data = extra_data;
  }

  static fromData(data: UserDeviceEntityData): UserDeviceEntity {
    return new UserDeviceEntity(data);
  }

  static fromDocument(data: QueryDocumentSnapshot): UserDeviceEntity {
    const resData = data.data() as UserDeviceEntityData;
    resData.id = data.id;
    return new UserDeviceEntity(resData);
  }
}

export class UserDeviceAdapter {
  static toMap(data: UserDeviceEntityData): { [key: string]: unknown } {
    const cleanData = cleanEntityId(data);
    return {
      ...cleanData,
    };
  }
}
