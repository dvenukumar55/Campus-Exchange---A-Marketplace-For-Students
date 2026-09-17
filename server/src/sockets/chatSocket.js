const socketAuth = require('./socketAuth');
const chatService = require('../services/chatService');
const notificationService = require('../services/notificationService');
const Listing = require('../models/Listing');
const logger = require('../utils/logger');

const initializeChatSocket = (io) => {
  // Inject io into notificationService
  notificationService.setIo(io);

  // Apply JWT authentication
  io.use(socketAuth);

  io.on('connection', (socket) => {
    const student = socket.student;
    logger.info('Socket client connected', {
      socketId: socket.id,
      studentId: student.studentId,
      collegeId: student.collegeId,
    });

    // Auto-join personal student room and college notification room
    socket.join(`student_${student.studentId}`);
    socket.join(`college_${student.collegeId}`);


    /**
     * Join a listing-specific conversation room with server-side authorization
     */
    socket.on('join_listing_chat', async ({ listingId }, callback) => {
      try {
        if (!listingId) {
          if (callback) callback({ error: 'listingId is required' });
          return;
        }

        const listing = await Listing.findOne({ listingId });
        if (!listing) {
          if (callback) callback({ error: 'Listing not found' });
          return;
        }

        // Cross-college rejection
        if (listing.collegeId !== student.collegeId) {
          if (callback) callback({ error: 'Cross-college chat access denied' });
          return;
        }

        // Join listing-associated room
        const roomName = `listing_${listingId}`;
        socket.join(roomName);

        logger.info('Student joined listing chat room', {
          roomName,
          studentId: student.studentId,
          listingId,
        });

        if (callback) callback({ success: true, roomName });
      } catch (err) {
        logger.error('Error joining listing chat', { error: err.message });
        if (callback) callback({ error: 'Failed to join chat room' });
      }
    });

    /**
     * Send real-time listing message
     */
    socket.on('send_message', async ({ listingId, message, conversationId }, callback) => {
      try {
        if (!listingId || !message || message.trim().length === 0) {
          if (callback) callback({ error: 'listingId and non-empty message are required' });
          return;
        }

        if (message.trim().length > 1000) {
          if (callback) callback({ error: 'Message exceeds 1000 characters limit' });
          return;
        }

        // Persist message to MongoDB before delivery confirmation
        const result = await chatService.sendMessage({
          listingId,
          student,
          messageText: message.trim(),
          conversationId,
        });

        const roomName = `listing_${listingId}`;

        // Broadcast to room participants in real time
        io.to(roomName).emit('new_message', {
          messageId: result.message.messageId,
          conversationId: result.conversation.conversationId,
          listingId,
          senderId: student.studentId,
          senderName: student.fullName,
          message: result.message.message,
          createdAt: result.message.createdAt,
        });

        if (callback) {
          callback({
            success: true,
            message: result.message,
            conversation: result.conversation,
          });
        }
      } catch (err) {
        logger.error('Error sending socket message', { error: err.message, studentId: student.studentId });
        if (callback) callback({ error: err.message || 'Failed to send message' });
      }
    });

    socket.on('disconnect', () => {
      logger.info('Socket client disconnected', {
        socketId: socket.id,
        studentId: student.studentId,
      });
    });
  });
};

module.exports = initializeChatSocket;
