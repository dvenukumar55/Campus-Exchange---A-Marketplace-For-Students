const { v4: uuidv4 } = require('uuid');
const Conversation = require('../models/Conversation');
const Message = require('../models/Message');
const Listing = require('../models/Listing');
const { PILOT_EVENT_TYPES, LISTING_STATUS } = require('../config/constants');
const {
  NotFoundError,
  ForbiddenError,
  CrossCollegeError,
  BadRequestError,
} = require('../utils/errors');
const eventService = require('./eventService');

class ChatService {
  /**
   * Retrieves or creates a conversation associated with a listing
   */
  async getOrCreateConversation({ listingId, student }) {
    const listing = await Listing.findOne({ listingId });
    if (!listing) {
      throw new NotFoundError('Associated listing does not exist.');
    }

    if (listing.collegeId !== student.collegeId) {
      throw new CrossCollegeError('Chat across different college boundaries is not permitted.');
    }

    // Buyer cannot be the seller
    if (listing.sellerId === student.studentId) {
      throw new BadRequestError('Seller cannot initiate a buyer chat with themselves.');
    }

    let conversation = await Conversation.findOne({
      listingId,
      buyerId: student.studentId,
    });

    let isNew = false;
    if (!conversation) {
      conversation = new Conversation({
        conversationId: `conv_${uuidv4().substring(0, 10)}`,
        listingId,
        collegeId: student.collegeId,
        buyerId: student.studentId,
        sellerId: listing.sellerId,
        lastMessage: '',
        lastMessageAt: new Date(),
      });
      await conversation.save();
      isNew = true;

      // Increment chat count on listing
      await Listing.updateOne({ listingId }, { $inc: { chatCount: 1 } });

      // Record pilot chat conversion event
      await eventService.recordEvent({
        eventType: PILOT_EVENT_TYPES.CHAT_CONVERSATION_INITIATED,
        collegeId: student.collegeId,
        studentId: student.studentId,
        listingId: listing.listingId,
        metadata: {
          sellerId: listing.sellerId,
          buyerId: student.studentId,
        },
      });
    }

    return { conversation, isNew, listing };
  }

  /**
   * Retrieves conversation history for a listing
   */
  async getMessagesForListing({ listingId, student, page = 1, limit = 50 }) {
    const listing = await Listing.findOne({ listingId });
    if (!listing) {
      throw new NotFoundError('Listing not found');
    }

    if (listing.collegeId !== student.collegeId) {
      throw new CrossCollegeError();
    }

    // Find all conversations on this listing where user is either buyer or seller
    const conversationQuery = {
      listingId,
      collegeId: student.collegeId,
      $or: [{ buyerId: student.studentId }, { sellerId: student.studentId }],
    };

    const conversations = await Conversation.find(conversationQuery).lean();
    if (!conversations || conversations.length === 0) {
      return { messages: [], conversation: null };
    }

    // If user is buyer, they have one conversation. If user is seller, they might have multiple buyer chats.
    const activeConv = conversations[0];

    const pageNum = Math.max(1, parseInt(page, 10));
    const limitNum = Math.min(100, Math.max(1, parseInt(limit, 10)));
    const skip = (pageNum - 1) * limitNum;

    const [messages, total] = await Promise.all([
      Message.find({ conversationId: activeConv.conversationId })
        .sort({ createdAt: 1 })
        .skip(skip)
        .limit(limitNum)
        .lean(),
      Message.countDocuments({ conversationId: activeConv.conversationId }),
    ]);

    return {
      messages,
      conversation: activeConv,
      conversationsList: conversations,
      pagination: {
        total,
        page: pageNum,
        limit: limitNum,
      },
    };
  }

  /**
   * Persists a chat message associated with a listing
   */
  async sendMessage({ listingId, student, messageText, conversationId }) {
    const listing = await Listing.findOne({ listingId });
    if (!listing) {
      throw new NotFoundError('Associated listing does not exist.');
    }

    if (listing.collegeId !== student.collegeId) {
      throw new CrossCollegeError();
    }

    let conversation;
    if (conversationId) {
      conversation = await Conversation.findOne({ conversationId, listingId });
    } else {
      // Find or create if buyer
      if (student.studentId === listing.sellerId) {
        throw new BadRequestError('Seller must specify conversationId when replying.');
      }
      const res = await this.getOrCreateConversation({ listingId, student });
      conversation = res.conversation;
    }

    if (!conversation) {
      throw new NotFoundError('Conversation not found');
    }

    // Verify user is authorized participant
    if (
      conversation.buyerId !== student.studentId &&
      conversation.sellerId !== student.studentId
    ) {
      throw new ForbiddenError('You are not an authorized participant in this conversation.');
    }

    const messageId = `msg_${uuidv4().substring(0, 10)}`;
    const now = new Date();

    const message = new Message({
      messageId,
      conversationId: conversation.conversationId,
      listingId,
      collegeId: student.collegeId,
      senderId: student.studentId,
      message: messageText,
    });

    await message.save();

    // Update conversation metadata
    conversation.lastMessage = messageText.substring(0, 100);
    conversation.lastMessageSenderId = student.studentId;
    conversation.lastMessageAt = now;
    await conversation.save();

    // Record pilot event
    await eventService.recordEvent({
      eventType: PILOT_EVENT_TYPES.CHAT_MESSAGE_SENT,
      collegeId: student.collegeId,
      studentId: student.studentId,
      listingId,
      metadata: {
        conversationId: conversation.conversationId,
        messageId,
      },
    });

    return {
      message,
      conversation,
    };
  }

  /**
   * Retrieves all active chat threads for the current student
   */
  async getUserConversations({ student }) {
    const conversations = await Conversation.find({
      collegeId: student.collegeId,
      $or: [{ buyerId: student.studentId }, { sellerId: student.studentId }],
    })
      .sort({ lastMessageAt: -1 })
      .lean();

    // Populate listing titles & photos
    const listingIds = [...new Set(conversations.map((c) => c.listingId))];
    const listings = await Listing.find({ listingId: { $in: listingIds } }).lean();
    const listingMap = new Map(listings.map((l) => [l.listingId, l]));

    return conversations.map((conv) => {
      const listing = listingMap.get(conv.listingId);
      return {
        ...conv,
        listingTitle: listing ? listing.title : 'Deleted Listing',
        listingPrice: listing ? listing.price : 0,
        listingPhoto: listing && listing.photoRefs?.length ? listing.photoRefs[0] : null,
        listingStatus: listing ? listing.status : 'closed',
      };
    });
  }
}

module.exports = new ChatService();
