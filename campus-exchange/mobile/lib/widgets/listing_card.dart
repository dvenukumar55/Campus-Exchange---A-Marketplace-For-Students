import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/listing.dart';
import 'condition_badge.dart';
import 'status_badge.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;

  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryIcon = _getCategoryIcon(listing.category);
    final categoryColor = _getCategoryAccentColor(listing.category);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Image / Media Area with Branded Visual Layering
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      categoryColor.withValues(alpha: 0.12),
                      const Color(0xFFF1F5F9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Stack(
                  children: [
                    // Center Icon / Illustration Anchor
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: categoryColor.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: categoryColor.withValues(alpha: 0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          categoryIcon,
                          size: 34,
                          color: categoryColor,
                        ),
                      ),
                    ),

                    // Top Left: Condition Badge
                    Positioned(
                      top: 10,
                      left: 10,
                      child: ConditionBadge(condition: listing.condition),
                    ),

                    // Top Right: Status Badge
                    Positioned(
                      top: 10,
                      right: 10,
                      child: StatusBadge(status: listing.status),
                    ),

                    // Bottom Left: Category Indicator Tag
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.dividerColor),
                        ),
                        child: Text(
                          listing.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: categoryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content Area
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price & Title Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₹${listing.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.primaryColor,
                                  letterSpacing: -0.6,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                listing.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                  height: 1.25,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: AppTheme.royalBlue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 10),

                    // Seller Information Footer
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEFF6FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 14,
                            color: AppTheme.royalBlue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  listing.sellerName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified_rounded,
                                color: AppTheme.successColor,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Campus Peer',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    final value = category.toLowerCase();
    if (value.contains('book') || value.contains('academic')) return Icons.menu_book_rounded;
    if (value.contains('calculator')) return Icons.calculate_rounded;
    if (value.contains('drawing') || value.contains('graphics')) return Icons.architecture_rounded;
    if (value.contains('lab')) return Icons.biotech_rounded;
    if (value.contains('hostel')) return Icons.bed_rounded;
    if (value.contains('electronic')) return Icons.devices_rounded;
    if (value.contains('uniform') || value.contains('apron')) return Icons.checkroom_rounded;
    if (value.contains('sport')) return Icons.sports_basketball_rounded;
    return Icons.inventory_2_rounded;
  }

  Color _getCategoryAccentColor(String category) {
    final value = category.toLowerCase();
    if (value.contains('book') || value.contains('academic')) return const Color(0xFF2563EB); // Royal Blue
    if (value.contains('calculator')) return const Color(0xFF0284C7); // Cyan
    if (value.contains('drawing') || value.contains('graphics')) return const Color(0xFF4F46E5); // Indigo
    if (value.contains('lab')) return const Color(0xFF059669); // Emerald
    if (value.contains('hostel')) return const Color(0xFFD97706); // Amber
    if (value.contains('electronic')) return const Color(0xFF0EA5E9); // Sky Blue
    return const Color(0xFF1E3A8A); // Midnight Blue
  }
}