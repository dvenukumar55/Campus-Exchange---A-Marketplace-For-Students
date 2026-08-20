const validator = require('validator');
const { BadRequestError } = require('../utils/errors');
const College = require('../models/College');

/**
 * Validates student official email verification payload
 */
const validateVerifyRequest = async (req, res, next) => {
  const { officialEmail, verificationCode, collegeId } = req.body;

  if (!officialEmail || typeof officialEmail !== 'string') {
    return next(new BadRequestError('Official college email address is required'));
  }

  const cleanEmail = officialEmail.trim().toLowerCase();
  if (!validator.isEmail(cleanEmail)) {
    return next(new BadRequestError('Please provide a valid email address'));
  }

  // Find college to validate email domain boundary
  let college;
  if (collegeId) {
    college = await College.findOne({ collegeId });
  } else {
    // Attempt to derive college by domain
    const domain = cleanEmail.split('@')[1];
    college = await College.findOne({ verificationDomain: domain });
  }

  if (!college) {
    return next(
      new BadRequestError(
        'Email domain is not recognized for any participating pilot college. Only official college emails are allowed.'
      )
    );
  }

  const emailDomain = cleanEmail.split('@')[1];
  if (emailDomain !== college.verificationDomain && !emailDomain.endsWith('.' + college.verificationDomain)) {
    return next(
      new BadRequestError(
        `Email domain @${emailDomain} does not match the official domain for ${college.name} (@${college.verificationDomain})`
      )
    );
  }

  req.validatedAuth = {
    officialEmail: cleanEmail,
    verificationCode: verificationCode ? String(verificationCode).trim() : null,
    college,
  };

  next();
};

module.exports = {
  validateVerifyRequest,
};
