const mongoose = require('mongoose');

const MessageSchema = new mongoose.Schema(
  {
    messageId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    conversationId: {
      type: String,
      required: true,
      index: true,
      ref: 'Conversation',
    },
    listingId: {
      type: String,
      required: true,
      index: true,
      ref: 'Listing',
    },
    collegeId: {
      type: String,
      required: true,
      index: true,
      ref: 'College',
    },
    senderId: {
      type: String,
      required: true,
      index: true,
      ref: 'Student',
    },
    message: {
      type: String,
      required: [true, 'Message text is required'],
      trim: true,
      maxlength: 1000,
    },
  },
  {
    timestamps: true,
  }
);

MessageSchema.index({ conversationId: 1, createdAt: 1 });
MessageSchema.index({ listingId: 1, createdAt: -1 });

module.exports = mongoose.model('Message', MessageSchema);
