/**
 * Supabase Edge Function: AI Chat Proxy (streaming)
 *
 * Receives {message, history} from the Flutter app and streams the response
 * back as Server-Sent Events (SSE). The API key never leaves the server.
 *
 * Secrets required (set via `supabase secrets set`):
 *   - AI_API_KEY: API key for OpenAI or Gemini
 *   - AI_PROVIDER: "openai" (default) or "gemini"
 *   - AI_SYSTEM_PROMPT: System prompt for the agent (optional)
 *
 * App dart-define:
 *   - AI_CHAT_ENDPOINT: https://<project-ref>.supabase.co/functions/v1/ai-chat
 *
 * Deploy: supabase functions deploy ai-chat --no-verify-jwt
 */

const AI_API_KEY = Deno.env.get("AI_API_KEY") ?? "";
const AI_PROVIDER = Deno.env.get("AI_PROVIDER") ?? "openai";
const AI_SYSTEM_PROMPT = Deno.env.get("AI_SYSTEM_PROMPT") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const SSE_HEADERS = {
  "Content-Type": "text/event-stream",
  "Cache-Control": "no-cache",
  "Access-Control-Allow-Origin": "*",
};

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface ChatMessage {
  role: "user" | "assistant";
  content: string;
}

// Pipes the OpenAI SSE stream directly to the Deno response.
function streamOpenAI(message: string, history: ChatMessage[]): Promise<Response> {
  const messages: { role: string; content: string }[] = [];
  if (AI_SYSTEM_PROMPT) messages.push({ role: "system", content: AI_SYSTEM_PROMPT });
  messages.push(...history);
  messages.push({ role: "user", content: message });

  return fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${AI_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ model: "gpt-4o-mini", messages, stream: true }),
  }).then((upstream) => {
    if (!upstream.ok) {
      return upstream.text().then((t) => {
        throw new Error(`OpenAI ${upstream.status}: ${t}`);
      });
    }
    // Pipe the upstream SSE body directly to the Flutter client
    return new Response(upstream.body, { headers: SSE_HEADERS });
  });
}

// Pipes the Gemini SSE stream directly to the Deno response.
function streamGemini(message: string, history: ChatMessage[]): Promise<Response> {
  const contents = [
    ...history.map((m) => ({
      role: m.role === "assistant" ? "model" : "user",
      parts: [{ text: m.content }],
    })),
    { role: "user", parts: [{ text: message }] },
  ];

  const body: Record<string, unknown> = { contents };
  if (AI_SYSTEM_PROMPT) {
    body.systemInstruction = { parts: [{ text: AI_SYSTEM_PROMPT }] };
  }

  // alt=sse makes Gemini return the same SSE format as OpenAI
  return fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:streamGenerateContent?key=${AI_API_KEY}&alt=sse`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    }
  ).then((upstream) => {
    if (!upstream.ok) {
      return upstream.text().then((t) => {
        throw new Error(`Gemini ${upstream.status}: ${t}`);
      });
    }
    return new Response(upstream.body, { headers: SSE_HEADERS });
  });
}

async function verifySupabaseJwt(req: Request): Promise<boolean> {
  const authHeader = req.headers.get("Authorization") ?? "";
  const token = authHeader.startsWith("Bearer ") ? authHeader.slice(7) : "";
  if (!token || !SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) return false;
  try {
    const { createClient } = await import("https://esm.sh/@supabase/supabase-js@2.47.10");
    const admin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
    const { data: { user }, error } = await admin.auth.getUser(token);
    return !error && user != null;
  } catch {
    return false;
  }
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: CORS_HEADERS });
  }

  if (req.method !== "POST") {
    return Response.json({ error: "Method not allowed" }, { status: 405 });
  }

  const authenticated = await verifySupabaseJwt(req);
  if (!authenticated) {
    return Response.json({ error: "Unauthorized" }, { status: 401 });
  }

  let body: { message?: string; history?: ChatMessage[] };
  try {
    body = await req.json();
  } catch {
    return Response.json({ error: "Invalid JSON" }, { status: 400 });
  }

  const { message, history = [] } = body;
  if (!message) {
    return Response.json({ error: "Missing message" }, { status: 400 });
  }

  if (!AI_API_KEY) {
    return Response.json(
      { error: "AI_API_KEY not configured. Run: supabase secrets set AI_API_KEY=..." },
      { status: 500 }
    );
  }

  try {
    return AI_PROVIDER === "gemini"
      ? await streamGemini(message, history)
      : await streamOpenAI(message, history);
  } catch (err) {
    console.error("[ai-chat]", err);
    // Send error as SSE event so the Flutter client can surface it
    const errorEvent = `data: ${JSON.stringify({ error: "AI request failed" })}\n\n`;
    return new Response(errorEvent, { headers: SSE_HEADERS });
  }
});
