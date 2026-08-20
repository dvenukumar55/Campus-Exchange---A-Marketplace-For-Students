const mongoose = require('mongoose');
const { REPORT_STATUS, REPORT_REASONS } = require('../config/constants');

const ReportSchema = new mongoose.Schema(
  {
    reportId: {
      type: String,
      required: true,
      unique: true,
      index: true,
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
    reporterId: {
      type: String,
      required: true,
      index: true,
      ref: 'Student',
    },
    sellerId: {
      type: String,
      required: true,
      index: true,
      ref: 'Student',
    },
    reason: {
      type: String,
      required: [true, 'Reason is required'],
      enum: REPORT_REASONS,
    },
    description: {
      type: String,
      required: [true, 'Report description is required'],
      trim: true,
      maxlength: 1000,
    },
    status: {
      type: String,
      enum: Object.values(REPORT_STATUS),
      default: REPORT_STATUS.OPEN,
      index: true,
    },
    reviewNotes: {
      type: String,
      trim: true,
    },
    reviewedBy: {
      type: String,
    },
    actionTaken: {
      type: String,
      enum: ['none', 'listing_removed', 'seller_warned', 'seller_suspended', 'rejected'],
      default: 'none',
    },
    resolvedAt: {
      type: Date,
    },
  },
  {
    timestamps: true,
  }
);

ReportSchema.index({ status: 1, createdAt: -1 });
ReportSchema.index({ collegeId: 1, status: 1 });

module.exports = mongoose.model('Report', ReportSchema);
