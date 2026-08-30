const mongoose = require('mongoose');

const OtpSchema = new mongoose.Schema(
  {
    email: {
      type: String,
      required: true,
      trim: true,
      lowercase: true,
      index: true,
    },
    otpHash: {
      type: String,
      required: true,
    },
    attempts: {
      type: Number,
      default: 0,
      min: 0,
    },
    verified: {
      type: Boolean,
      default: false,
    },
    expiresAt: {
      type: Date,
      required: true,
      index: { expires: 0 }, // Automatically remove document when expiresAt timestamp passes
    },
  },
  {
    timestamps: true,
  }
);

// Index on email for fast lookups
OtpSchema.index({ email: 1, verified: 1 });

module.exports = mongoose.model('Otp', OtpSchema);
