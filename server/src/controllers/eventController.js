const eventService = require('../services/eventService');
const { sendSuccess } = require('../utils/response');

class EventController {
  /**
   * POST /api/v1/events
   * Client-reported pilot telemetry/interaction event with server-side validation & deduplication
   */
  async recordEvent(req, res, next) {
    try {
      const result = await eventService.recordEvent({
        eventId: req.validatedEvent.eventId,
        eventType: req.validatedEvent.eventType,
        collegeId: req.student.collegeId,
        studentId: req.student.studentId,
        listingId: req.validatedEvent.listingId,
        metadata: req.validatedEvent.metadata,
      });

      if (result.duplicate) {
        return sendSuccess(res, 200, {
          eventId: result.eventId,
          recorded: false,
          message: 'Duplicate event detected and deduplicated',
        });
      }

      return sendSuccess(res, 201, {
        eventId: result.eventId,
        recorded: true,
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new EventController();
