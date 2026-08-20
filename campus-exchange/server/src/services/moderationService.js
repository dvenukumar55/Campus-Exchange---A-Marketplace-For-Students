const { v4: uuidv4 } = require('uuid');
const Report = require('../models/Report');
const Listing = require('../models/Listing');
const Student = require('../models/Student');
const { REPORT_STATUS, LISTING_STATUS, ACCOUNT_STATUS, PILOT_EVENT_TYPES } = require('../config/constants');
const { NotFoundError, CrossCollegeError, BadRequestError } = require('../utils/errors');
const eventService = require('./eventService');

class ModerationService {
  /**
   * Submits a report against a listing / seller
   */
  async createReport({ listingId, reporter, reason, description }) {
    const listing = await Listing.findOne({ listingId });
    if (!listing) {
      throw new NotFoundError('Reported listing does not exist.');
    }

    if (listing.collegeId !== reporter.collegeId) {
      throw new CrossCollegeError();
    }

    if (listing.sellerId === reporter.studentId) {
      throw new BadRequestError('You cannot report your own listing.');
    }

    const reportId = `rep_${uuidv4().substring(0, 10)}`;

    const report = new Report({
      reportId,
      collegeId: reporter.collegeId,
      listingId,
      reporterId: reporter.studentId,
      sellerId: listing.sellerId,
      reason,
      description,
      status: REPORT_STATUS.OPEN,
    });

    await report.save();

    await eventService.recordEvent({
      eventType: PILOT_EVENT_TYPES.REPORT_SUBMITTED,
      collegeId: reporter.collegeId,
      studentId: reporter.studentId,
      listingId,
      metadata: { reportId, reason },
    });

    return report;
  }

  /**
   * Reviews and resolves an open report (Project Team first-level review & college admin escalation)
   */
  async reviewReport({ reportId, reviewer, status, reviewNotes, actionTaken }) {
    const report = await Report.findOne({ reportId });
    if (!report) {
      throw new NotFoundError('Report not found');
    }

    report.status = status || REPORT_STATUS.RESOLVED;
    report.reviewNotes = reviewNotes || 'Reviewed by campus operations';
    report.reviewedBy = reviewer?.studentId || 'operations_team';
    report.actionTaken = actionTaken || 'none';
    report.resolvedAt = new Date();

    if (actionTaken === 'listing_removed') {
      await Listing.updateOne(
        { listingId: report.listingId },
        { status: LISTING_STATUS.CLOSED, closedReason: 'removed_by_moderation', closedAt: new Date() }
      );
    } else if (actionTaken === 'seller_suspended') {
      await Student.updateOne({ studentId: report.sellerId }, { accountStatus: ACCOUNT_STATUS.SUSPENDED });
      await Listing.updateMany(
        { sellerId: report.sellerId, status: LISTING_STATUS.ACTIVE },
        { status: LISTING_STATUS.CLOSED, closedReason: 'removed_by_moderation', closedAt: new Date() }
      );
    }

    await report.save();

    await eventService.recordEvent({
      eventType: PILOT_EVENT_TYPES.REPORT_RESOLVED,
      collegeId: report.collegeId,
      listingId: report.listingId,
      metadata: { reportId, actionTaken, status: report.status },
    });

    return report;
  }

  /**
   * Lists reports for moderation review queue
   */
  async getReports({ collegeId, status, page = 1, limit = 20 }) {
    const query = { collegeId };
    if (status && Object.values(REPORT_STATUS).includes(status)) {
      query.status = status;
    }

    const pageNum = Math.max(1, parseInt(page, 10));
    const limitNum = Math.min(50, Math.max(1, parseInt(limit, 10)));
    const skip = (pageNum - 1) * limitNum;

    const [items, total] = await Promise.all([
      Report.find(query).sort({ createdAt: -1 }).skip(skip).limit(limitNum).lean(),
      Report.countDocuments(query),
    ]);

    return {
      items,
      pagination: {
        total,
        page: pageNum,
        limit: limitNum,
        totalPages: Math.ceil(total / limitNum),
      },
    };
  }
}

module.exports = new ModerationService();
