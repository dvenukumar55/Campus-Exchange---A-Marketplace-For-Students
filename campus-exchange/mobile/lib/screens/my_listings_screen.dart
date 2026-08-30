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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Listings', style: TextStyle(fontWeight: FontWeight.w800)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: AppTheme.dividerColor),
        ),
      ),
      body: myListings.isEmpty
          ? EmptyStateView(
              title: 'No Listed Items Yet',
              message: 'You have not listed any academic items for sale yet. Turn your unused textbooks and lab supplies into cash!',
              icon: Icons.inventory_2_outlined,
              actionLabel: 'Sell an Item',
              onAction: () => Navigator.pushNamed(context, AppRoutes.createListing),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryColor,
                  letterSpacing: -0.5,
                ),
              ),
              StatusBadge(status: item.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Category: ${item.category} • Condition: ${item.condition}',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.listingDetail, arguments: item);
                },
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: const Text('View Detail'),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.editListing, arguments: item);
                  },
                  icon: const Icon(Icons.edit_outlined, size: 16, color: AppTheme.royalBlue),
                  label: const Text('Manage Status', style: TextStyle(color: AppTheme.royalBlue, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
