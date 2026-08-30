const request = require('supertest');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const app = require('../../src/app');
const Student = require('../../src/models/Student');
const College = require('../../src/models/College');
const Otp = require('../../src/models/Otp');
const Session = require('../../src/models/Session');
const otpService = require('../../src/services/otpService');

let mongoServer;

beforeAll(async () => {
  mongoServer = await MongoMemoryServer.create();
  const uri = mongoServer.getUri();
  await mongoose.connect(uri);

  // Setup pilot college
  await College.create({
    collegeId: 'avih-gunthapalli',
    name: 'Avanthi Institute of Engineering and Technology (AVIH), Gunthapalli',
    verificationDomain: 'avih.edu.in',
    status: 'active',
  });
}, 120000);

afterAll(async () => {
  if (mongoose.connection.readyState !== 0) {
    await mongoose.disconnect();
  }
  if (mongoServer) {
    await mongoServer.stop();
  }
}, 30000);


beforeEach(async () => {
  await Student.deleteMany({});
  await Otp.deleteMany({});
  await Session.deleteMany({});
});

describe('Security & Authentication Flow Integration Tests', () => {
  const testEmail = 'student1@avih.edu.in';
  const testRoll = '23Q61A0501';

  test('Step 1: Request OTP sends 6-digit OTP and creates secure hash in DB', async () => {
    const res = await request(app)
      .post('/api/v1/auth/request-otp')
      .send({ officialEmail: testEmail })
      .expect(200);

    expect(res.body.success).toBe(true);
    expect(res.body.message).toContain('Verification code sent');
    // Ensure raw OTP is NOT leaked in API response
    expect(res.body.otp).toBeUndefined();

    // Verify record in MongoDB is hashed
    const otpDoc = await Otp.findOne({ email: testEmail });
    expect(otpDoc).toBeTruthy();
    expect(otpDoc.otpHash).toBeTruthy();
    expect(otpDoc.attempts).toBe(0);
    expect(otpDoc.verified).toBe(false);
  });

  test('Step 1b: Dynamic recipient handling with multiple different student emails', async () => {
    const studentA = 'dvenukumar23@gmail.com';
    const studentB = 'student.beta.2026@gmail.com';

    // Request OTP for student A
    const resA = await request(app)
      .post('/api/v1/auth/request-otp')
      .send({ officialEmail: studentA })
      .expect(200);
    expect(resA.body.success).toBe(true);

    const docA = await Otp.findOne({ email: studentA });
    expect(docA).toBeTruthy();
    expect(docA.email).toBe(studentA);

    // Request OTP for student B
    const resB = await request(app)
      .post('/api/v1/auth/request-otp')
      .send({ officialEmail: studentB })
      .expect(200);
    expect(resB.body.success).toBe(true);

    const docB = await Otp.findOne({ email: studentB });
    expect(docB).toBeTruthy();
    expect(docB.email).toBe(studentB);

    // Ensure they are independent records
    expect(docA.email).not.toBe(docB.email);
  });

  test('Step 1c: Reject invalid email format on request-otp', async () => {
    const res = await request(app)
      .post('/api/v1/auth/request-otp')
      .send({ officialEmail: 'not-an-email' })
      .expect(400);

    expect(res.body.error).toBeTruthy();
    expect(res.body.error.message).toContain('Please provide a valid institutional email address.');
  });


  test('Step 2: Reject invalid OTP and track attempts', async () => {
    // Generate valid OTP
    const rawOtp = '654321';
    const otpHash = otpService.hashOtp(rawOtp);
    await Otp.create({
      email: testEmail,
      otpHash,
      attempts: 0,
      verified: false,
      expiresAt: new Date(Date.now() + 5 * 60 * 1000),
    });

    // Send wrong OTP
    const res = await request(app)
      .post('/api/v1/auth/verify-otp')
      .send({ officialEmail: testEmail, otp: '111111' })
      .expect(400);

    expect(res.body.error).toBeTruthy();
    expect(res.body.error.message).toContain('Invalid verification code');

    const updatedOtp = await Otp.findOne({ email: testEmail });
    expect(updatedOtp.attempts).toBe(1);
  });

  test('Step 2: Successful OTP verification returns verification token', async () => {
    const rawOtp = '789123';
    const otpHash = otpService.hashOtp(rawOtp);
    await Otp.create({
      email: testEmail,
      otpHash,
      attempts: 0,
      verified: false,
      expiresAt: new Date(Date.now() + 5 * 60 * 1000),
    });

    const res = await request(app)
      .post('/api/v1/auth/verify-otp')
      .send({ officialEmail: testEmail, otp: rawOtp })
      .expect(200);

    expect(res.body.success).toBe(true);
    expect(res.body.verified).toBe(true);
    expect(typeof res.body.verificationToken).toBe('string');
  });

  test('Step 3: Direct roll-number registration without OTP token is rejected', async () => {
    const res = await request(app)
      .post('/api/v1/auth/complete-registration')
      .send({
        officialEmail: testEmail,
        rollNumber: testRoll,
        verificationToken: '',
      })
      .expect(400);

    expect(res.body.error).toBeTruthy();
    expect(res.body.error.message).toContain('Verification token is required');
  });

  test('Step 3: Registration with valid verification token creates Student and active Session', async () => {
    const verificationToken = otpService.generateVerificationToken(testEmail);

    const res = await request(app)
      .post('/api/v1/auth/complete-registration')
      .send({
        officialEmail: testEmail,
        rollNumber: testRoll,
        verificationToken,
        deviceId: 'device_phone_a',
      })
      .expect(200);

    expect(res.body.success).toBe(true);
    expect(res.body.token).toBeTruthy();
    expect(res.body.sessionId).toBeTruthy();
    expect(res.body.student.officialEmail).toBe(testEmail);
    expect(res.body.student.rollNumber).toBe(testRoll);

    // Verify session exists in DB
    const session = await Session.findOne({ sessionId: res.body.sessionId });
    expect(session).toBeTruthy();
    expect(session.active).toBe(true);
    expect(session.deviceId).toBe('device_phone_a');
  });

  test('Email + Roll Number validation: Case 2 (Email exists under different roll number)', async () => {
    // Create initial student
    await Student.create({
      studentId: 'std_test_01',
      collegeId: 'avih-gunthapalli',
      officialEmail: testEmail,
      rollNumber: testRoll,
      verificationStatus: 'verified',
      accountStatus: 'active',
    });

    const verificationToken = otpService.generateVerificationToken(testEmail);

    const res = await request(app)
      .post('/api/v1/auth/complete-registration')
      .send({
        officialEmail: testEmail,
        rollNumber: '23Q61A9999', // Different roll number
        verificationToken,
        deviceId: 'device_test',
      })
      .expect(400);

    expect(res.body.error.message).toBe('The email and roll number do not match.');
  });

  test('Email + Roll Number validation: Case 3 (Roll number belongs to another account)', async () => {
    await Student.create({
      studentId: 'std_test_02',
      collegeId: 'avih-gunthapalli',
      officialEmail: 'existing@avih.edu.in',
      rollNumber: testRoll,
      verificationStatus: 'verified',
      accountStatus: 'active',
    });

    const otherEmail = 'impostor@avih.edu.in';
    const verificationToken = otpService.generateVerificationToken(otherEmail);

    const res = await request(app)
      .post('/api/v1/auth/complete-registration')
      .send({
        officialEmail: otherEmail,
        rollNumber: testRoll,
        verificationToken,
        deviceId: 'device_test',
      })
      .expect(400);

    expect(res.body.error.message).toBe('This roll number is already associated with another account.');
  });

  test('Single Active Session: Phone A logs in -> Phone B is rejected with 409 Conflict', async () => {
    // First: Create student account on Phone A
    const tokenA = otpService.generateVerificationToken(testEmail);
    const resA = await request(app)
      .post('/api/v1/auth/complete-registration')
      .send({
        officialEmail: testEmail,
        rollNumber: testRoll,
        verificationToken: tokenA,
        deviceId: 'device_phone_a',
      })
      .expect(200);

    const jwtA = resA.body.token;
    expect(jwtA).toBeTruthy();

    // Now Phone B tries to log in with same account
    const tokenB = otpService.generateVerificationToken(testEmail);
    const resB = await request(app)
      .post('/api/v1/auth/complete-registration')
      .send({
        officialEmail: testEmail,
        rollNumber: testRoll,
        verificationToken: tokenB,
        deviceId: 'device_phone_b',
      })
      .expect(409);

    expect(resB.body.error).toBeTruthy();
    expect(resB.body.error.message).toBe(
      'This account is already signed in on another device. Please sign out from that device before signing in here.'
    );

    // Verify Phone A session remains active and can access protected endpoint
    const meResA = await request(app)
      .get('/api/v1/auth/me')
      .set('Authorization', `Bearer ${jwtA}`)
      .expect(200);

    expect(meResA.body.student.officialEmail).toBe(testEmail);

    // Phone A logs out
    const logoutRes = await request(app)
      .post('/api/v1/auth/logout')
      .set('Authorization', `Bearer ${jwtA}`)
      .expect(200);

    expect(logoutRes.body.success).toBe(true);

    // Phone A session is now revoked: accessing protected endpoint returns 401
    await request(app)
      .get('/api/v1/auth/me')
      .set('Authorization', `Bearer ${jwtA}`)
      .expect(401);

    // Now Phone B tries to log in again: should succeed!
    const tokenB2 = otpService.generateVerificationToken(testEmail);
    const resB2 = await request(app)
      .post('/api/v1/auth/complete-registration')
      .send({
        officialEmail: testEmail,
        rollNumber: testRoll,
        verificationToken: tokenB2,
        deviceId: 'device_phone_b',
      })
      .expect(200);

    expect(resB2.body.success).toBe(true);
    expect(resB2.body.token).toBeTruthy();

    // Phone B can now access protected endpoints
    await request(app)
      .get('/api/v1/auth/me')
      .set('Authorization', `Bearer ${resB2.body.token}`)
      .expect(200);
  });
});
