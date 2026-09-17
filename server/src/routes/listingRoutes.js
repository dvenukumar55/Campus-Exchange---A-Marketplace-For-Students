const express = require('express');
const router = express.Router();
const listingController = require('../controllers/listingController');
const { authenticate, requireVerified } = require('../middleware/auth');
const { enforceCollegeContext } = require('../middleware/collegeContext');
const {
  validateCreateListing,
  validateUpdateListing,
  validateCloseListing,
} = require('../validators/listingValidators');
const upload = require('../middleware/upload');
const { uploadLimiter } = require('../middleware/rateLimiter');

// All marketplace listing operations require authenticated, verified student in same college
router.use(authenticate, requireVerified, enforceCollegeContext);

// GET /api/v1/listings - Browse active listings for authenticated student's college
router.get('/', listingController.getListings);

// GET /api/v1/listings/my - Current student's listings
router.get('/my', listingController.getMyListings);

// POST /api/v1/listings - Create listing for eligible academic/hostel item
router.post('/', validateCreateListing, listingController.create);

// POST /api/v1/listings/upload-image - Upload listing photo
router.post('/upload-image', uploadLimiter, upload.single('photo'), listingController.uploadImage);

// GET /api/v1/listings/:listingId - View single listing
router.get('/:listingId', listingController.getListingById);

// PATCH /api/v1/listings/:listingId - Update permitted details before closure
router.patch('/:listingId', validateUpdateListing, listingController.updateListing);

// POST /api/v1/listings/:listingId/close - Atomically close/sell listing
router.post('/:listingId/close', validateCloseListing, listingController.closeListing);

module.exports = router;
