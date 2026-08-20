const { isDuplicate } = require('../../src/utils/eventDeduplicator');

describe('Unit Test: Duplicate Event Prevention (T-026, T-032)', () => {
  test('Identifies duplicate pilot event key within TTL window', () => {
    const key = 'test_action_event_12345';
    expect(isDuplicate(key)).toBe(false);
    // Second submission with exact same key must be flagged as duplicate
    expect(isDuplicate(key)).toBe(true);
  });

  test('Different keys are not marked as duplicate', () => {
    expect(isDuplicate('event_A')).toBe(false);
    expect(isDuplicate('event_B')).toBe(false);
  });
});
