/**
 * In-memory / DB-assisted idempotency deduplicator for pilot events and critical transactions
 */
const processedEvents = new Map();
const TTL_MS = 60 * 60 * 1000; // 1 hour

const isDuplicate = (key) => {
  if (!key) return false;
  const now = Date.now();
  const timestamp = processedEvents.get(key);
  if (timestamp && now - timestamp < TTL_MS) {
    return true;
  }
  processedEvents.set(key, now);
  // Clean up periodically
  if (processedEvents.size > 10000) {
    for (const [k, v] of processedEvents.entries()) {
      if (now - v >= TTL_MS) {
        processedEvents.delete(k);
      }
    }
  }
  return false;
};

module.exports = {
  isDuplicate,
};
