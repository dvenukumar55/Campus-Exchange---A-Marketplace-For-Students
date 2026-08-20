import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/listing.dart';
import '../providers/listing_provider.dart';
import '../widgets/custom_text_field.dart';

class EditListingScreen extends StatefulWidget {
  final Listing listing;

  const EditListingScreen({Key? key, required this.listing}) : super(key: key);

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late String _selectedCategory;
  late String _selectedCondition;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.listing.title);
    _priceController = TextEditingController(text: widget.listing.price.toStringAsFixed(0));
    _descriptionController = TextEditingController(text: widget.listing.description);
    _selectedCategory = widget.listing.category;
    _selectedCondition = widget.listing.condition;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleCloseOrSell(String finalStatus) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(finalStatus == 'sold' ? 'Mark as Sold?' : 'Close Listing?'),
        content: Text(
          finalStatus == 'sold'
              ? 'This will record a completed campus transaction and move the listing to Sold.'
              : 'This will close the listing from the campus marketplace feed.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: finalStatus == 'sold' ? AppTheme.secondaryColor : AppTheme.errorColor,
              minimumSize: const Size(100, 40),
            ),
            child: Text(finalStatus == 'sold' ? 'Confirm Sale' : 'Close'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final listingProvider = Provider.of<ListingProvider>(context, listen: false);
      await listingProvider.closeListing(widget.listing.listingId, finalStatus);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Listing marked as $finalStatus successfully!'),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppTheme.errorColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Listing'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Item Title',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _priceController,
                label: 'Price (₹)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 4,
              ),
              const SizedBox(height: 28),

              // Action buttons for lifecycle closure
              if (widget.listing.isActive) ...[
                const Text(
                  'Listing Status Actions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _handleCloseOrSell('sold'),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Mark as Sold (Transaction Completed)'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryColor),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _handleCloseOrSell('closed'),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Close / Delist Item'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.errorColor),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This listing is ${widget.listing.status.toUpperCase()} and cannot be modified.',
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
