const metricsService = require('../services/metricsService');
const { sendSuccess } = require('../utils/response');

class MetricsController {
  /**
   * GET /api/v1/metrics
   * Retrieves live pilot performance and conversion metrics
   */
  async getMetrics(req, res, next) {
    try {
      const collegeId = req.student?.collegeId || req.query?.collegeId;
      const metrics = await metricsService.getPilotMetrics(collegeId);
      return sendSuccess(res, 200, { metrics });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new MetricsController();
