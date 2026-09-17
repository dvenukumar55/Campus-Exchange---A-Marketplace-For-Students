const mongoose = require('mongoose');
const { LISTING_STATUS, CATEGORIES, CONDITIONS } = require('../config/constants');

const ListingSchema = new mongoose.Schema(
  {
    listingId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    collegeId: {
      type: String,
      required: true,
      index: true,
      ref: 'College',
    },
    sellerId: {
      type: String,
      required: true,
      index: true,
      ref: 'Student',
    },
    sellerName: {
      type: String,
      default: 'Verified Student',
    },
    sellerEmail: {
      type: String,
    },
    title: {
      type: String,
      required: [true, 'Item title is required'],
      trim: true,
      maxlength: 120,
    },
    description: {
      type: String,
      required: [true, 'Item description is required'],
      trim: true,
      maxlength: 2000,
    },
    category: {
      type: String,
      required: [true, 'Category is required'],
      enum: CATEGORIES,
      index: true,
    },
    price: {
      type: Number,
      required: [true, 'Price is required'],
      min: [0, 'Price cannot be negative'],
    },
    condition: {
      type: String,
      required: [true, 'Condition is required'],
      enum: CONDITIONS,
      index: true,
    },
    photoRefs: {
      type: [String],
      validate: {
        validator: function (val) {
          // Photos are mandatory for active listings
          if (this.status === LISTING_STATUS.ACTIVE) {
            return Array.isArray(val) && val.length > 0;
          }
          return true;
        },
        message: 'At least one item photo is required for an active listing',
      },
    },
    status: {
      type: String,
      enum: Object.values(LISTING_STATUS),
      default: LISTING_STATUS.ACTIVE,
      index: true,
    },
    viewCount: {
      type: Number,
      default: 0,
    },
    chatCount: {
      type: Number,
      default: 0,
    },
    closedAt: {
      type: Date,
    },
    closedReason: {
      type: String,
      enum: ['sold', 'closed', 'removed_by_moderation', 'expired'],
    },
  },
  {
    timestamps: true,
  }
);

// Indexes specified in PRISM-S: (collegeId, status, createdAt) and sellerId
ListingSchema.index({ collegeId: 1, status: 1, createdAt: -1 });
ListingSchema.index({ collegeId: 1, category: 1, status: 1 });
ListingSchema.index({ sellerId: 1, createdAt: -1 });

// Text index for search across title and description
ListingSchema.index({ title: 'text', description: 'text' });

module.exports = mongoose.model('Listing', ListingSchema);
