const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { validateVerifyRequest } = require('../validators/authValidators');
const { authenticate } = require('../middleware/auth');
const { authLimiter } = require('../middleware/rateLimiter');

// GET /api/v1/auth/colleges - Retrieve list of available colleges
router.get('/colleges', authLimiter, authController.getColleges);

// POST /api/v1/auth/verify - Verify student college email and receive JWT
router.post('/verify', authLimiter, validateVerifyRequest, authController.verify);

// GET /api/v1/auth/me - Retrieve current verified student session info
router.get('/me', authenticate, authController.getMe);

// POST /api/v1/auth/logout - Session logout
router.post('/logout', authenticate, authController.logout);

module.exports = router;
