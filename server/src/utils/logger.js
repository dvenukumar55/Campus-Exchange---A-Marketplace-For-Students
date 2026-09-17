/**
 * Structured Logger adhering to PRISM-S observability specifications:
 * - Timestamps, requestId, route, status code, latency, and non-sensitive error codes
 * - STRICT RULE: Never log JWTs, passwords, verification codes, or sensitive personal data
 */
const sanitizeData = (data) => {
  if (!data || typeof data !== 'object') return data;
  const sanitized = Array.isArray(data) ? [...data] : { ...data };

  const forbiddenKeys = ['password', 'jwt', 'token', 'verificationCode', 'secret', 'authorization'];

  for (const key of Object.keys(sanitized)) {
    if (forbiddenKeys.some((f) => key.toLowerCase().includes(f))) {
      sanitized[key] = '***REDACTED***';
    } else if (typeof sanitized[key] === 'object' && sanitized[key] !== null) {
      sanitized[key] = sanitizeData(sanitized[key]);
    }
  }
  return sanitized;
};

const formatMessage = (level, message, meta = {}) => {
  const entry = {
    timestamp: new Date().toISOString(),
    level,
    message,
    ...sanitizeData(meta),
  };
  return JSON.stringify(entry);
};

const logger = {
  info: (msg, meta) => {
    console.log(formatMessage('INFO', msg, meta));
  },
  warn: (msg, meta) => {
    console.warn(formatMessage('WARN', msg, meta));
  },
  error: (msg, meta) => {
    console.error(formatMessage('ERROR', msg, meta));
  },
  debug: (msg, meta) => {
    if (process.env.NODE_ENV !== 'production') {
      console.debug(formatMessage('DEBUG', msg, meta));
    }
  },
};

module.exports = logger;
