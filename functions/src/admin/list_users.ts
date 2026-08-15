import * as admin from "firebase-admin";
import {HttpsError} from "firebase-functions/v2/https";
import {Logger} from "../core/logger/logger";

// Max users scanned in memory for search / non-indexed sorts (cost guard).
const SEARCH_SCAN_CAP = 500;

// Max page size the client may request.
const MAX_PAGE_SIZE = 50;

const ACTIVE_SUBSCRIPTION_STATUSES = ["ACTIVE", "LIFETIME"];

export interface AdminUser {
  id: string;
  email: string | null;
  name: string | null;
  createdAt: number | null;
  avatarPath: string | null;
  subscriber: boolean;
  role: string | null;
  blocked: boolean;
}

export interface ListUsersRequest {
  page?: number;
  pageSize?: number;
  search?: string;
  subscribersOnly?: boolean;
  sort?: string;
  sortAsc?: boolean;
  overview?: boolean;
}

type SortKey = "default" | "user" | "status" | "plan" | "joined";

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
      case "default":
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

async function loadSubscriberIds(db: admin.firestore.Firestore): Promise<Set<string>> {
  const active = new Set<string>();
  const snap = await db.collection("subscriptions")
    .where("status", "in", ACTIVE_SUBSCRIPTION_STATUSES)
    .get();
  for (const doc of snap.docs) active.add(doc.id);
  return active;
}

function mapUserSnap(
  doc: admin.firestore.DocumentSnapshot,
  activeSubscribers: Set<string>,
): AdminUser {
  const createdAt = doc.get("creation_date");
  return {
    id: doc.id,
    email: (doc.get("email") as string) || null,
    name: (doc.get("name") as string) || null,
    createdAt: createdAt ? createdAt.toMillis() : null,
    avatarPath: (doc.get("avatarPath") as string) || null,
    subscriber: activeSubscribers.has(doc.id),
    role: (doc.get("role") as string) || null,
    blocked: doc.get("blocked") === true,
  };
}

function mapUserDoc(
  doc: admin.firestore.QueryDocumentSnapshot,
  activeSubscribers: Set<string>,
): AdminUser {
  return mapUserSnap(doc, activeSubscribers);
}

async function enrichPage(
  db: admin.firestore.Firestore,
  docs: admin.firestore.QueryDocumentSnapshot[],
): Promise<AdminUser[]> {
  if (docs.length === 0) return [];
  const activeSubscribers = await loadSubscriberIdsForIds(
    db,
    docs.map((d) => d.id),
  );
  return docs.map((d) => mapUserDoc(d, activeSubscribers));
}

async function loadSubscriberIdsForIds(
  db: admin.firestore.Firestore,
  ids: string[],
): Promise<Set<string>> {
  const active = new Set<string>();
  for (let i = 0; i < ids.length; i += 200) {
    const chunk = ids.slice(i, i + 200);
    const refs = chunk.map((id) => db.collection("subscriptions").doc(id));
    const snaps = await db.getAll(...refs);
    for (const s of snaps) {
      if (
        s.exists &&
        ACTIVE_SUBSCRIPTION_STATUSES.includes(s.get("status"))
      ) {
        active.add(s.id);
      }
    }
  }
  return active;
}

function pagePayload(
  users: AdminUser[],
  totalUsers: number,
  page: number,
  pageSize: number,
  searchCapped = false,
) {
  const pageCount = totalUsers === 0 ? 1 : Math.ceil(totalUsers / pageSize);
  return {
    users,
    totalUsers,
    page,
    pageSize,
    pageCount,
    searchCapped,
  };
}

async function buildOverview(db: admin.firestore.Firestore) {
  const usersRef = db.collection("users");
  const now = new Date();
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const start = new Date(today);
  start.setDate(start.getDate() - 13);
  const sevenAgo = new Date(today);
  sevenAgo.setDate(sevenAgo.getDate() - 6);

  const [countSnap, subCountSnap, recentSnap] = await Promise.all([
    usersRef.count().get(),
    db.collection("subscriptions")
      .where("status", "in", ACTIVE_SUBSCRIPTION_STATUSES)
      .count()
      .get(),
    usersRef
      .where("creation_date", ">=", admin.firestore.Timestamp.fromDate(start))
      .get(),
  ]);

  const daily = Array<number>(14).fill(0);
  let new7d = 0;
  for (const doc of recentSnap.docs) {
    const createdAt = doc.get("creation_date");
    if (!createdAt) continue;
    const d = createdAt.toDate();
    const day = new Date(d.getFullYear(), d.getMonth(), d.getDate());
    const idx = Math.floor(
      (day.getTime() - start.getTime()) / (24 * 60 * 60 * 1000),
    );
    if (idx >= 0 && idx < 14) daily[idx]++;
    if (day.getTime() >= sevenAgo.getTime()) new7d++;
  }

  return {
    totalUsers: countSnap.data().count,
    subscribers: subCountSnap.data().count,
    new7d,
    daily,
    firstDayMs: start.getTime(),
    lastDayMs: today.getTime(),
  };
}

async function listUsersIndexedPage(
  db: admin.firestore.Firestore,
  page: number,
  pageSize: number,
  sort: SortKey,
  sortAsc: boolean,
) {
  const usersRef = db.collection("users");
  const countSnap = await usersRef.count().get();
  const totalUsers = countSnap.data().count;

  let query: admin.firestore.Query = usersRef;
  if (sort === "user") {
    query = usersRef.orderBy("name", sortAsc ? "asc" : "desc");
  } else {
    query = usersRef.orderBy("creation_date", sortAsc ? "asc" : "desc");
  }

  const snap = await query.offset(page * pageSize).limit(pageSize).get();
  const users = await enrichPage(db, snap.docs);
  return pagePayload(users, totalUsers, page, pageSize);
}

async function listUsersScannedPage(
  db: admin.firestore.Firestore,
  page: number,
  pageSize: number,
  search: string,
  subscribersOnly: boolean,
  sort: SortKey,
  sortAsc: boolean,
) {
  const usersRef = db.collection("users");
  const snap = await usersRef.limit(SEARCH_SCAN_CAP).get();
  const activeSubscribers = await loadSubscriberIds(db);
  let users = snap.docs.map((d) => mapUserDoc(d, activeSubscribers));
  const q = search.trim().toLowerCase();

  users = users.filter((u) => {
    if (subscribersOnly && !u.subscriber) return false;
    return matchesSearch(u, q);
  });
  sortUsers(users, sort, sortAsc);

  const totalUsers = users.length;
  const slice = users.slice(page * pageSize, (page + 1) * pageSize);
  const searchCapped =
    snap.size >= SEARCH_SCAN_CAP &&
    (q.length > 0 || subscribersOnly || sort !== "joined");
  return pagePayload(slice, totalUsers, page, pageSize, searchCapped);
}

async function listUsersSubscribersPage(
  db: admin.firestore.Firestore,
  page: number,
  pageSize: number,
  search: string,
  sort: SortKey,
  sortAsc: boolean,
) {
  // Query subscriptions without orderBy+offset — `in` + orderBy needs a composite
  // index and was throwing internal errors in production. Subscriber sets are
  // typically small enough to sort/paginate in memory after loading user rows.
  const subsSnap = await db.collection("subscriptions")
    .where("status", "in", ACTIVE_SUBSCRIPTION_STATUSES)
    .get();

  const totalUsers = subsSnap.size;
  if (totalUsers === 0) {
    return pagePayload([], 0, page, pageSize);
  }

  const allIds = subsSnap.docs.map((d) => d.id);
  const activeSubscribers = new Set(allIds);

  let users: AdminUser[] = [];
  for (let i = 0; i < allIds.length; i += 100) {
    const chunk = allIds.slice(i, i + 100);
    const snaps = await db.getAll(
      ...chunk.map((id) => db.collection("users").doc(id)),
    );
    users.push(
      ...snaps
        .filter((s) => s.exists)
        .map((s) => mapUserSnap(s, activeSubscribers)),
    );
  }

  const q = search.trim().toLowerCase();
  if (q) users = users.filter((u) => matchesSearch(u, q));
  sortUsers(users, sort, sortAsc);

  const filteredTotal = users.length;
  const slice = users.slice(page * pageSize, (page + 1) * pageSize);
  return pagePayload(slice, filteredTotal, page, pageSize);
}

function needsScan(search: string, subscribersOnly: boolean, sort: SortKey): boolean {
  if (search.trim().length > 0) return true;
  if (subscribersOnly) return true;
  return sort === "default" || sort === "status" || sort === "plan";
}

function canUseIndexedPagination(
  search: string,
  subscribersOnly: boolean,
  sort: SortKey,
): boolean {
  if (search.trim().length > 0) return false;
  if (subscribersOnly) return false;
  return sort === "joined" || sort === "user";
}

/**
 * Lists app users for the admin console (paginated) or returns Overview stats.
 */
export async function handleListUsers(
  db: admin.firestore.Firestore,
  data: ListUsersRequest | undefined,
  logger: Logger,
): Promise<Record<string, unknown>> {
  if (data?.overview === true) {
    return buildOverview(db);
  }

  const page = clampPage(data?.page);
  const pageSize = clampPageSize(data?.pageSize);
  const search = typeof data?.search === "string" ? data.search : "";
  const subscribersOnly = data?.subscribersOnly === true;
  const sort = parseSort(data?.sort);
  const sortAsc = data?.sortAsc === true;

  try {
    if (subscribersOnly && !search.trim()) {
      return await listUsersSubscribersPage(
        db, page, pageSize, search, sort, sortAsc,
      );
    }
    if (needsScan(search, subscribersOnly, sort)) {
      return await listUsersScannedPage(
        db, page, pageSize, search, subscribersOnly, sort, sortAsc,
      );
    }
    if (canUseIndexedPagination(search, subscribersOnly, sort)) {
      return await listUsersIndexedPage(db, page, pageSize, sort, sortAsc);
    }
    return await listUsersScannedPage(
      db, page, pageSize, search, subscribersOnly, sort, sortAsc,
    );
  } catch (e) {
    logger.error(`listUsers page error: ${e}`);
    throw new HttpsError("internal", "Failed to list users");
  }
}
