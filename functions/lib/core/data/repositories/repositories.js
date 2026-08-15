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
exports.subscriptionsRepository = exports.userDevicesRepository = exports.notificationsRepository = exports.usersRepository = void 0;
const subscription_repository_1 = require("./subscription_repository");
const user_device_repository_1 = require("./user_device_repository");
const user_notifications_repository_1 = require("./user_notifications_repository");
const user_repository_1 = require("./user_repository");
const admin = __importStar(require("firebase-admin"));
// One of the best practices for cloud function is
// Use global variables to reuse objects in future invocations
// https://firebase.google.com/docs/functions/tips#use_global_variables_to_reuse_objects_in_future_invocations
const firestore = admin.firestore();
exports.usersRepository = new user_repository_1.UserRepository(firestore);
exports.notificationsRepository = new user_notifications_repository_1.UserNotificationsRepository(firestore);
exports.userDevicesRepository = new user_device_repository_1.UserDevicesRepository(firestore);
exports.subscriptionsRepository = new subscription_repository_1.SubscriptionsRepository(firestore);
//# sourceMappingURL=repositories.js.map