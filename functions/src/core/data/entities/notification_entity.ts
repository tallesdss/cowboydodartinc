import {QueryDocumentSnapshot, Timestamp} from "firebase-admin/firestore";
import {cleanEntityId} from "./entity_utils";

export interface NotificationEntityData {
    id?: string,
    title: string;
    body?: string;
    type?: NotificationTypes,
    creation_date: Timestamp;
    seen_date?: Timestamp;
    notify_user: boolean;
    data?: { [key: string]: any },
    image_url?: string;
}

export enum NotificationTypes {
    WELCOME = "WELCOME",
    OTHER = "OTHER",
    LINK = "LINK",
}

export interface NotificationType {
    type: NotificationTypes;
}

export type NewNotificationEntityData = Omit<NotificationEntityData, "id">;

export interface NotificationEntity extends NotificationEntityData {}

export class NotificationEntity {
  constructor({
    id,
    title,
    body,
    type,
    creation_date,
    seen_date,
    notify_user,
    data,
    image_url,
  }: NotificationEntityData
  ) {
    this.id = id;
    this.title = title;
    this.body = body;
    this.type = type;
    this.creation_date = creation_date;
    this.seen_date = seen_date;
    this.notify_user = notify_user;
    this.data = data;
    this.image_url = image_url;
  }

  static fromData(data: NotificationEntityData): NotificationEntity {
    return new NotificationEntity(data);
  }

  static fromDocument(data: QueryDocumentSnapshot): NotificationEntity {
    const resData = data.data() as NotificationEntityData;
    resData.id = data.id;
    return new NotificationEntity(resData);
  }
}

export class NotificationAdapter {
  static toMap(data: NewNotificationEntityData): { [key: string]: unknown } {
    const cleaned = cleanEntityId(data);
    return {
      ...cleaned,
      // seen_date must be explicitly null (not absent) so Firestore isNull queries work for badge counts.
      seen_date: data.seen_date ?? null,
    };
  }
}
