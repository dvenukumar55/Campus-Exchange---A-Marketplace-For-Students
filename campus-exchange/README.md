# Campus Exchange — Closed College-Exclusive Marketplace

> **Pilot Phase:** Avanthi Institute of Engineering and Technology (AVIH, Gunthapalli)  
> **Pilot Domain:** `@avih.edu.in`  
> **Isolation Policy:** Strict Single-College Multi-Tenant Enforcement  

Campus Exchange is a dedicated, secure on-campus peer-to-peer marketplace where verified students can buy and sell eligible academic items (books, instruments, drawing kits, calculators, uniforms) and hostel essentials within their immediate college community.

---

## 🏗️ System Architecture

```
                                  ┌───────────────────────────────────┐
                                  │   Flutter Mobile Client (Android) │
                                  │   - Material 3 Design             │
                                  │   - Provider State Management     │
                                  │   - Socket.io Real-time Chat      │
                                  └─────────────────┬─────────────────┘
                                                    │ (REST / WSS)
                                                    ▼
                                  ┌───────────────────────────────────┐
                                  │   Node.js / Express API Cluster   │
                                  │   - Multi-Tenant College Isolation│
                                  │   - JWT Auth & Token Verification │
                                  │   - Real-time Socket.io Chat      │
                                  │   - Request Latency & SLA Monitor │
                                  └─────────────────┬─────────────────┘
                                                    │
                                                    ▼
                                  ┌───────────────────────────────────┐
                                  │   MongoDB Database                │
                                  │   - Colleges & Students           │
                                  │   - Active / Sold Listings        │
                                  │   - Conversations & Messages      │
                                  │   - Idempotent Pilot Telemetry    │
                                  └───────────────────────────────────┘
```

---

## 📁 Repository Structure

- `server/`: Complete Node.js / Express / MongoDB backend application.
  - `src/controllers/`: Auth, Listings, Chat, Reports, and Metrics controllers.
  - `src/middleware/`: College isolation boundary, JWT verification, rate limiting, and PRISM-S error handling.
  - `src/models/`: Mongoose schemas for `College`, `Student`, `Listing`, `Conversation`, `Message`, `Report`, and `PilotEvent`.
  - `src/services/`: Business logic, state machines, and event deduplication.
  - `src/sockets/`: Socket.io real-time chat with JWT room authentication.
  - `tests/`: 11 test suites covering unit, integration, security, performance, and availability checks.
- `mobile/`: Complete Flutter mobile application.
  - `lib/core/`: Network client, secure storage, theme, and constants.
  - `lib/models/`: Typed Dart data models.
  - `lib/services/`: HTTP and WebSocket service layer.
  - `lib/providers/`: State management providers for Auth, Listings, Chat, and Metrics.
  - `lib/screens/`: Splash, Verification, Marketplace Feed, Listing Detail, Create Listing, Edit Listing, Chat, Reports, and Metrics Dashboard.
  - `lib/widgets/`: Reusable Material 3 cards, badges, and input components.
- `docs/`: Comprehensive technical specifications:
  - `API.md`: Detailed REST & WebSocket API specification.
  - `DATABASE.md`: Schema models, indexes, and listing state machines.
  - `SECURITY.md`: College isolation boundary and threat mitigation matrix.
  - `DEPLOYMENT.md`: Containerization and environment operations.
  - `ROLLBACK.md`: Zero-data-loss rollback and data safety procedures.
  - `PRISM-M-TRACEABILITY.md`: Requirements traceability matrix covering all tasks.

---

## 🚀 Running the Project

### 1. Start the Backend Server
```bash
cd server
npm install
npm run seed     # Seeds AVIH pilot college & sample academic items
npm start        # Starts server on port 5000
```

### 2. Run Backend Test Suite
```bash
cd server
npm test
```

### 3. Run the Mobile App
```bash
cd mobile
flutter pub get
flutter run
```

---

## 🎯 Pilot Acceptance & NFR Metrics

- **Verified Student Sign-ups:** Target ≥ 100 verified students.
- **Active Listings:** Target ≥ 50 active listings per semester.
- **Listing-to-Chat Conversion Rate:** Target ≥ 50%.
- **Listing-to-Sale Conversion Rate:** Target ≥ 30%.
- **Response Time SLA:** ≤ 3000ms for all normal user actions.
- **Availability SLA:** 99.0% tracked via `/api/v1/health`.
