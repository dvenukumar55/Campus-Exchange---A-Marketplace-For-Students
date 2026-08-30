const { ERROR_CODES } = require('../config/constants');

class AppError extends Error {
  constructor(statusCode, code, message, details = null) {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
    this.details = details;
    Error.captureStackTrace(this, this.constructor);
  }
}

class BadRequestError extends AppError {
  constructor(message = 'Invalid request parameters', details = null) {
    super(400, ERROR_CODES.VALIDATION_ERROR, message, details);
  }
}

class UnauthorizedError extends AppError {
  constructor(message = 'Authentication required or invalid credentials') {
    super(401, ERROR_CODES.UNAUTHENTICATED, message);
  }
}

class ForbiddenError extends AppError {
  constructor(message = 'Access forbidden: Verified student status in matching college required', code = ERROR_CODES.UNAUTHORIZED_ACCESS) {
    super(403, code, message);
  }
}

class CrossCollegeError extends AppError {
  constructor(message = 'Access forbidden: Cross-college marketplace access is strictly prohibited') {
    super(403, ERROR_CODES.CROSS_COLLEGE_DENIED, message);
  }
}

class NotFoundError extends AppError {
  constructor(message = 'Requested resource not found', code = ERROR_CODES.LISTING_NOT_FOUND) {
    super(404, code, message);
  }
}

class ConflictError extends AppError {
  constructor(message = 'Resource state conflict', code = ERROR_CODES.INVALID_STATE_TRANSITION) {
    super(409, code, message);
  }
}

class ServiceUnavailableError extends AppError {
  constructor(message = 'Downstream service or database is temporarily unavailable') {
    super(503, ERROR_CODES.SERVICE_UNAVAILABLE, message);
  }
}

class EmailDeliveryError extends AppError {
  constructor(message = 'Failed to deliver verification email. Please check server email/SMTP configuration.') {
    super(502, 'EMAIL_DELIVERY_FAILED', message);
  }
}

module.exports = {
  AppError,
  BadRequestError,
  UnauthorizedError,
  ForbiddenError,
  CrossCollegeError,
  NotFoundError,
  ConflictError,
  ServiceUnavailableError,
  EmailDeliveryError,
};

