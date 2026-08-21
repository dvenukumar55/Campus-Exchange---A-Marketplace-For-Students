const authService = require('../services/authService');
const { sendSuccess } = require('../utils/response');

class AuthController {
  /**
   * POST /api/v1/auth/verify
   * Validates official college email verification state and returns JWT session
   */
  async verify(req, res, next) {
    try {
      const result = await authService.verifyAndAuthenticate(req.validatedAuth);
      return sendSuccess(res, 200, result);
    } catch (error) {
      next(error);
    }
  }
     /**
   * POST /api/v1/auth/send-code
   * Generates a development OTP for the official college email.
   */
  async sendCode(req, res, next) {
    try {
      const result = await authService.sendVerificationCode(req.validatedAuth);
      return sendSuccess(res, 200, result);
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
   */
  async logout(req, res) {
    return sendSuccess(res, 200, { message: 'Logged out successfully' });
  }
}

module.exports = new AuthController();
