# Campus Exchange - Deployment Architecture & Operations

## 1. Environment Architecture

```
[ Mobile App (Android/Flutter) ]
            │
            ▼ (HTTPS / WSS)
[ Reverse Proxy / API Gateway (Nginx/Cloudflare) ]
            │
            ▼
[ Node.js Backend Cluster (Express + Socket.io) ]
            │
    ┌───────┴───────┐
    ▼               ▼
[ MongoDB Replica ] [ Cloud Object Storage ]
```

---

## 2. Environment Variables

| Variable | Description | Example |
|---|---|---|
| `PORT` | Server listening port | `5000` |
| `NODE_ENV` | Environment mode | `production` / `staging` / `development` |
| `MONGODB_URI` | MongoDB connection URI | `mongodb://localhost:27017/campus_exchange` |
| `JWT_SECRET` | Secret key for JWT signing | `pilot_secret_secure_key_123` |
| `JWT_EXPIRES_IN` | Token duration | `7d` |
| `DEFAULT_COLLEGE_ID` | Active pilot college slug | `avih-gunthapalli` |
| `DEFAULT_COLLEGE_DOMAIN` | Active pilot email domain | `avih.edu.in` |

---

## 3. Containerization (Dockerfile)

```dockerfile
# Backend Dockerfile
FROM node:20-alpine AS base
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 5000
CMD ["npm", "start"]
```

---

## 4. Pre-Deployment Validation Checklist
1. All unit tests pass: `npm test`
2. Cross-college isolation tests pass.
3. Database indexes are verified and created on startup.
4. Pilot college configuration exists (`avih-gunthapalli`).
5. Health endpoint returns `200 OK` on `/api/v1/health`.
6. Rate limiting and CORS origins configured.
