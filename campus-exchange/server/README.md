# Campus Exchange - Backend Server API & Real-time Services

REST API and real-time Socket.io communication backend for **Campus Exchange**, a college-exclusive marketplace for verified students.

## Architecture
- **Runtime:** Node.js / Express.js
- **Database:** MongoDB / Mongoose
- **Authentication:** Official College Email Verification + JWT (HMAC-SHA256)
- **Real-Time Communication:** Socket.io
- **Security:** Helmet, CORS, Rate Limiting, College-Isolation Middleware

## API Endpoints (v1)

### Authentication
- `POST /api/v1/auth/verify` - Validate official college email and establish verified student session
- `GET /api/v1/auth/me` - Retrieve authenticated student profile and verification status
- `POST /api/v1/auth/logout` - Logout session

### Marketplace Listings
- `GET /api/v1/listings` - Browse active listings for authenticated student's college (supports search, category, condition, pagination)
- `GET /api/v1/listings/my` - Retrieve listings created by current student
- `POST /api/v1/listings` - Create new listing for eligible academic/hostel item
- `POST /api/v1/listings/upload-image` - Upload listing image
- `GET /api/v1/listings/:listingId` - Retrieve listing details
- `PATCH /api/v1/listings/:listingId` - Update permitted listing fields before closure
- `POST /api/v1/listings/:listingId/close` - Atomically mark listing as sold/closed

### Chat & Messaging
- `GET /api/v1/listings/:listingId/chat` - Retrieve listing-associated conversation history
- `POST /api/v1/listings/:listingId/chat` - Send message associated with listing
- `GET /api/v1/chats` - List all user conversations

### Moderation & Reports
- `POST /api/v1/reports` - Submit report against misleading listing or seller behavior
- `GET /api/v1/reports` - Moderation queue
- `POST /api/v1/reports/:reportId/review` - Review and resolve report

### Observability & Metrics
- `GET /api/v1/metrics` - Real-time pilot conversion metrics and target tracking
- `GET /api/v1/health` - SLA availability, uptime, and dependency health checks
- `POST /api/v1/events` - Telemetry event recording with deduplication

## Getting Started

### 1. Install Dependencies
```bash
npm install
```

### 2. Configure Environment
```bash
cp .env.example .env
# Edit .env with your MongoDB connection string and JWT secret
```

### 3. Start Server
```bash
# Development mode
npm run dev

# Production mode
npm start
```

### 4. Run Automated Test Suite
```bash
npm test
```
