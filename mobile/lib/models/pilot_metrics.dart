class PilotMetrics {
  final int verifiedSignups;
  final int totalListings;
  final int activeListings;
  final int soldListings;
  final int closedCancelledListings;
  final int listingsWithChat;
  final String listingToChatConversionRate;
  final String listingToSaleConversionRate;

  // Target values
  final int verifiedSignupsTarget;
  final bool verifiedSignupsMet;
  final int activeListingsTarget;
  final bool activeListingsMet;
  final double listingToChatTargetPercent;
  final bool listingToChatMet;
  final double listingToSaleTargetPercent;
  final bool listingToSaleMet;

  PilotMetrics({
    required this.verifiedSignups,
    required this.totalListings,
    required this.activeListings,
    required this.soldListings,
    required this.closedCancelledListings,
    required this.listingsWithChat,
    required this.listingToChatConversionRate,
    required this.listingToSaleConversionRate,
    required this.verifiedSignupsTarget,
    required this.verifiedSignupsMet,
    required this.activeListingsTarget,
    required this.activeListingsMet,
    required this.listingToChatTargetPercent,
    required this.listingToChatMet,
    required this.listingToSaleTargetPercent,
    required this.listingToSaleMet,
  });

  factory PilotMetrics.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    final targets = json['targets'] as Map<String, dynamic>? ?? {};

    return PilotMetrics(
      verifiedSignups: summary['verifiedSignups'] ?? 0,
      totalListings: summary['totalListings'] ?? 0,
      activeListings: summary['activeListings'] ?? 0,
      soldListings: summary['soldListings'] ?? 0,
      closedCancelledListings: summary['closedCancelledListings'] ?? 0,
      listingsWithChat: summary['listingsWithChat'] ?? 0,
      listingToChatConversionRate: summary['listingToChatConversionRate'] ?? '0.0%',
      listingToSaleConversionRate: summary['listingToSaleConversionRate'] ?? '0.0%',
      verifiedSignupsTarget: targets['verifiedSignupsTarget'] ?? 100,
      verifiedSignupsMet: targets['verifiedSignupsMet'] ?? false,
      activeListingsTarget: targets['activeListingsTarget'] ?? 50,
      activeListingsMet: targets['activeListingsMet'] ?? false,
      listingToChatTargetPercent: (targets['listingToChatTargetPercent'] as num?)?.toDouble() ?? 50.0,
      listingToChatMet: targets['listingToChatMet'] ?? false,
      listingToSaleTargetPercent: (targets['listingToSaleTargetPercent'] as num?)?.toDouble() ?? 30.0,
      listingToSaleMet: targets['listingToSaleMet'] ?? false,
    );
  }
}
