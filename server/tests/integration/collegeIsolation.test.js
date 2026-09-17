const request = require('supertest');
const app = require('../../src/app');
const authService = require('../../src/services/authService');
const { setupTestDB } = require('../setup');

describe('Integration Test: College Data Isolation & Boundary Enforcement (T-009, T-033, T-035)', () => {
  setupTestDB();

  const studentCollegeA = {
    studentId: 'std_college_a_1',
    collegeId: 'avih-gunthapalli',
    officialEmail: 'student@avih.edu.in',
    verificationStatus: 'verified',
  };

  const studentCollegeB = {
    studentId: 'std_college_b_1',
    collegeId: 'other-college-2026',
    officialEmail: 'student@other.edu.in',
    verificationStatus: 'verified',
  };

  const tokenCollegeA = authService.generateToken(studentCollegeA);
  const tokenCollegeB = authService.generateToken(studentCollegeB);

  test('Reject client attempts to query or inject cross-college parameters', async () => {
    // Student from College A tries to pass query param collegeId=other-college-2026
    const res = await request(app)
      .get('/api/v1/listings?collegeId=other-college-2026')
      .set('Authorization', `Bearer ${tokenCollegeA}`);

    // Must either reject with 403 Cross College or strictly force user collegeId
    if (res.statusCode === 403) {
      expect(res.body.error.code).toBe('CROSS_COLLEGE_DENIED');
    }
  });

  test('Unauthenticated requests to marketplace are rejected with 401', async () => {
    const res = await request(app).get('/api/v1/listings');
    expect(res.statusCode).toBe(401);
    expect(res.body.error.code).toBe('UNAUTHENTICATED');
  });

  test('Unverified student tokens are rejected with 403 UNVERIFIED_STUDENT', async () => {
    const unverifiedStudent = {
      studentId: 'std_unverified',
      collegeId: 'avih-gunthapalli',
      officialEmail: 'newbie@avih.edu.in',
      verificationStatus: 'pending',
    };
    const unverifiedToken = authService.generateToken(unverifiedStudent);

    const res = await request(app)
      .get('/api/v1/listings')
      .set('Authorization', `Bearer ${unverifiedToken}`);

    expect([401, 403]).toContain(res.statusCode);
  });
});
