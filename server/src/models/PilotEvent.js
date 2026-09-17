const mongoose = require('mongoose');

const PilotEventSchema = new mongoose.Schema(
  {
    eventId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    eventType: {
      type: String,
      required: true,
      index: true,
    },
    collegeId: {
      type: String,
      required: true,
      index: true,
      ref: 'College',
    },
    studentId: {
      type: String,
      index: true,
    },
    listingId: {
      type: String,
      index: true,
    },
    occurredAt: {
      type: Date,
      default: Date.now,
      index: true,
    },
    metadata: {
      type: mongoose.Schema.Types.Mixed,
      default: {},
    },
  },
  {
    timestamps: true,
  }
);

// Indexes for metric aggregation queries
PilotEventSchema.index({ collegeId: 1, eventType: 1, occurredAt: -1 });
PilotEventSchema.index({ eventType: 1, listingId: 1 });
PilotEventSchema.index({ eventType: 1, studentId: 1 });

module.exports = mongoose.model('PilotEvent', PilotEventSchema);
