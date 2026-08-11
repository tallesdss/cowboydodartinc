import * as admin from "firebase-admin";
import {setGlobalOptions} from "firebase-functions/v2";

// Initialize functions preferred region (replaced by kasy at project generation)
setGlobalOptions({region: "us-central1"});

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

