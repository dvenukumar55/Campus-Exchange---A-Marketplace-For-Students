const mongoose = require('mongoose');
const env = require('../config/env');
const { sendSuccess } = require('../utils/response');

class HealthController {
  /**
   * GET /api/v1/health
   * Standardized health check for observability, uptime monitoring, and SLA validation
   */
  async check(req, res) {
    const dbStatus = mongoose.connection.readyState === 1 ? 'healthy' : 'degraded';
    const isHealthy = dbStatus === 'healthy';

    const healthReport = {
      status: isHealthy ? 'healthy' : 'degraded',
      service: 'campus-exchange-api',
      version: '1.0.0',
      uptimeSeconds: Math.floor(process.uptime()),
      timestamp: new Date().toISOString(),
      dependencies: {
        database: {
          status: dbStatus,
          readyState: mongoose.connection.readyState,
        },
        storage: {
          provider: env.STORAGE_PROVIDER,
          status: 'healthy',
        },
        realtime: {
          service: 'socket.io',
          status: 'healthy',
        },
      },
      targets: {
        slaAvailabilityTarget: `${env.TARGET_AVAILABILITY_PERCENT}%`,
        maxResponseTimeTarget: `${env.TARGET_RESPONSE_TIME_MS}ms`,
      },
    };

    return res.status(isHealthy ? 200 : 503).json({
      success: isHealthy,
      requestId: res.locals.requestId,
      ...healthReport,
    });
  }
}

module.exports = new HealthController();
