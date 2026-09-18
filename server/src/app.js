const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const path = require('path');
const env = require('./config/env');
const routes = require('./routes');
const requestLogger = require('./middleware/requestLogger');
const errorHandler = require('./middleware/errorHandler');
const { generalLimiter } = require('./middleware/rateLimiter');
const { NotFoundError } = require('./utils/errors');

const app = express();
app.set('trust proxy', 1);
// Security HTTP headers
app.use(
  helmet({
    crossOriginResourcePolicy: { policy: 'cross-origin' },
  })
);

// CORS configuration
app.use(
  cors({
    origin: env.CORS_ORIGIN === '*' ? true : env.CORS_ORIGIN.split(','),
    methods: ['GET', 'POST', 'PATCH', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Request-Id'],
    credentials: true,
  })
);

// Request parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Observability and latency request logger
app.use(requestLogger);

// Rate limiter
app.use(generalLimiter);

// Serve static uploaded listing images
app.use('/uploads', express.static(env.STORAGE_LOCAL_DIR));

// Base root redirect to health endpoint
app.get('/', (req, res) => {
  res.json({
    service: 'Campus Exchange API',
    version: '1.0.0',
    pilotCollege: env.DEFAULT_COLLEGE_NAME,
    apiDocs: `${env.API_PREFIX}/health`,
    status: 'online',
  });
});

// Mount versioned API routes (/api/v1)
app.use(env.API_PREFIX, routes);

// 404 Not Found Handler for unknown endpoints
app.use((req, res, next) => {
  next(new NotFoundError(`Route ${req.method} ${req.originalUrl} not found on this server.`));
});

// Centralized error handler adhering to PRISM error contract
app.use(errorHandler);

module.exports = app;
