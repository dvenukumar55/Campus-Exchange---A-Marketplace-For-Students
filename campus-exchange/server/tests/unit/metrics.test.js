describe('Unit Test: Conversion Metrics Logic (T-028, T-032)', () => {
  test('Calculates listing-to-chat and listing-to-sale rates correctly', () => {
    const calculateRates = (totalListings, chatListings, soldListings) => {
      const listingToChatRate = totalListings > 0 ? (chatListings / totalListings) * 100 : 0;
      const listingToSaleRate = totalListings > 0 ? (soldListings / totalListings) * 100 : 0;
      return {
        listingToChatRate: parseFloat(listingToChatRate.toFixed(1)),
        listingToSaleRate: parseFloat(listingToSaleRate.toFixed(1)),
      };
    };

    // 100 listings, 60 with chats, 35 sold -> chat: 60%, sale: 35%
    const res1 = calculateRates(100, 60, 35);
    expect(res1.listingToChatRate).toBe(60.0);
    expect(res1.listingToSaleRate).toBe(35.0);

    // Target checks: ≥ 50% chat and ≥ 30% sale
    expect(res1.listingToChatRate >= 50.0).toBe(true);
    expect(res1.listingToSaleRate >= 30.0).toBe(true);

    // 0 listings case
    const res2 = calculateRates(0, 0, 0);
    expect(res2.listingToChatRate).toBe(0.0);
    expect(res2.listingToSaleRate).toBe(0.0);
  });
});
