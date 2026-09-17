const express = require('express');
const router = express.Router();
const reportController = require('../controllers/reportController');
const { authenticate, requireVerified } = require('../middleware/auth');
const { enforceCollegeContext } = require('../middleware/collegeContext');
const { validateReport } = require('../validators/reportValidators');

router.use(authenticate, requireVerified, enforceCollegeContext);

// POST /api/v1/reports - Create misleading listing / seller report
router.post('/', validateReport, reportController.createReport);

// GET /api/v1/reports - Moderation report queue
router.get('/', reportController.getReports);

// POST /api/v1/reports/:reportId/review - Review and take action on report
router.post('/:reportId/review', reportController.reviewReport);

module.exports = router;
