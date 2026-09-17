const Student = require('../models/Student');
const Listing = require('../models/Listing');
const Conversation = require('../models/Conversation');
const PilotEvent = require('../models/PilotEvent');
const { VERIFICATION_STATUS, LISTING_STATUS, PILOT_EVENT_TYPES } = require('../config/constants');
const env = require('../config/env');

class MetricsService {
  /**
   * Calculates real-time pilot conversion and participation metrics
   */
  async getPilotMetrics(collegeId) {
    const queryCollege = collegeId ? { collegeId } : {};

    // 1. Verified student sign-ups
    const verifiedSignups = await Student.countDocuments({
      ...queryCollege,
      verificationStatus: VERIFICATION_STATUS.VERIFIED,
    });

    // 2. Active listings
    const activeListings = await Listing.countDocuments({
      ...queryCollege,
      status: LISTING_STATUS.ACTIVE,
    });

    // 3. Total listings created
    const totalListings = await Listing.countDocuments({
      ...queryCollege,
    });

    // 4. Closed / Sold listings
    const soldListings = await Listing.countDocuments({
      ...queryCollege,
      status: LISTING_STATUS.SOLD,
    });

    const closedCancelledListings = await Listing.countDocuments({
      ...queryCollege,
      status: LISTING_STATUS.CLOSED,
    });

    // 5. Unique listings that have at least one buyer chat interaction
    const listingsWithChat = (
      await Conversation.distinct('listingId', {
        ...queryCollege,
      })
    ).length;

    // 6. Conversion metrics
    // Listing-to-chat conversion: (listings with at least 1 chat) / (total listings created)
    const listingToChatConversionRate =
      totalListings > 0 ? ((listingsWithChat / totalListings) * 100).toFixed(1) : '0.0';

    // Listing-to-sale conversion: (sold listings) / (total listings created)
    const listingToSaleConversionRate =
      totalListings > 0 ? ((soldListings / totalListings) * 100).toFixed(1) : '0.0';

    // 7. Pilot Targets evaluation
    const targets = {
      verifiedSignupsTarget: 100,
      verifiedSignupsCurrent: verifiedSignups,
      verifiedSignupsMet: verifiedSignups >= 100,

      activeListingsTarget: 50,
      activeListingsCurrent: activeListings,
      activeListingsMet: activeListings >= 50,

      listingToChatTargetPercent: 50.0,
      listingToChatCurrentPercent: parseFloat(listingToChatConversionRate),
      listingToChatMet: parseFloat(listingToChatConversionRate) >= 50.0,

      listingToSaleTargetPercent: 30.0,
      listingToSaleCurrentPercent: parseFloat(listingToSaleConversionRate),
      listingToSaleMet: parseFloat(listingToSaleConversionRate) >= 30.0,

      targetResponseTimeSeconds: env.TARGET_RESPONSE_TIME_MS / 1000,
      targetAvailabilityPercent: env.TARGET_AVAILABILITY_PERCENT,
    };

    return {
      collegeId: collegeId || 'all',
      summary: {
        verifiedSignups,
        totalListings,
        activeListings,
        soldListings,
        closedCancelledListings,
        listingsWithChat,
        listingToChatConversionRate: `${listingToChatConversionRate}%`,
        listingToSaleConversionRate: `${listingToSaleConversionRate}%`,
      },
      targets,
      timestamp: new Date().toISOString(),
    };
  }
}

module.exports = new MetricsService();
