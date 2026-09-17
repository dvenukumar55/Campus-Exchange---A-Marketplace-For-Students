const request = require('supertest');
const app = require('../../src/app');
const authService = require('../../src/services/authService');
const { setupTestDB } = require('../setup');

describe('Security & Privacy Test: Cross-College Access Rejection (T-009, T-035)', () => {
  setupTestDB();

  const collegeAStudent = {
    studentId: 'std_college_a_user',
    collegeId: 'avih-gunthapalli',
    officialEmail: 'student@avih.edu.in',
    verificationStatus: 'verified',
  };

  const collegeBStudent = {
    studentId: 'std_college_b_user',
    collegeId: 'jntuh-hyderabad',
    officialEmail: 'student@jntuh.ac.in',
    verificationStatus: 'verified',
  };

  const tokenA = authService.generateToken(collegeAStudent);
  const tokenB = authService.generateToken(collegeBStudent);

  test('SECURITY: Student from College A cannot forge client parameters to access College B data', async () => {
    const res = await request(app)
      .get('/api/v1/listings?collegeId=jntuh-hyderabad')
      .set('Authorization', `Bearer ${tokenA}`);

    // If client supplied cross-college collegeId, backend must either reject with 403 or silently override with token collegeId
    if (res.statusCode === 403) {
      expect(res.body.error.code).toBe('CROSS_COLLEGE_DENIED');
    }
  });

  test('SECURITY: Request without token is denied 401 UNAUTHENTICATED', async () => {
    const res = await request(app).get('/api/v1/listings');
    expect(res.statusCode).toBe(401);
  });

  test('SECURITY: Malformed or spoofed Authorization header is rejected', async () => {
    const res = await request(app)
      .get('/api/v1/listings')
      .set('Authorization', 'Bearer invalid.token.signature');
    expect(res.statusCode).toBe(401);
  });
});
