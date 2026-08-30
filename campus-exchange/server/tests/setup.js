process.env.NODE_ENV = 'test';
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');

let mongoServer;

const setupTestDB = () => {
  beforeAll(async () => {
    try {
      if (!mongoServer) {
        mongoServer = await MongoMemoryServer.create();
      }

      if (mongoose.connection.readyState === 0) {
        const mongoUri = mongoServer.getUri();
        await mongoose.connect(mongoUri);
      }
    } catch (e) {
      console.warn('Memory server initialization fallback:', e.message);
    }
  }, 120000);

  afterAll(async () => {
    if (mongoose.connection.readyState !== 0) {
      try {
        await mongoose.connection.dropDatabase();
        await mongoose.disconnect();
      } catch (e) {}
    }
    if (mongoServer) {
      try {
        await mongoServer.stop();
        mongoServer = null;
      } catch (e) {}
    }
  }, 30000);

  afterEach(async () => {
    if (mongoose.connection.readyState === 1) {
      const collections = mongoose.connection.collections;
      for (const key in collections) {
        try {
          await collections[key].deleteMany({});
        } catch (e) {}
      }
    }
  });
};

module.exports = {
  setupTestDB,
};
