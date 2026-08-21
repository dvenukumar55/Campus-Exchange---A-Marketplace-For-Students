module.exports = {
  LISTING_STATUS: {
    DRAFT: 'draft',
    ACTIVE: 'active',
    SOLD: 'sold',
    CLOSED: 'closed',
  },

  CATEGORIES: [
    'Academic / Books',
    'Lab Equipment & Instruments',
    'Drawing & Graphics Kits',
    'Scientific Calculators',
    'Hostel Essentials',
    'Electronics & Accessories',
    'Study Materials & Notes',
    'Uniforms & Aprons',
    'Sports & Fitness',
    'Miscellaneous Academic',
  ],

  CONDITIONS: [
    'New / Unused',
    'Like New',
    'Good',
    'Fair',
  ],

  VERIFICATION_STATUS: {
    PENDING: 'pending',
    VERIFIED: 'verified',
    REJECTED: 'rejected',
  },

  ACCOUNT_STATUS: {
    ACTIVE: 'active',
    SUSPENDED: 'suspended',
  },
USER_ROLE: {
  STUDENT: 'student',
  MODERATOR: 'moderator',
  ADMIN: 'admin',
},
  REPORT_STATUS: {
    OPEN: 'open',
    REVIEWING: 'reviewing',
    RESOLVED: 'resolved',
    REJECTED: 'rejected',
  },

  REPORT_REASONS: [
    'Misleading Condition or Details',
    'Incorrect Price or Commercial Seller',
    'Prohibited or Ineligible Item',
    'Unresponsive or Dishonest Behavior',
    'Fake or Infringing Photo',
    'Other Community Guideline Violation',
  ],

  PILOT_EVENT_TYPES: {
    STUDENT_SIGNUP_VERIFIED: 'STUDENT_SIGNUP_VERIFIED',
    STUDENT_LOGIN: 'STUDENT_LOGIN',
    LISTING_CREATED: 'LISTING_CREATED',
    LISTING_UPDATED: 'LISTING_UPDATED',
    LISTING_CLOSED_SOLD: 'LISTING_CLOSED_SOLD',
    LISTING_CLOSED_CANCELLED: 'LISTING_CLOSED_CANCELLED',
    CHAT_CONVERSATION_INITIATED: 'CHAT_CONVERSATION_INITIATED',
    CHAT_MESSAGE_SENT: 'CHAT_MESSAGE_SENT',
    REPORT_SUBMITTED: 'REPORT_SUBMITTED',
    REPORT_RESOLVED: 'REPORT_RESOLVED',
    USER_WARNED: 'USER_WARNED',
  },

  ERROR_CODES: {
    INVALID_REQUEST: 'INVALID_REQUEST',
    VALIDATION_ERROR: 'VALIDATION_ERROR',
    UNAUTHENTICATED: 'UNAUTHENTICATED',
    UNVERIFIED_STUDENT: 'UNVERIFIED_STUDENT',
    UNAUTHORIZED_ACCESS: 'UNAUTHORIZED_ACCESS',
    CROSS_COLLEGE_DENIED: 'CROSS_COLLEGE_DENIED',
    LISTING_NOT_FOUND: 'LISTING_NOT_FOUND',
    SELLER_MISMATCH: 'SELLER_MISMATCH',
    INVALID_STATE_TRANSITION: 'INVALID_STATE_TRANSITION',
    DUPLICATE_EVENT: 'DUPLICATE_EVENT',
    DUPLICATE_ACTION: 'DUPLICATE_ACTION',
    UPLOAD_FAILED: 'UPLOAD_FAILED',
    SERVICE_UNAVAILABLE: 'SERVICE_UNAVAILABLE',
    INTERNAL_SERVER_ERROR: 'INTERNAL_SERVER_ERROR',
    RATE_LIMIT_EXCEEDED: 'RATE_LIMIT_EXCEEDED',
  },
};
