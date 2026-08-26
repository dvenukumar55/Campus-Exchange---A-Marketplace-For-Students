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
  const CreateListingScreen({Key? key}) : super(key: key);

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
      _titleController.text = 'Java Programming Book';
      _priceController.text = '500';
      _selectedCategory = 'Academic / Books';
      _selectedCondition = 'Good';
      _descriptionController.text = 'Java programming book in good condition. Covers core concepts, OOP, and data structures for 2nd/3rd year CSE.';
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
          content: Text('${listing.title} was published successfully!', style: const TextStyle(fontWeight: FontWeight.bold)),
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
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Sell an Item', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _loadJavaBookPreset,
            child: const Text('Preset', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Photos'),
              const SizedBox(height: 12),
              Container(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._selectedImages.asMap().entries.map((entry) {
                      final index = entry.key;
                      final image = entry.value;
                      return Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: FileImage(image),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 16, color: Colors.white),
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
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 2),
                          ),
                          child: const Center(
                            child: Icon(Icons.add_a_photo_rounded, color: AppTheme.primaryColor, size: 32),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Details'),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _titleController,
                label: 'Item Title',
                hint: 'e.g. Java Programming Book',
                validator: (val) {
                  if (val == null || val.trim().length < 3) return 'Title must be at least 3 characters';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _priceController,
                label: 'Selling Price (₹)',
                hint: 'e.g. 500',
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Price is required';
                  final price = double.tryParse(val.trim());
                  if (price == null || price < 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                items: AppConstants.formCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: _isSubmitting ? null : (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedCondition,
                decoration: InputDecoration(
                  labelText: 'Condition',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                items: AppConstants.formConditions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: _isSubmitting ? null : (v) => setState(() => _selectedCondition = v!),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Describe condition, etc.',
                maxLines: 4,
                validator: (val) {
                  if (val == null || val.trim().length < 5) return 'Description must be at least 5 characters';
                  return null;
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitListing,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('Post Listing'),
              ),
              const SizedBox(height: 20),
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