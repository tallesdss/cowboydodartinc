"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.NotificationAdapter = exports.NotificationEntity = exports.NotificationTypes = void 0;
const entity_utils_1 = require("./entity_utils");
var NotificationTypes;
(function (NotificationTypes) {
    NotificationTypes["WELCOME"] = "WELCOME";
    NotificationTypes["OTHER"] = "OTHER";
    NotificationTypes["LINK"] = "LINK";
})(NotificationTypes || (exports.NotificationTypes = NotificationTypes = {}));
class NotificationEntity {
    constructor({ id, title, body, type, creation_date, seen_date, notify_user, data, image_url, }) {
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
    static fromData(data) {
        return new NotificationEntity(data);
    }
    static fromDocument(data) {
        const resData = data.data();
        resData.id = data.id;
        return new NotificationEntity(resData);
    }
}
exports.NotificationEntity = NotificationEntity;
class NotificationAdapter {
    static toMap(data) {
        var _a;
        const cleaned = (0, entity_utils_1.cleanEntityId)(data);
        return Object.assign(Object.assign({}, cleaned), { 
            // seen_date must be explicitly null (not absent) so Firestore isNull queries work for badge counts.
            seen_date: (_a = data.seen_date) !== null && _a !== void 0 ? _a : null });
    }
}
exports.NotificationAdapter = NotificationAdapter;
//# sourceMappingURL=notification_entity.js.map