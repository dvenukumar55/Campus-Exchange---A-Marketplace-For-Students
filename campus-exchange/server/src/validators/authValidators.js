const validator = require('validator');
const { BadRequestError } = require('../utils/errors');

/**
 * Validates authentication payload (Email + Roll Number)
 *
 * College is intentionally NOT accepted from the client.
 * The backend determines the student's college internally.
 */
const validateVerifyRequest = async (req, res, next) => {
  const { officialEmail, rollNumber } = req.body;

  if (!officialEmail || typeof officialEmail !== 'string') {
    return next(new BadRequestError('Email address is required'));
  }

  if (
    !rollNumber ||
    typeof rollNumber !== 'string' ||
    rollNumber.trim() === ''
  ) {
    return next(new BadRequestError('Roll number is required'));
  }

  const cleanEmail = officialEmail.trim().toLowerCase();
  const cleanRollNumber = rollNumber.trim().toUpperCase();

  if (!validator.isEmail(cleanEmail)) {
    return next(
      new BadRequestError('Please provide a valid email address')
    );
  }

  req.validatedAuth = {
    officialEmail: cleanEmail,
    rollNumber: cleanRollNumber,
  };

  next();
};

module.exports = {
  validateVerifyRequest,
};