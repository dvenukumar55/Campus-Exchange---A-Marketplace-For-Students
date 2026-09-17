const { BadRequestError } = require('../utils/errors');

const validateSendMessage = (req, res, next) => {
  const { message } = req.body;
  if (!message || typeof message !== 'string' || message.trim().length === 0) {
    return next(new BadRequestError('Message cannot be empty'));
  }

  if (message.trim().length > 1000) {
    return next(new BadRequestError('Message exceeds maximum allowed length of 1000 characters'));
  }

  req.validatedMessage = message.trim();
  next();
};

module.exports = {
  validateSendMessage,
};
