const authService = require('../services/authService');
const otpService = require('../services/otpService');
const { sendSuccess } = require('../utils/response');

class AuthController {
  /**
   * POST /api/v1/auth/request-otp
   * Generates and sends a 6-digit OTP to the provided institutional email.
   */
  async requestOtp(req, res, next) {
    try {
      const result = await otpService.requestOtp(req.validatedOtpRequest.officialEmail);
      return sendSuccess(res, 200, result);
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/v1/auth/verify-otp
   * Validates 6-digit OTP and returns a short-lived verification token.
   */
  async verifyOtp(req, res, next) {
    try {
      const result = await otpService.verifyOtp(
        req.validatedOtpVerify.officialEmail,
        req.validatedOtpVerify.otp
      );
      return sendSuccess(res, 200, result);
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/v1/auth/complete-registration
   * Validates verification token, roll number, single active session, and returns JWT session.
   */
  async completeRegistration(req, res, next) {
    try {
      const result = await authService.completeAuthentication(req.validatedAuth);
      return sendSuccess(res, 200, result);
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/v1/auth/verify
   * Legacy alias for complete-registration (requires verificationToken).
   */
  async verify(req, res, next) {
    try {
      const result = await authService.completeAuthentication(req.validatedAuth);
      return sendSuccess(res, 200, result);
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/v1/auth/colleges
   * Returns list of supported colleges
   */
  async getColleges(req, res, next) {
    try {
      const colleges = await authService.getColleges();
      return sendSuccess(res, 200, { colleges });
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/v1/auth/me
   * Retrieves profile and verification state of currently authenticated student
   */
  async getMe(req, res, next) {
    try {
      const profile = await authService.getProfile(req.student.studentId, req.student.collegeId);
      return sendSuccess(res, 200, { student: profile });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/v1/auth/logout
   * Revokes current server-side session in MongoDB
   */
  async logout(req, res, next) {
    try {
      const result = await authService.logout(
        req.sessionId,
        req.student?.studentId,
        req.student?.collegeId
      );
      return sendSuccess(res, 200, result);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new AuthController();
