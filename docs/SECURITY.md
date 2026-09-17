# Campus Exchange - Security Architecture & Threat Model

## 1. College Isolation Boundary (Mandatory Multi-Tenant Protection)

### Threat Vector
Students from College B attempting to view, message, or purchase items belonging to College A, or listing items across institutional boundaries.

### Enforcement Strategy
- **Layer 1: Database Scoping** — Every query executing in the repository layer automatically injects `{ collegeId: req.student.collegeId }`.
- **Layer 2: JWT Context Pinning** — The `collegeId` is embedded inside the signed JWT payload. The client cannot forge or substitute this value.
- **Layer 3: Cross-College Security Interceptor** — When requesting a specific resource by ID (e.g., `GET /listings/:id`), `collegeContext.js` verifies that the resource's `collegeId` strictly matches `req.student.collegeId`. If mismatch is detected, `403 CROSS_COLLEGE_DENIED` is raised immediately.
- **Layer 4: Socket.io Room Isolation** — Socket connections verify JWT and only allow clients to subscribe to rooms named `listing:${listingId}` after confirming ownership or same-college context.

---

## 2. Authentication & Token Management

- **Algorithm:** HMAC SHA-256 (`HS256`)
- **Token Expiry:** 7 Days (for mobile pilot convenience) with explicit logout invalidation.
- **Email Validation:** Strictly validated against the institution's whitelisted domain (`@avih.edu.in`).
- **Student Verification Gate:** Only students with `verificationStatus === 'verified'` can access `listings`, `chat`, and `create` endpoints.

---

## 3. Threat Mitigation Matrix

| Threat Category | Potential Impact | Implemented Mitigation | Verification Test |
|---|---|---|---|
| **Cross-College Snooping** | Data leakage between schools | Server-side query scoping + College Context interceptor | `tests/integration/collegeIsolation.test.js` |
| **API Denial of Service / Spam** | Service degradation | IP and Student-based rate limiting (100 req/15min) | `tests/security/rateLimit.test.js` |
| **NoSQL Injection / XSS** | Database corruption / script execution | Input sanitization, strict Joi schema validation, Mongo operators stripping | `tests/unit/validation.test.js` |
| **Unauthorized Listing Modification** | Defacement / Price tampering | Owner verification check before mutation | `tests/integration/marketplace.test.js` |
| **Duplicate Event Replay** | Skewed telemetry metrics | Idempotency keys on telemetry and lifecycle events | `tests/unit/eventDedup.test.js` |
| **Token Forgery** | Account takeover | JWT secret signature validation on all protected routes | `tests/unit/auth.test.js` |

---

## 4. Operational Telemetry & Observability
Every inbound HTTP request and error response is tagged with an `X-Request-Id` and monitored for execution latency (target SLA: ≤ 3000ms for user actions).
