const { PILOT_EVENT_TYPES } = require('../config/constants');
const { BadRequestError } = require('../utils/errors');

const validateEvent = (req, res, next) => {
  const { eventId, eventType, listingId, metadata } = req.body;

  if (!eventType || !Object.values(PILOT_EVENT_TYPES).includes(eventType)) {
    return next(new BadRequestError(`Invalid eventType. Allowed types: ${Object.values(PILOT_EVENT_TYPES).join(', ')}`));
  }

  req.validatedEvent = {
    eventId: eventId ? String(eventId).trim() : undefined,
    eventType,
    listingId: listingId ? String(listingId).trim() : undefined,
    metadata: metadata && typeof metadata === 'object' ? metadata : {},
  };

  next();
};

module.exports = {
  validateEvent,
};
