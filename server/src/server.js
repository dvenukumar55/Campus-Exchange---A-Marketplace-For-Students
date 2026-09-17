const http = require('http');
const { Server } = require('socket.io');
const app = require('./app');
const env = require('./config/env');
const { connectDB, disconnectDB } = require('./config/database');
const initializeChatSocket = require('./sockets/chatSocket');
const logger = require('./utils/logger');

const server = http.createServer(app);

// Initialize Socket.io
const io = new Server(server, {
  cors: {
    origin: env.CORS_ORIGIN === '*' ? true : env.CORS_ORIGIN.split(','),
    methods: ['GET', 'POST'],
    credentials: true,
  },
  pingTimeout: 30000,
  pingInterval: 10000,
});

initializeChatSocket(io);

const startServer = async () => {
  try {
    // Connect to database
    await connectDB();

    server.listen(env.PORT, () => {
      logger.info(`Campus Exchange Backend Server running on port ${env.PORT}`, {
        environment: env.NODE_ENV,
        port: env.PORT,
        apiPrefix: env.API_PREFIX,
        pilotCollege: env.DEFAULT_COLLEGE_NAME,
      });
    });
  } catch (error) {
    logger.error('Failed to start server', { error: error.message });
    process.exit(1);
  }
};

// Graceful shutdown handling
const handleGracefulShutdown = async (signal) => {
  logger.info(`Received ${signal}. Shutting down gracefully...`);
  server.close(async () => {
    logger.info('HTTP server closed.');
    await disconnectDB();
    logger.info('Database connection closed.');
    process.exit(0);
  });

  // Force close after 10s if hung
  setTimeout(() => {
    logger.error('Force closing server after timeout.');
    process.exit(1);
  }, 10000);
};

process.on('SIGTERM', () => handleGracefulShutdown('SIGTERM'));
process.on('SIGINT', () => handleGracefulShutdown('SIGINT'));

if (require.main === module) {
  startServer();
}

module.exports = { app, server, io };
