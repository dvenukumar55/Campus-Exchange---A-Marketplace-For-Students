const authService = require('../../src/services/authService');
const otpService = require('../../src/services/otpService');
const jwt = require('jsonwebtoken');
const env = require('../../src/config/env');

describe('Unit Test: Authentication and Verification (T-004, T-005, T-032)', () => {
  test('generateToken should produce valid verifiable JWT with claims and sessionId', () => {
    const student = {
      studentId: 'std_12345',
      collegeId: 'avih-gunthapalli',
      officialEmail: 'student@avih.edu.in',
      rollNumber: '23Q61A0501',
      verificationStatus: 'verified',
      role: 'student',
    };
    const sessionId = 'sess_test123456';

    const token = authService.generateToken(student, sessionId);
    expect(typeof token).toBe('string');

    const decoded = jwt.verify(token, env.JWT_SECRET);
    expect(decoded.studentId).toBe(student.studentId);
    expect(decoded.collegeId).toBe(student.collegeId);
    expect(decoded.officialEmail).toBe(student.officialEmail);
    expect(decoded.verificationStatus).toBe('verified');
    expect(decoded.sessionId).toBe(sessionId);
  });

  test('should reject expired or tampered JWT token', () => {
    const fakeToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.tampered.token';
    expect(() => {
      jwt.verify(fakeToken, env.JWT_SECRET);
    }).toThrow();
  });

  test('otpService generates 6-digit numeric OTP and SHA-256 hash', () => {
    const otp = otpService.generateOtp();
    expect(typeof otp).toBe('string');
    expect(otp.length).toBe(6);
    expect(/^\d{6}$/.test(otp)).toBe(true);

    const hash = otpService.hashOtp(otp);
    expect(typeof hash).toBe('string');
    expect(hash.length).toBe(64); // SHA-256 hex string is 64 chars
  });

  test('otpService verification token generation and validation', () => {
    const email = 'student@avih.edu.in';
    const token = otpService.generateVerificationToken(email);
    expect(typeof token).toBe('string');

    const isValid = otpService.validateVerificationToken(token, email);
    expect(isValid).toBe(true);

    // Mismatched email should throw
    expect(() => {
      otpService.validateVerificationToken(token, 'other@avih.edu.in');
    }).toThrow();
  });
});
