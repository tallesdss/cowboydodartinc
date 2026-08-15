"use strict";
/**
 * Firebase Cloud Function: AI Chat Proxy (streaming)
 *
 * Receives {message, history} from the Flutter app and streams the response
 * back as Server-Sent Events (SSE). The API key never leaves the server.
 *
 * Secrets required (set via `firebase functions:secrets:set`):
 *   - AI_API_KEY: API key for OpenAI or Gemini
 *
 * Environment variables (set in functions/.env):
 *   - AI_PROVIDER: "openai" (default) or "gemini"
 *   - AI_SYSTEM_PROMPT: System prompt for the agent (optional)
 *
 * App dart-define:
 *   - AI_CHAT_ENDPOINT: URL of this function after deploy
 *     Example: https://us-central1-<project-id>.cloudfunctions.net/aiChat
 *
 * Deploy: kasy deploy  (or: firebase deploy --only functions:aiChat)
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.aiChat = void 0;
const https_1 = require("firebase-functions/v2/https");
const params_1 = require("firebase-functions/params");
const auth_1 = require("firebase-admin/auth");
const aiApiKey = (0, params_1.defineSecret)("AI_API_KEY");
// Pipes the OpenAI SSE stream directly to the Express response.
async function streamOpenAI(res, apiKey, systemPrompt, message, history) {
    const messages = [];
    if (systemPrompt)
        messages.push({ role: "system", content: systemPrompt });
    for (const m of history)
        messages.push(m);
    messages.push({ role: "user", content: message });
    const upstream = await fetch("https://api.openai.com/v1/chat/completions", {
        method: "POST",
        headers: {
            Authorization: `Bearer ${apiKey}`,
            "Content-Type": "application/json",
        },
        body: JSON.stringify({ model: "gpt-4o-mini", messages, stream: true }),
    });
    if (!upstream.ok) {
        throw new Error(`OpenAI ${upstream.status}: ${await upstream.text()}`);
    }
    const reader = upstream.body.getReader();
    res.on("close", () => reader.cancel());
    while (true) {
        const { done, value } = await reader.read();
        if (done)
            break;
        res.write(value);
    }
}
// Pipes the Gemini SSE stream directly to the Express response.
async function streamGemini(res, apiKey, systemPrompt, message, history) {
    const contents = [
        ...history.map((m) => ({
            role: m.role === "assistant" ? "model" : "user",
            parts: [{ text: m.content }],
        })),
        { role: "user", parts: [{ text: message }] },
    ];
    const body = { contents };
    if (systemPrompt) {
        body.systemInstruction = { parts: [{ text: systemPrompt }] };
    }
    // alt=sse makes Gemini return the same SSE format as OpenAI
    const upstream = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:streamGenerateContent?key=${apiKey}&alt=sse`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
    });
    if (!upstream.ok) {
        throw new Error(`Gemini ${upstream.status}: ${await upstream.text()}`);
    }
    const reader = upstream.body.getReader();
    res.on("close", () => reader.cancel());
    while (true) {
        const { done, value } = await reader.read();
        if (done)
            break;
        res.write(value);
    }
}
async function verifyFirebaseToken(req, res) {
    var _a;
    const authHeader = (_a = req.headers.authorization) !== null && _a !== void 0 ? _a : "";
    const token = authHeader.startsWith("Bearer ") ? authHeader.slice(7) : "";
    if (!token) {
        res.status(401).json({ error: "Missing Authorization token" });
        return null;
    }
    try {
        const decoded = await (0, auth_1.getAuth)().verifyIdToken(token);
        return decoded.uid;
    }
    catch (_b) {
        res.status(401).json({ error: "Invalid or expired token" });
        return null;
    }
}
exports.aiChat = (0, https_1.onRequest)({ cors: true, secrets: [aiApiKey] }, async (req, res) => {
    var _a, _b;
    if (req.method !== "POST") {
        res.status(405).json({ error: "Method not allowed" });
        return;
    }
    const uid = await verifyFirebaseToken(req, res);
    if (!uid)
        return;
    const { message, history = [] } = req.body;
    if (!message) {
        res.status(400).json({ error: "Missing message" });
        return;
    }
    const apiKey = aiApiKey.value();
    if (!apiKey) {
        res
            .status(500)
            .json({ error: "AI_API_KEY not configured. Run: firebase functions:secrets:set AI_API_KEY" });
        return;
    }
    const provider = (_a = process.env.AI_PROVIDER) !== null && _a !== void 0 ? _a : "openai";
    const systemPrompt = (_b = process.env.AI_SYSTEM_PROMPT) !== null && _b !== void 0 ? _b : "";
    // SSE headers — must be set before any write
    res.setHeader("Content-Type", "text/event-stream");
    res.setHeader("Cache-Control", "no-cache");
    res.setHeader("X-Accel-Buffering", "no"); // disable nginx proxy buffering
    res.flushHeaders();
    try {
        if (provider === "gemini") {
            await streamGemini(res, apiKey, systemPrompt, message, history);
        }
        else {
            await streamOpenAI(res, apiKey, systemPrompt, message, history);
        }
        res.end();
    }
    catch (err) {
        console.error("[ai-chat]", err);
        // Send error as SSE event so the Flutter client can surface it
        res.write(`data: ${JSON.stringify({ error: "AI request failed" })}\n\n`);
        res.end();
    }
});
//# sourceMappingURL=index.js.map