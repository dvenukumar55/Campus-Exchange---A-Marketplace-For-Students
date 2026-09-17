const express = require('express');
const router = express.Router();

const { authenticate, requireAdmin } = require('../middleware/auth');
const moderationService = require('../services/moderationService');

const Student = require('../models/Student');
const Listing = require('../models/Listing');
const Report = require('../models/Report');
const PilotEvent = require('../models/PilotEvent');
const College = require('../models/College');

const {
  LISTING_STATUS,
  REPORT_STATUS,
  PILOT_EVENT_TYPES,
} = require('../config/constants');

const ADMIN_RECENT_EVENT_TYPES = [
  PILOT_EVENT_TYPES.REPORT_SUBMITTED,
  PILOT_EVENT_TYPES.REPORT_RESOLVED,
  PILOT_EVENT_TYPES.USER_WARNED,
  PILOT_EVENT_TYPES.USER_BLOCKED,
  PILOT_EVENT_TYPES.LISTING_CREATED,
  PILOT_EVENT_TYPES.LISTING_UPDATED,
  PILOT_EVENT_TYPES.LISTING_CLOSED_SOLD,
  PILOT_EVENT_TYPES.LISTING_CLOSED_CANCELLED,
  PILOT_EVENT_TYPES.STUDENT_SIGNUP_VERIFIED,
];

function enrichEvents(rawEvents, students, listings) {
  const studentMap = {};
  for (const s of students) {
    studentMap[s.studentId] = s;
  }

  const listingMap = {};
  for (const l of listings) {
    listingMap[l.listingId] = l;
  }

  return rawEvents.map((e) => {
    const student = studentMap[e.studentId];
    const listing = listingMap[e.listingId];
    const actor = student
      ? student.fullName
      : (e.metadata?.actor || e.studentId || 'System');
    let target = 'Campus';
    if (listing) {
      target = listing.title;
    } else if (e.metadata?.listingTitle) {
      target = e.metadata.listingTitle;
    } else if (e.metadata?.reportId) {
      target = `Report #${e.metadata.reportId}`;
    } else if (e.studentId && e.eventType && e.eventType.includes('STUDENT')) {
      target = student
        ? `${student.fullName} (${student.rollNumber || student.studentId})`
        : e.studentId;
    }

    return {
      eventId: e.eventId,
      eventType: e.eventType,
      collegeId: e.collegeId,
      studentId: e.studentId,
      listingId: e.listingId,
      actor,
      actorEmail: student ? student.officialEmail : null,
      target,
      occurredAt: e.occurredAt,
      metadata: e.metadata || {},
    };
  });
}

function deduplicateEvents(eventList) {
  const deduped = [];
  for (const ev of eventList) {
    if (deduped.length > 0) {
      const prev = deduped[deduped.length - 1];
      const sameType = prev.eventType === ev.eventType;
      const sameActor = prev.studentId === ev.studentId;
      const sameTarget = prev.listingId === ev.listingId;
      const timeDiff = Math.abs(
        new Date(prev.occurredAt) - new Date(ev.occurredAt)
      );
      if (sameType && sameActor && sameTarget && timeDiff < 3600000) {
        continue;
      }
    }
    deduped.push(ev);
  }
  return deduped;
}

/*
 * All admin routes require:
 * 1. Valid JWT
 * 2. Admin or moderator role
 */
router.use(authenticate, requireAdmin);

/**
 * GET /api/v1/admin/test
 */
router.get('/test', (req, res) => {
  res.json({
    success: true,
    message: 'Admin API is working',
    role: req.student.role,
  });
});

/**
 * GET /api/v1/admin/dashboard
 *
 * Returns REAL MongoDB statistics for the Admin Dashboard.
 */
router.get('/dashboard', async (req, res, next) => {
  try {
    const collegeId = req.student.collegeId || 'avih-gunthapalli';

    const [
      allColleges,
      totalStudents,
      verifiedStudents,
      activeStudents,
      suspendedStudents,
      activeListings,
      soldListings,
      closedListings,
      pendingReports,
      totalReports,
      volumeResult,
      campusListingStats,
      rawRecentEvents,
      studentsList,
      listingsList,
    ] = await Promise.all([
      College.find({}).lean(),

      Student.countDocuments({
        collegeId,
      }),

      Student.countDocuments({
        collegeId,
        $or: [
          { verificationStatus: 'verified' },
          { status: 'verified' },
        ],
      }),

      Student.countDocuments({
        collegeId,
        accountStatus: 'active',
      }),

      Student.countDocuments({
        collegeId,
        accountStatus: 'suspended',
      }),

      Listing.countDocuments({
        collegeId,
        status: LISTING_STATUS.ACTIVE,
      }),

      Listing.countDocuments({
        collegeId,
        status: LISTING_STATUS.SOLD,
      }),

      Listing.countDocuments({
        collegeId,
        status: LISTING_STATUS.CLOSED,
      }),

      Report.countDocuments({
        collegeId,
        status: { $in: ['open', 'pending', REPORT_STATUS.OPEN] },
      }),

      Report.countDocuments({
        collegeId,
      }),

      Listing.aggregate([
        {
          $match: {
            collegeId,
            status: LISTING_STATUS.ACTIVE,
          },
        },
        {
          $group: {
            _id: null,
            total: { $sum: '$price' },
          },
        },
      ]),

      Listing.aggregate([
        {
          $group: {
            _id: '$collegeId',
            listingCount: { $sum: 1 },
            activeCount: {
              $sum: {
                $cond: [
                  { $eq: ['$status', LISTING_STATUS.ACTIVE] },
                  1,
                  0,
                ],
              },
            },
          },
        },
        { $sort: { listingCount: -1 } },
      ]),

      PilotEvent.find({
        collegeId,
        eventType: { $in: ADMIN_RECENT_EVENT_TYPES },
      })
        .sort({ occurredAt: -1 })
        .limit(20)
        .lean(),

      Student.find({
        collegeId,
      })
        .select('studentId fullName officialEmail rollNumber')
        .lean(),

      Listing.find({
        collegeId,
      })
        .select('listingId title price category')
        .lean(),
    ]);

    const recentEvents = deduplicateEvents(
      enrichEvents(rawRecentEvents, studentsList, listingsList)
    );

    const collegeMap = {};
    for (const c of allColleges) {
      collegeMap[c.collegeId] = c.name;
    }

    const currentCollege = allColleges.find((c) => c.collegeId === collegeId);

    const marketVolume =
      volumeResult.length > 0 ? Number(volumeResult[0].total || 0) : 0;

    const statsMap = {};
    for (const item of campusListingStats) {
      statsMap[item._id] = {
        listingCount: item.listingCount || 0,
        activeCount: item.activeCount || 0,
      };
    }

    let campuses = allColleges.map((c) => ({
      collegeId: c.collegeId,
      name: c.name || c.collegeId,
      listingCount: statsMap[c.collegeId]?.listingCount || 0,
      activeCount: statsMap[c.collegeId]?.activeCount || 0,
    }));

    if (campuses.length === 0) {
      campuses = campusListingStats.map((item) => ({
        collegeId: item._id,
        name: collegeMap[item._id] || item._id,
        listingCount: item.listingCount || 0,
        activeCount: item.activeCount || 0,
      }));
    }

    if (campuses.length === 0) {
      campuses.push({
        collegeId: collegeId,
        name: currentCollege ? currentCollege.name : collegeId,
        listingCount: 0,
        activeCount: 0,
      });
    }

    res.json({
      success: true,
      data: {
        college: currentCollege
          ? {
              collegeId: currentCollege.collegeId,
              name: currentCollege.name,
              verificationDomain: currentCollege.verificationDomain,
              status: currentCollege.status,
            }
          : {
              collegeId,
              name: collegeMap[collegeId] || collegeId,
              verificationDomain: 'edu.in',
              status: 'active',
            },

        students: {
          total: totalStudents,
          verified: verifiedStudents,
          active: activeStudents,
          suspended: suspendedStudents,
        },

        listings: {
          active: activeListings,
          sold: soldListings,
          closed: closedListings,
          total: activeListings + soldListings + closedListings,
        },

        reports: {
          pending: pendingReports,
          total: totalReports,
        },

        market: {
          volume: marketVolume,
        },

        campuses,
        recentEvents,
      },
    });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/admin/students
 *
 * Real students from MongoDB.
 */
router.get('/students', async (req, res, next) => {
  try {
    const students = await Student.find({
      collegeId: req.student.collegeId,
    })
      .select(
        'studentId officialEmail rollNumber fullName department role accountStatus verificationStatus warningCount verifiedAt createdAt'
      )
      .sort({ createdAt: -1 })
      .lean();

    res.json({
      success: true,
      data: students,
    });

  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/admin/reports
 *
 * Real reports from MongoDB.
 */
router.get('/reports', async (req, res, next) => {
  try {
    const status = req.query.status;

    const query = {
      collegeId: req.student.collegeId,
    };

    if (
      status &&
      Object.values(REPORT_STATUS).includes(status)
    ) {
      query.status = status;
    }

    const reports = await Report.find(query)
      .sort({ createdAt: -1 })
      .limit(100)
      .lean();

    res.json({
      success: true,
      data: reports,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/admin/audit-logs
 *
 * Real PilotEvent records from MongoDB.
 */
router.get('/audit-logs', async (req, res, next) => {
  try {
    const collegeId = req.student.collegeId;

    const [rawEvents, studentsList, listingsList] = await Promise.all([
      PilotEvent.find({
        collegeId,
      })
        .sort({ occurredAt: -1 })
        .limit(100)
        .lean(),
      Student.find({
        collegeId,
      })
        .select('studentId fullName officialEmail rollNumber')
        .lean(),
      Listing.find({
        collegeId,
      })
        .select('listingId title price category')
        .lean(),
    ]);

    const events = deduplicateEvents(
      enrichEvents(rawEvents, studentsList, listingsList)
    );

    res.json({
      success: true,
      data: events,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/admin/listings
 *
 * Real marketplace listings for administration.
 */
router.get('/listings', async (req, res, next) => {
  try {
    const listings = await Listing.find({
      collegeId: req.student.collegeId,
    })
      .sort({ createdAt: -1 })
      .limit(100)
      .lean();

    res.json({
      success: true,
      data: listings,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * WARN STUDENT
 */
router.post('/students/:studentId/warn', async (req, res, next) => {
  try {
    const result = await moderationService.warnStudent({
      studentId: req.params.studentId,
      reviewer: req.student,
      rollNumber: req.body?.rollNumber,
    });

    res.json({
      success: true,
      warningCount: result.warningCount,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * BLOCK STUDENT
 */
router.post('/students/:studentId/block', async (req, res, next) => {
  try {
    const result = await moderationService.blockStudent({
      studentId: req.params.studentId,
      reviewer: req.student,
      rollNumber: req.body?.rollNumber,
    });

    res.json({
      success: true,
      accountStatus: result.accountStatus,
    });
  } catch (error) {
    next(error);
  }
});


module.exports = router;