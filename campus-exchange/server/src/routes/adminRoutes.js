const express = require('express');
const router = express.Router();

const { authenticate, requireAdmin } = require('../middleware/auth');
const moderationService = require('../services/moderationService');

router.get('/test', authenticate, requireAdmin, (req, res) => {
  res.json({
    success: true,
    message: 'Admin API is working',
    role: req.student.role,
  });
});

router.post('/students/:studentId/warn', authenticate, requireAdmin, async (req, res, next) => {
  try {
    const result = await moderationService.warnStudent({
      studentId: req.params.studentId,
      reviewer: req.student,
    });

    res.json({
      success: true,
      warningCount: result.warningCount,
    });
  } catch (error) {
    next(error);
  }
});
router.post('/students/:studentId/block', authenticate, requireAdmin, async (req, res, next) => {
  try {
    const result = await moderationService.blockStudent({
      studentId: req.params.studentId,
      reviewer: req.student,
    });

    res.json({
      success: true,
      accountStatus: result.accountStatus,
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;