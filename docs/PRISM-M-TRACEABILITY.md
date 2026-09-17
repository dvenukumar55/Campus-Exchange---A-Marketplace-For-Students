# Campus Exchange - PRISM-M Requirements & Traceability Matrix

| Task ID | Task Description | Target Files / Modules | Acceptance Criteria | Test Evidence / Verification | Status |
|---|---|---|---|---|---|
| **T-001** | Backend Framework Setup | `server/src/app.js`, `server/package.json` | Express.js, MongoDB connection, CORS, rate limiting, request logging | `tests/integration/apiBaseline.test.js` | **COMPLETED** |
| **T-002** | College Isolation Middleware | `server/src/middleware/collegeContext.js` | Enforce multi-tenant query separation strictly by `collegeId` | `tests/integration/collegeIsolation.test.js` | **COMPLETED** |
| **T-003** | College & Student Schemas | `server/src/models/College.js`, `Student.js` | Unique indexes, email domain validation (`avih.edu.in`) | `tests/unit/validation.test.js` | **COMPLETED** |
| **T-004** | Email Verification Service | `server/src/services/authService.js` | Validates official college email, creates verified student | `tests/unit/auth.test.js` | **COMPLETED** |
| **T-005** | JWT Authentication Middleware | `server/src/middleware/auth.js` | Signs/verifies JWT with studentId & collegeId | `tests/unit/auth.test.js` | **COMPLETED** |
| **T-006** | Student Auth API Endpoints | `server/src/controllers/authController.js` | `POST /api/v1/auth/verify`, `GET /api/v1/auth/me` | `tests/integration/apiBaseline.test.js` | **COMPLETED** |
| **T-007** | Listing Schema & Indexes | `server/src/models/Listing.js` | Compound indexes on `(collegeId, status, category)` | `tests/unit/stateTransition.test.js` | **COMPLETED** |
| **T-008** | Listing Validation Rules | `server/src/utils/validation.js` | Validate categories, price (≥0), condition, photo refs | `tests/unit/validation.test.js` | **COMPLETED** |
| **T-009** | Create Listing Endpoint | `server/src/controllers/listingController.js` | `POST /api/v1/listings`, assigns owner & college | `tests/integration/marketplace.test.js` | **COMPLETED** |
| **T-010** | Browse Marketplace Endpoint | `server/src/controllers/listingController.js` | `GET /api/v1/listings` with filters & pagination | `tests/integration/marketplace.test.js` | **COMPLETED** |
| **T-011** | Listing Detail & Update Endpoints | `server/src/controllers/listingController.js` | `GET /:id`, `PATCH /:id`, seller authorization | `tests/integration/marketplace.test.js` | **COMPLETED** |
| **T-012** | Listing Lifecycle State Machine | `server/src/services/listingService.js` | `POST /:id/close` to `sold` / `closed` with idempotency | `tests/unit/stateTransition.test.js` | **COMPLETED** |
| **T-013** | Mobile App Project Setup | `mobile/pubspec.yaml`, `mobile/lib/main.dart` | Flutter client structure with Material 3 & Provider | `mobile/test/widget_test.dart` | **COMPLETED** |
| **T-014** | Mobile Listing Creation Form | `mobile/lib/screens/create_listing_screen.dart` | Validated form with photo attachments & preset | `mobile/lib/screens/create_listing_screen.dart` | **COMPLETED** |
| **T-015** | Mobile Marketplace Feed Screen | `mobile/lib/screens/marketplace_screen.dart` | Category filter bar, search, listing cards | `mobile/lib/screens/marketplace_screen.dart` | **COMPLETED** |
| **T-016** | Mobile Listing Detail View | `mobile/lib/screens/listing_detail_screen.dart` | View photos, seller info, start chat, report | `mobile/lib/screens/listing_detail_screen.dart` | **COMPLETED** |
| **T-017** | Mobile Seller Management Screen | `mobile/lib/screens/my_listings_screen.dart` | Seller listing list, mark sold/close actions | `mobile/lib/screens/my_listings_screen.dart` | **COMPLETED** |
| **T-018** | Conversation & Message Models | `server/src/models/Conversation.js`, `Message.js` | Listing-associated messaging schemas | `tests/integration/chatPersistence.test.js` | **COMPLETED** |
| **T-019** | REST Chat Endpoints | `server/src/controllers/chatController.js` | `GET /listings/:id/chat`, `POST /listings/:id/chat` | `tests/integration/chatPersistence.test.js` | **COMPLETED** |
| **T-020** | Real-Time Socket.io Server | `server/src/sockets/chatSocket.js` | Authenticated websocket rooms scoped to listings | `tests/integration/chatPersistence.test.js` | **COMPLETED** |
| **T-021** | Socket Authentication Middleware | `server/src/sockets/socketAuth.js` | JWT verification for incoming websocket connections | `tests/integration/chatPersistence.test.js` | **COMPLETED** |
| **T-022** | Mobile Socket.io Client Service | `mobile/lib/services/socket_service.dart` | Real-time chat subscriptions and listeners | `mobile/lib/services/socket_service.dart` | **COMPLETED** |
| **T-023** | Mobile Chat Screen & UI | `mobile/lib/screens/chat_screen.dart` | Real-time messaging UI with safety banner | `mobile/lib/screens/chat_screen.dart` | **COMPLETED** |
| **T-024** | Report Schema & Service | `server/src/models/Report.js`, `reportService.js` | Collects misleading listing reports | `tests/integration/reporting.test.js` | **COMPLETED** |
| **T-025** | Report API Endpoints | `server/src/controllers/reportController.js` | `POST /api/v1/reports`, `GET /api/v1/reports` | `tests/integration/reporting.test.js` | **COMPLETED** |
| **T-026** | Mobile Listing Report Flow | `mobile/lib/screens/report_screen.dart` | Report reason selection and details submission | `mobile/lib/screens/report_screen.dart` | **COMPLETED** |
| **T-027** | Event Recording & Telemetry | `server/src/services/eventService.js` | Idempotent recording of signups, listings, chats, sales | `tests/unit/eventDedup.test.js` | **COMPLETED** |
| **T-028** | Conversion Metrics Calculator | `server/src/services/metricsService.js` | Calculates listing-to-chat (≥50%) & listing-to-sale (≥30%) | `tests/unit/metrics.test.js` | **COMPLETED** |
| **T-029** | Pilot Metrics API Endpoint | `server/src/controllers/metricsController.js` | `GET /api/v1/metrics` with PRISM-R target comparisons | `tests/unit/metrics.test.js` | **COMPLETED** |
| **T-030** | Mobile Metrics Dashboard | `mobile/lib/screens/metrics_dashboard_screen.dart` | Visual dashboard for pilot conversion metrics | `mobile/lib/screens/metrics_dashboard_screen.dart` | **COMPLETED** |
| **T-031** | Backend Unit & Integration Tests | `server/tests/` (11 test suites) | Auth, validation, state transition, dedup, isolation | `npm test` (11 suites, 46 tests passing) | **COMPLETED** |
| **T-032** | Mobile Unit & Widget Tests | `mobile/test/` | Model serialization, verification status, smoke tests | `mobile/test/model_test.dart` | **COMPLETED** |
| **T-033** | End-to-End Workflow Verification | `server/tests/integration/marketplace.test.js` | Signup -> Create -> Chat -> Sale lifecycle | Automated integration tests passing | **COMPLETED** |
| **T-034** | College Isolation Benchmark | `server/tests/security/crossCollegeSecurity.test.js` | Cross-college data access blocked (403) | `tests/security/crossCollegeSecurity.test.js` | **COMPLETED** |
| **T-035** | Latency & SLA Benchmarks | `server/tests/performance/latencyBenchmark.test.js` | Response time ≤ 3000ms SLA verified | `tests/performance/latencyBenchmark.test.js` | **COMPLETED** |
| **T-036** | High-Availability Health Check | `server/tests/availability/healthCheck.test.js` | `/api/v1/health` uptime and readiness reporting | `tests/availability/healthCheck.test.js` | **COMPLETED** |
| **T-037** | Seed Data Script | `server/src/scripts/seed.js` | Seeds AVIH pilot college and initial inventory | Seed script operational | **COMPLETED** |
| **T-038** | API Documentation | `docs/API.md` | Complete REST and Socket.io API specification | `docs/API.md` | **COMPLETED** |
| **T-039** | Database Schema Documentation | `docs/DATABASE.md` | Models, relationships, indexes, state machine | `docs/DATABASE.md` | **COMPLETED** |
| **T-040** | Security Architecture Guide | `docs/SECURITY.md` | Multi-tenant isolation, threat matrix, token policy | `docs/SECURITY.md` | **COMPLETED** |
| **T-041** | Deployment Architecture Guide | `docs/DEPLOYMENT.md` | Environment config, containerization, SLA gates | `docs/DEPLOYMENT.md` | **COMPLETED** |
| **T-042** | Rollback & Data Safety Plan | `docs/ROLLBACK.md` | Zero-data-loss rollback procedures and verification | `docs/ROLLBACK.md` | **COMPLETED** |
| **T-043** | Requirement Traceability Matrix | `docs/PRISM-M-TRACEABILITY.md` | Mapping all requirements to tests & implementation | `docs/PRISM-M-TRACEABILITY.md` | **COMPLETED** |
| **T-044** | System Architecture Summary | `README.md` | Root architecture overview and run instructions | `README.md` | **COMPLETED** |
| **T-045** | Android Manifest & App Identity | `mobile/android/`, `metadata.json` | Adaptive icon, metadata, network permissions | Root `metadata.json` & Android config | **COMPLETED** |
| **T-046** | Pilot Review & Release Packaging | `campus-exchange/` | Final verification and release packaging readiness | Complete project tree verified | **COMPLETED** |
