const validator = require('validator');
const { BadRequestError } = require('../utils/errors');
const College = require('../models/College');
const env = require('../config/env');

/**
 * Validates student official email verification payload
 *
 * Development:
 *   Only the configured test email is allowed because we don't
 *   currently have a real college email domain.
 *
 * Production:
 *   The email must belong to a participating college domain.
 */
const validateVerifyRequest = async (req, res, next) => {
  const { officialEmail, verificationCode, collegeId } = req.body;

  if (!officialEmail || typeof officialEmail !== 'string') {
    return next(new BadRequestError('Email address is required'));
  }

  const cleanEmail = officialEmail.trim().toLowerCase();

  if (!validator.isEmail(cleanEmail)) {
    return next(new BadRequestError('Please provide a valid email address'));
  }

  /*
   * DEVELOPMENT TEST ACCOUNT
   *
   * We do not currently have a real college email domain.
   * Therefore, only the configured Gmail test account is allowed
   * during development.
   */
  if (
    env.NODE_ENV !== 'production' &&
    cleanEmail === 'kittud0005@gmail.com'
  ) {
    const college = await College.findOne({
      collegeId: collegeId || env.DEFAULT_COLLEGE_ID,
    });

    if (!college) {
      return next(
        new BadRequestError('Default pilot college is not configured')
      );
    }

    req.validatedAuth = {
      officialEmail: cleanEmail,
      verificationCode: verificationCode
        ? String(verificationCode).trim()
        : null,
      college,
    };

    return next();
  }

  /*
   * PRODUCTION / OFFICIAL COLLEGE EMAIL VALIDATION
   */
  let college;

  if (collegeId) {
    college = await College.findOne({ collegeId });
  } else {
    const domain = cleanEmail.split('@')[1];
    college = await College.findOne({
      verificationDomain: domain,
    });
  }

  if (!college) {
    return next(
      new BadRequestError(
        'Email domain is not recognized for any participating pilot college. Only official college emails are allowed.'
      )
    );
  }

  const emailDomain = cleanEmail.split('@')[1];

  if (
    emailDomain !== college.verificationDomain &&
    !emailDomain.endsWith('.' + college.verificationDomain)
  ) {
    return next(
      new BadRequestError(
        `Email domain @${emailDomain} does not match the official domain for ${college.name} (@${college.verificationDomain})`
      )
    );
  }

  req.validatedAuth = {
    officialEmail: cleanEmail,
    verificationCode: verificationCode
      ? String(verificationCode).trim()
      : null,
    college,
  };

  next();
};

module.exports = {
  validateVerifyRequest,
};