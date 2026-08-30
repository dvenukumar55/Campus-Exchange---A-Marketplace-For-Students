const express = require('express');
const router = express.Router();
const adminRoutes = require('./adminRoutes');
const authRoutes = require('./authRoutes');
const listingRoutes = require('./listingRoutes');
const chatRoutes = require('./chatRoutes');
const reportRoutes = require('./reportRoutes');
const eventRoutes = require('./eventRoutes');
const metricsRoutes = require('./metricsRoutes');
const healthRoutes = require('./healthRoutes');

const notificationRoutes = require('./notificationRoutes');

// Version 1 API routes
router.use('/admin', adminRoutes);
router.use('/auth', authRoutes);
router.use('/listings', listingRoutes);
router.use('/listings', chatRoutes); // /listings/:listingId/chat
router.use('/notifications', notificationRoutes);
router.use('/reports', reportRoutes);
router.use('/events', eventRoutes);
router.use('/metrics', metricsRoutes);
router.use('/health', healthRoutes);

module.exports = router;

