import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/listing.dart';
import 'condition_badge.dart';
import 'status_badge.dart';

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
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area with fallback gradient placeholder
            Container(
              height: 160,
              width: double.infinity,
              color: const Color(0xFFE2E8F0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: Icon(
                      _getCategoryIcon(listing.category),
                      size: 64,
                      color: AppTheme.primaryColor.withOpacity(0.35),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: StatusBadge(status: listing.status),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: ConditionBadge(condition: listing.condition),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${listing.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          listing.category,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    listing.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.school_outlined, size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          listing.sellerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
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
    );
  }

  IconData _getCategoryIcon(String category) {
    if (category.contains('Books') || category.contains('Academic')) return Icons.menu_book;
    if (category.contains('Calculator')) return Icons.calculate;
    if (category.contains('Drawing') || category.contains('Graphics')) return Icons.architecture;
    if (category.contains('Lab')) return Icons.biotech;
    if (category.contains('Hostel')) return Icons.night_shelter;
    if (category.contains('Electronics')) return Icons.devices;
    if (category.contains('Uniforms')) return Icons.checkroom;
    return Icons.inventory_2;
  }
}
