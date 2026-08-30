const mongoose = require('mongoose');

const SessionSchema = new mongoose.Schema(
  {
    sessionId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    studentId: {
      type: String,
      required: true,
      index: true,
      ref: 'Student',
    },
    collegeId: {
      type: String,
      required: true,
      index: true,
      ref: 'College',
    },
    deviceId: {
      type: String,
      required: true,
      index: true,
    },
    active: {
      type: Boolean,
      default: true,
      index: true,
    },
    expiresAt: {
      type: Date,
      required: true,
      index: { expires: 0 },
    },
    revokedAt: {
      type: Date,
      default: null,
    },
    lastSeenAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  }
);

// Compound index to quickly check for active sessions per student
SessionSchema.index({ studentId: 1, active: 1 });

module.exports = mongoose.model('Session', SessionSchema);
