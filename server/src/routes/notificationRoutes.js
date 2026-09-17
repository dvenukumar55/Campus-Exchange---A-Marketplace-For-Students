const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');
const { authenticate } = require('../middleware/auth');
const { generalLimiter } = require('../middleware/rateLimiter');

// All notification routes are protected by authenticated session
router.use(authenticate);

// GET /api/v1/notifications - List user's notifications
router.get('/', generalLimiter, notificationController.getNotifications);

// GET /api/v1/notifications/unread-count - Get total unread count for badge
router.get('/unread-count', generalLimiter, notificationController.getUnreadCount);

// PATCH /api/v1/notifications/read-all - Mark all as read
router.patch('/read-all', generalLimiter, notificationController.markAllAsRead);

// PATCH /api/v1/notifications/:notificationId/read - Mark single notification as read
router.patch('/:notificationId/read', generalLimiter, notificationController.markAsRead);

module.exports = router;
