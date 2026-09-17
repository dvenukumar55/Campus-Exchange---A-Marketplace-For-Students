const { REPORT_REASONS } = require('../config/constants');
const { BadRequestError } = require('../utils/errors');

const validateReport = (req, res, next) => {
  const { listingId, reason, description } = req.body;

  if (!listingId || typeof listingId !== 'string') {
    return next(new BadRequestError('Valid listingId is required'));
  }

  if (!reason || !REPORT_REASONS.includes(reason)) {
    return next(new BadRequestError(`Reason must be one of: ${REPORT_REASONS.join(', ')}`));
  }

  if (!description || typeof description !== 'string' || description.trim().length < 5) {
    return next(new BadRequestError('Please provide a descriptive report reason (at least 5 characters)'));
  }

  req.validatedReport = {
    listingId: listingId.trim(),
    reason,
    description: description.trim(),
  };

  next();
};

module.exports = {
  validateReport,
};
