const { CrossCollegeError, ForbiddenError } = require('../utils/errors');

/**
 * Enforces server-derived college context.
 * Overwrites any client-supplied collegeId with req.student.collegeId.
 */
const enforceCollegeContext = (req, res, next) => {
  if (!req.student || !req.student.collegeId) {
    return next(new ForbiddenError('No authenticated college context found'));
  }

  // If client maliciously supplied a different collegeId in params/body/query, reject or force server value
  const clientSuppliedCollegeId = req.params?.collegeId || req.body?.collegeId || req.query?.collegeId;
  if (clientSuppliedCollegeId && clientSuppliedCollegeId !== req.student.collegeId) {
    return next(new CrossCollegeError('Cross-college access is strictly prohibited. Access denied.'));
  }

  // Derive and bind server-authenticated collegeId
  req.collegeId = req.student.collegeId;
  if (req.body && typeof req.body === 'object') {
    req.body.collegeId = req.student.collegeId;
  }

  next();
};

/**
 * Helper to verify that a found database entity belongs to the requesting student's college
 */
const assertSameCollege = (entityCollegeId, studentCollegeId) => {
  if (!entityCollegeId || entityCollegeId !== studentCollegeId) {
    throw new CrossCollegeError();
  }
};

module.exports = {
  enforceCollegeContext,
  assertSameCollege,
};
