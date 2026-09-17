const { CATEGORIES, CONDITIONS, LISTING_STATUS } = require('../config/constants');
const { BadRequestError } = require('../utils/errors');

const validateCreateListing = (req, res, next) => {
  const { title, description, category, price, condition, photoRefs } = req.body;

  if (!title || typeof title !== 'string' || title.trim().length < 3) {
    return next(new BadRequestError('Item title must be at least 3 characters long'));
  }

  if (!description || typeof description !== 'string' || description.trim().length < 5) {
    return next(new BadRequestError('Item description must be at least 5 characters long'));
  }

  if (!category || !CATEGORIES.includes(category)) {
    return next(new BadRequestError(`Category must be one of: ${CATEGORIES.join(', ')}`));
  }

  if (price === undefined || price === null || isNaN(Number(price)) || Number(price) < 0) {
    return next(new BadRequestError('Price must be a valid non-negative number'));
  }

  if (!condition || !CONDITIONS.includes(condition)) {
    return next(new BadRequestError(`Condition must be one of: ${CONDITIONS.join(', ')}`));
  }

  if (!photoRefs || !Array.isArray(photoRefs) || photoRefs.length === 0) {
    return next(new BadRequestError('At least one item photo reference is required for a complete active listing'));
  }

  req.validatedListing = {
    title: title.trim(),
    description: description.trim(),
    category,
    price: Number(price),
    condition,
    photoRefs: photoRefs.filter((p) => typeof p === 'string' && p.trim().length > 0),
  };

  next();
};

const validateUpdateListing = (req, res, next) => {
  const { title, description, category, price, condition, photoRefs } = req.body;
  const updates = {};

  if (title !== undefined) {
    if (typeof title !== 'string' || title.trim().length < 3) {
      return next(new BadRequestError('Title must be at least 3 characters'));
    }
    updates.title = title.trim();
  }

  if (description !== undefined) {
    if (typeof description !== 'string' || description.trim().length < 5) {
      return next(new BadRequestError('Description must be at least 5 characters'));
    }
    updates.description = description.trim();
  }

  if (category !== undefined) {
    if (!CATEGORIES.includes(category)) {
      return next(new BadRequestError(`Category must be one of: ${CATEGORIES.join(', ')}`));
    }
    updates.category = category;
  }

  if (price !== undefined) {
    if (isNaN(Number(price)) || Number(price) < 0) {
      return next(new BadRequestError('Price must be a non-negative number'));
    }
    updates.price = Number(price);
  }

  if (condition !== undefined) {
    if (!CONDITIONS.includes(condition)) {
      return next(new BadRequestError(`Condition must be one of: ${CONDITIONS.join(', ')}`));
    }
    updates.condition = condition;
  }

  if (photoRefs !== undefined) {
    if (!Array.isArray(photoRefs) || photoRefs.length === 0) {
      return next(new BadRequestError('Listing must retain at least one photo'));
    }
    updates.photoRefs = photoRefs.filter((p) => typeof p === 'string' && p.trim().length > 0);
  }

  // Prevent arbitrary client manipulation of status, collegeId, sellerId
  delete req.body.status;
  delete req.body.collegeId;
  delete req.body.sellerId;
  delete req.body.listingId;

  req.validatedUpdates = updates;
  next();
};

const validateCloseListing = (req, res, next) => {
  const { finalStatus, closedReason } = req.body;
  if (!finalStatus || ![LISTING_STATUS.SOLD, LISTING_STATUS.CLOSED].includes(finalStatus)) {
    return next(new BadRequestError('finalStatus must be either "sold" or "closed"'));
  }

  req.validatedClosure = {
    finalStatus,
    closedReason: closedReason || (finalStatus === LISTING_STATUS.SOLD ? 'sold' : 'closed'),
  };
  next();
};

module.exports = {
  validateCreateListing,
  validateUpdateListing,
  validateCloseListing,
};
