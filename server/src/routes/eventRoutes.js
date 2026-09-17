const express = require('express');
const router = express.Router();
const eventController = require('../controllers/eventController');
const { authenticate, requireVerified } = require('../middleware/auth');
const { enforceCollegeContext } = require('../middleware/collegeContext');
const { validateEvent } = require('../validators/eventValidators');

router.use(authenticate, requireVerified, enforceCollegeContext);

// POST /api/v1/events - Record a client-initiated pilot event with deduplication
router.post('/', validateEvent, eventController.recordEvent);

module.exports = router;
