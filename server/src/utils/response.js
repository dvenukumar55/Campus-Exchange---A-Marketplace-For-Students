/**
 * Consistent JSON response helper adhering to PRISM-S:
 * Error standard format:
 * {
 *   "error": {
 *     "code": "CODE",
 *     "message": "Human readable message",
 *     "requestId": "server-generated-id",
 *     "details": []
 *   }
 * }
 */
const sendSuccess = (res, statusCode = 200, data = {}, meta = null) => {
  const payload = {
    success: true,
    requestId: res.locals?.requestId,
    ...data,
  };
  if (meta) {
    payload.meta = meta;
  }
  return res.status(statusCode).json(payload);
};

const sendError = (res, statusCode = 500, code = 'INTERNAL_SERVER_ERROR', message = 'An unexpected server error occurred', details = null) => {
  const requestId = res.locals?.requestId || `req_${Date.now()}`;
  return res.status(statusCode).json({
    error: {
      code,
      message,
      requestId,
      ...(details ? { details } : {}),
    },
  });
};

module.exports = {
  sendSuccess,
  sendError,
};
