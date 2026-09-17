const notificationService = require('../services/notificationService');
const { sendSuccess } = require('../utils/response');

class NotificationController {
  /**
   * GET /api/v1/notifications
   * Retrieves student's notification inbox
   */
  async getNotifications(req, res, next) {
    try {
      const result = await notificationService.getNotifications({
        studentId: req.student.studentId,
        collegeId: req.student.collegeId,
        page: req.query.page,
        limit: req.query.limit,
      });

      return sendSuccess(res, 200, result);
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/v1/notifications/unread-count
   * Retrieves count of unread notifications for badge
   */
  async getUnreadCount(req, res, next) {
    try {
      const result = await notificationService.getUnreadCount({
        studentId: req.student.studentId,
        collegeId: req.student.collegeId,
      });

      return sendSuccess(res, 200, result);
    } catch (error) {
      next(error);
    }
  }

  /**
   * PATCH /api/v1/notifications/:notificationId/read
   * Marks a specific notification as read
   */
  async markAsRead(req, res, next) {
    try {
      const result = await notificationService.markAsRead({
        notificationId: req.params.notificationId,
        studentId: req.student.studentId,
        collegeId: req.student.collegeId,
      });

      return sendSuccess(res, 200, result);
    } catch (error) {
      next(error);
    }
  }

  /**
   * PATCH /api/v1/notifications/read-all
   * Marks all student notifications as read
   */
  async markAllAsRead(req, res, next) {
    try {
      const result = await notificationService.markAllAsRead({
        studentId: req.student.studentId,
        collegeId: req.student.collegeId,
      });

      return sendSuccess(res, 200, result);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new NotificationController();
