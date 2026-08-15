"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onNewSubscription = void 0;
const logger_1 = require("../core/logger/logger");
const repositories_1 = require("../core/data/repositories/repositories");
const notifications_api_1 = require("../notifications/notifications_api");
const firestore_1 = require("firebase-functions/v2/firestore");
/// Localized copy for the "subscription saved" notification.
function subscriptionSavedText(locale) {
    switch (locale) {
        case "pt":
            return { title: "Assinatura confirmada", body: "Obrigado pela sua confiança!" };
        case "es":
            return { title: "Suscripción confirmada", body: "¡Gracias por tu confianza!" };
        default:
            return { title: "Subscription confirmed", body: "Thank you for your trust!" };
    }
}
/// Resolves the user's language: the locale persisted on the user (set on web at
/// checkout), then the device locale (native), then English.
async function resolveUserLocale(userId, userLocale) {
    var _a, _b;
    if (userLocale)
        return userLocale.substring(0, 2).toLowerCase();
    try {
        const devices = await repositories_1.userDevicesRepository.getDevices([userId]);
        const raw = (_b = (_a = devices[0]) === null || _a === void 0 ? void 0 : _a.extra_data) === null || _b === void 0 ? void 0 : _b["deviceLocale"];
        if (raw)
            return raw.substring(0, 2).toLowerCase();
    }
    catch (_c) {
        // Fall through to the default below.
    }
    return "en";
}
exports.onNewSubscription = (0, firestore_1.onDocumentCreated)("subscriptions/{userId}", async (event) => {
    if (!event.data) {
        return Promise.resolve();
    }
    const userId = event.params.userId;
    const logger = new logger_1.Logger("onNewSubscription");
    try {
        logger.info(`New subscription for user ${userId}`);
        const user = await repositories_1.usersRepository.getFromId(userId);
        if (!user) {
            logger.error(`User ${userId} not found`);
            return;
        }
        const locale = await resolveUserLocale(userId, user.locale);
        const { title, body } = subscriptionSavedText(locale);
        await notifications_api_1.notificationsApi.notify([userId], {
            title,
            body,
        });
    }
    catch (error) {
        logger.error(`Error processing subscription for user ${userId} : ${error}`);
    }
});
//# sourceMappingURL=triggers.js.map