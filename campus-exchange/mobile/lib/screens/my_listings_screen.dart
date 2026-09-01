import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/listing.dart';
import '../providers/auth_provider.dart';
import '../providers/listing_provider.dart';
import '../routes/app_routes.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/status_badge.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final listingProvider = Provider.of<ListingProvider>(context);
    final currentStudentId = authProvider.currentStudent?.studentId;

    final myListings = listingProvider.listings
        .where((item) => item.sellerId == currentStudentId)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1128),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1128),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'My Listings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ),
      body: myListings.isEmpty
          ? EmptyStateView(
              title: 'No Listed Items Yet',
              message:
                  'You have not listed any academic items for sale yet. Turn your unused textbooks and lab supplies into cash!',
              icon: Icons.inventory_2_outlined,
              actionLabel: 'Sell an Item',
              onAction: () =>
                  Navigator.pushNamed(context, AppRoutes.createListing),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              itemCount: myListings.length,
              itemBuilder: (context, index) {
                final item = myListings[index];
                return _buildMyListingItemCard(context, item);
              },
            ),
    );
  }

  Widget _buildMyListingItemCard(BuildContext context, Listing item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111936),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${item.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              StatusBadge(status: item.status),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Category: ${item.category} • Condition: ${item.condition}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.06),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.listingDetail,
                    arguments: item,
                  );
                },
                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 16,
                  color: Color(0xFF94A3B8),
                ),
                label: const Text(
                  'View Detail',
                  style: TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 12.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.buttonGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.editListing,
                      arguments: item,
                    );
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 15,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Manage Status',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
