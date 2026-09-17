const express = require('express');
const router = express.Router();
const healthController = require('../controllers/healthController');

// GET /api/v1/health - SLA health check and uptime status
router.get('/', healthController.check);

module.exports = router;
