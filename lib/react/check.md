# TruckFix Chat API — Flutter developer guide

This document covers **job-scoped chat** and the **TruckFix Support inbox** for `kp_backend`. Fleet, mechanic, company, and mechanic-employee apps use the same **`/api/v1/chat`** routes with that user’s access token. **Admin** uses separate routes under **`/api/v1/admin`** for support replies.

**REST base URL:** `https://<host>:<port>/api/v1`  
**Chat routes:** `/chat/…` → e.g. `GET /api/v1/chat/threads`

---

## 1. Authentication & responses

### Headers

- `Authorization: Bearer <accessToken>` on every request.
- `Content-Type: application/json` for JSON bodies (omit for `multipart/form-data` uploads).

Tokens come from `POST /api/v1/auth/login` (typically `data.accessToken`). Chat routes use **`protect`** + **`requireActive`**: blocked/suspended users cannot call them.

### Response envelope

```json
{
  "status": "success",
  "message": "…",
  "data": {},
  "meta": {}
}
```

Errors: HTTP status + often `{ "status": "error", "message": "…" }`.

---

## 2. Job chat — who can access a thread?

For `jobId`, the server runs **`ensureChatAccess`**:

| Role | Condition |
|------|-----------|
| `FLEET` | `user._id` is `job.fleet`. |
| `MECHANIC` | `user._id` is `job.assignedMechanic`. |
| `COMPANY` | `user._id` is `job.assignedCompany`. |
| `MECHANIC_EMPLOYEE` | User is **assigned mechanic**, **or** `job.assignedCompany` equals `user.companyMembership.company`. |
| `ADMIN` | Allowed. |

Otherwise **403**. Unknown job **404**.

### 2.1 Counterparty (thread header / “who am I talking to?”)

All job participants share **one** timeline. `counterparty` is a **UI hint** for the primary other party:

| Viewer | `counterparty` |
|--------|----------------|
| **Fleet** | Assigned mechanic, else assigned company. |
| **Company** | Assigned mechanic/employee if set, else fleet. |
| **Mechanic** | Fleet. |
| **Mechanic employee** (company job, same `companyMembership.company`) | Company if they are the assignee; assigned mechanic if company desk user; else fleet. |
| **Mechanic employee** (fleet-only job) | Fleet. |

### 2.2 Push notifications (`CHAT_MESSAGE`) on `POST /chat/jobs/:jobId/messages`

| Sender | Notified users |
|--------|----------------|
| **ADMIN** | Fleet + assigned mechanic + assigned company (unique; whoever exists). |
| **Fleet** | Assigned mechanic + assigned company (if any). |
| **Company** | Assigned mechanic + fleet. |
| **Mechanic employee** (company job, assignee) | Company + fleet. |
| **Mechanic employee** (company desk, not assignee) | Assigned mechanic + fleet. |
| **Mechanic employee** (otherwise) | Fleet. |
| **Mechanic** | Fleet. |

**Socket.IO** still emits `chat:message` to the **job room** and participant **user** rooms (`fleet`, `assignedMechanic`, `assignedCompany`).

---

## 3. REST — inbox

### `GET /api/v1/chat/threads`

**Purpose:** Messages home — job threads plus, on **page 1**, the **TruckFix Support** row (if the role has a support inbox).

**Query**

| Param | Default | Max |
|-------|---------|-----|
| `page` | `1` | — |
| `limit` | `20` | `50` |

**Pagination with support row**

- Roles with support inbox: **FLEET, MECHANIC, MECHANIC_EMPLOYEE, COMPANY** (not `ADMIN`).
- **Page 1:** response is **`[ supportRow, …jobRows ]`** with at most **`limit - 1`** job rows after the support row (so total length ≤ `limit`).
- **Page 2+:** only job rows; **`jobSkip = (page - 1) * limit - 1`** so job pages line up after the first page’s support slot.
- **`meta.total`** counts **job threads + 1** when support is included (even if support has never been messaged).

**`meta`**

| Field | Meaning |
|-------|---------|
| `page`, `limit` | As sent. |
| `total` | Job threads + support row (1) when applicable. |
| `totalPages` | `ceil(total / limit)`. |
| `unreadThreads` | Job threads with unread + 1 if support has unread. |

**Thread object — job (`kind: "JOB"`)**

| Field | Type | Notes |
|-------|------|--------|
| `kind` | `"JOB"` | Discriminator. |
| `job` | `Map` | `_id`, `jobCode`, `title`, `status`, `vehicle`, `location`. |
| `counterparty` | `Map?` | `_id`, `role`, `label`, `profilePhotoUrl`. Threads with **no** counterparty are **dropped**. |
| `unreadCount` | `int` | Others’ messages not read by you. |
| `lastMessage` | `Map?` | Job message shape (see §5); `jobId` set. |
| `updatedAt` | ISO string | For sorting. |

**Subtitle in UI (job rows):** build client-side, e.g. `"${job['jobCode']} · ${job['title']}"`.

**Thread object — support (`kind: "SUPPORT"`, page 1 only)**

| Field | Type | Notes |
|-------|------|--------|
| `kind` | `"SUPPORT"` | Open with **`/chat/support/...`** APIs, not job APIs. |
| `conversationId` | `"support"` | Stable id for navigation. |
| `threadUserId` | `String` | Your user id (owner of the support thread). |
| `job` | `null` | — |
| `subtitle` | `"System & billing"` | Fixed copy. |
| `counterparty` | `Map` | `role: "SUPPORT"`, `label: "TruckFix Support"`, `profilePhotoUrl: null`. |
| `unreadCount`, `lastMessage`, `updatedAt` | | Same semantics as jobs; `lastMessage` uses **support** message shape (§5). |

**Flutter:** `switch (row['kind']) { case 'JOB': openJobChat(row['job']['_id']); case 'SUPPORT': openSupportInbox(); }`

---

## 4. REST — job messages

### `GET /api/v1/chat/jobs/:jobId/messages`

Paginated history. Query: `limit` (default **50**, max **200**), optional **`before`** or **`beforeMessageId`** (message `_id` — load **older** than that message).

**`data`:** `job`, `counterparty`, `items` (newest at **end** of list), `meta` (`limit`, `hasOlder`, `hasNewer`, `nextBefore`, `oldestMessageId`, `newestMessageId`).

### `POST /api/v1/chat/jobs/:jobId/messages`

JSON body: at least one of **`text`** (trimmed, non-empty) or **`attachments`** (non-empty `List<String>` URLs).

**201** → created message (same shape as list items).

### `POST /api/v1/chat/jobs/:jobId/attachments`

`multipart/form-data`, field **`file`**, one image, max **8 MB**. **201** → `{ url, width?, height?, publicId?, format? }` — put `url` in `attachments` on `POST …/messages`.

### `PATCH /api/v1/chat/jobs/:jobId/read`

Marks others’ messages read for the current user. **`data`:** `{ jobId, markedCount }`.

---

## 5. REST — support inbox (real TruckFix Support thread)

Stored as **`SupportInboxMessage`** in MongoDB. One logical thread per **`threadUser`** (the logged-in customer).

### Customer (`/api/v1/chat/…`)

| Method | Path |
|--------|------|
| `GET` | `/chat/support/messages` |
| `POST` | `/chat/support/messages` |
| `POST` | `/chat/support/attachments` |
| `PATCH` | `/chat/support/read` |

Same JSON / multipart rules as job chat (`text` and/or `attachments`; image field **`file`**).

**`GET /chat/support/messages` — `data`**

| Field | Notes |
|-------|--------|
| `kind` | `"SUPPORT"` |
| `conversationId` | `"support"` |
| `threadUserId` | Your user id. |
| `counterparty` | TruckFix Support label. |
| `subtitle` | `"System & billing"` |
| `items` | List of messages (shape below). |
| `meta` | Same cursor pattern as job chat (`before` / `beforeMessageId`, `hasOlder`, `nextBefore`, …). |

**403** if role has no support inbox (e.g. `ADMIN` using customer chat routes for support).

### Admin (`/api/v1/admin/…`, Bearer **admin** token)

| Method | Path |
|--------|------|
| `GET` | `/admin/users/:userId/support-inbox/messages` |
| `POST` | `/admin/users/:userId/support-inbox/messages` |

`:userId` is the **customer’s** user id (`threadUser`). **`GET`** response includes `threadUser: { _id, role, email }` for context.

### Notifications (optional UI)

- Customer sends → **`SUPPORT_INBOX_MESSAGE`** to **each active admin**.
- Admin replies → **`SUPPORT_INBOX_REPLY`** to the **customer**.

---

## 6. Message JSON shape (job + support)

### Job message (`GET …/jobs/…/messages`, `chat:message`)

| Field | Type |
|-------|------|
| `_id` | `String` |
| `jobId` | `String` |
| `sender` | `{ _id, role, label, profilePhotoUrl }` |
| `text` | `String` |
| `attachments` | `List<String>` |
| `createdAt`, `updatedAt` | ISO |
| `isOwn` | `bool` |
| `isRead` | `bool` |

### Support message (support APIs + `support:message`)

Same as above **plus**:

| Field | Type |
|-------|------|
| `kind` | `"SUPPORT"` |
| `conversationId` | `"support"` |
| `threadUserId` | `String` (owner of thread) |
| `jobId` | `null` |

---

## 7. Realtime — Socket.IO

Connect to **`https://<host>:<port>`** (not under `/api/v1`). Default path **`/socket.io/`**.

**Auth:** e.g. `OptionBuilder().setAuth({'token': accessToken})` or `Authorization: Bearer …`.

**On connect:** `session:ready` with `user { _id, role, email }`.

### Job room

| Emit | Payload |
|------|---------|
| `job:subscribe` | `{ "jobId": "<id>" }` — ack `{ ok, room? \| error }` |
| `job:unsubscribe` | `{ "jobId": "<id>" }` |
| `chat:typing` | `{ "jobId", "typing": bool }` |

| Listen | Payload |
|--------|---------|
| `chat:message` | `{ jobId, message }` |
| `chat:read` | `{ jobId, readerId, markedCount }` |

Also on job subscription: **`job:statusChanged`**, **`job:location`**, **`job:event`** (optional for your UI).

### Support inbox

No subscribe call required: server targets **`user:<yourId>`** and **`role:ADMIN`**.

| Listen | Payload |
|--------|---------|
| `support:message` | `{ threadUserId, message }` — `message` matches §6 support shape |
| `support:read` | `{ threadUserId, readerId, markedCount }` |

**Recommended:** one socket per session; on job screen → `job:subscribe`; always listen for **`support:message`** / **`support:read`** if you show the support thread.

---

## 8. Dart notes (sketch)

- **Inbox row:** `final kind = row['kind'] as String? ?? 'JOB';`
- **Message `jobId`:** nullable for support — use `String? jobId = j['jobId'] as String?;`
- **Typo fix:** use `label` only (no stray characters in field names).

```dart
// Example: normalize one list item from GET .../threads
String? subtitleForRow(Map<String, dynamic> row) {
  if (row['kind'] == 'SUPPORT') return row['subtitle'] as String?;
  final job = row['job'] as Map<String, dynamic>?;
  if (job == null) return null;
  final code = job['jobCode'] as String? ?? '';
  final title = job['title'] as String? ?? '';
  return '$code · $title'.trim();
}
```

---

## 9. Integration checklist

| # | Task |
|---|------|
| 1 | Store `accessToken` after login. |
| 2 | HTTP client base `.../api/v1` + `Authorization` interceptor. |
| 3 | Inbox: `GET /chat/threads` — handle **`kind`** (`JOB` vs `SUPPORT`). |
| 4 | Job thread: `GET /chat/jobs/$jobId/messages` + `before` pagination. |
| 5 | Support thread: `GET /chat/support/messages` + same pagination. |
| 6 | Send: `POST` job or support `…/messages`; images via respective `…/attachments`. |
| 7 | Read: `PATCH` job or support `…/read` when opening/leaving. |
| 8 | Socket: connect + `job:subscribe` for job; listen **`chat:*`** and **`support:*`**. |

---

## 10. Endpoint summary

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/api/v1/chat/threads` | Inbox (jobs + support row on page 1) |
| `GET` | `/api/v1/chat/jobs/:jobId/messages` | Job messages |
| `POST` | `/api/v1/chat/jobs/:jobId/messages` | Send job message |
| `POST` | `/api/v1/chat/jobs/:jobId/attachments` | Job chat image |
| `PATCH` | `/api/v1/chat/jobs/:jobId/read` | Mark job messages read |
| `GET` | `/api/v1/chat/support/messages` | Support messages |
| `POST` | `/api/v1/chat/support/messages` | Send support message |
| `POST` | `/api/v1/chat/support/attachments` | Support image |
| `PATCH` | `/api/v1/chat/support/read` | Mark support read |
| `GET` | `/api/v1/admin/users/:userId/support-inbox/messages` | Admin: load user’s support thread |
| `POST` | `/api/v1/admin/users/:userId/support-inbox/messages` | Admin: reply |

---

*Sources: `chat.router.js`, `chat.service.js`, `supportInbox.model.js`, `supportInbox.service.js`, `realtime/socket.js`, `admin.router.js`.*
