const request = require('supertest');
const { app } = require('../../src/server');
const Student = require('../../src/models/Student');
const Session = require('../../src/models/Session');
const Notification = require('../../src/models/Notification');
const authService = require('../../src/services/authService');
const notificationService = require('../../src/services/notificationService');
const { setupTestDB } = require('../setup');
const { VERIFICATION_STATUS, ACCOUNT_STATUS } = require('../../src/config/constants');
const { v4: uuidv4 } = require('uuid');

describe('Integration Test: New Listing Notifications & College Isolation', () => {
  setupTestDB();

  let studentA, studentB, studentC;
  let tokenA, tokenB, tokenC;

  beforeEach(async () => {
    // Student A (College 1 - AVIH)
    studentA = await Student.create({
      studentId: 'std_user_a',
      collegeId: 'avih-gunthapalli',
      officialEmail: 'student_a@avih.edu.in',
      fullName: 'Student A',
      verificationStatus: VERIFICATION_STATUS.VERIFIED,
      accountStatus: ACCOUNT_STATUS.ACTIVE,
      rollNumber: '23Q61A0501',
    });
    const sessionAId = uuidv4();
    await Session.create({
      sessionId: sessionAId,
      studentId: studentA.studentId,
      collegeId: studentA.collegeId,
      deviceId: uuidv4(),
      active: true,
      expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000),
    });
    tokenA = authService.generateToken(studentA, sessionAId);

    // Student B (College 1 - AVIH)
    studentB = await Student.create({
      studentId: 'std_user_b',
      collegeId: 'avih-gunthapalli',
      officialEmail: 'student_b@avih.edu.in',
      fullName: 'Student B',
      verificationStatus: VERIFICATION_STATUS.VERIFIED,
      accountStatus: ACCOUNT_STATUS.ACTIVE,
      rollNumber: '23Q61A0502',
    });
    const sessionBId = uuidv4();
    await Session.create({
      sessionId: sessionBId,
      studentId: studentB.studentId,
      collegeId: studentB.collegeId,
      deviceId: uuidv4(),
      active: true,
      expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000),
    });
    tokenB = authService.generateToken(studentB, sessionBId);

    // Student C (College 2 - OTHER)
    studentC = await Student.create({
      studentId: 'std_user_c',
      collegeId: 'cbit-hyderabad',
      officialEmail: 'student_c@cbit.edu.in',
      fullName: 'Student C',
      verificationStatus: VERIFICATION_STATUS.VERIFIED,
      accountStatus: ACCOUNT_STATUS.ACTIVE,
      rollNumber: '160120733001',
    });
    const sessionCId = uuidv4();
    await Session.create({
      sessionId: sessionCId,
      studentId: studentC.studentId,
      collegeId: studentC.collegeId,
      deviceId: uuidv4(),
      active: true,
      expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000),
    });
    tokenC = authService.generateToken(studentC, sessionCId);
  });

  test('Student A creates listing -> Student B receives notification, Student A & C do not', async () => {
    // 1. Student A creates a listing: "Java Programming Book" for ₹500
    const createListingRes = await request(app)
      .post('/api/v1/listings')
      .set('Authorization', `Bearer ${tokenA}`)
      .send({
        title: 'Java Programming Book',
        description: 'Complete reference for second year computer science',
        category: 'Academic / Books',
        price: 500,
        condition: 'Like New',
        photoRefs: ['mock_photo_1.jpg'],
      });

    expect(createListingRes.statusCode).toBe(201);
    const listingId = createListingRes.body.listingId;
    expect(listingId).toBeDefined();

    // Small delay to ensure async notification dispatch
    await new Promise((r) => setTimeout(r, 100));

    // 2. Check Student B's notifications (Same College)
    const notifsBRes = await request(app)
      .get('/api/v1/notifications')
      .set('Authorization', `Bearer ${tokenB}`);

    expect(notifsBRes.statusCode).toBe(200);
    expect(notifsBRes.body.notifications.length).toBe(1);
    const notifB = notifsBRes.body.notifications[0];
    expect(notifB.title).toBe('New listing posted');
    expect(notifB.message).toBe('Student A posted Java Programming Book for ₹500');
    expect(notifB.listingId).toBe(listingId);
    expect(notifB.isRead).toBe(false);

    // Check Student B's unread count API
    const unreadBRes = await request(app)
      .get('/api/v1/notifications/unread-count')
      .set('Authorization', `Bearer ${tokenB}`);
    expect(unreadBRes.statusCode).toBe(200);
    expect(unreadBRes.body.unreadCount).toBe(1);

    // 3. Check Student A's notifications (Creator - must NOT receive own notification)
    const notifsARes = await request(app)
      .get('/api/v1/notifications')
      .set('Authorization', `Bearer ${tokenA}`);
    expect(notifsARes.statusCode).toBe(200);
    expect(notifsARes.body.notifications.length).toBe(0);

    const unreadARes = await request(app)
      .get('/api/v1/notifications/unread-count')
      .set('Authorization', `Bearer ${tokenA}`);
    expect(unreadARes.body.unreadCount).toBe(0);

    // 4. Check Student C's notifications (Different College - must NOT receive)
    const notifsCRes = await request(app)
      .get('/api/v1/notifications')
      .set('Authorization', `Bearer ${tokenC}`);
    expect(notifsCRes.statusCode).toBe(200);
    expect(notifsCRes.body.notifications.length).toBe(0);

    // 5. Student B marks notification as read
    const markReadRes = await request(app)
      .patch(`/api/v1/notifications/${notifB.notificationId}/read`)
      .set('Authorization', `Bearer ${tokenB}`);
    expect(markReadRes.statusCode).toBe(200);
    expect(markReadRes.body.notification.isRead).toBe(true);
    expect(markReadRes.body.unreadCount).toBe(0);

    // 6. Student A posts a second listing -> Student B marks all as read
    await request(app)
      .post('/api/v1/listings')
      .set('Authorization', `Bearer ${tokenA}`)
      .send({
        title: 'Data Structures Manual',
        description: 'Lab manual with clean notes',
        category: 'Academic / Books',
        price: 250,
        condition: 'Good',
        photoRefs: ['mock_photo_2.jpg'],
      });

    await new Promise((r) => setTimeout(r, 100));

    const readAllRes = await request(app)
      .patch('/api/v1/notifications/read-all')
      .set('Authorization', `Bearer ${tokenB}`);
    expect(readAllRes.statusCode).toBe(200);
    expect(readAllRes.body.unreadCount).toBe(0);

    const finalUnreadB = await request(app)
      .get('/api/v1/notifications/unread-count')
      .set('Authorization', `Bearer ${tokenB}`);
    expect(finalUnreadB.body.unreadCount).toBe(0);
  });
});

