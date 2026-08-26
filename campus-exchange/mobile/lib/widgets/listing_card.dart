import 'package:flutter/material.dart';
import '../models/listing.dart';
import 'condition_badge.dart';
import 'status_badge.dart';
import '../core/theme/app_theme.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;

  const ListingCard({
    Key? key,
    required this.listing,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(listing.category);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Image Area
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      categoryColor.withOpacity(0.15),
                      categoryColor.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: categoryColor.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getCategoryIcon(listing.category),
                          size: 48,
                          color: categoryColor,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: StatusBadge(status: listing.status),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: ConditionBadge(condition: listing.condition),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          listing.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: categoryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Info Area
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                listing.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppTheme.violetAccent.withOpacity(0.1),
                          child: const Icon(Icons.person_rounded, size: 18, color: AppTheme.violetAccent),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Listed by',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              Text(
                                listing.sellerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.verified_rounded, color: AppTheme.successColor, size: 20),
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
    return Icons.inventory_2_rounded;
  }

  Color _getCategoryColor(String category) {
    final value = category.toLowerCase();
    if (value.contains('book') || value.contains('academic')) return AppTheme.violetAccent;
    if (value.contains('drawing') || value.contains('graphics')) return AppTheme.tealAccent;
    if (value.contains('lab')) return AppTheme.successColor;
    if (value.contains('electronic')) return AppTheme.blueAccent;
    if (value.contains('uniform') || value.contains('apron')) return AppTheme.warningColor;
    if (value.contains('hostel')) return const Color(0xFFEC4899);
    return AppTheme.primaryColor;
  }
}