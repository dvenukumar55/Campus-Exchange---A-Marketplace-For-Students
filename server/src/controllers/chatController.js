const chatService = require('../services/chatService');
const { sendSuccess } = require('../utils/response');

class ChatController {
  /**
   * GET /api/v1/listings/:listingId/chat
   * Retrieves listing-associated conversation history
   */
  async getMessages(req, res, next) {
    try {
      const { listingId } = req.params;
      const { page, limit } = req.query;

      const result = await chatService.getMessagesForListing({
        listingId,
        student: req.student,
        page,
        limit,
      });

      return sendSuccess(
        res,
        200,
        {
          messages: result.messages,
          conversation: result.conversation,
        },
        result.pagination
      );
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/v1/listings/:listingId/chat
   * Creates a listing-associated chat message
   */
  async sendMessage(req, res, next) {
    try {
      const { listingId } = req.params;
      const { conversationId } = req.body;

      const result = await chatService.sendMessage({
        listingId,
        student: req.student,
        messageText: req.validatedMessage,
        conversationId,
      });

      return sendSuccess(res, 201, {
        messageId: result.message.messageId,
        listingId,
        senderId: result.message.senderId,
        createdAt: result.message.createdAt,
        message: result.message,
        conversation: result.conversation,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/v1/chats
   * Retrieves list of all conversations for current student
   */
  async getUserConversations(req, res, next) {
    try {
      const conversations = await chatService.getUserConversations({
        student: req.student,
      });

      return sendSuccess(res, 200, { items: conversations });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new ChatController();
