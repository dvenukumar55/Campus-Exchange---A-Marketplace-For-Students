import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/listing.dart';
import '../providers/listing_provider.dart';
import '../widgets/status_badge.dart';

class EditListingScreen extends StatefulWidget {
  final Listing listing;

  const EditListingScreen({
    super.key,
    required this.listing,
  });

  @override
  State<EditListingScreen> createState() =>
      _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  late String _currentStatus;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.listing.status;
  }

  Future<void> _updateStatus(String newStatus) async {
    if (_isUpdating || newStatus == _currentStatus) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final listingProvider =
          Provider.of<ListingProvider>(context, listen: false);

      await listingProvider.closeListing(
        widget.listing.listingId,
        newStatus,
      );

      if (!mounted) return;

      setState(() {
        _currentStatus = newStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Status updated to $newStatus',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update status: $e',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Manage Listing',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1,
            color: AppTheme.dividerColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.dividerColor,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A)
                        .withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '₹${widget.listing.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(
                        status: _currentStatus,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.listing.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Category: ${widget.listing.category} • Condition: ${widget.listing.condition}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.dividerColor,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A)
                        .withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Listing Availability Status',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Update availability when an item is exchanged or completed',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _buildStatusActionTile(
                    title: 'Mark as Active / Available',
                    subtitle:
                        'Item is visible to peers in the campus marketplace',
                    icon: Icons.check_circle_outline_rounded,
                    color: AppTheme.successColor,
                    targetStatus: 'active',
                  ),
                  const Divider(height: 16),
                  _buildStatusActionTile(
                    title: 'Mark as Sold / Exchanged',
                    subtitle:
                        'Item has been successfully handed over to a peer',
                    icon: Icons.handshake_outlined,
                    color: AppTheme.royalBlue,
                    targetStatus: 'sold',
                  ),
                  const Divider(height: 16),
                  _buildStatusActionTile(
                    title: 'Close Listing',
                    subtitle:
                        'Remove listing from marketplace visibility',
                    icon: Icons.cancel_outlined,
                    color: AppTheme.errorColor,
                    targetStatus: 'closed',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String targetStatus,
  }) {
    final isCurrent =
        _currentStatus.toLowerCase() ==
            targetStatus.toLowerCase();

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight:
              isCurrent ? FontWeight.w800 : FontWeight.w600,
          color:
              isCurrent ? color : AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 11,
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: isCurrent
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'CURRENT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            )
          : _isUpdating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : OutlinedButton(
                  onPressed: () =>
                      _updateStatus(targetStatus),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(70, 34),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                  ),
                  child: const Text(
                    'Set',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
    );
  }
}