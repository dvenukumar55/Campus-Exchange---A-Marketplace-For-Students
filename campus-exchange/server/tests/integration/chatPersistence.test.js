const request = require('supertest');
const app = require('../../src/app');
const authService = require('../../src/services/authService');
const { setupTestDB } = require('../setup');

describe('Integration Test: Chat and Conversation Persistence (T-023, T-024, T-033)', () => {
  setupTestDB();

  const verifiedBuyer = {
    studentId: 'std_buyer_test',
    collegeId: 'avih-gunthapalli',
    officialEmail: 'buyer@avih.edu.in',
    fullName: 'Test Buyer',
    verificationStatus: 'verified',
  };

  const buyerToken = authService.generateToken(verifiedBuyer);

  test('Send chat message validation: Rejects empty or oversized messages', async () => {
    const emptyMsgRes = await request(app)
      .post('/api/v1/listings/list_sample/chat')
      .set('Authorization', `Bearer ${buyerToken}`)
      .send({ message: '' });

    expect(emptyMsgRes.statusCode).toBe(400);

    const oversizedMsg = 'A'.repeat(1005);
    const oversizedRes = await request(app)
      .post('/api/v1/listings/list_sample/chat')
      .set('Authorization', `Bearer ${buyerToken}`)
      .send({ message: oversizedMsg });

    expect(oversizedRes.statusCode).toBe(400);
  });
});
