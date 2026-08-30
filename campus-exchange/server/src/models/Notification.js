const mongoose = require('mongoose');

const NotificationSchema = new mongoose.Schema(
  {
    notificationId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    recipientStudentId: {
      type: String,
      required: true,
      index: true,
      ref: 'Student',
    },
    collegeId: {
      type: String,
      required: true,
      index: true,
      ref: 'College',
    },
    listingId: {
      type: String,
      required: true,
      index: true,
      ref: 'Listing',
    },
    senderStudentId: {
      type: String,
      default: '',
    },
    senderName: {
      type: String,
      default: '',
    },
    listingTitle: {
      type: String,
      default: '',
    },
    title: {
      type: String,
      required: true,
      trim: true,
    },
    message: {
      type: String,
      required: true,
      trim: true,
    },
    type: {
      type: String,
      enum: ['NEW_LISTING', 'SYSTEM', 'REPORT_UPDATE'],
      default: 'NEW_LISTING',
      index: true,
    },
    isRead: {
      type: Boolean,
      default: false,
      index: true,
    },
    readAt: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: true,
  }
);

// Compound indexes for fast querying and uniqueness per recipient & listing
NotificationSchema.index({ recipientStudentId: 1, isRead: 1, createdAt: -1 });
NotificationSchema.index({ collegeId: 1, recipientStudentId: 1 });
NotificationSchema.index({ recipientStudentId: 1, listingId: 1, type: 1 }, { unique: true });

module.exports = mongoose.model('Notification', NotificationSchema);
