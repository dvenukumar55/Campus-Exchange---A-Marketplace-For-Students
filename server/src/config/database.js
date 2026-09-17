const mongoose = require('mongoose');
const env = require('./env');
const logger = require('../utils/logger');

let isConnected = false;

const connectDB = async () => {
  if (isConnected) {
    return;
  }

  try {
    const opts = {
      autoIndex: true,
      maxPoolSize: 10,
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
    };

    await mongoose.connect(env.MONGODB_URI, opts);
    isConnected = true;
    logger.info('MongoDB successfully connected', { uri: env.MONGODB_URI.replace(/\/\/[^:]+:[^@]+@/, '//***:***@') });

    // Seed default college if missing
    await seedDefaultCollege();
  } catch (error) {
    logger.error('Failed to connect to MongoDB', { error: error.message });
    throw error;
  }
};

const disconnectDB = async () => {
  if (!isConnected) return;
  await mongoose.disconnect();
  isConnected = false;
  logger.info('MongoDB disconnected');
};

const seedDefaultCollege = async () => {
  try {
    const College = require('../models/College');
    const existing = await College.findOne({ collegeId: env.DEFAULT_COLLEGE_ID });
    if (!existing) {
      await College.create({
        collegeId: env.DEFAULT_COLLEGE_ID,
        name: env.DEFAULT_COLLEGE_NAME,
        verificationDomain: env.DEFAULT_COLLEGE_DOMAIN,
        status: 'active',
      });
      logger.info(`Seeded initial pilot college: ${env.DEFAULT_COLLEGE_NAME}`);
    }
  } catch (err) {
    logger.warn('Seed default college skipped or failed', { error: err.message });
  }
};

module.exports = {
  connectDB,
  disconnectDB,
  isConnected: () => isConnected && mongoose.connection.readyState === 1,
};
