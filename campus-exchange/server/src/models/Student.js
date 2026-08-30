const { VERIFICATION_STATUS, ACCOUNT_STATUS, USER_ROLE } = require('../config/constants');
const mongoose = require('mongoose');

const StudentSchema = new mongoose.Schema(
  {
    studentId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    collegeId: {
      type: String,
      required: true,
      index: true,
      ref: 'College',
    },
    officialEmail: {
      type: String,
      required: true,
      trim: true,
      lowercase: true,
      index: true,
    },
    rollNumber: {
      type: String,
      required: true,
      trim: true,
      uppercase: true,
    },
    fullName: {
      type: String,
      trim: true,
      default: 'Student',
    },
    department: {
      type: String,
      trim: true,
      default: 'General Engineering',
    },
    graduatingYear: {
      type: Number,
      default: 2026,
    },
    verificationStatus: {
      type: String,
      enum: Object.values(VERIFICATION_STATUS),
      default: VERIFICATION_STATUS.PENDING,
      index: true,
    },
    accountStatus: {
      type: String,
      enum: Object.values(ACCOUNT_STATUS),
      default: ACCOUNT_STATUS.ACTIVE,
      index: true,
    },
    role: {
      type: String,
      enum: Object.values(USER_ROLE),
      default: USER_ROLE.STUDENT,
      index: true,
    },
    warningCount: {
      type: Number,
      default: 0,
      min: 0,
    },
    verifiedAt: {
      type: Date,
    },
  },
  {
    timestamps: true,
  }
);

// Compound indexes: rollNumber and officialEmail must be unique per college
StudentSchema.index({ collegeId: 1, rollNumber: 1 }, { unique: true });
StudentSchema.index({ collegeId: 1, officialEmail: 1 }, { unique: true });

module.exports = mongoose.model('Student', StudentSchema);

