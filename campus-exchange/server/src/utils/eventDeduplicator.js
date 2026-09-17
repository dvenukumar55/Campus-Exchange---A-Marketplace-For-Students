/**
 * In-memory / DB-assisted idempotency deduplicator for pilot events and critical transactions
 */
const processedEvents = new Map();
const DEFAULT_TTL_MS = 5 * 60 * 1000; // 5 minutes

const isDuplicate = (key, ttlMs = DEFAULT_TTL_MS) => {
  if (!key) return false;
  const now = Date.now();
  const timestamp = processedEvents.get(key);
  if (timestamp && now - timestamp < ttlMs) {
    return true;
  }
  processedEvents.set(key, now);
  // Clean up periodically
  if (processedEvents.size > 5000) {
    for (const [k, v] of processedEvents.entries()) {
      if (now - v >= ttlMs) {
        processedEvents.delete(k);
      }
    }
  }
  return false;
};

module.exports = {
  isDuplicate,
};
