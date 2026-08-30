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

  const ListingDetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isSeller = authProvider.currentStudent?.studentId == listing.sellerId;
    final formattedDate = DateFormat.yMMMMd().format(listing.createdAt);
    final categoryColor = _getCategoryAccentColor(listing.category);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Item Details', style: TextStyle(fontWeight: FontWeight.w800)),
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
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: AppTheme.dividerColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Header Area with Gradient Backdrop
            Container(
              height: 230,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    categoryColor.withValues(alpha: 0.15),
                    const Color(0xFFF1F5F9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: const Border(bottom: BorderSide(color: AppTheme.dividerColor, width: 1)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: categoryColor.withValues(alpha: 0.3), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor.withValues(alpha: 0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getCategoryIcon(listing.category),
                        size: 58,
                        color: categoryColor,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: ConditionBadge(condition: listing.condition),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: StatusBadge(status: listing.status),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Date Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Text(
                          listing.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: categoryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Text(
                        'Listed $formattedDate',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Price
                  Text(
                    '₹${listing.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryColor,
                      letterSpacing: -0.8,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Title
                  Text(
                    listing.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.3,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 18),
                  const Divider(),
                  const SizedBox(height: 18),

                  // Description Section
                  const Text(
                    'Item Description',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.dividerColor),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      listing.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.55,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Seller Profile Card
                  const Text(
                    'Seller Information',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.dividerColor),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            gradient: AppTheme.heroCardGradient,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              listing.sellerName.isNotEmpty
                                  ? listing.sellerName.substring(0, 1).toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ),
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
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Row(
                                children: [
                                  Icon(Icons.verified_rounded, size: 14, color: AppTheme.successColor),
                                  SizedBox(width: 4),
                                  Text(
                                    'Verified AVIH Student',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF047857),
                                      fontWeight: FontWeight.w700,
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

                  const SizedBox(height: 20),

                  // Safety Advice Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: AppTheme.trustGradient,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.shield_rounded, size: 20, color: AppTheme.successColor),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Campus Peer Exchange Safety',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF065F46),
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Meet inside campus areas (Library, Canteen, Student Lounge) for physical inspection before completing handover.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF047857),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppTheme.dividerColor, width: 1)),
          ),
          child: isSeller
              ? OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.editListing, arguments: listing);
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Manage My Listing'),
                )
              : Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: listing.isActive ? AppTheme.buttonGradient : null,
                    color: listing.isActive ? null : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: listing.isActive ? AppTheme.glowButtonShadow : null,
                  ),
                  child: ElevatedButton.icon(
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Colors.white),
                    label: Text(
                      listing.isActive ? 'Chat with Seller' : 'Item Unavailable',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
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

  Color _getCategoryAccentColor(String category) {
    final value = category.toLowerCase();
    if (value.contains('book') || value.contains('academic')) return const Color(0xFF2563EB);
    if (value.contains('calculator')) return const Color(0xFF0284C7);
    if (value.contains('drawing') || value.contains('graphics')) return const Color(0xFF4F46E5);
    if (value.contains('lab')) return const Color(0xFF059669);
    if (value.contains('hostel')) return const Color(0xFFD97706);
    if (value.contains('electronic')) return const Color(0xFF0EA5E9);
    return const Color(0xFF1E3A8A);
  }
}
