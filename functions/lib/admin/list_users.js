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
exports.handleListUsers = handleListUsers;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
// Max users scanned in memory for search / non-indexed sorts (cost guard).
const SEARCH_SCAN_CAP = 500;
// Max page size the client may request.
const MAX_PAGE_SIZE = 50;
const ACTIVE_SUBSCRIPTION_STATUSES = ["ACTIVE", "LIFETIME"];
function clampPageSize(n) {
    const v = typeof n === "number" ? n : Number(n);
    if (!Number.isFinite(v))
        return 10;
    return Math.min(MAX_PAGE_SIZE, Math.max(1, Math.floor(v)));
}
function clampPage(n) {
    const v = typeof n === "number" ? n : Number(n);
    if (!Number.isFinite(v))
        return 0;
    return Math.max(0, Math.floor(v));
}
function parseSort(raw) {
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
function rankActive(u) {
    return u.email && u.email.length > 0 ? 0 : 1;
}
function rankSub(u) {
    return u.subscriber ? 0 : 1;
}
function displayKey(u) {
    var _a;
    const base = u.name && u.name.length > 0 ? u.name : ((_a = u.email) !== null && _a !== void 0 ? _a : "~");
    return base.toLowerCase();
}
function sortUsers(users, sort, asc) {
    const dir = asc ? 1 : -1;
    users.sort((a, b) => {
        var _a, _b, _c, _d, _e, _f;
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
                r = ((_a = a.createdAt) !== null && _a !== void 0 ? _a : 0) - ((_b = b.createdAt) !== null && _b !== void 0 ? _b : 0);
                break;
            case "default":
            default: {
                const byActive = rankActive(a) - rankActive(b);
                if (byActive !== 0)
                    r = byActive;
                else {
                    const bySub = rankSub(a) - rankSub(b);
                    if (bySub !== 0)
                        r = bySub;
                    else
                        r = ((_c = a.createdAt) !== null && _c !== void 0 ? _c : 0) - ((_d = b.createdAt) !== null && _d !== void 0 ? _d : 0);
                }
                break;
            }
        }
        if (r === 0)
            r = ((_e = b.createdAt) !== null && _e !== void 0 ? _e : 0) - ((_f = a.createdAt) !== null && _f !== void 0 ? _f : 0);
        return r * dir;
    });
}
function matchesSearch(u, q) {
    var _a, _b;
    if (!q)
        return true;
    const email = ((_a = u.email) !== null && _a !== void 0 ? _a : "").toLowerCase();
    const name = ((_b = u.name) !== null && _b !== void 0 ? _b : "").toLowerCase();
    return email.includes(q) || name.includes(q);
}
async function loadSubscriberIds(db) {
    const active = new Set();
    const snap = await db.collection("subscriptions")
        .where("status", "in", ACTIVE_SUBSCRIPTION_STATUSES)
        .get();
    for (const doc of snap.docs)
        active.add(doc.id);
    return active;
}
function mapUserSnap(doc, activeSubscribers) {
    const createdAt = doc.get("creation_date");
    return {
        id: doc.id,
        email: doc.get("email") || null,
        name: doc.get("name") || null,
        createdAt: createdAt ? createdAt.toMillis() : null,
        avatarPath: doc.get("avatarPath") || null,
        subscriber: activeSubscribers.has(doc.id),
        role: doc.get("role") || null,
        blocked: doc.get("blocked") === true,
    };
}
function mapUserDoc(doc, activeSubscribers) {
    return mapUserSnap(doc, activeSubscribers);
}
async function enrichPage(db, docs) {
    if (docs.length === 0)
        return [];
    const activeSubscribers = await loadSubscriberIdsForIds(db, docs.map((d) => d.id));
    return docs.map((d) => mapUserDoc(d, activeSubscribers));
}
async function loadSubscriberIdsForIds(db, ids) {
    const active = new Set();
    for (let i = 0; i < ids.length; i += 200) {
        const chunk = ids.slice(i, i + 200);
        const refs = chunk.map((id) => db.collection("subscriptions").doc(id));
        const snaps = await db.getAll(...refs);
        for (const s of snaps) {
            if (s.exists &&
                ACTIVE_SUBSCRIPTION_STATUSES.includes(s.get("status"))) {
                active.add(s.id);
            }
        }
    }
    return active;
}
function pagePayload(users, totalUsers, page, pageSize, searchCapped = false) {
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
async function buildOverview(db) {
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
    const daily = Array(14).fill(0);
    let new7d = 0;
    for (const doc of recentSnap.docs) {
        const createdAt = doc.get("creation_date");
        if (!createdAt)
            continue;
        const d = createdAt.toDate();
        const day = new Date(d.getFullYear(), d.getMonth(), d.getDate());
        const idx = Math.floor((day.getTime() - start.getTime()) / (24 * 60 * 60 * 1000));
        if (idx >= 0 && idx < 14)
            daily[idx]++;
        if (day.getTime() >= sevenAgo.getTime())
            new7d++;
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
async function listUsersIndexedPage(db, page, pageSize, sort, sortAsc) {
    const usersRef = db.collection("users");
    const countSnap = await usersRef.count().get();
    const totalUsers = countSnap.data().count;
    let query = usersRef;
    if (sort === "user") {
        query = usersRef.orderBy("name", sortAsc ? "asc" : "desc");
    }
    else {
        query = usersRef.orderBy("creation_date", sortAsc ? "asc" : "desc");
    }
    const snap = await query.offset(page * pageSize).limit(pageSize).get();
    const users = await enrichPage(db, snap.docs);
    return pagePayload(users, totalUsers, page, pageSize);
}
async function listUsersScannedPage(db, page, pageSize, search, subscribersOnly, sort, sortAsc) {
    const usersRef = db.collection("users");
    const snap = await usersRef.limit(SEARCH_SCAN_CAP).get();
    const activeSubscribers = await loadSubscriberIds(db);
    let users = snap.docs.map((d) => mapUserDoc(d, activeSubscribers));
    const q = search.trim().toLowerCase();
    users = users.filter((u) => {
        if (subscribersOnly && !u.subscriber)
            return false;
        return matchesSearch(u, q);
    });
    sortUsers(users, sort, sortAsc);
    const totalUsers = users.length;
    const slice = users.slice(page * pageSize, (page + 1) * pageSize);
    const searchCapped = snap.size >= SEARCH_SCAN_CAP &&
        (q.length > 0 || subscribersOnly || sort !== "joined");
    return pagePayload(slice, totalUsers, page, pageSize, searchCapped);
}
async function listUsersSubscribersPage(db, page, pageSize, search, sort, sortAsc) {
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
    let users = [];
    for (let i = 0; i < allIds.length; i += 100) {
        const chunk = allIds.slice(i, i + 100);
        const snaps = await db.getAll(...chunk.map((id) => db.collection("users").doc(id)));
        users.push(...snaps
            .filter((s) => s.exists)
            .map((s) => mapUserSnap(s, activeSubscribers)));
    }
    const q = search.trim().toLowerCase();
    if (q)
        users = users.filter((u) => matchesSearch(u, q));
    sortUsers(users, sort, sortAsc);
    const filteredTotal = users.length;
    const slice = users.slice(page * pageSize, (page + 1) * pageSize);
    return pagePayload(slice, filteredTotal, page, pageSize);
}
function needsScan(search, subscribersOnly, sort) {
    if (search.trim().length > 0)
        return true;
    if (subscribersOnly)
        return true;
    return sort === "default" || sort === "status" || sort === "plan";
}
function canUseIndexedPagination(search, subscribersOnly, sort) {
    if (search.trim().length > 0)
        return false;
    if (subscribersOnly)
        return false;
    return sort === "joined" || sort === "user";
}
/**
 * Lists app users for the admin console (paginated) or returns Overview stats.
 */
async function handleListUsers(db, data, logger) {
    if ((data === null || data === void 0 ? void 0 : data.overview) === true) {
        return buildOverview(db);
    }
    const page = clampPage(data === null || data === void 0 ? void 0 : data.page);
    const pageSize = clampPageSize(data === null || data === void 0 ? void 0 : data.pageSize);
    const search = typeof (data === null || data === void 0 ? void 0 : data.search) === "string" ? data.search : "";
    const subscribersOnly = (data === null || data === void 0 ? void 0 : data.subscribersOnly) === true;
    const sort = parseSort(data === null || data === void 0 ? void 0 : data.sort);
    const sortAsc = (data === null || data === void 0 ? void 0 : data.sortAsc) === true;
    try {
        if (subscribersOnly && !search.trim()) {
            return await listUsersSubscribersPage(db, page, pageSize, search, sort, sortAsc);
        }
        if (needsScan(search, subscribersOnly, sort)) {
            return await listUsersScannedPage(db, page, pageSize, search, subscribersOnly, sort, sortAsc);
        }
        if (canUseIndexedPagination(search, subscribersOnly, sort)) {
            return await listUsersIndexedPage(db, page, pageSize, sort, sortAsc);
        }
        return await listUsersScannedPage(db, page, pageSize, search, subscribersOnly, sort, sortAsc);
    }
    catch (e) {
        logger.error(`listUsers page error: ${e}`);
        throw new https_1.HttpsError("internal", "Failed to list users");
    }
}
//# sourceMappingURL=list_users.js.map