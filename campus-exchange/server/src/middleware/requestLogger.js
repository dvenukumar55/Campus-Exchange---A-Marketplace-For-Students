const { v4: uuidv4 } = require('uuid');
const logger = require('../utils/logger');
const env = require('../config/env');

const requestLogger = (req, res, next) => {
  const requestId = req.headers['x-request-id'] || `req_${uuidv4().substring(0, 8)}`;
  req.requestId = requestId;
  res.locals.requestId = requestId;
  res.setHeader('X-Request-Id', requestId);

  const startHrTime = process.hrtime();
  const startTime = Date.now();

  res.on('finish', () => {
    const elapsedHrTime = process.hrtime(startHrTime);
    const latencyMs = Math.round(elapsedHrTime[0] * 1000 + elapsedHrTime[1] / 1e6);

    const logMeta = {
      requestId,
      method: req.method,
      route: req.originalUrl || req.url,
      statusCode: res.statusCode,
      latencyMs,
      collegeId: req.student?.collegeId || 'anonymous',
      studentId: req.student?.studentId || 'anonymous',
    };

    if (latencyMs > env.TARGET_RESPONSE_TIME_MS) {
      logger.warn(`SLA Latency Target Breached (> ${env.TARGET_RESPONSE_TIME_MS}ms)`, logMeta);
    } else if (res.statusCode >= 500) {
      logger.error('API Error Response', logMeta);
    } else if (res.statusCode >= 400) {
      logger.warn('API Client Warning Response', logMeta);
    } else {
      logger.info('API Request Handled', logMeta);
    }
  });

  next();
};

module.exports = requestLogger;
