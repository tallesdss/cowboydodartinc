/**
 * Supabase Edge Function: Admin — List Users
 *
 * Paginated user list + Overview aggregates. Shape matches the Firebase
 * Cloud Function so the shared Flutter UI stays identical across backends.
 *
 * Request body (JSON):
 *   Paginated: { page?, pageSize?, search?, subscribersOnly?, sort?, sortAsc? }
 *   Overview:  { overview: true }
 */

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.47.10";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const SEARCH_SCAN_CAP = 500;
const MAX_PAGE_SIZE = 50;
const ACTIVE_SUBSCRIPTION_STATUSES = ["ACTIVE", "LIFETIME"];

type SortKey = "default" | "user" | "status" | "plan" | "joined";

type AdminSupabase = ReturnType<typeof createClient<any, "public", any>>;

interface AdminUser {
  id: string;
  email: string | null;
  name: string | null;
  createdAt: number | null;
  avatarPath: string | null;
  subscriber: boolean;
}

interface ListUsersBody {
  page?: number;
  pageSize?: number;
  search?: string;
  subscribersOnly?: boolean;
  sort?: string;
  sortAsc?: boolean;
  overview?: boolean;
}

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function clampPageSize(n: unknown): number {
  const v = typeof n === "number" ? n : Number(n);
  if (!Number.isFinite(v)) return 10;
  return Math.min(MAX_PAGE_SIZE, Math.max(1, Math.floor(v)));
}

function clampPage(n: unknown): number {
  const v = typeof n === "number" ? n : Number(n);
  if (!Number.isFinite(v)) return 0;
  return Math.max(0, Math.floor(v));
}

function parseSort(raw: unknown): SortKey {
  switch (raw) {
    case "user":
    case "status":
    case "plan":
    case "joined":
      return raw;
    default:
      return "default";
  }
}

function rankActive(u: AdminUser): number {
  return u.email && u.email.length > 0 ? 0 : 1;
}

function rankSub(u: AdminUser): number {
  return u.subscriber ? 0 : 1;
}

function displayKey(u: AdminUser): string {
  const base = u.name && u.name.length > 0 ? u.name : (u.email ?? "~");
  return base.toLowerCase();
}

function sortUsers(users: AdminUser[], sort: SortKey, asc: boolean): void {
  const dir = asc ? 1 : -1;
  users.sort((a, b) => {
    let r = 0;
    switch (sort) {
      case "user":
        r = displayKey(a).localeCompare(displayKey(b));
        break;
      case "status":
        r = rankActive(a) - rankActive(b);
        break;
      case "plan":
        r = rankSub(a) - rankSub(b);
        break;
      case "joined":
        r = (a.createdAt ?? 0) - (b.createdAt ?? 0);
        break;
      default: {
        const byActive = rankActive(a) - rankActive(b);
        if (byActive !== 0) r = byActive;
        else {
          const bySub = rankSub(a) - rankSub(b);
          if (bySub !== 0) r = bySub;
          else r = (a.createdAt ?? 0) - (b.createdAt ?? 0);
        }
        break;
      }
    }
    if (r === 0) r = (b.createdAt ?? 0) - (a.createdAt ?? 0);
    return r * dir;
  });
}

function matchesSearch(u: AdminUser, q: string): boolean {
  if (!q) return true;
  const email = (u.email ?? "").toLowerCase();
  const name = (u.name ?? "").toLowerCase();
  return email.includes(q) || name.includes(q);
}

function pagePayload(
  users: AdminUser[],
  totalUsers: number,
  page: number,
  pageSize: number,
  searchCapped = false,
) {
  const pageCount = totalUsers === 0 ? 1 : Math.ceil(totalUsers / pageSize);
  return { users, totalUsers, page, pageSize, pageCount, searchCapped };
}

function mapRow(
  d: Record<string, unknown>,
  activeSubscribers: Set<string>,
): AdminUser {
  return {
    id: d.id as string,
    email: (d.email as string) || null,
    name: (d.name as string) || null,
    createdAt: d.creation_date
      ? new Date(d.creation_date as string).getTime()
      : null,
    avatarPath: (d.avatar_url as string) || null,
    subscriber: activeSubscribers.has(d.id as string),
  };
}

async function loadSubscriberIds(
  admin: AdminSupabase,
): Promise<Set<string>> {
  const { data, error } = await admin
    .from("subscriptions")
    .select("user_id")
    .in("status", ACTIVE_SUBSCRIPTION_STATUSES);
  if (error) throw error;
  return new Set((data ?? []).map((s) => s.user_id as string));
}

async function loadSubscriberIdsForUsers(
  admin: AdminSupabase,
  ids: string[],
): Promise<Set<string>> {
  if (ids.length === 0) return new Set();
  const { data, error } = await admin
    .from("subscriptions")
    .select("user_id, status")
    .in("user_id", ids);
  if (error) throw error;
  const active = new Set<string>();
  for (const s of data ?? []) {
    if (ACTIVE_SUBSCRIPTION_STATUSES.includes(s.status as string)) {
      active.add(s.user_id as string);
    }
  }
  return active;
}

async function buildOverview(admin: AdminSupabase) {
  const now = new Date();
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const start = new Date(today);
  start.setDate(start.getDate() - 13);
  const sevenAgo = new Date(today);
  sevenAgo.setDate(sevenAgo.getDate() - 6);

  const startIso = start.toISOString();

  const [countRes, subCountRes, recentRes] = await Promise.all([
    admin.from("users").select("*", { count: "exact", head: true }),
    admin
      .from("subscriptions")
      .select("*", { count: "exact", head: true })
      .in("status", ACTIVE_SUBSCRIPTION_STATUSES),
    admin
      .from("users")
      .select("creation_date")
      .gte("creation_date", startIso),
  ]);

  if (countRes.error) throw countRes.error;
  if (subCountRes.error) throw subCountRes.error;
  if (recentRes.error) throw recentRes.error;

  const daily = Array<number>(14).fill(0);
  let new7d = 0;
  for (const row of recentRes.data ?? []) {
    if (!row.creation_date) continue;
    const d = new Date(row.creation_date as string);
    const day = new Date(d.getFullYear(), d.getMonth(), d.getDate());
    const idx = Math.floor(
      (day.getTime() - start.getTime()) / (24 * 60 * 60 * 1000),
    );
    if (idx >= 0 && idx < 14) daily[idx]++;
    if (day.getTime() >= sevenAgo.getTime()) new7d++;
  }

  return {
    totalUsers: countRes.count ?? 0,
    subscribers: subCountRes.count ?? 0,
    new7d,
    daily,
    firstDayMs: start.getTime(),
    lastDayMs: today.getTime(),
  };
}

async function listIndexedPage(
  admin: AdminSupabase,
  page: number,
  pageSize: number,
  sort: SortKey,
  sortAsc: boolean,
) {
  const from = page * pageSize;
  const to = from + pageSize - 1;
  const orderCol = sort === "user" ? "name" : "creation_date";

  const { count, error: countError } = await admin
    .from("users")
    .select("*", { count: "exact", head: true });
  if (countError) throw countError;

  const { data, error } = await admin
    .from("users")
    .select("id, email, name, creation_date, avatar_url")
    .order(orderCol, { ascending: sortAsc, nullsFirst: false })
    .range(from, to);
  if (error) throw error;

  const rows = data ?? [];
  const activeSubscribers = await loadSubscriberIdsForUsers(
    admin,
    rows.map((r) => r.id as string),
  );
  const users = rows.map((r) => mapRow(r, activeSubscribers));
  return pagePayload(users, count ?? 0, page, pageSize);
}

async function listScannedPage(
  admin: AdminSupabase,
  page: number,
  pageSize: number,
  search: string,
  subscribersOnly: boolean,
  sort: SortKey,
  sortAsc: boolean,
) {
  const { data, error } = await admin
    .from("users")
    .select("id, email, name, creation_date, avatar_url")
    .limit(SEARCH_SCAN_CAP);
  if (error) throw error;

  const activeSubscribers = await loadSubscriberIds(admin);
  let users = (data ?? []).map((r) => mapRow(r, activeSubscribers));
  const q = search.trim().toLowerCase();

  users = users.filter((u) => {
    if (subscribersOnly && !u.subscriber) return false;
    return matchesSearch(u, q);
  });
  sortUsers(users, sort, sortAsc);

  const totalUsers = users.length;
  const slice = users.slice(page * pageSize, (page + 1) * pageSize);
  const searchCapped =
    (data?.length ?? 0) >= SEARCH_SCAN_CAP &&
    (q.length > 0 || subscribersOnly || sort !== "joined");
  return pagePayload(slice, totalUsers, page, pageSize, searchCapped);
}

async function listSubscribersPage(
  admin: AdminSupabase,
  page: number,
  pageSize: number,
  search: string,
  sort: SortKey,
  sortAsc: boolean,
) {
  const from = page * pageSize;
  const to = from + pageSize - 1;

  const { count, error: countError } = await admin
    .from("subscriptions")
    .select("*", { count: "exact", head: true })
    .in("status", ACTIVE_SUBSCRIPTION_STATUSES);
  if (countError) throw countError;

  const { data: subs, error: subError } = await admin
    .from("subscriptions")
    .select("user_id")
    .in("status", ACTIVE_SUBSCRIPTION_STATUSES)
    .order("user_id")
    .range(from, to);
  if (subError) throw subError;

  const ids = (subs ?? []).map((s) => s.user_id as string);
  if (ids.length === 0) {
    return pagePayload([], count ?? 0, page, pageSize);
  }

  const { data: rows, error } = await admin
    .from("users")
    .select("id, email, name, creation_date, avatar_url")
    .in("id", ids);
  if (error) throw error;

  const activeSubscribers = new Set(ids);
  let users = (rows ?? []).map((r) => mapRow(r, activeSubscribers));
  const q = search.trim().toLowerCase();
  if (q) users = users.filter((u) => matchesSearch(u, q));
  sortUsers(users, sort, sortAsc);

  return pagePayload(users, count ?? 0, page, pageSize);
}

function needsScan(search: string, subscribersOnly: boolean, sort: SortKey): boolean {
  if (search.trim().length > 0) return true;
  if (subscribersOnly) return true;
  return sort === "default" || sort === "status" || sort === "plan";
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return json({ error: "Missing or invalid Authorization header" }, 401);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !anonKey || !serviceRoleKey) {
    console.error("[admin-list-users] Missing SUPABASE_URL / ANON / SERVICE key");
    return json({ error: "Server configuration error" }, 500);
  }

  const token = authHeader.replace("Bearer ", "");
  const supabaseAuth = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });
  const {
    data: { user },
    error: authError,
  } = await supabaseAuth.auth.getUser(token);
  if (authError || !user) {
    return json({ error: "You must be authenticated" }, 401);
  }

  let body: ListUsersBody = {};
  try {
    const raw = await req.json();
    if (raw && typeof raw === "object") body = raw as ListUsersBody;
  } catch {
    body = {};
  }

  try {
    const { data: caller, error: callerError } = await supabaseAuth
      .from("users")
      .select("role")
      .eq("id", user.id)
      .maybeSingle();
    if (callerError || !caller || caller.role !== "admin") {
      return json({ error: "Admin role required" }, 403);
    }

    const admin = createClient(supabaseUrl, serviceRoleKey);

    if (body.overview === true) {
      return json(await buildOverview(admin), 200);
    }

    const page = clampPage(body.page);
    const pageSize = clampPageSize(body.pageSize);
    const search = typeof body.search === "string" ? body.search : "";
    const subscribersOnly = body.subscribersOnly === true;
    const sort = parseSort(body.sort);
    const sortAsc = body.sortAsc === true;

    if (subscribersOnly && !search.trim()) {
      return json(
        await listSubscribersPage(admin, page, pageSize, search, sort, sortAsc),
        200,
      );
    }
    if (needsScan(search, subscribersOnly, sort)) {
      return json(
        await listScannedPage(
          admin, page, pageSize, search, subscribersOnly, sort, sortAsc,
        ),
        200,
      );
    }
    return json(await listIndexedPage(admin, page, pageSize, sort, sortAsc), 200);
  } catch (e) {
    console.error("[admin-list-users] Error:", e);
    return json({ error: "Failed to list users" }, 500);
  }
});
