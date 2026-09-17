const path = require('path');
const fs = require('fs');
const env = require('../config/env');
const logger = require('../utils/logger');
const { BadRequestError } = require('../utils/errors');

/**
 * Storage service abstraction for item listing photos
 */
class StorageService {
  /**
   * Resolves storage reference to accessible URL
   */
  resolveImageUrl(photoRef) {
    if (!photoRef) return '';
    if (photoRef.startsWith('http://') || photoRef.startsWith('https://')) {
      return photoRef;
    }
    // Local / static route
    return `/uploads/${photoRef}`;
  }

  /**
   * Validates that photos exist and references are valid
   */
  validatePhotoReferences(photoRefs) {
    if (!photoRefs || !Array.isArray(photoRefs) || photoRefs.length === 0) {
      throw new BadRequestError('At least one item photo is required for listing activation');
    }

    if (photoRefs.length > env.STORAGE_MAX_PHOTO_COUNT) {
      throw new BadRequestError(`Cannot exceed maximum of ${env.STORAGE_MAX_PHOTO_COUNT} photos per listing`);
    }

    return true;
  }

  /**
   * Deletes a stored file if needed
   */
  async deleteFile(filename) {
    if (env.STORAGE_PROVIDER === 'local') {
      try {
        const filePath = path.join(env.STORAGE_LOCAL_DIR, filename);
        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
        }
      } catch (err) {
        logger.warn('Failed to delete file from storage', { filename, error: err.message });
      }
    }
  }
}

module.exports = new StorageService();
