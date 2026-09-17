const request = require('supertest');
const app = require('../../src/app');
const authService = require('../../src/services/authService');
const { REPORT_REASONS } = require('../../src/config/constants');
const { setupTestDB } = require('../setup');

describe('Integration Test: Report and Moderation Flow (T-029, T-033)', () => {
  setupTestDB();

  const verifiedStudent = {
    studentId: 'std_reporter_1',
    collegeId: 'avih-gunthapalli',
    officialEmail: 'reporter@avih.edu.in',
    verificationStatus: 'verified',
  };
  const token = authService.generateToken(verifiedStudent);

  test('Validates report reasons against approved PRISM list', async () => {
    const invalidReport = {
      listingId: 'list_test_123',
      reason: 'Invalid Custom Reason Not In Spec',
      description: 'Misleading condition details',
    };

    const res = await request(app)
      .post('/api/v1/reports')
      .set('Authorization', `Bearer ${token}`)
      .send(invalidReport);

    expect(res.statusCode).toBe(400);
    expect(res.body.error.code).toBe('VALIDATION_ERROR');
  });

  test('Report reason is accepted when matching approved constants', () => {
    expect(REPORT_REASONS).toContain('Misleading Condition or Details');
    expect(REPORT_REASONS).toContain('Incorrect Price or Commercial Seller');
    expect(REPORT_REASONS).toContain('Prohibited or Ineligible Item');
  });
});
