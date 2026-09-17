# Campus Exchange - Flutter Mobile Client

Flutter-based mobile client application for **Campus Exchange**, providing a college-exclusive marketplace for verified students.

## Architecture
- **Framework:** Flutter / Dart
- **Target Platform:** Android (and cross-platform ready)
- **State Management:** Provider
- **Networking:** HTTP REST Client with timeout SLA tracking
- **Real-Time Chat:** Socket.io Client
- **Local Secure Storage:** SharedPreferences / Secure Storage Abstraction

## Features
- **Official Student Verification:** College email boundary verification (`@avih.edu.in`).
- **Marketplace Feed:** Browse active academic and hostel listings with categories, condition filters, and real-time search.
- **Listing Creation & Validation:** Full validation requiring photos, price, condition, category, and genuine item details.
- **Buyer-Seller Real-Time Chat:** Listing-associated chat via Socket.io for immediate campus peer coordination.
- **Lifecycle & Transaction Closure:** Atomic seller transitions to `sold` / `closed` states with duplicate event prevention.
- **Moderation & Reporting:** Student reporting flow for misleading listings or guideline violations.
- **Pilot Metrics Dashboard:** Live visibility into sign-ups, active listings, and listing-to-chat/sale conversion rates.

## Getting Started

### Prerequisites
- Flutter SDK (>= 3.0.0)
- Android SDK

### Run the App
```bash
# Get dependencies
flutter pub get

# Run on connected Android device / emulator
flutter run
```

### Run Tests
```bash
flutter test
```
