# Campus Exchange - Database Schema & State Transitions

## Database Engine: MongoDB (Mongoose ODM)

All operational collections maintain strict compound index isolation on `(collegeId, ...)` to enforce logical multi-tenancy and optimize queries.

---

## Data Models

### 1. `College` Collection
```typescript
{
  collegeId: String,          // Unique slug, e.g. "avih-gunthapalli"
  name: String,               // "Avanthi Institute of Engineering and Technology"
  code: String,               // "AVIH"
  allowedEmailDomains: [String], // ["avih.edu.in"]
  status: String,             // "active" | "inactive" | "pilot"
  pilotSettings: {
    targetSignups: Number,    // 100
    targetActiveListings: Number // 50
  },
  createdAt: Date,
  updatedAt: Date
}
```
**Indexes:** `collegeId` (unique), `allowedEmailDomains` (index).

---

### 2. `Student` Collection
```typescript
{
  studentId: String,          // Unique ID, e.g. "std_xxx"
  collegeId: String,          // Ref to College
  officialEmail: String,      // Normalized lowercase official email
  fullName: String,
  department: String,
  verificationStatus: String, // "pending" | "verified" | "rejected"
  verificationToken: String,
  verifiedAt: Date,
  accountStatus: String,      // "active" | "suspended" | "flagged"
  createdAt: Date,
  updatedAt: Date
}
```
**Indexes:** `(collegeId, officialEmail)` (unique), `studentId` (unique).

---

### 3. `Listing` Collection
```typescript
{
  listingId: String,          // Unique ID, e.g. "list_xxx"
  collegeId: String,          // Enforced tenant boundary
  sellerId: String,           // Student ID of the owner
  sellerName: String,
  sellerEmail: String,
  title: String,              // Validated length (3-120 chars)
  description: String,
  category: String,           // Enforced enum
  price: Number,              // Min 0, Max 50000
  condition: String,          // Enforced enum ("New / Unused", "Like New", "Good", "Fair")
  photoRefs: [String],        // Array of photo URLs/keys (min 1 for active)
  status: String,             // "draft" | "active" | "sold" | "closed"
  viewCount: Number,
  chatCount: Number,
  closedAt: Date,
  closedReason: String,
  createdAt: Date,
  updatedAt: Date
}
```
**Indexes:**
- `(collegeId, status, createdAt)`
- `(collegeId, category, status)`
- `(collegeId, sellerId, status)`
- `(collegeId, title: "text", description: "text")`

---

### 4. `Conversation` & `Message` Collections
```typescript
// Conversation
{
  conversationId: String,
  listingId: String,
  collegeId: String,
  buyerId: String,
  sellerId: String,
  lastMessage: String,
  lastMessageSenderId: String,
  lastMessageAt: Date,
  createdAt: Date
}

// Message
{
  messageId: String,
  conversationId: String,
  listingId: String,
  collegeId: String,
  senderId: String,
  message: String,
  createdAt: Date
}
```
**Indexes:** `(collegeId, listingId, buyerId)` (unique conversation), `(conversationId, createdAt)`.

---

### 5. `PilotEvent` Collection (Telemetry & Metrics)
```typescript
{
  eventId: String,
  collegeId: String,
  eventType: String,         // "SIGNUP_VERIFIED", "LISTING_CREATED", "CHAT_INITIATED", "LISTING_SOLD", "LISTING_CLOSED"
  idempotencyKey: String,    // Unique dedup key
  studentId: String,
  listingId: String,
  metadata: Object,
  timestamp: Date
}
```
**Indexes:** `idempotencyKey` (unique), `(collegeId, eventType, timestamp)`.

---

## Listing Lifecycle State Machine

```
               ┌─────────────┐
               │    DRAFT    │
               └──────┬──────┘
                      │ (Publish with Valid Photos)
                      ▼
               ┌─────────────┐
        ┌─────▶│   ACTIVE    │◀─────┐
        │      └──────┬──────┘      │
(Admin/ │             │             │ (Moderation Clear)
 Seller │      ┌──────┴──────┐      │
 Reopen)│      ▼             ▼      │
   ┌────┴────────────┐ ┌────────────┴───┐
   │      SOLD       │ │     CLOSED     │
   │ (Sale Event ID) │ │(Delisted/Admin)│
   └─────────────────┘ └────────────────┘
```
**State Rules:**
1. Only `active` listings are browsable and searchable on the student feed.
2. Only the listing owner (or system admin) can transition to `sold` or `closed`.
3. Transitioning to `sold` emits an idempotent `LISTING_SOLD` event.
4. Transitioning to `closed` emits an idempotent `LISTING_CLOSED` event.
