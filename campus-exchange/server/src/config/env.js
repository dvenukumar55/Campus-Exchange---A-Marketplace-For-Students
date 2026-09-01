const dotenv = require('dotenv');
const path = require('path');

// Load environment variables from .env if present
dotenv.config();

const env = {
  NODE_ENV: process.env.NODE_ENV || 'development',
  PORT: parseInt(process.env.PORT || '5000', 10),
  API_PREFIX: process.env.API_PREFIX || '/api/v1',
  MONGODB_URI: process.env.MONGODB_URI || 'mongodb://localhost:27017/campus_exchange',
  JWT_SECRET: process.env.JWT_SECRET || 'dev_jwt_secret_campus_exchange_avih_2026',
  JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN || '7d',
  CORS_ORIGIN: process.env.CORS_ORIGIN || '*',
  
  // Storage settings
  STORAGE_PROVIDER: process.env.STORAGE_PROVIDER || 'local',
  STORAGE_LOCAL_DIR: process.env.STORAGE_LOCAL_DIR || path.join(__dirname, '../../uploads'),
  STORAGE_MAX_FILE_SIZE_MB: parseInt(process.env.STORAGE_MAX_FILE_SIZE_MB || '5', 10),
  STORAGE_ALLOWED_MIME_TYPES: (
    process.env.STORAGE_ALLOWED_MIME_TYPES ||
    'image/jpeg,image/jpg,image/pjpeg,image/png,image/webp,image/gif,image/bmp,image/x-ms-bmp,image/heic,image/heif,image/heic-sequence,image/heif-sequence,image/tiff,image/tif,image/x-tiff,image/svg+xml'
  ).split(','),
  TARGET_RESPONSE_TIME_MS: parseInt(process.env.TARGET_RESPONSE_TIME_MS || '3000', 10),
  TARGET_AVAILABILITY_PERCENT: parseFloat(process.env.TARGET_AVAILABILITY_PERCENT || '99.0'),
  
  // Session & Security Settings
  SESSION_TTL_HOURS: parseInt(process.env.SESSION_TTL_HOURS || '24', 10),
  OTP_EXPIRY_MINUTES: parseInt(process.env.OTP_EXPIRY_MINUTES || '5', 10),
  OTP_MAX_ATTEMPTS: parseInt(process.env.OTP_MAX_ATTEMPTS || '5', 10),

  // Gmail SMTP Settings
  SMTP_HOST: process.env.SMTP_HOST || 'smtp.gmail.com',
  SMTP_PORT: parseInt(process.env.SMTP_PORT || '465', 10),
  SMTP_SECURE: process.env.SMTP_SECURE === 'true' || process.env.SMTP_PORT === '465' || !process.env.SMTP_PORT,
  SMTP_USER: process.env.SMTP_USER || '',
  SMTP_PASS: process.env.SMTP_PASS || process.env.SMTP_PASSWORD || '',
  SMTP_FROM: process.env.SMTP_FROM || (process.env.SMTP_USER ? `Campus Exchange <${process.env.SMTP_USER}>` : ''),

  // Default pilot college
  DEFAULT_COLLEGE_ID: process.env.DEFAULT_COLLEGE_ID || 'avih-gunthapalli',
  DEFAULT_COLLEGE_NAME: process.env.DEFAULT_COLLEGE_NAME || 'Avanthi Institute of Engineering and Technology (AVIH), Gunthapalli',
  DEFAULT_COLLEGE_DOMAIN: process.env.DEFAULT_COLLEGE_DOMAIN || 'avih.edu.in',
};

module.exports = env;
