const jwt = require('jsonwebtoken');
const env = require('../config/env');
const Student = require('../models/Student');
const { VERIFICATION_STATUS, ACCOUNT_STATUS } = require('../config/constants');
const logger = require('../utils/logger');

/**
 * Socket.io middleware for JWT authentication
 */
const socketAuth = async (socket, next) => {
  try {
    const token =
      socket.handshake.auth?.token ||
      socket.handshake.headers?.authorization?.replace('Bearer ', '') ||
      socket.handshake.query?.token;

    if (!token) {
      return next(new Error('Authentication token required'));
    }

    let decoded;
    try {
      decoded = jwt.verify(token, env.JWT_SECRET);
    } catch (err) {
      return next(new Error('Invalid or expired authentication token'));
    }

    if (!decoded || !decoded.studentId || !decoded.collegeId) {
      return next(new Error('Malformed token claims'));
    }

    const student = await Student.findOne({
      studentId: decoded.studentId,
      collegeId: decoded.collegeId,
    });

    if (!student) {
      return next(new Error('Student not found'));
    }

    if (student.accountStatus === ACCOUNT_STATUS.SUSPENDED) {
      return next(new Error('Account suspended'));
    }

    if (student.verificationStatus !== VERIFICATION_STATUS.VERIFIED) {
      return next(new Error('Only verified students may access marketplace chat'));
    }

    socket.student = student;
    socket.collegeId = student.collegeId;
    socket.studentId = student.studentId;

    next();
  } catch (error) {
    logger.error('Socket authentication failed', { error: error.message });
    next(new Error('Socket authentication error'));
  }
};

module.exports = socketAuth;
