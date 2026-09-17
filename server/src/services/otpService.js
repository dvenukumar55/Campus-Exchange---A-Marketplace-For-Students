const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const env = require('../config/env');
const Otp = require('../models/Otp');
const emailService = require('./emailService');
const { BadRequestError } = require('../utils/errors');
const logger = require('../utils/logger');

class OtpService {
  /**
   * Generates a 6-digit numeric OTP.
   */
  generateOtp() {
    return crypto.randomInt(100000, 1000000).toString();
  }

  /**
   * Generates a SHA-256 hash of the OTP for secure database storage.
   */
  hashOtp(otp) {
    return crypto
      .createHash('sha256')
      .update(String(otp).trim())
      .digest('hex');
  }

  /**
   * Generates expiration timestamp (5 minutes).
   */
  getExpiry() {
    const minutes = env.OTP_EXPIRY_MINUTES || 5;
    return new Date(Date.now() + minutes * 60 * 1000);
  }

  /**
   * Generates a short-lived cryptographic verification token upon successful OTP verification.
   * This token is required to proceed to the roll number stage.
   */
  generateVerificationToken(email) {
    return jwt.sign(
      {
        officialEmail: email.trim().toLowerCase(),
        purpose: 'email_otp_verified',
      },
      env.JWT_SECRET,
      {
        expiresIn: '10m', // Valid for 10 minutes to complete roll number entry
      }
    );
  }

  /**
   * Validates a verification token.
   */
  validateVerificationToken(token, expectedEmail) {
    if (!token || typeof token !== 'string') {
      throw new BadRequestError('Email OTP verification is required before proceeding.');
    }

    try {
      const decoded = jwt.verify(token, env.JWT_SECRET);
      if (
        decoded.purpose !== 'email_otp_verified' ||
        decoded.officialEmail !== expectedEmail.trim().toLowerCase()
      ) {
        throw new BadRequestError('Invalid or mismatched email verification state.');
      }
      return true;
    } catch (err) {
      if (err.name === 'TokenExpiredError') {
        throw new BadRequestError('Email verification has expired. Please verify your email again.');
      }
      throw new BadRequestError('Invalid or forged email verification token.');
    }
  }

  /**
   * Requests a new OTP for an email address.
   * Invalidates any prior active OTPs for this email.
   */
  async requestOtp(email) {
    const cleanEmail = email.trim().toLowerCase();

    logger.info('OTP request received', { email: cleanEmail });

    // Invalidate/delete any previous OTP requests for this email
    await Otp.deleteMany({ email: cleanEmail });

    // Generate 6-digit OTP
    const rawOtp = this.generateOtp();
    const otpHash = this.hashOtp(rawOtp);
    const expiresAt = this.getExpiry();

    // Store securely hashed OTP in MongoDB
    await Otp.create({
      email: cleanEmail,
      otpHash,
      attempts: 0,
      verified: false,
      expiresAt,
    });

    // Deliver OTP via email service
    try {
      await emailService.sendVerificationCode(cleanEmail, rawOtp);
    } catch (err) {
      // Clean up newly created OTP record so broken OTP requests are not left in db
      await Otp.deleteMany({ email: cleanEmail });
      logger.error('Failed to dispatch OTP email', { email: cleanEmail, error: err.message });
      throw err;
    }

    logger.info('OTP request processed and dispatched', { email: cleanEmail });

    return {
      message: 'Verification code sent to email successfully',
      expiresInMinutes: env.OTP_EXPIRY_MINUTES || 5,
    };

  }

  /**
   * Verifies the provided 6-digit OTP against the stored secure hash.
   */
  async verifyOtp(email, otp) {
    const cleanEmail = email.trim().toLowerCase();
    const cleanOtp = String(otp).trim();

    logger.info('OTP verification attempt received', { email: cleanEmail });

    if (!/^\d{6}$/.test(cleanOtp)) {
      throw new BadRequestError('Please enter a valid 6-digit verification code.');
    }

    const maxAttempts = env.OTP_MAX_ATTEMPTS || 5;

    // Find the latest unverified OTP record for this email
    const otpRecord = await Otp.findOne({
      email: cleanEmail,
      verified: false,
    }).sort({ createdAt: -1 });

    if (!otpRecord) {
      throw new BadRequestError('No active verification code found for this email. Please request a new code.');
    }

    // Check expiration
    if (new Date(otpRecord.expiresAt).getTime() < Date.now()) {
      await Otp.deleteOne({ _id: otpRecord._id });
      throw new BadRequestError('Verification code has expired. Please request a new code.');
    }

    // Check maximum attempts
    if (otpRecord.attempts >= maxAttempts) {
      await Otp.deleteOne({ _id: otpRecord._id });
      throw new BadRequestError('Maximum verification attempts exceeded. Please request a new code.');
    }

    // Verify hash match
    const isMatch = this.hashOtp(cleanOtp) === otpRecord.otpHash;

    if (!isMatch) {
      otpRecord.attempts += 1;
      await otpRecord.save();

      const remainingAttempts = maxAttempts - otpRecord.attempts;
      if (remainingAttempts <= 0) {
        await Otp.deleteOne({ _id: otpRecord._id });
        throw new BadRequestError('Maximum verification attempts exceeded. Please request a new code.');
      }

      throw new BadRequestError(`Invalid verification code. ${remainingAttempts} attempt${remainingAttempts === 1 ? '' : 's'} remaining.`);
    }

    // Mark as verified and single-use cleanup
    otpRecord.verified = true;
    await otpRecord.save();
    await Otp.deleteOne({ _id: otpRecord._id });

    logger.info('OTP verified successfully', { email: cleanEmail });

    // Generate short-lived verification token
    const verificationToken = this.generateVerificationToken(cleanEmail);

    return {
      verified: true,
      verificationToken,
      message: 'Email verified successfully. Please enter your roll number to proceed.',
    };
  }
}

module.exports = new OtpService();