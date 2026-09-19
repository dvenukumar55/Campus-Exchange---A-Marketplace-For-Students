const listingService = require('../services/listingService');
const { sendSuccess } = require('../utils/response');
const cloudinary = require('../config/cloudinary');

class ListingController {
  /**
   * POST /api/v1/listings
   * Creates a listing for an eligible academic/hostel item
   */
  async create(req, res, next) {
    try {
      const listing = await listingService.createListing({
        student: req.student,
        listingData: req.validatedListing,
      });

      return sendSuccess(res, 201, {
        listingId: listing.listingId,
        status: listing.status,
        createdAt: listing.createdAt,
        listing,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/v1/listings
   * Browses active listings in authenticated student's college
   */
  async getListings(req, res, next) {
    try {
      const { category, condition, search, page, limit, sort } = req.query;
      const result = await listingService.getListings({
        collegeId: req.student.collegeId,
        category,
        condition,
        search,
        page,
        limit,
        sort,
      });

      return sendSuccess(res, 200, { items: result.items }, result.pagination);
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/v1/listings/my
   * Retrieves listings created by current student
   */
  async getMyListings(req, res, next) {
    try {
      const listings = await listingService.getMyListings({
        studentId: req.student.studentId,
        collegeId: req.student.collegeId,
      });

      return sendSuccess(res, 200, { items: listings });
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/v1/listings/:listingId
   * Retrieves a single listing
   */
  async getListingById(req, res, next) {
    try {
      const { listingId } = req.params;
      const listing = await listingService.getListingById({
        listingId,
        collegeId: req.student.collegeId,
        studentId: req.student.studentId,
      });

      return sendSuccess(res, 200, { listing });
    } catch (error) {
      next(error);
    }
  }

  /**
   * PATCH /api/v1/listings/:listingId
   * Updates permitted details before closure
   */
  async updateListing(req, res, next) {
    try {
      const { listingId } = req.params;
      const updatedListing = await listingService.updateListing({
        listingId,
        student: req.student,
        updates: req.validatedUpdates,
      });

      return sendSuccess(res, 200, { listing: updatedListing });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/v1/listings/:listingId/close
   * Closes or marks a listing as sold
   */
  async closeListing(req, res, next) {
    try {
      const { listingId } = req.params;
      const result = await listingService.closeListing({
        listingId,
        student: req.student,
        finalStatus: req.validatedClosure.finalStatus,
        closedReason: req.validatedClosure.closedReason,
      });

      return sendSuccess(res, 200, {
        listingId: result.listing.listingId,
        status: result.listing.status,
        closedAt: result.listing.closedAt,
        saleEventId: result.saleEventId,
        listing: result.listing,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/v1/listings/upload-image
   * Handles photo upload for listing creation
   */
  // async uploadImage(req, res, next) {
  //   try {
  //     if (!req.file) {
  //       return res.status(400).json({
  //         error: {
  //           code: 'UPLOAD_FAILED',
  //           message: 'No image file uploaded in request',
  //         },
  //       });
  //     }

  //     const photoRef = req.file.filename;
  //     return sendSuccess(res, 201, {
  //       photoRef,
  //       url: `/uploads/${photoRef}`,
  //       size: req.file.size,
  //       mimetype: req.file.mimetype,
  //     });
  //   } catch (error) {
  //     next(error);
  //   }
  // }

  async uploadImage(req, res, next) {
    try {
      if (!req.file) {
        return res.status(400).json({
          error: {
            code: 'UPLOAD_FAILED',
            message: 'No image file uploaded in request',
          },
        });
      }

      const result = await new Promise((resolve, reject) => {
        const stream = cloudinary.uploader.upload_stream(
          {
            folder: 'campus-exchange/listings',
            resource_type: 'image',
          },
          (error, result) => {
            if (error) {
              reject(error);
            } else {
              resolve(result);
            }
          }
        );

        stream.end(req.file.buffer);
      });

      const photoRef = result.secure_url;

      return sendSuccess(res, 201, {
        photoRef,
        url: result.secure_url,
        size: req.file.size,
        mimetype: req.file.mimetype,
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new ListingController();
