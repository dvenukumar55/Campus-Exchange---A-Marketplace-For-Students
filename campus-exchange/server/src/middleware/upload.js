const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { v4: uuidv4 } = require('uuid');
const env = require('../config/env');
const { BadRequestError } = require('../utils/errors');

// Ensure local storage directory exists if using local provider
if (env.STORAGE_PROVIDER === 'local') {
  if (!fs.existsSync(env.STORAGE_LOCAL_DIR)) {
    fs.mkdirSync(env.STORAGE_LOCAL_DIR, { recursive: true });
  }
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, env.STORAGE_LOCAL_DIR);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    const photoId = `photo_${uuidv4()}${ext}`;
    cb(null, photoId);
  },
});

const fileFilter = (req, file, cb) => {
  if (env.STORAGE_ALLOWED_MIME_TYPES.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(
      new BadRequestError(
        `Invalid file format: ${file.mimetype}. Allowed formats: ${env.STORAGE_ALLOWED_MIME_TYPES.join(', ')}`
      ),
      false
    );
  }
};

const upload = multer({
  storage,
  limits: {
    fileSize: env.STORAGE_MAX_FILE_SIZE_MB * 1024 * 1024,
    files: env.STORAGE_MAX_PHOTO_COUNT,
  },
  fileFilter,
});

module.exports = upload;
