const moderationService = require('../services/moderationService');
const { sendSuccess } = require('../utils/response');

class ReportController {
  /**
   * POST /api/v1/reports
   * Creates a misleading-listing or seller behavior report
   */
  async createReport(req, res, next) {
    try {
      const report = await moderationService.createReport({
        listingId: req.validatedReport.listingId,
        reporter: req.student,
        reason: req.validatedReport.reason,
        description: req.validatedReport.description,
      });

      return sendSuccess(res, 201, {
        reportId: report.reportId,
        status: report.status,
        createdAt: report.createdAt,
        report,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/v1/reports
   * Lists reports for moderation review
   */
  async getReports(req, res, next) {
    try {
      const { status, page, limit } = req.query;
      const result = await moderationService.getReports({
        collegeId: req.student.collegeId,
        status,
        page,
        limit,
      });

      return sendSuccess(res, 200, { items: result.items }, result.pagination);
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/v1/reports/:reportId/review
   * Resolves a report and executes moderation action
   */
  async reviewReport(req, res, next) {
    try {
      const { reportId } = req.params;
      const { status, reviewNotes, actionTaken } = req.body;

      const report = await moderationService.reviewReport({
        reportId,
        reviewer: req.student,
        status,
        reviewNotes,
        actionTaken,
      });

      return sendSuccess(res, 200, { report });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new ReportController();
