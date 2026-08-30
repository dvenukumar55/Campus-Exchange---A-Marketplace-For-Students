const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const {
  validateRequestOtp,
  validateVerifyOtp,
  validateCompleteRegistration,
  validateVerifyRequest,
} = require('../validators/authValidators');
const { authenticate } = require('../middleware/auth');
const {
  authLimiter,
  otpRequestLimiter,
  otpVerifyLimiter,
} = require('../middleware/rateLimiter');

// GET /api/v1/auth/colleges - Retrieve list of available colleges
router.get('/colleges', authLimiter, authController.getColleges);

// POST /api/v1/auth/request-otp - Send 6-digit OTP to institutional email
router.post(
  '/request-otp',
  otpRequestLimiter,
  validateRequestOtp,
  authController.requestOtp
);

// POST /api/v1/auth/verify-otp - Verify 6-digit OTP and get verification token
router.post(
  '/verify-otp',
  otpVerifyLimiter,
  validateVerifyOtp,
  authController.verifyOtp
);

// POST /api/v1/auth/complete-registration - Complete login/registration with verified email + roll number
router.post(
  '/complete-registration',
  authLimiter,
  validateCompleteRegistration,
  authController.completeRegistration
);

// POST /api/v1/auth/verify - Legacy alias for complete-registration (enforces OTP verification token)
router.post(
  '/verify',
  authLimiter,
  validateVerifyRequest,
  authController.verify
);

// GET /api/v1/auth/me - Retrieve current verified student session info
router.get('/me', authenticate, authController.getMe);

// POST /api/v1/auth/logout - Session logout and server-side revocation
router.post('/logout', authenticate, authController.logout);

module.exports = router;
