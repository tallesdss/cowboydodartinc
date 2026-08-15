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
exports.verifyAdReward = void 0;
const crypto_1 = require("crypto");
const admin = __importStar(require("firebase-admin"));
const logger_1 = require("firebase-functions/logger");
const https_1 = require("firebase-functions/v2/https");
/**
 * AdMob rewarded-ads Server-Side Verification (SSV).
 *
 * When a user finishes a rewarded (or rewarded-interstitial) ad, Google calls
 * this endpoint with the reward details and a cryptographic signature. We verify
 * the signature against Google's public keys, then grant the reward exactly once
 * (idempotent on `transaction_id`). This is the secure way to grant rewards: a
 * tampered client can never fake it.
 *
 * Setup: deploy, then in the AdMob console set this function's URL as the SSV
 * callback for each rewarded ad unit:
 *   https://<region>-<project>.cloudfunctions.net/ads-verifyAdReward
 *
 * Docs: https://developers.google.com/admob/flutter/ssv
 */
const VERIFIER_KEYS_URL = "https://gstatic.com/admob/reward/verifier-keys.json";
const KEYS_TTL_MS = 60 * 60 * 1000; // 1h
let cachedKeys = null;
let cachedAt = 0;
/** Fetches (and caches) Google's rewarded-ads public verifier keys. */
async function getVerifierKeys() {
    const now = Date.now();
    if (cachedKeys && now - cachedAt < KEYS_TTL_MS)
        return cachedKeys;
    const res = await fetch(VERIFIER_KEYS_URL);
    if (!res.ok) {
        throw new Error(`Failed to fetch verifier keys: ${res.status}`);
    }
    const json = (await res.json());
    cachedKeys = json.keys;
    cachedAt = now;
    return cachedKeys;
}
/**
 * Verifies the SSV signature. The signed content is the raw query string up to
 * (but excluding) `&signature=`; `signature` and `key_id` are always the last
 * two parameters, in that order.
 */
async function isSignatureValid(rawQuery) {
    const signatureIndex = rawQuery.indexOf("&signature=");
    if (signatureIndex < 0)
        return false;
    const contentToVerify = rawQuery.substring(0, signatureIndex);
    const params = new URLSearchParams(rawQuery);
    const signature = params.get("signature");
    const keyId = params.get("key_id");
    if (!signature || !keyId)
        return false;
    const keys = await getVerifierKeys();
    const key = keys.find((k) => String(k.keyId) === keyId);
    if (!key) {
        (0, logger_1.error)(`[ads-ssv] no verifier key for key_id=${keyId}`);
        return false;
    }
    const verifier = (0, crypto_1.createVerify)("SHA256");
    verifier.update(contentToVerify);
    verifier.end();
    // AdMob signatures are base64url-encoded ASN.1 DER ECDSA over secp256r1.
    return verifier.verify(key.pem, Buffer.from(signature, "base64url"));
}
exports.verifyAdReward = (0, https_1.onRequest)({ cors: false }, async (req, res) => {
    var _a, _b, _c, _d;
    if (req.method !== "GET") {
        res.status(405).send("Method Not Allowed");
        return;
    }
    const rawQuery = req.originalUrl.includes("?") ?
        req.originalUrl.substring(req.originalUrl.indexOf("?") + 1) :
        "";
    try {
        let valid = false;
        try {
            valid = await isSignatureValid(rawQuery);
        }
        catch (e) {
            // Transient (e.g. verifier-key fetch failed) — 500 so Google retries.
            (0, logger_1.error)("[ads-ssv] verification error", e);
            res.status(500).send("verification error");
            return;
        }
        if (!valid) {
            // Forged/invalid: ack with 200 so Google doesn't retry a request that
            // can never become valid. We simply don't grant anything.
            (0, logger_1.info)("[ads-ssv] invalid signature — dropping");
            res.status(200).send("ok");
            return;
        }
        const userId = req.query.user_id;
        const transactionId = req.query.transaction_id;
        const rewardAmount = Number((_a = req.query.reward_amount) !== null && _a !== void 0 ? _a : 0);
        const rewardItem = (_b = req.query.reward_item) !== null && _b !== void 0 ? _b : "";
        const customData = (_c = req.query.custom_data) !== null && _c !== void 0 ? _c : "";
        const adUnit = (_d = req.query.ad_unit) !== null && _d !== void 0 ? _d : "";
        if (!userId || !transactionId) {
            // Signature is valid but no user to grant to: ack so Google stops
            // retrying. Configure `userId` via setServerSideOptions on the client.
            (0, logger_1.info)("[ads-ssv] valid callback without user_id/transaction_id");
            res.status(200).send("ok");
            return;
        }
        const db = admin.firestore();
        const rewardRef = db
            .collection("users")
            .doc(userId)
            .collection("ad_rewards")
            .doc(transactionId);
        await db.runTransaction(async (tx) => {
            const existing = await tx.get(rewardRef);
            if (existing.exists)
                return; // already granted: idempotent
            tx.set(rewardRef, {
                amount: rewardAmount,
                item: rewardItem,
                customData,
                adUnit,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            // ─── Grant the reward ─────────────────────────────────────────────
            // Replace this with your own entitlement (coins, lives, no-ads pass…).
            // The example keeps a running balance on the user document.
            tx.set(db.collection("users").doc(userId), {
                adRewardBalance: admin.firestore.FieldValue.increment(rewardAmount),
            }, { merge: true });
        });
        (0, logger_1.info)(`[ads-ssv] reward granted user=${userId} tx=${transactionId}`);
        res.status(200).send("ok");
    }
    catch (e) {
        (0, logger_1.error)("[ads-ssv]", e);
        res.status(500).send(e instanceof Error ? e.message : String(e));
    }
});
//# sourceMappingURL=ads_functions.js.map