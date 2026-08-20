import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/listing.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import '../widgets/condition_badge.dart';
import '../widgets/status_badge.dart';

class ListingDetailScreen extends StatelessWidget {
  final Listing listing;

  const ListingDetailScreen({Key? key, required this.listing}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isSeller = authProvider.currentStudent?.studentId == listing.sellerId;
    final formattedDate = DateFormat.yMMMMd().format(listing.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        actions: [
          if (!isSeller)
            IconButton(
              icon: const Icon(Icons.flag_outlined),
              tooltip: 'Report Listing',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.report,
                  arguments: listing,
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo Header
            Container(
              height: 240,
              width: double.infinity,
              color: const Color(0xFFE2E8F0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: Icon(
                      Icons.menu_book,
                      size: 96,
                      color: AppTheme.primaryColor.withOpacity(0.3),
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
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          listing.category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        'Listed $formattedDate',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    listing.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price
                  Text(
                    '₹${listing.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const Divider(height: 32),

                  // Description
                  const Text(
                    'Item Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    listing.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const Divider(height: 32),

                  // Seller Info Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          child: const Icon(Icons.person, color: AppTheme.primaryColor),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                listing.sellerName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Verified Student • AVIH Campus',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.secondaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isSeller
              ? OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.editListing, arguments: listing);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Manage / Edit My Listing'),
                )
              : ElevatedButton.icon(
                  onPressed: listing.isActive
                      ? () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.chat,
                            arguments: {
                              'listing': listing,
                              'listingId': listing.listingId,
                            },
                          );
                        }
                      : null,
                  icon: const Icon(Icons.chat),
                  label: Text(listing.isActive ? 'Chat with Seller' : 'Item Sold / Unavailable'),
                ),
        ),
      ),
    );
  }
}
