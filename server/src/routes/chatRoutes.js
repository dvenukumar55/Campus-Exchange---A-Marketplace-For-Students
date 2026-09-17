const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');
const { authenticate, requireVerified } = require('../middleware/auth');
const { enforceCollegeContext } = require('../middleware/collegeContext');
const { validateSendMessage } = require('../validators/chatValidators');

router.use(authenticate, requireVerified, enforceCollegeContext);

// GET /api/v1/listings/:listingId/chat - Get messages for a listing
router.get('/:listingId/chat', chatController.getMessages);

// POST /api/v1/listings/:listingId/chat - Send message for a listing
router.post('/:listingId/chat', validateSendMessage, chatController.sendMessage);

module.exports = router;
