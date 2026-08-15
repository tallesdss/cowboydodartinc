"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.handleNotificationType = handleNotificationType;
function isNotificationParams(obj) {
    if (obj !== null && typeof obj === "object") {
        return "type" in obj;
    }
    return false;
}
function isSystemNotificationParams(obj) {
    if (obj !== null && typeof obj === "object") {
        return "systemNotification" in obj && "title" in obj;
    }
    return false;
}
function isSystemOnlyNotificationParams(obj) {
    if (obj !== null && typeof obj === "object") {
        return "systemNotification" in obj && !("title" in obj);
    }
    return false;
}
function handleNotificationType(params, onBasicNotification, onSystemNotification, onSystemOnlyNotification) {
    if (isNotificationParams(params) && onBasicNotification) {
        onBasicNotification(params);
    }
    else if (isSystemNotificationParams(params) && onSystemNotification) {
        onSystemNotification(params);
    }
    else if (isSystemOnlyNotificationParams(params) && onSystemOnlyNotification) {
        onSystemOnlyNotification(params);
    }
}
//# sourceMappingURL=notification.js.map