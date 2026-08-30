const { v4: uuidv4 } = require('uuid');
const Notification = require('../models/Notification');
const Student = require('../models/Student');
const { VERIFICATION_STATUS, ACCOUNT_STATUS } = require('../config/constants');
const logger = require('../utils/logger');

class NotificationService {
  constructor() {
    this._io = null;
  }

  setIo(io) {
    this._io = io;
  }

  /**
   * Broadcasts and persists new listing notifications to all other verified active students in the same college.
   */
  async notifyNewListing({ listing, sellerStudent }) {
    try {
      if (!listing || !sellerStudent) return { count: 0 };

      const collegeId = listing.collegeId;
      const sellerId = sellerStudent.studentId;
      const sellerName = sellerStudent.fullName || 'Student';

      // Find all active, verified students in the same college excluding the seller
      const recipients = await Student.find(
        {
          collegeId,
          studentId: { $ne: sellerId },
          verificationStatus: VERIFICATION_STATUS.VERIFIED,
          accountStatus: ACCOUNT_STATUS.ACTIVE,
        },
        'studentId officialEmail fullName'
      ).lean();

      if (!recipients || recipients.length === 0) {
        return { count: 0 };
      }

      const title = 'New listing posted';
      const message = `${sellerName} posted ${listing.title} for ₹${listing.price}`;

      const notificationsToInsert = recipients.map((recipient) => ({
        notificationId: `notif_${uuidv4().replace(/-/g, '').substring(0, 12)}`,
        recipientStudentId: recipient.studentId,
        collegeId,
        listingId: listing.listingId,
        senderStudentId: sellerId,
        senderName: sellerName,
        listingTitle: listing.title || '',
        title,
        message,
        type: 'NEW_LISTING',
        isRead: false,
        readAt: null,
      }));


      // Persist in MongoDB
      try {
        await Notification.insertMany(notificationsToInsert, { ordered: false });
      } catch (insertErr) {
        logger.warn('Some notifications were duplicates and skipped', {
          error: insertErr.message,
          listingId: listing.listingId,
        });
      }

      // Real-time delivery via Socket.io if connected
      if (this._io) {
        notificationsToInsert.forEach((notif) => {
          this._io.to(`student_${notif.recipientStudentId}`).emit('new_notification', notif);
        });
        this._io.to(`college_${collegeId}`).emit('college_new_listing', {
          listingId: listing.listingId,
          title,
          message,
          sellerId,
        });
      }

      logger.info('Dispatched new listing notifications to peer students', {
        collegeId,
        listingId: listing.listingId,
        recipientCount: recipients.length,
      });

      return { count: recipients.length };
    } catch (error) {
      logger.error('Failed to dispatch new listing notifications', {
        error: error.message,
        listingId: listing?.listingId,
      });
      return { count: 0, error: error.message };
    }
  }

  /**
   * Retrieves paginated notifications for the authenticated student.
   */
  async getNotifications({ studentId, collegeId, page = 1, limit = 50 }) {
    const pageNum = Math.max(1, parseInt(page, 10));
    const limitNum = Math.min(100, Math.max(1, parseInt(limit, 10)));
    const skip = (pageNum - 1) * limitNum;

    const query = {
      recipientStudentId: studentId,
      collegeId,
    };

    const [notifications, total, unreadCount] = await Promise.all([
      Notification.find(query)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limitNum)
        .lean(),
      Notification.countDocuments(query),
      Notification.countDocuments({ ...query, isRead: false }),
    ]);

    return {
      notifications,
      unreadCount,
      pagination: {
        page: pageNum,
        limit: limitNum,
        total,
        totalPages: Math.ceil(total / limitNum) || 1,
      },
    };
  }

  /**
   * Retrieves current unread notifications count for badge.
   */
  async getUnreadCount({ studentId, collegeId }) {
    const count = await Notification.countDocuments({
      recipientStudentId: studentId,
      collegeId,
      isRead: false,
    });

    return { unreadCount: count };
  }

  /**
   * Marks a specific notification as read.
   */
  async markAsRead({ notificationId, studentId, collegeId }) {
    const notification = await Notification.findOneAndUpdate(
      {
        notificationId,
        recipientStudentId: studentId,
        collegeId,
      },
      {
        $set: {
          isRead: true,
          readAt: new Date(),
        },
      },
      { new: true }
    );

    const unreadCount = await Notification.countDocuments({
      recipientStudentId: studentId,
      collegeId,
      isRead: false,
    });

    return {
      notification,
      unreadCount,
    };
  }

  /**
   * Marks all unread notifications for a student as read.
   */
  async markAllAsRead({ studentId, collegeId }) {
    await Notification.updateMany(
      {
        recipientStudentId: studentId,
        collegeId,
        isRead: false,
      },
      {
        $set: {
          isRead: true,
          readAt: new Date(),
        },
      }
    );

    return {
      success: true,
      unreadCount: 0,
      message: 'All notifications marked as read',
    };
  }
}

module.exports = new NotificationService();
