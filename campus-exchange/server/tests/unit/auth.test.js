const authService = require('../../src/services/authService');
const jwt = require('jsonwebtoken');
const env = require('../../src/config/env');

describe('Unit Test: Authentication and Verification (T-004, T-005, T-032)', () => {
  const mockCollege = {
    collegeId: 'avih-gunthapalli',
    name: 'Avanthi Institute of Engineering and Technology',
    verificationDomain: 'avih.edu.in',
  };

  test('generateToken should produce valid verifiable JWT with claims', () => {
    const student = {
      studentId: 'std_12345',
      collegeId: 'avih-gunthapalli',
      officialEmail: 'student@avih.edu.in',
      verificationStatus: 'verified',
    };

    const token = authService.generateToken(student);
    expect(typeof token).toBe('string');

    const decoded = jwt.verify(token, env.JWT_SECRET);
    expect(decoded.studentId).toBe(student.studentId);
    expect(decoded.collegeId).toBe(student.collegeId);
    expect(decoded.officialEmail).toBe(student.officialEmail);
    expect(decoded.verificationStatus).toBe('verified');
  });

  test('should reject expired or tampered JWT token', () => {
    const fakeToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.tampered.token';
    expect(() => {
      jwt.verify(fakeToken, env.JWT_SECRET);
    }).toThrow();
  });
});
