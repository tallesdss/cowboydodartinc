"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
const admin = __importStar(require("firebase-admin"));
const v2_1 = require("firebase-functions/v2");
// Initialize functions preferred region (replaced by kasy at project generation)
(0, v2_1.setGlobalOptions)({ region: "us-central1" });
admin.initializeApp();
// authentications
exports.authTriggers = require("./authentication/triggers");
exports.authFunctions = require("./authentication/functions");
// notifications
exports.notificationsTriggers = require("./notifications/triggers");
exports.notificationsFunctions = require("./notifications/admin_functions");
exports.deviceTriggers = require("./notifications/device_triggers");
// subscriptions
exports.subscriptions = require("./subscriptions/subscriptions_functions");
exports.subscriptionTriggers = require("./subscriptions/triggers");
// stripe web subscriptions (activated when the Stripe module is enabled)
exports.stripeFunctions = require("./subscriptions/stripe_functions");
// admin console (listUsers — gated on users/{uid}.role == "admin")
exports.adminFunctions = require("./admin/functions");
// feature requests: vote counter updated atomically by client (WriteBatch)
// llm chat proxy (activated when withAiChat = true)
exports.aiChat = require("./ai_chat").aiChat;
// ads: rewarded Server-Side Verification (activated when the ads module is on)
exports.ads = require("./ads/ads_functions");
// library functions
exports.library = require("./library/triggers");
//# sourceMappingURL=index.js.map