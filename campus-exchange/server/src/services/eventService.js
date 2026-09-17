const { v4: uuidv4 } = require('uuid');
const PilotEvent = require('../models/PilotEvent');
const logger = require('../utils/logger');
const { isDuplicate } = require('../utils/eventDeduplicator');

/**
 * Service to record and deduplicate pilot events for metric measurement
 */
class EventService {
  /**
   * Records a pilot event with deduplication protection
   */
  async recordEvent({ eventId, eventType, collegeId, studentId, listingId, metadata = {} }) {
    try {
      const generatedEventId = eventId || `evt_${uuidv4()}`;

      // Check in-memory deduplicator to prevent bursts
      const dedupeKey = `${eventType}:${collegeId}:${studentId || ''}:${listingId || ''}:${metadata?.actionId || ''}`;
      if (isDuplicate(dedupeKey)) {
        logger.info('Suppressed duplicate pilot event submission', { dedupeKey, eventType });
        return { eventId: generatedEventId, recorded: false, duplicate: true };
      }

      // Check DB for identical eventId
      const existing = await PilotEvent.findOne({ eventId: generatedEventId });
      if (existing) {
        logger.info('Pilot event with same eventId already recorded', { eventId: generatedEventId });
        return { eventId: existing.eventId, recorded: false, duplicate: true };
      }

      const pilotEvent = new PilotEvent({
        eventId: generatedEventId,
        eventType,
        collegeId,
        studentId,
        listingId,
        occurredAt: new Date(),
        metadata,
      });

      await pilotEvent.save();

      logger.info('Pilot Event Recorded', {
        eventId: generatedEventId,
        eventType,
        collegeId,
        listingId,
      });

      return { eventId: generatedEventId, recorded: true, duplicate: false };
    } catch (error) {
      logger.error('Failed to record pilot event', { error: error.message, eventType });
      // Do not break the user transaction if metric recording encounters a transient failure
      return { eventId: null, recorded: false, error: error.message };
    }
  }
}

module.exports = new EventService();
