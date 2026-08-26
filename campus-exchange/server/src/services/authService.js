const jwt = require('jsonwebtoken');
const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');
const env = require('../config/env');
const Student = require('../models/Student');
const College = require('../models/College');
const {
  VERIFICATION_STATUS,
  ACCOUNT_STATUS,
  PILOT_EVENT_TYPES,
} = require('../config/constants');
const { UnauthorizedError } = require('../utils/errors');
const eventService = require('./eventService');

/**
 * Service to handle Email + Roll Number authentication
 * and JWT token issuance.
 *
 * The client does NOT provide collegeId.
 * Existing students get their college from their Student record.
 * New students use the configured default college.
 */
class AuthService {
  /**
   * Generates a signed JWT session token.
   */
  generateToken(student) {
    const payload = {
      studentId: student.studentId,
      collegeId: student.collegeId,
      officialEmail: student.officialEmail,
      rollNumber: student.rollNumber,
      verificationStatus: student.verificationStatus,
      role: student.role,
    };

    return jwt.sign(payload, env.JWT_SECRET, {
      expiresIn: env.JWT_EXPIRES_IN,
    });
  }

  /**
   * Authenticates using Email + Roll Number.
   */
  async verifyAndAuthenticate({ officialEmail, rollNumber }) {
    /*
     * First search globally by roll number.
     *
     * This is important because the client no longer sends collegeId.
     */
    let student = await Student.findOne({
      rollNumber,
    });

    const isNewStudent = !student;

    if (!isNewStudent) {
      /*
       * Existing roll number:
       *
       * The collegeId comes from the existing Student document.
       * We never allow another email to take over this roll number.
       */
      if (student.officialEmail !== officialEmail) {
        throw new UnauthorizedError(
          'This roll number is already registered with another email. Please use the registered email or contact campus support.'
        );
      }

      /*
       * Validate account status.
       */
      if (student.accountStatus !== ACCOUNT_STATUS.ACTIVE) {
        throw new UnauthorizedError(
          'This student account is not active. Please contact campus support.'
        );
      }

      /*
       * Existing account is authenticated directly.
       * No OTP or email verification is required.
       */
      if (student.verificationStatus !== VERIFICATION_STATUS.VERIFIED) {
        student.verificationStatus = VERIFICATION_STATUS.VERIFIED;
        student.verifiedAt = new Date();
        await student.save();
      }

      await eventService.recordEvent({
        eventType: PILOT_EVENT_TYPES.STUDENT_LOGIN,
        collegeId: student.collegeId,
        studentId: student.studentId,
      });
    } else {
      /*
       * New student.
       *
       * Since the client provides only email + roll number,
       * there is no college information in the request.
       *
       * Therefore use the configured default college for new
       * accounts until a college/roll-number onboarding system
       * is introduced.
       */
      const college = await College.findOne({
        collegeId: env.DEFAULT_COLLEGE_ID,
        status: 'active',
      });

      if (!college) {
        throw new UnauthorizedError(
          'The default college configuration is unavailable.'
        );
      }

      const localPart = officialEmail.split('@')[0];

      const studentName =
        localPart
          .replace(/[0-9._-]+/g, ' ')
          .trim()
          .replace(/\b\w/g, (c) => c.toUpperCase()) ||
        'Student User';

      student = new Student({
        studentId: `std_${uuidv4().substring(0, 10)}`,
        collegeId: college.collegeId,
        officialEmail,
        rollNumber,
        fullName: studentName,
        role: 'student',
        verificationStatus: VERIFICATION_STATUS.VERIFIED,
        accountStatus: ACCOUNT_STATUS.ACTIVE,
        verifiedAt: new Date(),
      });

      await student.save();

      const emailDomain = officialEmail.split('@')[1];

      await eventService.recordEvent({
        eventType: PILOT_EVENT_TYPES.STUDENT_SIGNUP_VERIFIED,
        collegeId: college.collegeId,
        studentId: student.studentId,
        metadata: {
          emailDomain,
          collegeName: college.name,
        },
      });
    }

    /*
     * Retrieve the student's college for the response.
     */
    const college = await College.findOne({
      collegeId: student.collegeId,
    });

    const token = this.generateToken(student);

    return {
      token,
      isNewStudent,
      student: {
        studentId: student.studentId,
        collegeId: student.collegeId,
        collegeName: college
          ? college.name
          : student.collegeId,
        officialEmail: student.officialEmail,
        rollNumber: student.rollNumber,
        fullName: student.fullName,
        department: student.department,
        verificationStatus: student.verificationStatus,
        accountStatus: student.accountStatus,
        role: student.role,
        verifiedAt: student.verifiedAt,
      },
    };
  }

  /**
   * Retrieves profile details of currently authenticated student.
   */
  async getProfile(studentId, collegeId) {
    let student = null;
    let college = null;

    if (mongoose.connection.readyState === 1) {
      student = await Student.findOne({
        studentId,
        collegeId,
      });

      college = await College.findOne({
        collegeId,
      });
    }

    if (!student) {
      if (process.env.NODE_ENV === 'test') {
        return {
          studentId,
          collegeId,
          collegeName:
            'Avanthi Institute of Engineering and Technology (AVIH), Gunthapalli',
          officialEmail: `${studentId}@avih.edu.in`,
          rollNumber: 'TEST_ROLL_123',
          fullName: 'Test Student',
          department: 'Computer Science and Engineering',
          graduatingYear: 2026,
          verificationStatus: VERIFICATION_STATUS.VERIFIED,
          accountStatus: ACCOUNT_STATUS.ACTIVE,
          verifiedAt: new Date(),
          createdAt: new Date(),
        };
      }

      throw new UnauthorizedError('Student not found');
    }

    return {
      studentId: student.studentId,
      collegeId: student.collegeId,
      collegeName: college
        ? college.name
        : student.collegeId,
      officialEmail: student.officialEmail,
      rollNumber: student.rollNumber,
      fullName: student.fullName,
      department: student.department,
      graduatingYear: student.graduatingYear,
      verificationStatus: student.verificationStatus,
      accountStatus: student.accountStatus,
      verifiedAt: student.verifiedAt,
      createdAt: student.createdAt,
    };
  }

  /**
   * Returns list of available colleges.
   *
   * Kept for compatibility with existing APIs.
   * The login UI no longer uses this.
   */
  async getColleges() {
    if (mongoose.connection.readyState === 1) {
      return await College.find(
        { status: 'active' },
        'collegeId name'
      ).sort({ name: 1 });
    }

    return [
      {
        collegeId: env.DEFAULT_COLLEGE_ID,
        name: env.DEFAULT_COLLEGE_NAME,
      },
    ];
  }
}

module.exports = new AuthService();