# Campus Exchange - Rollback Strategy & Data Safety

## 1. Zero-Data-Loss Principle
In the event of a deployment failure, performance regression, or schema mismatch:
- **No data destruction:** All operational collections (`Students`, `Listings`, `Conversations`, `Messages`, `PilotEvents`) maintain historical records.
- Soft-deletion and immutable audit logs ensure no transactions or reports are permanently lost during rollbacks.

---

## 2. Rollback Procedures

### Scenario A: Backend API Service Rollback
1. **Trigger:** Unhandled crash loop or error rate > 1% on `/api/v1/health`.
2. **Action:**
   - Divert traffic at the reverse proxy to the previous stable release container tag (`v1.0.x`).
   - Flush non-persistent socket connections; mobile clients will automatically reconnect with exponential backoff.
   - Verify health check: `curl http://localhost:5000/api/v1/health`.

### Scenario B: Database Schema Migration Rollback
1. **Pre-Migration Safety:** Automated snapshot taken prior to applying database migrations.
2. **Down-Migration Scripts:**
   - Any new indexes or schema validations must have matching downgrade steps in `migrations/`.
   - Idempotent events table ensures telemetry integrity if events are replayed post-restore.

### Scenario C: Mobile Client Version Fallback
1. Mobile app handles backward-compatible API payload responses gracefully with null safety and fallback default values.
2. If critical mobile build issues arise, maintain API support for `v1.0.0` while publishing hotfix APK.

---

## 3. Verification Post-Rollback
- [ ] Health endpoint returns status `healthy`
- [ ] Student verification endpoint responds ≤ 1000ms
- [ ] Marketplace listing feed displays items correctly for `avih-gunthapalli`
- [ ] Metrics calculation matches expected database counts
