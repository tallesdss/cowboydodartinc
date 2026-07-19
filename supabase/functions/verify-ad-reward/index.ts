/**
 * Supabase Edge Function: AdMob rewarded Server-Side Verification (SSV).
 *
 * When a user finishes a rewarded (or rewarded-interstitial) ad, Google calls
 * this endpoint with the reward details and a cryptographic signature. We verify
 * the signature against Google's public keys, then grant the reward exactly once
 * (idempotent on `transaction_id`) via the grant_ad_reward() SQL function. This
 * is the secure way to grant rewards: a tampered client can never fake it.
 *
 * Setup: deploy, then in the AdMob console set this function's URL as the SSV
 * callback for each rewarded ad unit:
 *   https://<project-ref>.supabase.co/functions/v1/verify-ad-reward
 *
 * No secret is needed (verification uses Google's public keys). The handler uses
 * the service role key to call the grant function.
 *
 * Verification uses Web Crypto (crypto.subtle), like every other edge function
 * here. AdMob signs with ECDSA P-256 / SHA-256 and sends an ASN.1 DER signature,
 * while Web Crypto expects the raw r||s (IEEE P1363) form, so we convert.
 *
 * @see https://developers.google.com/admob/flutter/ssv
 */

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.47.10";

const VERIFIER_KEYS_URL = "https://gstatic.com/admob/reward/verifier-keys.json";
const KEYS_TTL_MS = 60 * 60 * 1000; // 1h

interface VerifierKey {
  keyId: number;
  pem: string;
  base64: string; // DER SubjectPublicKeyInfo, base64-encoded
}

let cachedKeys: VerifierKey[] | null = null;
let cachedAt = 0;

/** Fetches (and caches) Google's rewarded-ads public verifier keys. */
async function getVerifierKeys(): Promise<VerifierKey[]> {
  const now = Date.now();
  if (cachedKeys && now - cachedAt < KEYS_TTL_MS) return cachedKeys;
  const res = await fetch(VERIFIER_KEYS_URL);
  if (!res.ok) throw new Error(`Failed to fetch verifier keys: ${res.status}`);
  const json = (await res.json()) as { keys: VerifierKey[] };
  cachedKeys = json.keys;
  cachedAt = now;
  return cachedKeys;
}

function base64ToBytes(b64: string): Uint8Array<ArrayBuffer> {
  const bin = atob(b64);
  const bytes = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
  return bytes;
}

function base64UrlToBytes(b64url: string): Uint8Array<ArrayBuffer> {
  const b64 = b64url.replace(/-/g, "+").replace(/_/g, "/");
  const pad = (4 - (b64.length % 4)) % 4;
  return base64ToBytes(b64 + "=".repeat(pad));
}

/** Converts an ASN.1 DER ECDSA signature to raw r||s (64 bytes for P-256). */
function derToP1363(der: Uint8Array): Uint8Array<ArrayBuffer> {
  let offset = 0;
  if (der[offset++] !== 0x30) throw new Error("bad DER: no sequence");
  // sequence length (skip; short or long form)
  let lenByte = der[offset++];
  if (lenByte & 0x80) offset += lenByte & 0x7f;

  const readInt = (): Uint8Array => {
    if (der[offset++] !== 0x02) throw new Error("bad DER: no integer");
    const len = der[offset++];
    let val = der.subarray(offset, offset + len);
    offset += len;
    // strip leading zero padding
    let i = 0;
    while (i < val.length - 1 && val[i] === 0x00) i++;
    val = val.subarray(i);
    if (val.length > 32) throw new Error("bad DER: integer too long");
    const out = new Uint8Array(32);
    out.set(val, 32 - val.length);
    return out;
  };

  const r = readInt();
  const s = readInt();
  const sig = new Uint8Array(64);
  sig.set(r, 0);
  sig.set(s, 32);
  return sig;
}

/**
 * Verifies the SSV signature. The signed content is the raw query string up to
 * (but excluding) `&signature=`; `signature` and `key_id` are always the last
 * two parameters, in that order.
 */
async function isSignatureValid(rawQuery: string): Promise<boolean> {
  const sigIndex = rawQuery.indexOf("&signature=");
  if (sigIndex < 0) return false;
  const contentToVerify = rawQuery.substring(0, sigIndex);

  const params = new URLSearchParams(rawQuery);
  const signature = params.get("signature");
  const keyId = params.get("key_id");
  if (!signature || !keyId) return false;

  const keys = await getVerifierKeys();
  const key = keys.find((k) => String(k.keyId) === keyId);
  if (!key) {
    console.error(`[ads-ssv] no verifier key for key_id=${keyId}`);
    return false;
  }

  const publicKey = await crypto.subtle.importKey(
    "spki",
    base64ToBytes(key.base64),
    { name: "ECDSA", namedCurve: "P-256" },
    false,
    ["verify"],
  );
  const sig = derToP1363(base64UrlToBytes(signature));
  return crypto.subtle.verify(
    { name: "ECDSA", hash: "SHA-256" },
    publicKey,
    sig,
    new TextEncoder().encode(contentToVerify),
  );
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers":
          "authorization, x-client-info, apikey, content-type",
        "Access-Control-Allow-Methods": "GET, OPTIONS",
      },
    });
  }
  if (req.method !== "GET") {
    return new Response("Method not allowed", { status: 405 });
  }

  // Use the raw query string (not re-encoded) so the signature matches exactly.
  const rawQuery = req.url.includes("?") ?
    req.url.substring(req.url.indexOf("?") + 1) :
    "";

  try {
    let valid = false;
    try {
      valid = await isSignatureValid(rawQuery);
    } catch (e) {
      console.error("[ads-ssv] signature verification error", e);
      valid = false;
    }
    if (!valid) {
      // Forged/invalid: ack with 200 so Google doesn't retry a request that can
      // never become valid. We just don't grant anything.
      console.log("[ads-ssv] invalid signature — dropping");
      return new Response("ok", { status: 200 });
    }

    const params = new URLSearchParams(rawQuery);
    const userId = params.get("user_id");
    const transactionId = params.get("transaction_id");
    const amount = Number(params.get("reward_amount") ?? 0);
    const item = params.get("reward_item") ?? "";
    const customData = params.get("custom_data") ?? "";
    const adUnit = params.get("ad_unit") ?? "";

    if (!userId || !transactionId) {
      console.log("[ads-ssv] valid callback without user_id/transaction_id");
      return new Response("ok", { status: 200 });
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!supabaseUrl || !serviceRoleKey) {
      // Transient/config fault — non-2xx so Google retries later.
      console.error("SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY not set");
      return new Response("Server configuration error", { status: 500 });
    }

    const supabase = createClient(supabaseUrl, serviceRoleKey);
    const { data, error } = await supabase.rpc("grant_ad_reward", {
      p_user_id: userId,
      p_transaction_id: transactionId,
      p_amount: amount,
      p_item: item,
      p_custom_data: customData,
      p_ad_unit: adUnit,
    });
    if (error) {
      // Transient DB fault — non-2xx so Google retries.
      console.error("[ads-ssv] grant error", error);
      return new Response(error.message, { status: 500 });
    }

    console.log(
      `[ads-ssv] reward ${data ? "granted" : "duplicate"} ` +
        `user=${userId} tx=${transactionId}`,
    );
    return new Response("ok", { status: 200 });
  } catch (e) {
    console.error("[ads-ssv]", e);
    return new Response(e instanceof Error ? e.message : String(e), {
      status: 500,
    });
  }
});
