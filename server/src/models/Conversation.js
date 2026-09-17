const mongoose = require('mongoose');

const ConversationSchema = new mongoose.Schema(
  {
    conversationId: {
      type: String,
      required: true,
      unique: true,
      index: true,
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
    buyerId: {
      type: String,
      required: true,
      index: true,
      ref: 'Student',
    },
    sellerId: {
      type: String,
      required: true,
      index: true,
      ref: 'Student',
    },
    lastMessage: {
      type: String,
      default: '',
    },
    lastMessageSenderId: {
      type: String,
    },
    lastMessageAt: {
      type: Date,
      default: Date.now,
      index: true,
    },
  },
  {
    timestamps: true,
  }
);

// One conversation per listing + buyer combination
ConversationSchema.index({ listingId: 1, buyerId: 1 }, { unique: true });
ConversationSchema.index({ collegeId: 1, buyerId: 1, lastMessageAt: -1 });
ConversationSchema.index({ collegeId: 1, sellerId: 1, lastMessageAt: -1 });

module.exports = mongoose.model('Conversation', ConversationSchema);
