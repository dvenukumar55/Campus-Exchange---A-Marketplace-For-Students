const { v4: uuidv4 } = require('uuid');
const Listing = require('../models/Listing');
const { LISTING_STATUS, PILOT_EVENT_TYPES } = require('../config/constants');
const {
  BadRequestError,
  NotFoundError,
  ForbiddenError,
  CrossCollegeError,
  ConflictError,
} = require('../utils/errors');
const storageService = require('./storageService');
const eventService = require('./eventService');

class ListingService {
  /**
   * Creates an active listing with strict server-side derivation of collegeId and sellerId
   */
  async createListing({ student, listingData }) {
    // Validate photo references
    storageService.validatePhotoReferences(listingData.photoRefs);

    const listingId = `list_${uuidv4().substring(0, 10)}`;

    const listing = new Listing({
      listingId,
      collegeId: student.collegeId,
      sellerId: student.studentId,
      sellerName: student.fullName || 'Verified Student',
      sellerEmail: student.officialEmail,
      title: listingData.title,
      description: listingData.description,
      category: listingData.category,
      price: listingData.price,
      condition: listingData.condition,
      photoRefs: listingData.photoRefs,
      status: LISTING_STATUS.ACTIVE,
      viewCount: 0,
      chatCount: 0,
    });

    await listing.save();

    // Record pilot event
    await eventService.recordEvent({
      eventType: PILOT_EVENT_TYPES.LISTING_CREATED,
      collegeId: student.collegeId,
      studentId: student.studentId,
      listingId: listing.listingId,
      metadata: {
        category: listing.category,
        price: listing.price,
        condition: listing.condition,
      },
    });

    return listing;
  }

  /**
   * Browses active listings strictly filtered by authenticated student's college
   */
  async getListings({ collegeId, category, condition, search, page = 1, limit = 20, sort = 'newest' }) {
    const query = {
      collegeId,
      status: LISTING_STATUS.ACTIVE,
    };

    if (category && category !== 'All') {
      query.category = category;
    }

    if (condition && condition !== 'All') {
      query.condition = condition;
    }

    if (search && search.trim().length > 0) {
      const searchRegex = new RegExp(search.trim(), 'i');
      query.$or = [{ title: searchRegex }, { description: searchRegex }];
    }

    const pageNum = Math.max(1, parseInt(page, 10));
    const limitNum = Math.min(50, Math.max(1, parseInt(limit, 10)));
    const skip = (pageNum - 1) * limitNum;

    let sortOptions = { createdAt: -1 };
    if (sort === 'price_asc') {
      sortOptions = { price: 1, createdAt: -1 };
    } else if (sort === 'price_desc') {
      sortOptions = { price: -1, createdAt: -1 };
    }

    const [items, total] = await Promise.all([
      Listing.find(query).sort(sortOptions).skip(skip).limit(limitNum).lean(),
      Listing.countDocuments(query),
    ]);

    return {
      items,
      pagination: {
        total,
        page: pageNum,
        limit: limitNum,
        totalPages: Math.ceil(total / limitNum),
        hasMore: skip + items.length < total,
      },
    };
  }

  /**
   * Retrieves single listing with college isolation check
   */
  async getListingById({ listingId, collegeId, studentId }) {
    const listing = await Listing.findOne({ listingId });

    if (!listing) {
      throw new NotFoundError('The requested listing could not be found.');
    }

    // Strict cross-college protection
    if (listing.collegeId !== collegeId) {
      throw new CrossCollegeError('Access to listings from other colleges is denied.');
    }

    // Increment view count if viewed by non-seller
    if (studentId && listing.sellerId !== studentId) {
      await Listing.updateOne({ listingId }, { $inc: { viewCount: 1 } });
      listing.viewCount += 1;
    }

    return listing;
  }

  /**
   * Retrieves listings created by the authenticated student
   */
  async getMyListings({ studentId, collegeId }) {
    return Listing.find({
      sellerId: studentId,
      collegeId,
    })
      .sort({ createdAt: -1 })
      .lean();
  }

  /**
   * Updates listing permitted fields before closure
   */
  async updateListing({ listingId, student, updates }) {
    const listing = await Listing.findOne({ listingId });

    if (!listing) {
      throw new NotFoundError('The requested listing could not be found.');
    }

    if (listing.collegeId !== student.collegeId) {
      throw new CrossCollegeError();
    }

    if (listing.sellerId !== student.studentId) {
      throw new ForbiddenError('Only the verified seller who created this listing can modify it.');
    }

    if (listing.status !== LISTING_STATUS.ACTIVE) {
      throw new ConflictError(
        `Cannot edit listing in '${listing.status}' state. Only active listings can be modified.`
      );
    }

    if (updates.photoRefs) {
      storageService.validatePhotoReferences(updates.photoRefs);
    }

    Object.assign(listing, updates);
    await listing.save();

    // Record pilot update event
    await eventService.recordEvent({
      eventType: PILOT_EVENT_TYPES.LISTING_UPDATED,
      collegeId: student.collegeId,
      studentId: student.studentId,
      listingId: listing.listingId,
    });

    return listing;
  }

  /**
   * Atomically transitions listing from ACTIVE to SOLD or CLOSED
   * Enforces duplicate closure prevention and idempotent sale event generation
   */
  async closeListing({ listingId, student, finalStatus, closedReason }) {
    const listing = await Listing.findOne({ listingId });

    if (!listing) {
      throw new NotFoundError('The requested listing could not be found.');
    }

    if (listing.collegeId !== student.collegeId) {
      throw new CrossCollegeError();
    }

    if (listing.sellerId !== student.studentId) {
      throw new ForbiddenError('Only the seller can close this listing.');
    }

    // Check current status: reject conflict if already closed/sold
    if (listing.status === LISTING_STATUS.SOLD || listing.status === LISTING_STATUS.CLOSED) {
      throw new ConflictError(
        `Listing is already ${listing.status}. Repeated close requests cannot mutate state or generate duplicate events.`
      );
    }

    const now = new Date();
    const targetStatus = finalStatus === 'sold' ? LISTING_STATUS.SOLD : LISTING_STATUS.CLOSED;

    // Atomic update
    const updatedListing = await Listing.findOneAndUpdate(
      {
        listingId,
        sellerId: student.studentId,
        collegeId: student.collegeId,
        status: LISTING_STATUS.ACTIVE,
      },
      {
        $set: {
          status: targetStatus,
          closedAt: now,
          closedReason: closedReason || (targetStatus === LISTING_STATUS.SOLD ? 'sold' : 'closed'),
        },
      },
      { new: true }
    );

    if (!updatedListing) {
      throw new ConflictError('Concurrent state change detected or listing is no longer active.');
    }

    // Record single pilot closure/sale event
    const eventType =
      targetStatus === LISTING_STATUS.SOLD
        ? PILOT_EVENT_TYPES.LISTING_CLOSED_SOLD
        : PILOT_EVENT_TYPES.LISTING_CLOSED_CANCELLED;

    const eventResult = await eventService.recordEvent({
      eventType,
      collegeId: student.collegeId,
      studentId: student.studentId,
      listingId: updatedListing.listingId,
      metadata: {
        price: updatedListing.price,
        category: updatedListing.category,
        closedReason: updatedListing.closedReason,
      },
    });

    return {
      listing: updatedListing,
      saleEventId: eventResult.eventId,
    };
  }
}

module.exports = new ListingService();
