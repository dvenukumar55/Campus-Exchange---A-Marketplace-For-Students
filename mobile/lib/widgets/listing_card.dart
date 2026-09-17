import 'package:flutter/material.dart';

import '../core/constants/api_constants.dart';
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
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF111936),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: categoryColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: categoryColor.withValues(alpha: 0.12),
          highlightColor: categoryColor.withValues(alpha: 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMediaSection(
                categoryIcon,
                categoryColor,
              ),
              _buildContentSection(categoryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaSection(
    IconData categoryIcon,
    Color categoryColor,
  ) {
    return Container(
      height: 148,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            categoryColor.withValues(alpha: 0.22),
            const Color(0xFF0F172A),
            const Color(0xFF0B1128),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(19),
          topRight: Radius.circular(19),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -25,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: categoryColor.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            left: -35,
            bottom: -35,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2563EB).withValues(alpha: 0.1),
              ),
            ),
          ),
          if (listing.photoRefs.isNotEmpty)
            Positioned.fill(
              child: Image.network(
                '${ApiConstants.uploadsUrl}/${listing.photoRefs.first}',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildCategoryIconFallback(
                  categoryIcon,
                  categoryColor,
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildCategoryIconFallback(
                    categoryIcon,
                    categoryColor,
                  );
                },
              ),
            )
          else
            _buildCategoryIconFallback(categoryIcon, categoryColor),
          Positioned(
            top: 10,
            left: 10,
            child: ConditionBadge(
              condition: listing.condition,
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: StatusBadge(
              status: listing.status,
            ),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: _buildCategoryBadge(categoryColor),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: _buildOpenButton(categoryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIconFallback(
    IconData categoryIcon,
    Color categoryColor,
  ) {
    return Center(
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: const Color(0xFF111936),
          shape: BoxShape.circle,
          border: Border.all(
            color: categoryColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: categoryColor.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          categoryIcon,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(Color categoryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1128).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: categoryColor.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: categoryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: categoryColor.withValues(alpha: 0.7),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Text(
            listing.category.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              color: categoryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenButton(Color categoryColor) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0xFF0B1128).withValues(alpha: 0.85),
        shape: BoxShape.circle,
        border: Border.all(
          color: categoryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Icon(
        Icons.arrow_forward_rounded,
        size: 15,
        color: categoryColor,
      ),
    );
  }

  Widget _buildContentSection(Color categoryColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
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
                    _buildPriceRow(),
                    const SizedBox(height: 5),
                    Text(
                      listing.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.07),
          ),
          const SizedBox(height: 10),
          _buildSellerRow(categoryColor),
        ],
      ),
    );
  }

  Widget _buildPriceRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '₹${listing.price.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 7),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 2.5,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF17224D),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: const Color(0xFF6366F1).withValues(alpha: 0.25),
            ),
          ),
          child: const Text(
            'FIXED',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: Color(0xFF818CF8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSellerRow(Color categoryColor) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: categoryColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: categoryColor.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            Icons.person_rounded,
            size: 15,
            color: categoryColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      listing.sellerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.verified_rounded,
                    size: 13,
                    color: Color(0xFF22C55E),
                  ),
                ],
              ),
              const SizedBox(height: 1),
              const Text(
                'Verified campus seller',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 7,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.school_outlined,
                size: 11,
                color: Color(0xFFCBD5E1),
              ),
              SizedBox(width: 4),
              Text(
                'Campus',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFCBD5E1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    final value = category.toLowerCase();

    if (value.contains('book') || value.contains('academic')) {
      return Icons.menu_book_rounded;
    }

    if (value.contains('calculator')) {
      return Icons.calculate_rounded;
    }

    if (value.contains('drawing') || value.contains('graphics')) {
      return Icons.architecture_rounded;
    }

    if (value.contains('lab')) {
      return Icons.biotech_rounded;
    }

    if (value.contains('hostel')) {
      return Icons.bed_rounded;
    }

    if (value.contains('electronic')) {
      return Icons.devices_rounded;
    }

    if (value.contains('uniform') || value.contains('apron')) {
      return Icons.checkroom_rounded;
    }

    if (value.contains('sport')) {
      return Icons.sports_basketball_rounded;
    }

    return Icons.inventory_2_rounded;
  }

  Color _getCategoryAccentColor(String category) {
    final value = category.toLowerCase();

    if (value.contains('book') || value.contains('academic')) {
      return const Color(0xFF818CF8);
    }

    if (value.contains('calculator')) {
      return const Color(0xFF38BDF8);
    }

    if (value.contains('drawing') || value.contains('graphics')) {
      return const Color(0xFFA78BFA);
    }

    if (value.contains('lab')) {
      return const Color(0xFF2DD4BF);
    }

    if (value.contains('hostel')) {
      return const Color(0xFFFB923C);
    }

    if (value.contains('electronic')) {
      return const Color(0xFF60A5FA);
    }

    if (value.contains('uniform') || value.contains('apron')) {
      return const Color(0xFFF472B6);
    }

    if (value.contains('sport')) {
      return const Color(0xFFFB7185);
    }

    return const Color(0xFF6366F1);
  }
}
