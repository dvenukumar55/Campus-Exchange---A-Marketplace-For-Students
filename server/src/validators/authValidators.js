const validator = require('validator');
const { BadRequestError } = require('../utils/errors');

/**
 * Validates request for OTP sending
 */
const validateRequestOtp = async (req, res, next) => {
  const { officialEmail } = req.body;

  if (!officialEmail || typeof officialEmail !== 'string') {
    return next(new BadRequestError('Institutional email address is required.'));
  }

  const cleanEmail = officialEmail.trim().toLowerCase();

  if (!validator.isEmail(cleanEmail)) {
    return next(new BadRequestError('Please provide a valid institutional email address.'));
  }

  req.validatedOtpRequest = {
    officialEmail: cleanEmail,
  };

  next();
};

/**
 * Validates OTP verification payload
 */
const validateVerifyOtp = async (req, res, next) => {
  const { officialEmail, otp } = req.body;

  if (!officialEmail || typeof officialEmail !== 'string') {
    return next(new BadRequestError('Email address is required.'));
  }

  const cleanEmail = officialEmail.trim().toLowerCase();
  if (!validator.isEmail(cleanEmail)) {
    return next(new BadRequestError('Please provide a valid email address.'));
  }

  if (!otp || typeof otp !== 'string' || !/^\d{6}$/.test(otp.trim())) {
    return next(new BadRequestError('Please enter a valid 6-digit verification code.'));
  }

  req.validatedOtpVerify = {
    officialEmail: cleanEmail,
    otp: otp.trim(),
  };

  next();
};

/**
 * Validates roll number submission after OTP verification
 */
const validateCompleteRegistration = async (req, res, next) => {
  const { officialEmail, rollNumber, verificationToken, deviceId } = req.body;

  if (!officialEmail || typeof officialEmail !== 'string') {
    return next(new BadRequestError('Email address is required.'));
  }

  if (!rollNumber || typeof rollNumber !== 'string' || rollNumber.trim() === '') {
    return next(new BadRequestError('Roll number is required.'));
  }

  if (!verificationToken || typeof verificationToken !== 'string') {
    return next(new BadRequestError('Verification token is required. Please verify email OTP first.'));
  }

  const cleanEmail = officialEmail.trim().toLowerCase();
  const cleanRollNumber = rollNumber.trim().toUpperCase();

  if (!validator.isEmail(cleanEmail)) {
    return next(new BadRequestError('Please provide a valid email address.'));
  }

  req.validatedAuth = {
    officialEmail: cleanEmail,
    rollNumber: cleanRollNumber,
    verificationToken: verificationToken.trim(),
    deviceId: typeof deviceId === 'string' ? deviceId.trim() : 'device_unknown',
  };

  next();
};

/**
 * Compatibility handler for legacy /verify route.
 * Rejects requests without OTP verification token.
 */
const validateVerifyRequest = async (req, res, next) => {
  const { officialEmail, rollNumber, verificationToken, deviceId } = req.body;

  if (!verificationToken) {
    return next(
      new BadRequestError(
        'Direct login without OTP verification is disabled. Please complete email OTP verification.'
      )
    );
  }

  return validateCompleteRegistration(req, res, next);
};

module.exports = {
  validateRequestOtp,
  validateVerifyOtp,
  validateCompleteRegistration,
  validateVerifyRequest,
};