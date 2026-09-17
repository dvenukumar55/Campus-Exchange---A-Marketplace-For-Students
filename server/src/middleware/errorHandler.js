const { AppError } = require('../utils/errors');
const { sendError } = require('../utils/response');
const logger = require('../utils/logger');

const errorHandler = (err, req, res, next) => {
  // If headers were already sent, delegate to default Express handler
  if (res.headersSent) {
    return next(err);
  }

  const requestId = res.locals.requestId || req.requestId || 'req_unknown';

  // Known application domain errors
  if (err instanceof AppError) {
    logger.warn(`Application domain error [${err.code}]: ${err.message}`, {
      code: err.code,
      statusCode: err.statusCode,
      requestId,
      details: err.details,
    });

    return sendError(res, err.statusCode, err.code, err.message, err.details);
  }

  // Multer upload errors
  if (err.name === 'MulterError') {
    let message = 'File upload error';
    if (err.code === 'LIMIT_FILE_SIZE') {
      message = 'Uploaded image exceeds maximum allowable file size limit';
    } else if (err.code === 'LIMIT_FILE_COUNT') {
      message = 'Too many photos uploaded. Max photo count exceeded.';
    }
    return sendError(res, 400, 'UPLOAD_FAILED', message, err.field);
  }

  // Mongoose validation errors
  if (err.name === 'ValidationError') {
    const messages = Object.values(err.errors).map((e) => e.message);
    return sendError(res, 400, 'VALIDATION_ERROR', messages.join(', '), messages);
  }

  // Mongoose CastError (invalid ObjectId / parameter format)
  if (err.name === 'CastError') {
    return sendError(res, 400, 'INVALID_REQUEST', `Invalid format for field: ${err.path}`);
  }

  // MongoDB duplicate key error (E11000)
  if (err.code === 11000) {
    const key = Object.keys(err.keyValue || {})[0] || 'field';
    return sendError(res, 409, 'DUPLICATE_ACTION', `A resource with that ${key} already exists.`);
  }

  // Unhandled / server errors - never expose internal stack traces or database info
  logger.error('Unhandled internal server error', {
    error: err.message,
    stack: process.env.NODE_ENV !== 'production' ? err.stack : undefined,
    requestId,
  });

  return sendError(res, 500, 'INTERNAL_SERVER_ERROR', 'An unexpected internal error occurred on the server.');
};

module.exports = errorHandler;
