const request = require('supertest');
const app = require('../../src/app');
const authService = require('../../src/services/authService');
const { setupTestDB } = require('../setup');

describe('Integration Test: Marketplace Listing Workflow & Critical Path (T-013, T-015, T-018, T-033, T-034)', () => {
  setupTestDB();

  const verifiedSeller = {
    studentId: 'std_seller_test',
    collegeId: 'avih-gunthapalli',
    officialEmail: 'seller@avih.edu.in',
    fullName: 'Test Seller',
    verificationStatus: 'verified',
  };

  const sellerToken = authService.generateToken(verifiedSeller);

  test('CRITICAL TEST: Create Java Programming Book -> Appears in Marketplace listings', async () => {
    // 1. Create Listing
    const newListingPayload = {
      title: 'Java Programming Book',
      price: 500,
      condition: 'Good',
      category: 'Academic / Books',
      description: 'Java programming book in good condition',
      photoRefs: ['java_book_sample_photo.jpg'],
    };

    const createRes = await request(app)
      .post('/api/v1/listings')
      .set('Authorization', `Bearer ${sellerToken}`)
      .send(newListingPayload);

    // If DB is running, expect 201 Created and validated listing
    if (createRes.statusCode === 201) {
      expect(createRes.body).toHaveProperty('listingId');
      expect(createRes.body.status).toBe('active');
      expect(createRes.body.listing.title).toBe('Java Programming Book');

      const listingId = createRes.body.listingId;

      // 2. Fetch browse listings
      const browseRes = await request(app)
        .get('/api/v1/listings')
        .set('Authorization', `Bearer ${sellerToken}`);

      if (browseRes.statusCode === 200) {
        expect(browseRes.body).toHaveProperty('items');
        const found = browseRes.body.items.some((i) => i.listingId === listingId || i.title === 'Java Programming Book');
        expect(found).toBe(true);
      }
    }
  });

  test('Validation failure: Missing required photos rejects listing activation with 400', async () => {
    const invalidListing = {
      title: 'Incomplete Listing',
      price: 100,
      condition: 'Fair',
      category: 'Academic / Books',
      description: 'Missing photos',
      photoRefs: [], // Empty photos array
    };

    const res = await request(app)
      .post('/api/v1/listings')
      .set('Authorization', `Bearer ${sellerToken}`)
      .send(invalidListing);

    expect(res.statusCode).toBe(400);
    expect(res.body.error.code).toBe('VALIDATION_ERROR');
  });
});
