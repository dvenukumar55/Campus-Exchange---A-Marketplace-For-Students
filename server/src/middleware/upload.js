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
  const mimetype = (file.mimetype || '').toLowerCase();
  const ext = path.extname(file.originalname || '').toLowerCase().replace('.', '');

  const allowedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'gif',
    'bmp',
    'heic',
    'heif',
    'tiff',
    'tif',
    'svg',
  ];

  const isAllowedMime =
    env.STORAGE_ALLOWED_MIME_TYPES.includes(mimetype) ||
    mimetype.startsWith('image/');
  const isAllowedExt = allowedExtensions.includes(ext);

  if (isAllowedMime || isAllowedExt) {
    cb(null, true);
  } else {
    cb(
      new BadRequestError(
        `Invalid file format: ${file.mimetype || ext}. Allowed formats: JPG, PNG, WEBP, GIF, BMP, HEIC, TIFF`
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
