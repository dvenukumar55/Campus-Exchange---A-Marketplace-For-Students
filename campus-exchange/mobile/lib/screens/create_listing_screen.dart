import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/listing.dart';
import '../providers/listing_provider.dart';
import '../services/listing_service.dart';
import '../widgets/custom_text_field.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();
  final ListingService _listingService = ListingService();

  String _selectedCategory = AppConstants.formCategories.first;
  String _selectedCondition = 'Good';

  final List<File> _selectedImages = [];
  final List<String> _photoRefs = [];

  bool _isSubmitting = false;
  bool _isUploadingImage = false;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_isSubmitting || _isUploadingImage) return;

    try {
      final List<XFile> pickedImages = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (pickedImages.isEmpty) return;

      final remainingSlots = 5 - _selectedImages.length;

      if (remainingSlots <= 0) {
        _showMessage('You can add a maximum of 5 photos.', isError: true);
        return;
      }

      final imagesToAdd = pickedImages.take(remainingSlots).toList();

      setState(() {
        for (final image in imagesToAdd) {
          final file = File(image.path);
          final alreadyAdded = _selectedImages.any((existing) => existing.path == file.path);
          if (!alreadyAdded) {
            _selectedImages.add(file);
          }
        }
      });

      if (pickedImages.length > remainingSlots) {
        _showMessage('Only 5 photos can be added to one listing.', isError: true);
      }
    } catch (e) {
      _showMessage('Unable to open gallery: $e', isError: true);
    }
  }

  void _removeImage(int index) {
    if (_isSubmitting || _isUploadingImage) return;
    setState(() {
      _selectedImages.removeAt(index);
      if (index < _photoRefs.length) {
        _photoRefs.removeAt(index);
      }
    });
  }

  Future<void> _uploadSelectedImages() async {
    if (_selectedImages.isEmpty) {
      throw Exception('Please add at least one item photo.');
    }

    setState(() {
      _isUploadingImage = true;
    });

    try {
      _photoRefs.clear();
      for (final image in _selectedImages) {
        final photoRef = await _listingService.uploadListingImage(image);
        if (photoRef.isEmpty) {
          throw Exception('The server did not return a valid photo reference.');
        }
        _photoRefs.add(photoRef);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  void _loadJavaBookPreset() {
    setState(() {
      _titleController.text = 'Scientific Calculator (FX-991EX)';
      _priceController.text = '500';
      _selectedCategory = 'Scientific Calculators';
      _selectedCondition = 'Good';
      _descriptionController.text =
          'Scientific calculator in excellent working condition. Essential for engineering mathematics and physics labs.';
    });
  }

  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      _showMessage('Please add at least one item photo.', isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _uploadSelectedImages();
      if (_photoRefs.isEmpty) {
        throw Exception('No uploaded photo references were returned.');
      }

      if (!mounted) return;
      final listingProvider = Provider.of<ListingProvider>(context, listen: false);
      final Listing listing = await listingProvider.createListing(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        price: double.parse(_priceController.text.trim()),
        condition: _selectedCondition,
        photoRefs: List<String>.from(_photoRefs),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${listing.title} was published successfully!',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Failed to create listing: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Sell an Item', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          TextButton.icon(
            onPressed: _isSubmitting ? null : _loadJavaBookPreset,
            icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
            label: const Text('Sample Preset'),
          ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: AppTheme.dividerColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Photos Section Card
              _buildFormSectionCard(
                stepNumber: '1',
                title: 'Item Photos',
                subtitle: 'Add up to 5 photos (at least 1 required)',
                child: Column(
                  children: [
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ..._selectedImages.asMap().entries.map((entry) {
                            final index = entry.key;
                            final image = entry.value;
                            return Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.dividerColor),
                                image: DecorationImage(
                                  image: FileImage(image),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.black87,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, size: 12, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          if (_selectedImages.length < 5)
                            GestureDetector(
                              onTap: _pickImages,
                              child: Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFBFDBFE),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo_outlined, color: AppTheme.royalBlue, size: 24),
                                    SizedBox(height: 4),
                                    Text(
                                      'Add Photo',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.royalBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Basic Information Card
              _buildFormSectionCard(
                stepNumber: '2',
                title: 'Basic Information',
                subtitle: 'Specify what you are listing and the asking price',
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _titleController,
                      label: 'Listing Title',
                      hint: 'e.g. Scientific Calculator',
                      validator: (val) {
                        if (val == null || val.trim().length < 3) return 'Title must be at least 3 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _priceController,
                      label: 'Selling Price (₹)',
                      hint: 'e.g. 500',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.currency_rupee_rounded,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Price is required';
                        final price = double.tryParse(val.trim());
                        if (price == null || price < 0) return 'Enter a valid amount';
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Item Details Card
              _buildFormSectionCard(
                stepNumber: '3',
                title: 'Category & Condition',
                subtitle: 'Accurate classification helps peers find your item faster',
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Category',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          items: AppConstants.formCategories
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: _isSubmitting ? null : (v) => setState(() => _selectedCategory = v!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Condition',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCondition,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          items: AppConstants.formConditions
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: _isSubmitting ? null : (v) => setState(() => _selectedCondition = v!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Description & Notes',
                      hint: 'Describe the item condition and important details',
                      maxLines: 4,
                      validator: (val) {
                        if (val == null || val.trim().length < 5) return 'Description must be at least 5 characters';
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppTheme.buttonGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppTheme.glowButtonShadow,
                ),
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitListing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 18, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Publish Listing to Campus',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSectionCard({
    required String stepNumber,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppTheme.royalBlue,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    stepNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}