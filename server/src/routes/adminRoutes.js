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
} = require('../config/constants');

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
      recentEvents,
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
      })
        .sort({ occurredAt: -1 })
        .limit(20)
        .lean(),
    ]);

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
    const events = await PilotEvent.find({
      collegeId: req.student.collegeId,
    })
      .sort({ occurredAt: -1 })
      .limit(100)
      .lean();

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