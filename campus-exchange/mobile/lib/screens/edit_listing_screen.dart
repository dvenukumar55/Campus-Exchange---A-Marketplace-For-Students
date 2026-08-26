import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/listing.dart';
import '../providers/listing_provider.dart';

class EditListingScreen extends StatefulWidget {
  final Listing listing;

  const EditListingScreen({
    Key? key,
    required this.listing,
  }) : super(key: key);

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _selectedStatus;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.listing.status;
  }

  Future<void> _updateListing() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedStatus == widget.listing.status) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final listingProvider = Provider.of<ListingProvider>(context, listen: false);
      
      final finalStatus = _selectedStatus.toLowerCase() == 'sold' ? 'sold' : 'active';

      await listingProvider.closeListing(
        widget.listing.listingId,
        finalStatus,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Listing status updated successfully!', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: finalStatus == 'sold' ? AppTheme.tealAccent : AppTheme.successColor,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: ${e.toString()}', style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Manage Listing', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Managing: ${widget.listing.title}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Listing Status'),
              const SizedBox(height: 12),
              const Text('Only changing status is supported. Contact campus moderators if you need to delete a listing.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Active (Available)', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successColor))),
                      DropdownMenuItem(value: 'sold', child: Text('Sold (Unavailable)', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.errorColor))),
                    ],
                    onChanged: _isSubmitting ? null : (v) => setState(() => _selectedStatus = v!),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _updateListing,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('Update Status'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }
}
