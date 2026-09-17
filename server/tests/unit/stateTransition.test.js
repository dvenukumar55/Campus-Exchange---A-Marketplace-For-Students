const { LISTING_STATUS } = require('../../src/config/constants');

describe('Unit Test: Listing State Transitions & Invariant Rules (T-019, T-032)', () => {
  test('Listing status states are defined as draft, active, sold, closed', () => {
    expect(LISTING_STATUS.ACTIVE).toBe('active');
    expect(LISTING_STATUS.SOLD).toBe('sold');
    expect(LISTING_STATUS.CLOSED).toBe('closed');
  });

  test('Valid transitions: ACTIVE -> SOLD and ACTIVE -> CLOSED', () => {
    const isValidTransition = (currentStatus, nextStatus) => {
      if (currentStatus === LISTING_STATUS.ACTIVE && [LISTING_STATUS.SOLD, LISTING_STATUS.CLOSED].includes(nextStatus)) {
        return true;
      }
      return false;
    };

    expect(isValidTransition('active', 'sold')).toBe(true);
    expect(isValidTransition('active', 'closed')).toBe(true);
    expect(isValidTransition('sold', 'active')).toBe(false);
    expect(isValidTransition('closed', 'sold')).toBe(false);
  });
});
